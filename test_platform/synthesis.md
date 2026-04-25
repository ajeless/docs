# Test Platform — Synthesis

```
────────────────────────────────────────────────────────────────────────
  PROJECT     test-platform
  FILE        synthesis.md
  ROLE        platform working doc
  STATUS      active · authoritative
  UPDATED     2026-04-25
────────────────────────────────────────────────────────────────────────
```

*Companion to `curation.md` (the curation project) and `eval_case_schema.md` (the case schema reference). Where this document and `curation.md` overlap, `curation.md` is authoritative on curation matters and this document is authoritative on test platform matters. The original ideation that preceded this document is preserved in `archive/`; the consolidated merge of those ideation conversations is at `archive/consolidated.md`.*

*This document is the working position for the test platform project. When this document and the archived ideation disagree, this document wins.*

---

## §1 — What this project actually is

The product is an **autonomous testing control plane**, not a team of agents.

That framing matters. "Team of agents" pushes toward internal cleverness — how many agents, what they argue about, how they coordinate. "Control plane" pushes toward product behavior — what does it discover, what evidence does it produce, what decisions can users trust it to make, how deterministic is it, how does it recover when it's wrong.

Agents are likely part of the implementation. They should not be the identity of the product. The user-facing thing is a testing system with stable, inspectable stages that happen to use agentic reasoning inside them.

Working definition:

> An autonomous testing control plane that discovers test surfaces, models system behavior, synthesizes risk-driven test strategy, executes specialized testing engines, and judges readiness with evidence — and that is honest about what it can and cannot determine.

The defensible core is the strategist and the judge. Execution can be borrowed from specialized tools (Playwright, pytest, k6, Semgrep, ZAP, and the long list in `archive/consolidated.md` §4). Discovery can partly be borrowed from crawling and static analysis. What's hardest to replicate — and therefore most valuable — is the system that decides what matters, chooses what to run, learns from evidence, and outputs a trustworthy confidence assessment.

The platform is honest about which classes of bugs it can address and which it cannot. Some classes of failure (configuration-dependent, load-dependent, specification-contested) are outside what any reasonable system can determine from a repository alone. The platform names these limits rather than producing false confidence about them.

---

## §2 — The pipeline

Five stages, each producing an inspectable artifact:

**Discover → Plan → Generate → Execute → Judge**

**Discover** builds a structured model of the system under test: stack, routes, API surface, auth boundaries, data flows, dependencies, state. The best shorthand for this stage is *exploratory reconnaissance plus systematic adversarial test design*. It's not human-style exploratory testing (wandering around, following hunches); it's machine-style reconnaissance that produces a formal model with risk surfaces called out.

**Plan** takes the model and produces a test strategy: what test types apply, where the risks concentrate, what classes of failure are worth hunting for, how coverage should be distributed. This stage encodes testing theory — equivalence classes, boundary value analysis, state transitions, pairwise combinatorics, error guessing, contract expectations, risk-based prioritization. The agent applies these ideas to messy real targets; it does not replace them.

**Generate** turns the strategy into concrete executable artifacts: test files in the right framework, fixtures, data, configs for each engine. This stage leans heavily on existing tools (pytest, Playwright, k6, Schemathesis, Pact, etc.) — the agent generates the inputs these tools expect.

**Execute** runs tests in sandboxed containers and collects raw results, artifacts, and evidence (logs, traces, screenshots, coverage, timing).

**Judge** correlates evidence across engines and produces a confidence assessment — risks flagged, gaps identified, regressions called out, ship-or-hold recommendation with reasoning. This is the second-hardest part of the system and the most defensible one.

Each stage must produce an artifact a human (or a separate evaluation system) can read and critique. This is not optional — it's how we avoid the cascade problem below.

---

## §3 — The cascade problem

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

## §4 — Reasoning tiers

A scale that proved useful while curating evaluation cases. It captures the depth of analysis a system would need to anticipate a given bug.

**Tier 1 — local pattern.** Look at one function or block. Recognize a known antipattern. Code smell visible in the snippet itself.

**Tier 2 — multi-element correlation.** Look at two or three pieces of code together. Cross-reference field definitions with their usage. Match a model's properties to a viewset's exposed methods. The bug is visible only when you look at A and B side by side.

**Tier 3 — domain reasoning.** Apply knowledge of the framework's semantics. Know what `ModelViewSet` exposes by default. Know that PATCH passes partial attrs. Know that JSONField permits arbitrary structure. The bug requires understanding what the framework does behind the scenes.

**Tier 4 — system-level reasoning.** The bug only manifests across components or interaction patterns. A signal cascade where one handler clobbers another's work. A foreign-key authorization gap that's correct per-endpoint but lets data leak across them. The bug isn't in any one place — it's in how pieces interact.

**Tier 5 — emergent or environmental.** The code is correct in every reasonable model of the world but breaks under conditions the developer didn't model: a specific load profile, a specific deployment topology, a specific clock-skew window, a specific filesystem behavior, a specific upstream contract that changed. Often these only show up at scale or in production.

**Tier 6 — adversarial / specification-level.** The code does exactly what the spec says, and the spec is wrong. Or there is no spec, and "what it should do" is genuinely contested. These bugs are arguments about intent, not about code.

Costs scale roughly multiplicatively, not additively. Tier 1 is cheap and may even be tractable with non-LLM static analysis. Tier 3 requires real LLM reasoning over context. Tier 4 likely needs the system to actually run things or build a model of dynamic behavior. Tier 5 may require fault injection, load testing, or chaos engineering — possibly outside what any static or single-snapshot system can detect. Tier 6 may not be detectable by any automated system because the ground truth doesn't exist.

The platform is honest about which tiers it covers. A well-designed control plane covers Tiers 1–3 strongly, does useful but partial work on Tier 4, and explicitly acknowledges Tier 5 as "this requires running it in production-like conditions, here's what we'd suggest." Tier 6 is human-only.

---

## §5 — Orthogonal capabilities

Reasoning depth is one dimension. The platform also needs at least these distinct capabilities, which are orthogonal to each other and to reasoning tier:

**Testing theory.** Boundary value analysis, equivalence partitioning, state coverage, pairwise testing, mutation testing, risk-based prioritization. Generic across stacks. Tells you what kinds of inputs and conditions to consider once you know what you're testing.

**Domain knowledge.** Framework-specific antipatterns, language idioms, ecosystem conventions. DRF, Django ORM, FastAPI dependency injection, React lifecycle. Tells you where the bugs cluster in a given technology stack.

**Code reasoning.** Reading code accurately, tracing data flow, understanding control flow, recognizing patterns. What lets the system work from a Python file to "this endpoint accepts an optional field that's later accessed unguarded."

**System modeling.** Building an internal representation of how components fit together — routes, data flow, auth boundaries, async pipelines, external dependencies. Without this, Tier 4 is impossible.

**Risk calibration.** Knowing what to prioritize. A platform that flags 2,000 surfaces equally is as useless as one that flags none. Partly testing theory, partly heuristics about real-world bug distributions, partly user-context awareness.

**Self-knowledge.** Knowing what the system itself can and cannot determine, and saying so explicitly. "I noticed this endpoint takes user input but I couldn't trace where it goes. Worth a human look."

The reason this matters: investing more in deep reasoning capability doesn't help if the other capabilities are weak. A system with extreme domain knowledge but poor risk calibration produces noise. A system with strong code reasoning but no testing theory produces irrelevant findings. The capabilities have to develop together, or further investment in one yields diminishing returns.

The case schema records `capability_demand` per bug, which lets evaluation measure whether the platform's capabilities are at compatible levels. See `eval_case_schema.md` §4.2.

---

## §6 — How we evaluate the system itself

This is the hardest problem in the project, and the curation project (see `curation.md`) is built around solving it.

**The meta-problem.** We're building a system that makes quality judgments, so we need a way to judge the quality of those judgments. We can't rely on a handful of humans to eyeball the output — humans miss things, and humans don't scale.

**The insight.** Open-source projects with rich issue histories are a massive, pre-existing source of ground truth. For any well-maintained project with good issue labeling and linked bug-fix PRs, we can roll the codebase back to the commit before a known bug was reported, run Discover and Plan against that snapshot, and ask: would the system's output have directed testing toward the area where the bug actually lived?

That's a measurable correlation. Not perfect — it's still a proxy — but it's automated, repeatable, and grounded in reality rather than human intuition.

The curation project produces structured evaluation cases that support this measurement under disciplined conditions: explicit evidence boundaries (what the system is allowed to see), mode applicability (whether a case is fairly evaluable in repo-only mode), contamination tracking (which cases may be tainted by public-history exposure during model training), and pre-fix/post-fix differential evaluation (false-positive pressure). Details in `curation.md` §5.

**The headline metric.** Repo-only Discover/Plan performance on cases marked headline-eligible. This measures whether the platform delivers on its core promise — given a repository snapshot, can the system identify the risks that actually mattered?

Other modes (issue-assisted, diff-assisted, post-fix test assessment) measure secondary product capabilities and are scored separately.

---

## §7 — The first spike

Not a platform. Not a CLI. Not an orchestrator.

Build a **test strategy document generator**: a program that takes a repo URL, runs Discover and Plan, and outputs a structured analysis — here's what I found, here's what I'd test, here's where the risk is, here's what I can't determine without more context. No execution, no containers, no test generation.

Why this:

- It isolates the hardest parts of the system (understanding a codebase well enough to test it meaningfully) from the easier parts (spawning Docker containers, running pytest).
- It produces an artifact directly evaluable against the curated case files.
- It's cheap to build relative to the full platform — weeks, not months.
- If the output is weak, we've learned something critical before investing in infrastructure. If it's strong, we have a real foundation to build on.

The architecture flows from knowing what works, not from assuming what will.

This spike depends on the curation project producing enough cases to evaluate against. Until at least 30–60 cases exist in the calibration split, the spike's evaluation will be noisy.

---

## §8 — Execution substrate and harness

**Decision: Docker + Testcontainers + Claude Agent SDK, directly.**

Considered and rejected: OpenClaw and NanoClaw.

These are personal AI assistant frameworks — their identity is around always-on agents that live in messaging apps and perform personal tasks. Using one as a testing harness means carrying machinery we don't need (messaging gateways, persistent personal memory, cron schedulers, channel adapters) and shaping our architecture around a use case that isn't ours. OpenClaw additionally has a documented security track record (including a real-world breach and academic analysis showing low sandbox-escape defense rates) that disqualifies it as the execution substrate for a quality-focused platform. NanoClaw is substantially more defensible but still fit for a different problem.

The primitives we actually need — isolated execution environments, resource limits, network policy, filesystem scoping, clean teardown, parallel runs — are solved directly by Docker, Testcontainers, and (for orchestration at scale) Kubernetes. The Claude Agent SDK provides the agentic reasoning layer. A thin custom wrapper exposes scoped tools to the agent inside a well-configured sandbox.

This keeps the architecture simple, auditable, and shaped to testing.

---

## §9 — Human-in-the-loop model

The autonomy-versus-approval tension is real. The resolution: **checkpoints live at stage boundaries, not per-action.**

Inside each pipeline stage, the agent acts autonomously within its sandbox — it doesn't ask permission to read files, run tests, or emit artifacts inside the perimeter. The human reviews at stage boundaries:

- After Discover, before Plan: does the system model look right?
- After Plan, before Generate: is this the right strategy?
- After Judge, before results are published: does this assessment hold up?

This matches how experienced engineers actually want to engage with autonomous systems — approve the direction, let the execution run, review the output. It's also orthogonal to the execution substrate, so the model doesn't change if a heavier orchestration layer is introduced later.

The perimeter itself is enforced at the infrastructure layer: Docker network policies, read-only mounts where possible, non-root containers, scoped tool sets in the Claude Agent SDK, comprehensive logging for after-the-fact review.

---

## §10 — What's decided

- **Product identity:** autonomous testing control plane
- **Pipeline stages:** Discover → Plan → Generate → Execute → Judge
- **Architectural constraint:** each stage produces an inspectable artifact
- **Center of gravity:** Plan (the strategist) and Judge (the evidence layer)
- **Reasoning tier scale:** 1–6, with explicit acknowledgment of which tiers the platform covers
- **Capability framework:** six orthogonal capabilities (testing theory, domain knowledge, code reasoning, system modeling, risk calibration, self-knowledge)
- **First spike:** test strategy document generator (Discover + Plan only, no execution)
- **Headline metric:** repo-only Discover/Plan performance on headline-eligible cases
- **Evaluation approach:** historical backtesting against curated open-source projects, with disciplined evidence boundaries, contamination tracking, mode applicability, pre-fix/post-fix differential evaluation, and dataset splits — owned by the curation project
- **Execution substrate:** Docker + Testcontainers + Claude Agent SDK (not OpenClaw, not NanoClaw)
- **Human-in-the-loop pattern:** checkpoints at stage boundaries, not per-action

---

## §11 — What's still open

**Target stack for the first spike.** Historical backtesting requires picking projects in a specific stack. Python web backends (FastAPI / Django / Flask) are the working assumption; the curation project's Phase 1 work will produce concrete project selections.

**What the Discover artifact actually looks like.** A route graph? An endpoint list with schemas? A state machine? A risk map? Probably some combination, but the exact schema is the contract between Discover and Plan — it needs to be defined before either is built. Good first step: manually build this artifact for three or four real repos and see what representation actually supports good strategy generation.

**Coverage vocabulary.** Traditional line/branch coverage doesn't fit a multi-engine platform. Definitions are needed for "percentage of discovered routes exercised," "percentage of API endpoints fuzzed," "percentage of risk-ranked surfaces with at least one assertion." The Judge's output format depends on this.

**Bug type priorities.** "More thorough coverage and finding real bugs" is directionally right but too broad. Which bug classes should the first version be exceptionally good at: regressions, auth/session bugs, data validation failures, integration mismatches, performance cliffs, input-handling errors? Different answers lead to different Discover and Plan designs. The case corpus is starting to surface evidence here.

**Judge output format.** Score? Ranked risks? Ship/hold gate? Diff from last run? All of the above? This shape defines the product experience and needs explicit design work before the Judge stage is built.

**Failure mode transparency.** When Discover misidentifies a stack, when generated tests have hallucinated imports, when auth can't be handled — what does the system say? "I couldn't test these three surfaces, here's why" is far more trustworthy than silent skipping or generated noise. Design decision, not implementation afterthought.

**Learning loop.** Does the system incorporate feedback from previous runs? From humans marking findings as false positives? This is what separates a scanner from a platform that improves over time.

**Branding, licensing, monetization.** Carried forward from the original ideation. Not urgent at this stage.

---

## §12 — Reading order for new collaborators

For someone picking up this project family fresh:

1. `README.md` — project family overview, navigation
2. This document — current thinking on the test platform, decisions, open problems
3. `curation.md` — the curation project, methodology, benchmark integrity
4. `eval_case_schema.md` — the schema reference for evaluation cases
5. `curation/cases/paperless-ngx/*.yaml` — concrete examples of the methodology in practice
6. `archive/consolidated.md` — the merged ideation, only if specific provenance or context is needed
7. `archive/ideation/*.md` — the raw ideation documents, only if direct provenance is needed for a particular idea

When this document and `curation.md` overlap, this document is authoritative on test platform matters and `curation.md` is authoritative on curation matters. When this document and the archived ideation disagree, this document wins.

---

```
────────────────────────────────────────────────────────────────────────
  END · synthesis.md
  platform working doc
────────────────────────────────────────────────────────────────────────
```
