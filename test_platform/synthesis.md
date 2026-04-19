# Test Platform — Synthesis

*Companion to `consolidated.md`. The consolidated doc merges the raw ideation from seven separate conversations. This doc captures where the thinking has moved since that ideation — the working hypotheses, the architectural decisions, and the open problems that now define the next phase of work. When the two documents disagree, this one takes precedence.*

---

## 1. What this project actually is

The product is an **autonomous testing control plane**, not a team of agents.

That framing matters. "Team of agents" pushes toward internal cleverness — how many agents, what they argue about, how they coordinate. "Control plane" pushes toward product behavior — what does it discover, what evidence does it produce, what decisions can users trust it to make, how deterministic is it, how does it recover when it's wrong.

Agents are likely part of the implementation. They should not be the identity of the product. The user-facing thing is a testing system with stable, inspectable stages that happen to use agentic reasoning inside them.

Working definition:

> An autonomous testing control plane that discovers test surfaces, models system behavior, synthesizes risk-driven test strategy, executes specialized testing engines, and judges readiness with evidence.

The defensible core is the strategist and the judge. Execution can be borrowed from specialized tools (Playwright, pytest, k6, Semgrep, ZAP, and the long list in `consolidated.md` §4). Discovery can partly be borrowed from crawling and static analysis. What's hardest to replicate — and therefore most valuable — is the system that decides what matters, chooses what to run, learns from evidence, and outputs a trustworthy confidence assessment.

---

## 2. The pipeline

Five stages, each producing an inspectable artifact:

**Discover → Plan → Generate → Execute → Judge**

**Discover** builds a structured model of the system under test: stack, routes, API surface, auth boundaries, data flows, dependencies, state. The best shorthand for this stage is *exploratory reconnaissance plus systematic adversarial test design*. It's not human-style exploratory testing (wandering around, following hunches); it's machine-style reconnaissance that produces a formal model with risk surfaces called out.

**Plan** takes the model and produces a test strategy: what test types apply, where the risks concentrate, what classes of failure are worth hunting for, how coverage should be distributed. This stage encodes testing theory — equivalence classes, boundary value analysis, state transitions, pairwise combinatorics, error guessing, contract expectations, risk-based prioritization. The agent is there to apply these ideas to messy real targets, not to replace them.

**Generate** turns the strategy into concrete executable artifacts: test files in the right framework, fixtures, data, configs for each engine. This stage leans heavily on existing tools (pytest, Playwright, k6, Schemathesis, Pact, etc.) — the agent generates the inputs these tools expect.

**Execute** runs tests in sandboxed containers and collects raw results, artifacts, and evidence (logs, traces, screenshots, coverage, timing).

**Judge** correlates evidence across engines and produces a confidence assessment — risks flagged, gaps identified, regressions called out, ship-or-hold recommendation with reasoning. This is the second-hardest part of the system and the most defensible one.

Each stage must produce an artifact a human (or a separate evaluation system) can read and critique. This is not optional — it's how we avoid the cascade problem below.

---

## 3. The cascade problem

If Discover builds a bad model, Plan produces a strategy based on wrong assumptions. If Plan picks wrong priorities, Generate produces tests for the wrong surfaces. If Generate produces weak tests, Execute returns meaningless passes. If Judge trusts those passes, the whole system confidently ships broken software.

Errors compound. That's a first-class architectural constraint, not a footnote.

The architectural response is that every stage produces a **structured, inspectable artifact** that can be evaluated independently of every other stage:

- Discover: a structured system model (routes, APIs, auth, data flows, risk surfaces)
- Plan: a test strategy document (what to test, why, in what priority)
- Generate: actual test code, fixtures, configs
- Execute: raw results, logs, coverage, evidence files
- Judge: a confidence report with supporting evidence

This means questions like "was the discovery accurate?" or "given this model, was the strategy appropriate?" can be asked in isolation rather than debugged through an opaque pipeline.

---

## 4. How we evaluate the system itself

This is the hardest problem in the project, and it deserves to be solved before anything gets built.

**The meta-problem.** We're building a system that makes quality judgments, so we need a way to judge the quality of those judgments. We can't rely on a handful of humans to eyeball the output — humans miss things, and humans don't scale.

**The insight.** Open-source projects with rich issue histories are a massive, pre-existing source of ground truth. For any well-maintained project with good issue labeling and linked bug-fix PRs, we can roll the codebase back to the commit before a known bug was reported, run Discover and Plan against that snapshot, and ask: would the system's output have directed testing toward the area where the bug actually lived?

That's a measurable correlation. Not perfect — it's still a proxy — but it's automated, repeatable, and grounded in reality rather than human intuition.

**A concrete evaluation spike looks like this:**

1. Pick 3–5 open-source projects in the target stack with strong issue discipline (clear `bug` labels, linked fix commits, active maintenance).
2. Identify 10–20 well-documented bugs per project with linked fix commits.
3. For each bug, check out the codebase at the commit just before the fix.
4. Run Discover against that snapshot.
5. Score whether the Discover output identified the relevant module, endpoint, data flow, or risk surface as something worth testing.
6. Aggregate the hit rate.

Humans calibrate the rubric at the start — does this correlation metric actually measure something meaningful? Once calibrated, the historical data becomes the primary evaluator.

**Caution.** Avoid overfitting. Don't tune the system until Discover retroactively catches every known bug in project X; that way lies a detector that works on X and nothing else. Keep a holdout set of projects that the evaluation work hasn't seen.

---

## 5. The first spike

Not a platform. Not a CLI. Not an orchestrator.

Build a **test strategy document generator**: a program that takes a repo URL, runs Discover and Plan, and outputs a structured analysis — here's what I found, here's what I'd test, here's where the risk is, here's what I can't determine without more context. No execution, no containers, no test generation.

Why this?

- It isolates the hardest parts of the system (understanding a codebase well enough to test it meaningfully) from the easier parts (spawning Docker containers, running pytest).
- It produces an artifact that is directly evaluable against the historical bug data described above.
- It's cheap to build relative to the full platform — weeks, not months.
- If the output is weak, we've learned something critical before investing in infrastructure. If it's strong, we have a real foundation to build on.

The architecture flows from knowing what works, not from assuming what will.

---

## 6. Execution substrate and harness

**Decision: Docker + Testcontainers + Claude Agent SDK, directly.**

Considered and rejected: OpenClaw and NanoClaw.

These are personal AI assistant frameworks — their identity is around always-on agents that live in messaging apps (WhatsApp, Telegram, Slack) and perform personal tasks. Using one as a testing harness means carrying machinery we don't need (messaging gateways, persistent personal memory, cron schedulers, channel adapters) and shaping our architecture around a use case that isn't ours. OpenClaw additionally has a documented security track record (including a real-world breach and academic analysis showing sandbox-escape defense rates around 17%) that disqualifies it as the execution substrate for a quality-focused platform. NanoClaw is substantially more defensible but still fit for a different problem.

The primitives we actually need — isolated execution environments, resource limits, network policy, filesystem scoping, clean teardown, parallel runs — are solved directly by Docker, Testcontainers, and (for orchestration at scale) Kubernetes. The Claude Agent SDK provides the agentic reasoning layer. A thin custom wrapper exposes scoped tools to the agent inside a well-configured sandbox.

This keeps the architecture simple, auditable, and shaped to testing.

---

## 7. Human-in-the-loop model

The autonomy-versus-approval tension is real. The resolution: **checkpoints live at stage boundaries, not per-action.**

Inside each pipeline stage, the agent acts autonomously within its sandbox — it doesn't ask permission to read files, run tests, or emit artifacts inside the perimeter. The human reviews at stage boundaries:

- After Discover, before Plan: does the system model look right?
- After Plan, before Generate: is this the right strategy?
- After Judge, before results are published: does this assessment hold up?

This matches how experienced engineers actually want to engage with autonomous systems — approve the direction, let the execution run, review the output. It's also orthogonal to the execution substrate, so the model doesn't change if a heavier orchestration layer is introduced later.

The perimeter itself is enforced at the infrastructure layer: Docker network policies, read-only mounts where possible, non-root containers, scoped tool sets in the Claude Agent SDK, comprehensive logging for after-the-fact review.

---

## 8. What's decided

- **Product identity:** autonomous testing control plane
- **Pipeline stages:** Discover → Plan → Generate → Execute → Judge
- **Architectural constraint:** each stage produces an inspectable artifact
- **Center of gravity:** Plan (the strategist) and Judge (the evidence layer)
- **First spike:** test strategy document generator (Discover + Plan only, no execution)
- **Evaluation approach:** historical backtesting against open-source projects with rich issue histories
- **Execution substrate:** Docker + Testcontainers + Claude Agent SDK (not OpenClaw, not NanoClaw)
- **Human-in-the-loop pattern:** checkpoints at stage boundaries, not per-action

---

## 9. What's still open

**Target stack for the first spike.** Historical backtesting requires picking projects in a specific stack. Python web apps (FastAPI / Django / Flask) are natural given the ideation docs' emphasis, but not yet chosen. This decision blocks starting the evaluation spike.

**What the Discover artifact actually looks like.** A route graph? An endpoint list with schemas? A state machine? A risk map? Probably some combination, but the exact schema is the contract between Discover and Plan — it needs to be defined before either is built. Good first step: manually build this artifact for three or four real repos and see what representation actually supports good strategy generation.

**Coverage vocabulary.** Traditional line/branch coverage doesn't fit a multi-engine platform. Definitions are needed for "percentage of discovered routes exercised," "percentage of API endpoints fuzzed," "percentage of risk-ranked surfaces with at least one assertion." The Judge's output format depends on this.

**Bug type priorities.** "More thorough coverage and finding real bugs" is directionally right but too broad. Which bug classes should the first version be exceptionally good at: regressions, auth/session bugs, data validation failures, integration mismatches, performance cliffs, input-handling errors? Different answers lead to different Discover and Plan designs.

**Judge output format.** Score? Ranked risks? Ship/hold gate? Diff from last run? All of the above? This shape defines the product experience and needs explicit design work before the Judge stage is built.

**Failure mode transparency.** When Discover misidentifies a stack, when generated tests have hallucinated imports, when auth can't be handled — what does the system say? "I couldn't test these three surfaces, here's why" is far more trustworthy than silent skipping or generated noise. Design decision, not implementation afterthought.

**Learning loop.** Does the system incorporate feedback from previous runs? From humans marking findings as false positives? This is what separates a scanner from a platform that improves over time.

**Branding, licensing, monetization.** Carried forward from `consolidated.md` §9. Not urgent at this stage.

---

## 10. Reading order for new collaborators

For someone picking this project up fresh:

1. This document — current thinking, decisions, open problems
2. `consolidated.md` — the raw ideation, tool landscape, architectural options considered
3. The seven `ideation*.md` files — only if specific provenance or context is needed for a particular idea

When this doc and the consolidated doc disagree, this doc wins. The consolidated doc is a catalog; this doc is a working position.