# Curation — Project Working Document

*Companion to `synthesis.md` and `eval_case_schema.md`. Where `synthesis.md` describes the eventual autonomous testing control plane, this document describes a separate project — the curation project — whose output feeds the test platform's evaluation but which has its own goals, methodology, and lifecycle. The schema reference for the curation outputs is `eval_case_schema.md`. This document is the working position for the curation project; when this document and `synthesis.md` overlap, this one is authoritative on curation matters.*

---

## 1. What curation is

Curation is the project of assembling and maintaining the body of evaluation cases against which the test platform's quality is measured. Its outputs are concrete: curated project lists with rationale, evaluation case files with structured ground truth, and a methodology that lets new cases be added without re-deriving the criteria each time.

Curation is not preparation for the test platform. It is one of several projects that together will make the test platform work. The others — the platform itself, the runtime infrastructure, possibly later a learning loop and a results UI — are downstream. Curation comes first because everything downstream depends on it, and because most of the difficulty in building the platform sits in evaluation, not implementation.

The framing matters: if we treat curation as a sidecar, we'll build it sloppily and reuse it sloppily. Treating it as a project means giving it its own goals, its own success criteria, its own decisions, and its own working documents.

## 2. Why this is the right first project

Three reasons.

First, it solves the cascade trust problem at the right level. The test platform makes quality judgments about software; we need a way to judge whether those judgments are good. That way is the eval set, and the eval set has to be trustworthy or the rest is theater. Building the eval set first, with care, means everything we build downstream has a fixed point to evaluate against.

Second, it's the work that produces the most learning per unit of effort. Every curated project teaches us something about what testing patterns matter, what bug classes recur, what the schema fails to capture, and what the platform will need to be able to reason about. None of those learnings are available from architecture diagrams or implementation work. They only come from looking at real code and real bugs.

Third, it plays to the strengths available right now. Identifying good projects, reading bug fixes, classifying them, building rubrics — these are tasks where careful manual work is cheap and produces durable artifacts. Building a control plane, by contrast, requires significant engineering effort whose value is uncertain until evaluation exists.

## 3. What curation produces

The deliverables of the curation project, in roughly the order they're produced:

- **A curated project list** with structured per-project entries. Each entry captures rationale for inclusion or rejection, signals that justified the decision, the project's tech stack and complexity, accessibility for local development, license, and observed bug-class distribution.

- **Evaluation case files** for each included project, conforming to `eval_case_schema.md`. One file per source PR, commit, or security advisory, each containing structured bug entries with location answer keys, reasoning tier, capability demand, mode applicability, contamination tracking, and expected findings.

- **A reasoning tier scale** with worked examples for each tier. The current scale runs 1–6: local pattern, multi-element correlation, domain reasoning, system interaction, environmental/emergent, and specification-level. The scale is provisional and refined as new cases require.

- **An orthogonal capabilities list** describing what skills the platform must hold to handle each case. Currently: testing theory, domain knowledge, code reasoning, system modeling, risk calibration, self-knowledge.

- **Rejection rationales** for projects considered and not included. These are themselves data — they document what fails the criteria, which sharpens the criteria.

- **A curation methodology** describing how new cases are added: how projects are screened, how bugs are selected from their issue trackers, how they're classified, and how the schema is updated when a case doesn't fit cleanly.

The curated project list and the evaluation case files are the visible outputs. The methodology, scale, capabilities list, and rejection rationales are the durable knowledge that lets the project survive new ecosystems and new contributors.

## 4. Phases

The curation project has phases because not all of its work can be done at once, and trying to do it all at once would freeze decisions before they're informed.

**Phase 1 — Python web backends and services.** Establish the methodology against an ecosystem we already understand. Target 15–20 projects examined deeply, 8–10 included in the active eval set. Produce 30–60 evaluation cases distributed across reasoning tiers. The goal of this phase is not corpus size — it's methodology stability.

**Phase 2 — Cross-ecosystem validation.** Deliberately stretch into one or two non-Python ecosystems to test whether the methodology, the reasoning tiers, and the capability list survive contact with different testing cultures. Likely candidates: a typed JavaScript/TypeScript backend ecosystem (Express/NestJS) and a more strongly-typed compiled language ecosystem (Go services, possibly Rust). If the schema needs to flex significantly here, that's a finding — better to discover it now than after deep investment in the platform.

**Phase 3 — Specialty surfaces.** Once we've established methodology in two or three general ecosystems, deliberately seek out classes of bugs that the eval set is currently weak in. Tier 5 (environmental / emergent) cases will likely require seeking out projects with concurrency, distributed-system, or scale-dependent behavior. Tier 6 (spec-level) cases may require projects with strong specification cultures (protocols, formal verification, contract-driven systems). This phase is where the curation project starts deliberately filling gaps rather than discovering them.

**Ongoing — maintenance.** Even after the initial corpus stabilizes, projects evolve, new bugs are reported, and the platform's capabilities expand. The curation project doesn't have an end state; it has a steady-state where new cases get added, old cases get retired or revised, and the methodology gets refined.

The phase boundaries are not sharp. Phase 1 produces evidence that informs Phase 2 scope; Phase 2 may surface gaps that motivate Phase 3 more than originally planned. The phases exist to keep us from over-committing to one ecosystem and to force the question "does this generalize?" before it's too expensive to answer.

## 5. Benchmark integrity

Curation produces ground truth. But ground truth is only useful if it can't be gamed. The remainder of this section establishes the disciplines that protect benchmark integrity.

### 5.1 Evidence boundaries

The Curator and the system under evaluation do not see the same evidence.

The Curator may use the full historical record to construct ground truth: issue text, PR descriptions, commit messages, fix diffs, post-fix code, maintainer comments, added regression tests, security advisories, release notes, and external commentary.

The system under evaluation must be evaluated under an explicit evidence mode. Without this boundary, the system may appear to discover risks when it is actually reading historical spoilers.

The four supported evidence modes, defined in `eval_case_schema.md` §5:

**Repo-only mode.** The system sees only the pre-fix repository snapshot. This mode evaluates the platform's core promise: "given a repo, find the risks."

**Issue-assisted mode.** Repo snapshot plus user-facing issue text. This mode evaluates triage and localization.

**Diff-assisted mode.** Repo snapshot plus a proposed fix diff. This mode evaluates PR review and test-adequacy assessment.

**Post-fix test-assessment mode.** Repo snapshot plus maintainer-added tests. This mode evaluates test-quality judgment.

These modes must not be mixed in scoring. A system that performs well in issue-assisted mode has not necessarily demonstrated repo-only discovery ability.

### 5.2 Canonical evaluation mode

Repo-only is the headline evaluation mode for the Discover and Plan stages.

The platform's primary promise is repo-first risk discovery: given a repository snapshot, can the system discover important risk surfaces and propose useful tests without being handed the historical bug report or fix? The other modes are valuable but evaluate secondary product capabilities.

The headline metric reports repo-only performance over cases that are *plausibly* discoverable in repo-only mode. Cases marked as `repo_only.expected_detectability: not_expected` (because they require external context the repository cannot provide) do not count against the headline metric. They may still be scored under assisted modes.

### 5.3 Evidence mode vs. execution mode

Evidence mode and execution mode are orthogonal axes.

`repo_only` means the system sees no historical spoilers. It does not mean the system is restricted to static analysis. A repo-only evaluation may run with `execution_mode: static_only`, `sandbox_dynamic` (running existing tests, starting services, observing runtime behavior), or `sandbox_dynamic_with_generated_tests` (additionally creating and running new tests).

These execution modes should be tracked separately because dynamic execution may improve detection, but at higher cost. The same case can be evaluated under different execution modes to measure that tradeoff.

A case file does not specify execution mode; the evaluator does. The case file must, however, declare evidence-mode applicability.

### 5.4 Public-history contamination

Because curated cases come from public repositories, some models may have encountered the issue, PR, advisory, or fix during training. This is a different problem from evidence boundaries: even if the evaluator hides the issue text at evaluation time, the model may already know it.

Each case records contamination characteristics: estimated risk (`low | medium | high`) and contamination types (`public_issue`, `public_pr`, `public_advisory`, `widely_discussed`, `widely_indexed`, `likely_training_data`, `unknown`). See `eval_case_schema.md` §4.2.

Mitigations include:

- Maintaining a private holdout split that's never used during platform development
- Prioritizing recent bugs where appropriate
- Tracking model knowledge cutoff dates
- Comparing repo-only results against issue-assisted results (a system reading from memory may show suspiciously similar performance across modes)
- Differential evaluation against post-fix snapshots
- Supplementing historical cases with seeded or synthetic controls

Contamination cannot be eliminated for historical public-bug cases. It can only be measured and partially defended against.

### 5.5 Contamination-resistant controls

Historical open-source bugs are valuable because they are real. They reflect actual project behavior, actual maintainer fixes, and actual regression tests. But they all carry contamination risk, and a benchmark composed entirely of contamination-prone cases may overstate platform capability.

The corpus should therefore include a small set of contamination-resistant controls, introduced as early as practical:

**Private seeded bugs.** A curator intentionally inserts a realistic bug into a private branch of a real project snapshot. The bug is designed to resemble realistic project failures but has not appeared in public history.

**Synthetic mini-projects.** Small purpose-built applications contain known defects across specific reasoning tiers and capability demands. Useful for controlled testing but less representative than real projects.

**Mutated historical bugs.** A real historical bug pattern is adapted into a different project, route, model, or framework so the system cannot rely on memorized public details. Catches whether the system has learned the pattern or merely the instance.

**Canary cases.** Private cases designed specifically to detect whether a system is relying on leaked issue/PR/fix information rather than repository reasoning.

Synthetic and seeded cases do not replace historical cases. They serve a different role. Historical cases test realism; synthetic and seeded cases test contamination resistance, controlled coverage, and sensitivity to specific reasoning patterns. A mature evaluation suite contains both.

### 5.6 Mode applicability

Not every historical bug is fairly discoverable in every evidence mode. Some bugs are visible from code structure, framework semantics, or local invariants. Others require user intent, production conditions, deployment topology, changed upstream behavior, or information that simply isn't in the repository.

Each bug episode declares its applicability per mode (see `eval_case_schema.md` §4.2). A case marked `repo_only.expected_detectability: not_expected` is unfair to score against repo-only performance. The same case may be perfectly fair in `issue_assisted` mode.

This prevents the headline metric from becoming either too harsh (penalizing the platform for cases it never had a fair shot at) or too vague (averaging over cases of wildly different difficulty).

### 5.7 Pre-fix / post-fix differential evaluation

Each case preserves both pre-fix and post-fix commits. Evaluation can therefore measure differential behavior:

- Does the system identify the risk on the pre-fix snapshot?
- Does the system stop identifying, or appropriately downgrade, the risk on the post-fix snapshot?
- If the system still flags the post-fix code, is it identifying a real residual risk or pattern-matching too broadly?

This creates false-positive pressure for free, using ground truth we already have. A case file declares its expected post-fix behavior in `post_fix_expected_behavior` (see `eval_case_schema.md` §4.2). For most cases, `should_still_flag: false` is correct; for some, the fix is partial and continued flagging is appropriate.

When the system runs against the pre-fix snapshot, it sees the tests that exist at that snapshot — including any tests that already existed before the fix added more. It does NOT see the tests added in the fix. This is the natural definition of "the snapshot," but it deserves stating because it has occasionally tripped people up.

### 5.8 Negative controls and false-positive pressure

A benchmark made entirely of known bugs encourages systems to flag everything. Beyond post-fix snapshots, false-positive pressure can come from:

- Nearby code that resembles the bug pattern but is safe
- Unrelated modules from the same project
- Accepted cases where the correct answer is "insufficient evidence"
- Stable releases with no known relevant bug in the target surface

Negative controls are harder to curate than positive bug cases, so they may be introduced gradually. But the benchmark must be designed with them in mind from the start — a system that flags every surface as risky should not score artificially well.

### 5.9 Dataset splits

Curated cases are not all used the same way. Splits prevent the system from being tuned against the same cases used to evaluate it.

**Exploration cases** are used while developing the schema and methodology. May be inspected freely and discussed in detail.

**Calibration cases** are used to tune scoring rubrics and compare early system behavior. Ground truth is known to the team.

**Validation cases** evaluate whether improvements generalize beyond calibration.

**Holdout cases** are reserved for later evaluation and must not be used while developing prompts, heuristics, or platform behavior.

Splits happen primarily at the project level, not the case level. If cases from the same project appear in both calibration and validation, the system may learn project-specific patterns rather than general testing reasoning. Project-level splits force the system to demonstrate generalization.

A small fraction of within-project case-level splits may be useful for diagnosing within-project consistency, but should never be the only split discipline.

### 5.10 Metric hierarchy

The evaluation suite reports multiple metrics, but they don't all carry the same product meaning.

**Primary metric.** Repo-only Discover/Plan performance on cases marked headline-eligible. This is the headline measure of whether the platform can inspect a repository and identify important testing risks.

**Secondary metrics.** Issue-assisted localization, diff-assisted review, post-fix test assessment. Valuable product capabilities but not substitutes for repo-only discovery.

**Diagnostic metrics.** Performance by reasoning tier, capability demand, project type, ecosystem, bug category, evidence mode, contamination risk. These explain where the platform is strong or weak.

**Integrity metrics.** False-positive burden, post-fix downgrade behavior, negative-control performance, reproducibility, cost. These protect against systems that look effective only because they flag too much, memorize public bugs, or spend unreasonable resources.

Reports that conflate these tiers are reports that hide the truth. The most important metric is the primary; integrity metrics are the floor below which other metrics become meaningless.

### 5.11 Scoring dimensions cases must support

The Curator does not run evaluations, but case files must preserve enough information to support meaningful scoring later. Each case should make it possible to score along these dimensions:

- **Surface recall** at multiple levels (project area, module, file, symbol, endpoint, data model, workflow)
- **Root-cause proximity** — pointing at a nearby file vs. identifying the mechanism
- **Risk-category match** — identifying the right class of risk (validation, authorization, idempotency, state coordination, etc.)
- **Test-intent match** — proposing a test whose intent would plausibly catch the historical bug
- **Specificity** — actionable detail vs. broad area-level findings
- **Priority** — ranking high enough that a planner would actually act
- **Noise / false-positive burden** — how many unrelated surfaces were flagged
- **Confidence calibration** — appropriate uncertainty
- **Cost** — token budget, wall-clock time, tool use, runtime execution
- **Reproducibility** — similar findings across repeated runs
- **Pre-fix/post-fix differential behavior** — flag-then-clear behavior

Each case's `location_answer_key` block (see `eval_case_schema.md` §4.2) is structured to support multi-level surface recall scoring. The other dimensions are supported via the various notes fields.

### 5.12 Ground truth is evidence, not omniscience

Historical fixes are the best available ground truth, but they are not perfect.

A fix diff may touch files that are not part of the root cause. It may omit files that contributed to the risk. Maintainer-added tests reflect what maintainers chose to test, not necessarily a complete test strategy. Issue text may describe symptoms rather than causes.

For this reason, each case distinguishes:

- The user-visible failure
- The affected public surface
- Suspected root cause
- Changed files
- Changed symbols
- Added tests
- Curator interpretation

Changed files are an answer-key input, not the whole answer key. The schema's location_answer_key block makes these layers explicit and scorable separately.

## 6. Inclusion criteria

A project is a candidate for inclusion when it satisfies the following:

**Active maintenance.** Commits within the last six months, ideally the last month. The project must be alive enough that its issue tracker reflects current reality.

**Disciplined issue and PR culture.** Bug labels applied consistently. Linked PRs that close issues with explicit references. Fix commits whose diffs make the bug locatable. This is the single most important criterion: if we can't tell from the git history what was wrong and where, the project is unusable as ground truth no matter how good the code is.

**Resolved bugs of varied class.** Not just one type of bug repeating endlessly. We want exposure to different reasoning tiers and different capability demands, and a project that only ever fixes UI styling issues won't give us that.

**Tractable complexity.** Substantial enough that testing it is non-trivial; not so sprawling that finding the relevant code for each bug becomes a research project of its own. A reasonable rule of thumb: a competent developer should be able to orient in the codebase within a day.

**Locally runnable.** Can be cloned, built, and run without exotic infrastructure or paid services. We need to be able to check out pre-fix snapshots and reason about them.

**License compatibility.** The project's source must be publicly inspectable and usable for analysis under terms compatible with the curation project's intended storage, redistribution, and tooling. Permissive licenses are easiest. Copyleft licenses are not automatically excluded, but they require care if code snapshots, diffs, or derived artifacts are redistributed.

**Sufficient history.** At least a few years of issues so we have a meaningful reservoir of resolved bugs to sample from.

These criteria are written in language-neutral terms where possible. Where they're Python-specific (none of them are, intentionally), they should be flagged.

## 7. Exclusion criteria

A project is rejected when:

The issue tracker is dominated by feature requests, support questions, or "doesn't work" reports without sufficient detail. These projects might be valuable to their users but they don't give us evaluable ground truth.

Bug fixes routinely span dozens of files or rewrite whole modules. We need bugs whose locations are bounded enough that "did Discover point at this surface?" is a meaningful question.

The project's testing culture is so weak that fix commits don't include tests, or tests are written in a non-standard way that resists pattern-matching. We rely on test additions as part of the answer key.

The project requires authentication, paid services, or cloud infrastructure to run meaningfully — anything that introduces a dependency we can't reproduce in a sandbox.

Security findings have insufficient public detail to reconstruct.

Frameworks and libraries are not categorically excluded but they are not part of the main *application* corpus. They form parallel corpora that test different platform capabilities (framework-aware reasoning, library-API reasoning) and should be tracked separately via `project_type` (see `eval_case_schema.md` §4.1).

Rejection is itself data. Rejected projects are documented with rationale, which sharpens the criteria.

## 8. Per-project methodology

For each candidate project, the curation work consists of:

**Initial screening.** Verify the project meets inclusion criteria. If it fails any, document the rejection and stop.

**Sample bug surveying.** Find 10–20 closed bug-fix PRs spanning the project's recent history (typically 6–18 months). For each, confirm that the fix commit is locatable, the changed files are bounded, and the bug class is tractable.

**Bug classification.** For each candidate bug, determine its bug class, reasoning tier, capability demand, mode applicability, and code locations. This is the core analytic work. Bugs that resist classification are flagged for either schema revision or exclusion.

**Schema feedback.** Note any case where the existing schema fails to capture something important. Don't silently work around schema limits — surface them so the schema can evolve. The schema serving the cases is more important than the cases serving the schema.

**Case file production.** Produce one structured YAML case file per source PR or advisory, conforming to `eval_case_schema.md`.

**Project-entry production.** Produce a structured per-project entry in the curated project list, including rationale, signals, bug-class distribution observed, and notes on anything unusual the project surfaced.

The work is mostly manual in this phase. Lightweight tooling — scripts to fetch PR metadata from forge APIs, extract diffs against parent commits, identify candidate bug-fix PRs by commit-message convention — speeds the work without making decisions for it.

## 9. Source-forge neutrality

Phase 1 may primarily use GitHub because its issue and PR metadata are easy to access, but the curation methodology is not GitHub-specific.

Neutral concepts are used where possible: repository, source forge, issue or defect report, change request, merge request / pull request, fix commit, advisory, release note. Case schemas may include forge-specific fields, but their core meaning remains portable across GitHub, GitLab, Codeberg, SourceHut, self-hosted Git, and other systems.

This matters because candidate projects may live on multiple forges, and the curation project commits to evaluating projects on their merits rather than on where they happen to be hosted.

## 10. Security case handling

Security bugs are high-value evaluation cases — they are often Tier 3 or 4, they represent the kind of finding the platform should excel at, and they tend to come with rigorous public documentation. But they require care.

Only publicly disclosed vulnerabilities are curated. The curation project does not investigate, exploit, or validate vulnerabilities against live systems. Reproduction, if performed, happens only against local sandboxed snapshots.

Security case files distinguish between:

- Public advisory information (allowed in curator notes)
- Curator interpretation (clearly marked as such)
- Exploit mechanics (summarized, not expanded; only as much as needed to evaluate platform discovery)
- Expected test intent

If exploit details are unnecessary for evaluating Discovery or Plan, they're summarized rather than reproduced. The goal is to evaluate risk discovery and test strategy, not to produce exploit documentation.

## 11. Curation tooling roadmap

Automation is deferred, not rejected. The curation project evolves through stages:

**Stage 0 — Manual curation.** Humans inspect projects, PRs, diffs, tests, and issues by hand. Establishes the methodology. (Phase 1.)

**Stage 1 — Metadata helpers.** Scripts fetch repository metadata, labels, issues, PRs/MRs, commits, changed files, and linked tests.

**Stage 2 — Candidate ranking.** Tools rank possible bug-fix changes by likely usefulness: bounded diff, bug label, linked issue, added regression tests, clear affected surface.

**Stage 3 — Draft case generation.** An agent drafts case files from source evidence; humans review and approve.

**Stage 4 — Assisted judgment.** The Curator begins suggesting reasoning tiers, capability demands, and expected test intent, with reviewer correction.

**Stage 5 — Evaluated automated curation.** Only after the methodology is stable should automated curation decisions be trusted. The Curator itself must be evaluated against human-reviewed curation decisions before its output is accepted without review.

The progression is intentionally cautious. Premature automation freezes weak criteria; the criteria need to mature against real cases first. By Stage 5, the Curator becomes a system in its own right — itself subject to evaluation against the same standards we apply to the test platform.

## 12. What is explicitly out of scope

Scope creep is the most likely failure mode for a project like this. Each item below has been considered and deferred deliberately.

**Fully automated curation.** We are not yet building an autonomous Curator that accepts or rejects projects and cases without human review. That level of automation would freeze criteria before they are mature. A robust Curator is an eventual goal (see §11), but not now.

**Building the test platform itself.** This is the project that comes after curation. We are deliberately not writing Discover, Plan, Generate, Execute, or Judge code as part of this work.

**Running evaluations against the test platform.** Until the test platform exists in some form, there's nothing to evaluate. We are building the rubric and the cases, not running the test.

**Optimization of curation throughput.** Quality and methodology stability matter more than volume. Throughput becomes a meaningful target once the methodology is fixed.

**Cross-ecosystem work in Phase 1.** Even if a TypeScript or Go project would be tempting to include, we explicitly defer until Phase 2.

**Visualization, dashboards, or reporting tooling for the eval set.** YAML files in a directory, with a README, are sufficient at this stage.

**Automated bug-class taxonomies.** Bug classes are named ad-hoc as cases require them. A systematic taxonomy will emerge naturally; designing one up front would freeze categories before they've been earned.

**Project scorecards with mechanical scoring.** Structured prose rationales are better at this stage. Scorecard discipline becomes valuable once we've curated enough projects manually to know what dimensions actually predict project quality. Phase 2 deliverable, not Phase 1.

**Formal inter-rater calibration protocols.** The principle that disagreements are signal, not noise, is durable. The procedural overhead of formal inter-rater agreement is premature for the current scale of the project.

## 13. Relationship to the test platform

Curation produces the data against which the test platform is evaluated. It does not specify the test platform's architecture, capabilities, or behavior. The platform's design is downstream.

That said, curation surfaces requirements implicitly. When a case requires `system_modeling` to catch, that's evidence the platform must invest in system modeling. When a case demands cross-resource authorization reasoning, that's evidence the platform must encode authorization patterns. The curation project doesn't dictate the platform's design, but it strongly informs it by establishing what classes of reasoning the platform must handle to be considered successful.

This is a healthy pattern: evaluation drives design, rather than design driving evaluation. It's the inverse of what happens when a team builds a system first and then asks "how do we know it works?" That inversion is the whole reason curation comes first.

## 14. Open questions for this project

**Where does the curated project list live?** A single `projects.md` file alongside the eval case YAML files? A directory of per-project markdown? Some structured registry format? For Phase 1, single markdown is probably sufficient. Worth revisiting at Phase 2 boundary.

**How are case files versioned?** When a project releases a new version that changes how a previously-curated bug would be analyzed, do we update the case file or freeze it? Probably freeze, with a "superseded by" pointer if a new version of the same bug class emerges.

**How much of the lightweight tooling is shared with the eventual test platform?** A script that fetches PR metadata from GitHub is useful here and probably useful there too. Lean toward curation-specific now; extract when the second consumer materializes.

**What's the cadence for revisiting Phase 1's outputs?** Once Phase 2 reveals limits in the schema, we'll likely need to revisit Phase 1 cases. Bulk revisit at the phase boundary, or rolling updates as findings emerge? Probably bulk at boundaries, to avoid case files churning constantly.

**How do we introduce contamination-resistant controls without disrupting Phase 1?** The friend's feedback argued for introducing a small number early rather than waiting for Phase 3. The first seeded or mutated-historical cases should appear during Phase 1, but how many and at what point in Phase 1 is open.

**Who reviews curation work?** For a solo or small-team effort, this may be self-review with notes for later. For larger-team effort, it's a real workflow question.

---

## 15. Reading order for new collaborators

For someone picking up the curation project specifically:

1. This document — what the curation project is and how it works
2. `eval_case_schema.md` — the schema reference for case files
3. `curation/cases/paperless-ngx/*.yaml` — the seed cases, demonstrating the methodology
4. `synthesis.md` — for context on how curation feeds the test platform
5. `archive/consolidated.md` — only for historical context on the original ideation

When this document and `synthesis.md` overlap, this document is authoritative on curation matters and the synthesis is authoritative on test platform matters. Where they conflict structurally, flag for resolution rather than picking one.
