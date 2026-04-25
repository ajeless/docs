# Archive

This directory contains historical artifacts from the original ideation phase of the test platform project. **These documents are preserved for reference but are not authoritative on the project's current state.** When they disagree with the working documents in the parent directory (`synthesis.md`, `curation.md`, `eval_case_schema.md`), the working documents win.

## What's here

**`ideation/`** — Seven original conversations exploring what an autonomous testing platform might look like. Each is a separate brainstorming session with overlapping content. They cover product vision, tool landscape, architectural options, UX considerations, and operational workflows.

**`consolidated.md`** — A merged synthesis of the seven ideation documents, produced before the strategic refinements that gave rise to the current working documents. It catalogs ideas faithfully but does not capture the structural decisions made afterward (control-plane framing, pipeline stages, reasoning tier scale, capability framework, evaluation discipline).

## Why these are preserved

Three reasons:

1. **Provenance.** Some specific ideas in the working documents trace back to particular ideation sessions. When provenance matters, these are the source.

2. **Intellectual history.** The trajectory from "AI testing agent" to "autonomous testing control plane" was a real move with real reasoning behind it. Future collaborators may want to understand how the thinking evolved, especially if they're tempted to relitigate decisions that have already been made.

3. **Recoverability.** Ideas that were de-emphasized in the current working documents may become relevant again later (some of the test types and tools surveyed in the ideation are likely to come back when the platform's coverage expands). Throwing them away would lose data.

## Why these are not authoritative

The working documents in the parent directory represent the project's current position after substantial revision. The ideation documents predate:

- The framing of the platform as a control plane rather than an agent swarm
- The Discover/Plan/Generate/Execute/Judge pipeline structure
- The reasoning tier scale (1–6) and the orthogonal capabilities framework
- The decision to make curation a first-class project rather than preparation
- The benchmark integrity disciplines (evidence boundaries, mode applicability, contamination tracking, dataset splits, differential evaluation)
- The execution substrate decision (Docker + Testcontainers + Claude Agent SDK; not OpenClaw or NanoClaw)

Reading the archive without context risks anchoring on positions the project has since moved past.

## Reading guidance

If you're a new collaborator: don't start here. Start with the parent directory's `README.md` and read the working documents.

If you're tracing a specific idea's origin: search the archive after you've understood the current position, not before.

If you're considering reviving a deprecated approach: read the archive to find what the original argument was, then check the working documents for whether and why it was de-emphasized. The de-emphasis may have been deliberate; it may also have been incidental and worth revisiting. Both are possible.
