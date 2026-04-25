# Test Platform

```
────────────────────────────────────────────────────────────────────────
  PROJECT     test-platform
  FILE        README.md
  ROLE        navigation
  STATUS      active · phase 1
  UPDATED     2026-04-25
────────────────────────────────────────────────────────────────────────
```

A project family aimed at building an autonomous testing control plane — a system that, given a repository, can discover what should be tested, propose a test strategy, generate and run tests, and judge the result with evidence. The project is in its early planning and curation phase, not its implementation phase.

---

## §1 — Project family

This work has split into multiple related projects, each with its own working document. Treat the working documents as authoritative; treat everything else as supporting material.

**`synthesis.md`** — the test platform itself. The eventual control plane: pipeline (Discover → Plan → Generate → Execute → Judge), reasoning tiers, capability framework, execution substrate, and human-in-the-loop model. This is what we will eventually build.

**`curation.md`** — the curation project. Building the body of evaluation cases and methodology against which the test platform's quality is measured. This is what we are building first, because trust in the platform requires trust in the evaluation, and the evaluation has to exist before the platform can be measured against it.

**`eval_case_schema.md`** — the schema reference. The structured format that evaluation case files conform to, with field definitions, allowed values, required vs optional fields, and a minimal complete example. Both `curation.md` and any future evaluator code reference this document as the contract.

---

## §2 — Active outputs

**`curation/cases/`** — evaluation case files, organized by source project. Each YAML file describes one source artifact (PR, commit, security advisory) and zero or more bug episodes within it, with structured ground truth. The current files are the seed cases drawn from paperless-ngx; more will be added as Phase 1 curation work proceeds.

**`curation/projects.md`** *(forthcoming)* — the curated project list. Per-project entries with rationale, signals that justified inclusion, bug-class distribution, and notes on what each project surfaced about the methodology. Not yet populated.

---

## §3 — Archive

**`archive/`** — historical artifacts from the original ideation phase, preserved for reference but not authoritative. Contains the seven original ideation conversations and their merged synthesis (`consolidated.md`). See `archive/README.md` for orientation.

When the working documents and the archive disagree, the working documents win. The archive is reference material, not the project's current position.

---

## §4 — Where to start

If you're new to the project, read in this order:

1. This README, for navigation
2. `synthesis.md`, for what the test platform is
3. `curation.md`, for the project we're actively building first
4. `eval_case_schema.md`, for the structure of the work products
5. One or two of the case files in `curation/cases/`, for concrete examples

The archive is useful only if you need to trace where an idea originated, or to understand how the thinking evolved. It is not required reading for collaborators picking up the active work.

---

## §5 — Project status

Active. The curation project is in Phase 1. The test platform is not yet under construction; its design will be informed by what curation reveals. See each working document's "what's still open" section for the live questions.

---

```
────────────────────────────────────────────────────────────────────────
  END · README.md
  navigation
────────────────────────────────────────────────────────────────────────
```
