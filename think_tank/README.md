<div align="center">

<img src="assets/hero-blueprint.svg" alt="Think Tank — a local-first idea workspace" width="100%">

![Status](https://img.shields.io/badge/status-WIP-7fb3ff?style=flat-square&labelColor=0d1b2a)
![Stage](https://img.shields.io/badge/stage-preliminary-7fb3ff?style=flat-square&labelColor=0d1b2a)
![Local-First](https://img.shields.io/badge/local--first-yes-7fb3ff?style=flat-square&labelColor=0d1b2a)
![Multi-Agent](https://img.shields.io/badge/multi--agent-yes-7fb3ff?style=flat-square&labelColor=0d1b2a)
![License](https://img.shields.io/badge/license-TBD-7fb3ff?style=flat-square&labelColor=0d1b2a)

</div>

# Think Tank

> **Status:** Preliminary idea / WIP. Not under active development.
> This document captures the current thinking so it can be picked up later. Most of it is still up for revision.

A local-first idea workspace where a human and multiple AI agents develop ideas into durable, searchable, versioned artifacts. The core artifact is not the chat transcript — it's a structured, editable project state: claims, questions, evidence, disagreements, decisions, assumptions, artifacts, and changes over time.

<img src="assets/divider-blueprint.svg" alt="" width="100%">

## Contents

| § | Section |
|---|---|
| `01` | [Why this exists](#why-this-exists) |
| `02` | [Thesis](#thesis) |
| `03` | [What it is](#what-it-is) · [What it is NOT](#what-it-is-not) |
| `04` | [Core abstractions](#core-abstractions) |
| &nbsp;&nbsp;`04.1` | [Project state (`state.json`)](#project-state-statejson) |
| &nbsp;&nbsp;`04.2` | [Modes (not "exchange depth")](#modes-not-exchange-depth) |
| &nbsp;&nbsp;`04.3` | [Hierarchical summaries](#hierarchical-summaries-semantic-zoom-not-compression-ratio) |
| &nbsp;&nbsp;`04.4` | [Inline elaboration / glossary capture](#inline-elaboration--glossary-capture) |
| &nbsp;&nbsp;`04.5` | ["IDE for ideas" — what that actually means](#ide-for-ideas--what-that-actually-means) |
| `05` | [Project layout (provisional)](#project-layout-provisional) |
| `06` | [A day in the life](#a-day-in-the-life) |
| `07` | [Relationship to Deliberation Room](#relationship-to-deliberation-room) |
| `08` | [Validation plan](#validation-plan) |
| `09` | [Prior art surveyed](#prior-art-surveyed) |
| `10` | [Open questions](#open-questions) |
| `11` | [Risks](#risks) |
| `12` | [Status & next steps](#status--next-steps) |

<img src="assets/divider-blueprint.svg" alt="" width="100%">

## Why this exists

Working with AI assistants for ideation is genuinely useful, but the workflow has gaps:

- Each tool is its own silo. Conversations live inside one provider's UI.
- Insights vanish into chat history. Hard to find, harder to build on.
- Each new session starts from scratch — agents forget definitions, framings, and decisions already settled.
- "Multi-model" tools mostly do side-by-side comparison, not collaborative development of an idea.
- Browser searches and side conversations break flow when you want to define a term or chase an example.

The bet: the most valuable thing isn't a better chat UI. It's a **representation of an evolving idea that survives across sessions, agents, and providers**.

<img src="assets/divider-blueprint.svg" alt="" width="100%">

## Thesis

> [!IMPORTANT]
> Think Tank is a local-first idea workspace where a human and multiple AI agents develop ideas into durable, searchable, versioned artifacts. Its core artifact is not the chat transcript, but a structured, editable project state.

This is sharper than "multi-agent chat room for ideation," because the latter risks becoming "LibreChat plus some agent turns." The novel artifact is the **project structure itself** — a representation of an evolving idea that's good enough you'd open `state.json` directly the way you'd open a source file.

<img src="assets/divider-blueprint.svg" alt="" width="100%">

## What it is

A workspace where:

- **Multiple AI agents** can be called in parallel or in turn, from any combination of providers (Anthropic, OpenAI, Google, xAI, OpenRouter, local models via Ollama / LM Studio, etc.).
- The output of those calls feeds into a **structured project state** — not just a transcript.
- That state is **human-editable, versioned, and source-control-friendly**.
- Every agent (including new ones brought into a session later) automatically reads from the same shared project state, so context doesn't have to be re-explained.
- Agents can **read and write artifacts** in a per-project sandbox (notes, drafts, diagrams, data).
- Inline **right-click-elaborate** lets you capture definitions, examples, and clarifications into a project glossary without breaking the conversation.

## What it is NOT

- Not a real-time chat UI (LibreChat, Open WebUI, MultipleChat already exist).
- Not a model-comparison tool (TypingMind, ChatPlayground exist).
- Not an agent orchestration framework (LangGraph, CrewAI, OpenAI Agents SDK exist).
- Not an autonomous agent swarm — the human stays in the loop and in control.
- Not an extension of [Deliberation Room](#relationship-to-deliberation-room). Sibling, not child.

<img src="assets/divider-blueprint.svg" alt="" width="100%">

## Core abstractions

```mermaid
flowchart LR
    H([Human]):::human
    subgraph providers[Providers]
      A1[Anthropic]:::agent
      A2[OpenAI]:::agent
      A3[Google]:::agent
      A4[Local / Ollama]:::agent
    end
    H --> providers
    providers --> M{{modes:<br/>blind_parallel · critique<br/>red_team · synthesis}}:::mode
    M --> S[(state.json)]:::state
    S --> V[verdict · gist · brief · deep_dive]:::summary
    S --> H
    classDef human fill:#7fb3ff,stroke:#0d1b2a,color:#0d1b2a,font-weight:bold;
    classDef agent fill:#0d1b2a,stroke:#7fb3ff,color:#e8f1ff;
    classDef mode  fill:#1f3b66,stroke:#7fb3ff,color:#e8f1ff;
    classDef state fill:#7fb3ff,stroke:#0d1b2a,color:#0d1b2a,font-weight:bold;
    classDef summary fill:#0d1b2a,stroke:#7fb3ff,color:#e8f1ff;
```

### Project state (`state.json`)

The durable artifact. A structured representation of the evolving idea. Provisional sketch:

```json
{
  "project": {
    "name": "Think Tank",
    "one_sentence_description": "",
    "current_thesis": "",
    "status": "exploring"
  },
  "claims": [
    {
      "id": "claim_001",
      "text": "",
      "status": "active",
      "confidence": "medium",
      "supporting_evidence": [],
      "objections": [],
      "supersedes": [],
      "superseded_by": null,
      "created_at": "",
      "updated_at": ""
    }
  ],
  "questions": [],
  "assumptions": [],
  "decisions": [],
  "disagreements": [],
  "evidence": [],
  "glossary": [],
  "artifacts": [],
  "next_actions": [],
  "change_log": []
}
```

> [!WARNING]
> The schema is intentionally provisional. **Don't design it up front.** Let it emerge from real use — premature schemas collect empty fields you dutifully fill in instead of the fields you actually needed.

> [!NOTE]
> **Human-readability is a real concern.** If `state.json` becomes the canonical artifact too early, the project folder may feel alien — you'd be reading raw JSON to understand your own thinking. One option (deferred to Layer 3): treat `state.json` as canonical but always render a `state.md` alongside it as a read-only human view, regenerated on every change. Or skip canonical state entirely for the prototype and let it emerge from `notes/` and `transcripts/`. See [Open questions](#open-questions).

### Modes (not "exchange depth")

Instead of "have agents talk for N turns," interactions happen in named modes:

| Mode | Behavior |
|---|---|
| `blind_parallel` | same prompt to multiple agents, no cross-talk, synthesized after |
| `critique` | one agent's output reviewed by another |
| `red_team` | adversarial pass against a position |
| `research_review` | evidence-gathering pass |
| `synthesis` | collapse multi-agent output into one consolidated view |
| `debate_optional` | sequential cross-talk, used sparingly |

The default is **parallel-then-synthesize**. Sequential debate is a tool used deliberately, not a primary loop. Sequential model-to-model debate tends to converge, repeat, or hallucinate unless agents have meaningfully different roles, tools, or evidence.

### Hierarchical summaries (semantic zoom, not compression ratio)

| File | Purpose |
|---|---|
| `verdict.md` | one line |
| `gist.md` | short human overview |
| `brief.md` | structured summary with major reasoning |
| `deep_dive.md` | detailed synthesis |
| `transcript.jsonl` | complete raw exchange |
| `state.json` | canonical structured project state |

A reader picks a level based on the *kind* of overview they need, not how much patience they have.

### Inline elaboration / glossary capture

Select text in the conversation, pick a verb from a context menu, get an answer captured into the right slice of state.

| Verb | What it does | Lands in |
|---|---|---|
| `define` | "What does this mean?" | glossary |
| `concretize` | "Real-world examples?" | glossary / artifacts |
| `simplify` | "Plain-English version?" | glossary |
| `deepen` | "Go further on this." | notes |
| `compare-to` | "How does this differ from X?" | claims |
| `cite` / `source` | "Where does this come from?" | evidence |
| `steelman` | "Best version of this argument?" | claims-to-verify |
| `critique` | "Strongest objection?" | claims-to-verify |
| `branch` | "Related concepts worth exploring?" | open questions |

The verb determines both the prompt to the sub-agent and the destination in state. Same UI gesture, different bucket. Solves the "I keep stopping to ask what something means" problem and builds a personal knowledge graph as a side effect of normal use.

CLI fallback for prototyping (no UI required to validate the workflow):

```bash
tt elaborate "exchange depth" --as=define --context="<paste surrounding text>"
```

### "IDE for ideas" — what that actually means

Not "chat with projects." The metaphor only delivers if it implements the idea-equivalents of what makes IDEs useful:

| Code IDE feature | Think Tank equivalent |
|---|---|
| Jump to definition | Jump to original claim / source / decision |
| Find references | Where else did I discuss this? |
| Refactor | Rename/reframe a concept across the project |
| Type-checking | Check claim consistency |
| Linting | Detect stale, unsupported, vague, contradictory claims |
| Git diff | Show how my position changed over time |
| Dependency graph | Show claims, evidence, assumptions, objections |
| Tests | Validate claims against sources or examples |

These are graph operations, not chat features. The chat is one input surface; the graph is the product.

<img src="assets/divider-blueprint.svg" alt="" width="100%">

## Project layout (provisional)

```
~/thinktank/<project>/
  notes/         # markdown notes, human and agent
  transcripts/   # JSONL of every model call
  artifacts/     # diagrams, drafts, data, generated outputs
  state.json     # canonical structured project state
  verdict.md
  gist.md
  brief.md
  deep_dive.md
  .git/
```

Per-project sandbox: agents read/write freely **inside** the project folder, never outside.

<img src="assets/divider-blueprint.svg" alt="" width="100%">

## A day in the life

The clearest way to picture Think Tank is to walk through a session. The example below is fictional — it shows what *would* happen if the prototype existed today and you used it on this very project.

### Day 1 — first prompt

```bash
tt new think-tank --description "A local-first idea workspace where humans and agents develop ideas into versioned artifacts."
tt agent add skeptic --model claude-opus-4-7
tt agent add researcher --model gpt-5
tt agent add synthesizer --model gemini-3
tt ask "Is Think Tank worth building?"
```

After the command finishes, the project folder looks like:

```
~/thinktank/think-tank/
  state.json
  verdict.md           # "Possibly. Validate the workflow before the architecture."
  gist.md              # 2–3 paragraph human overview
  brief.md             # structured summary with disagreements surfaced
  deep_dive.md         # full synthesis of all three agents
  transcripts/
    2026-04-25T0930.jsonl    # raw responses from all three agents
  notes/
  artifacts/
  .git/                # initial commit
```

Open `verdict.md` and you see one line. Open `gist.md` and you see the human overview. Open `state.json` and you see the structured representation: candidate claims, open questions, where the agents disagreed, and which mode produced each piece.

### Day 3 — pushback on a claim

A couple of days later, you've spent some time using MultipleChat for real ideation. Side-by-side comparison turned out to be more useful than the original framing assumed. You run:

```bash
tt ask "Update: I tried MultipleChat for two days. Side-by-side comparison was actually useful — keeping multiple drafts visible helped me see disagreements I'd otherwise miss. Reconsider the 'not a model comparison tool' anti-goal."
```

The agents respond, the synthesizer revises state, and `git diff state.json` shows:

```diff
- {
-   "id": "claim_003",
-   "text": "Side-by-side model comparison is incidental, not the point.",
-   "status": "active",
-   "confidence": "high"
- }
+ {
+   "id": "claim_003",
+   "text": "Side-by-side model comparison is incidental, not the point.",
+   "status": "superseded",
+   "confidence": "high",
+   "superseded_by": "claim_007"
+ }
+ {
+   "id": "claim_007",
+   "text": "Visible parallel responses are useful when the user is comparing model framings, not just merging into a single answer.",
+   "status": "active",
+   "confidence": "medium",
+   "supersedes": ["claim_003"],
+   "supporting_evidence": ["notes/2026-04-27-multiplechat-trial.md"]
+ }
```

That's the durable record. Two weeks from now, you can answer "why did I change my mind on this?" by reading the supersession chain — not by scrolling through chats.

### Day 10 — inline elaboration captures a term

Mid-conversation, an agent uses the phrase "semantic zoom." You half-know what they mean. Instead of breaking flow to ask, you select the phrase and run:

```bash
tt elaborate "semantic zoom" --as=define
```

A glossary entry appears in `state.json` (and any rendered view alongside it):

```json
{
  "id": "term_014",
  "term": "semantic zoom",
  "definition": "A summarization model where each level captures a different kind of information (verdict, gist, reasoning, full detail) rather than a different compression ratio. Contrasts with percentage-based summaries.",
  "captured_from": "transcripts/2026-05-04T1402.jsonl#L23",
  "captured_at": "2026-05-04T14:09:00Z",
  "status": "captured"
}
```

You keep going. Later, `tt review` surfaces the term in a weekly digest so it doesn't sit unread in a graveyard.

### What you can answer two weeks later

| Question | How |
|---|---|
| "How has my view of X changed?" | `git log -p state.json` filtered by claim id |
| "Where did I first say Y?" | grep across `transcripts/` |
| "What did I decide about Z?" | `decisions[]` in `state.json` |
| "Which claims am I least confident in?" | query `state.json` by `confidence` |
| "What questions are still open?" | `questions[]` in `state.json` |
| "Which terms did I never come back to?" | `tt review --stale` |

The product is the answer to those questions, not the chat that produced them.

<img src="assets/divider-blueprint.svg" alt="" width="100%">

## Relationship to Deliberation Room

Think Tank and [Deliberation Room](https://github.com/ajeless/deliberation-room) are siblings, not parent and child. Different anti-goals, different cadence, different defaults.

**Deliberation Room** is *disciplined deliberation* — round-based, blind responses, structured to fight groupthink. Explicit anti-goals against real-time chat, model comparison, and autonomous swarms.

**Think Tank** is an *evolving idea workspace* — looser cadence, on-demand agent calls, multiple modes (some of which DR explicitly rules out).

What's worth cannibalizing from DR:

- Provider abstraction
- Three-layer memory model (transcript / working summary / structured state)
- JSONL persistence and append-only event log
- Human-override-tracking on structured state
- Checkpoint discipline (versioned state revisions, diff, rollback)

What's not portable:

- The human-seeded round protocol (too rigid for solo ideation)
- Blind-by-default within rounds (sometimes you want a critique pass)
- The room/participant cadence model

The repo is still useful. Fork the concepts, not the product.

<img src="assets/divider-blueprint.svg" alt="" width="100%">

## Validation plan

Three layers, in order. Don't skip ahead.

### Layer 1 — Test existing tools first

Before building, use what's already out there for real ideation tasks. The goal is to find specifically what each one fails to do.

- [Open WebUI](https://github.com/open-webui/open-webui) — open-source, multi-model, self-hostable, has experimental synthesis
- [LibreChat](https://github.com/danny-avila/LibreChat) — agents, files, code interpreter, MCP, memory
- [MultipleChat](https://multiplechat.com) — closest pitch to "agents working together"
- [TypingMind](https://typingmind.com) — multi-model parallel responses
- [AnythingLLM](https://anythingllm.com) — workspace-centric, RAG-heavy
- [Poe](https://poe.com) — multi-bot rooms with `@` mentions

Without doing this, the build is against a strawman of existing tools. "It's not local," "no versioning," or "agents don't share memory" — those answers shape Think Tank.

### Layer 2 — Weekend script

Smallest possible local prototype. No UI, no framework, no sandboxing, no provider manager. ~200 lines of Python.

```text
1. Read state.json + user prompt
2. Send in parallel to 2–3 model providers
3. Append responses to transcripts/
4. Ask one model to update state.json
5. Generate summary files
6. Git commit
```

Use it on three real ideation problems for two weeks. **The product test:** after two weeks, do I prefer opening this folder over scrolling through old chats?

### Layer 3 — Schema and interface

Only after Layer 2 has earned its keep:

- Refine `state.json` schema based on what actually emerged
- Build TUI or web UI
- Inline elaboration / glossary capture (right-click context menu)
- Search (ripgrep first, vector later)
- Visual graph view of claims and dependencies
- Sandboxed artifact creation
- Provider manager and key auto-discovery
- Sub-agent / sub-project support
- Visualizations (Mermaid, charts, mind-maps, flow-charts)

<img src="assets/divider-blueprint.svg" alt="" width="100%">

## Prior art surveyed

| Tool | Closest to | Gap |
|---|---|---|
| MultipleChat | Multi-model collaboration | No structured state, no local-first |
| Open WebUI | Multi-model + synthesis | No project state model |
| LibreChat | Agents + files + memory | Chat-centric, not idea-centric |
| AnythingLLM | Workspace + RAG | Not multi-agent deliberation |
| TypingMind | Multi-model parallel | No cross-agent collaboration |
| Poe | Multi-bot rooms | Cloud-only, no project artifacts |
| ChatPlayground | Many-model comparison | Comparison-focused, not deliberation |
| LangGraph / CrewAI / OpenAI Agents SDK | Agent orchestration | Frameworks, not end-user products |
| Microsoft Agent Framework / AutoGen | Group-chat patterns | Developer-facing, not idea-facing |
| Cursor / Claude Code | Sandboxed agent files | Code-centric |
| Cloudflare Project Think | Durable sub-agents + sandboxes | Infrastructure, not idea workspace |

> [!TIP]
> **White space:** a structured, editable, versionable representation of an evolving idea, with multiple agents reading/writing it and the human keeping editorial control.

<img src="assets/divider-blueprint.svg" alt="" width="100%">

## Open questions

To resolve through use, not up-front design:

- What's the right granularity for a "claim"? When does a long agent response become one claim vs. many?
- Do questions need hierarchy, or is a flat list sufficient?
- How does state degrade gracefully when an agent confidently writes nonsense into it?
- Is "decision" different from "conclusion"? From "current thesis"?
- Does the change log need to be human-readable, or is git diff enough?
- How does this scale across multiple related projects? Cross-project search? Shared glossary?
- Where does the workspace boundary actually fall? Per-idea, per-domain, per-month?
- What's the right capture cadence for the glossary so it doesn't become a graveyard?
- Where does the review surface live? Weekly digest? `tt review` command? Stale-claim linter?
- **Canonical state: JSON, Markdown, or both?** If `state.json` is canonical, the project folder may feel alien to a human reader. If `state.md` is canonical, structured queries get harder. A render-from-JSON `state.md` view avoids the dual-canonical sync problem but adds a build step. May be best to defer until the prototype reveals which feels worse in practice.

<img src="assets/divider-blueprint.svg" alt="" width="100%">

## Risks

> [!CAUTION]
> - **UX overload.** Multi-agent output is verbose. Hierarchical summaries are not optional.
> - **False consensus.** Same-family models converge. Need explicit roles, not just turns.
> - **Cost and latency.** Frontier-model debate isn't cheap. Design for restraint — parallel-then-synthesize over long debates, on-demand over scheduled.
> - **Sandbox safety.** Agents read/write inside the project folder, never outside.
> - **Schema rigidity.** A premature schema collects empty fields. Let it emerge.
> - **Capture-without-review.** Glossary and state files become graveyards if there's no review surface. Build the review path from day one, even if it's just a digest.
> - **Sunk-cost bias toward DR.** The Deliberation Room repo is mature, but its design philosophy doesn't fully fit. Resist the pull to port it wholesale.

<img src="assets/divider-blueprint.svg" alt="" width="100%">

## Status & next steps

- [x] Initial ideation captured (this doc)
- [ ] Hands-on evaluation: Open WebUI / LibreChat / MultipleChat
- [ ] Document specific gaps in those tools
- [ ] Weekend script prototype
- [ ] Two weeks of real-use evaluation
- [ ] Schema refinement based on observed needs
- [ ] Decision: build, compose from existing tools, or drop

<img src="assets/divider-blueprint.svg" alt="" width="100%">

<div align="center">

*This document synthesizes ideation across multiple AI-assisted conversations. It is preliminary and reflects current thinking, not commitments.*

</div>