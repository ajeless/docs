# Think Tank

A local-first engine for ideating with multiple LLMs. The user works through an idea with several models in parallel; the engine turns those interactions into durable, structured project state that accumulates across sessions. Transcripts. Claims. Questions. Evidence. Disagreements. Decisions. Eventually artifacts — diagrams, charts, mind maps that make ideas inspectable rather than just readable.

The engine is the product. A lean CLI is the first adapter that lets a human drive it from a terminal. Other adapters may follow. The whole thing runs on your machine, against your data, through a single OpenRouter API key.

> **Status:** Design notes for a forthcoming code repository at https://github.com/ajeless/think-tank.

---

## What makes Think Tank distinct

Most tools that talk to multiple LLMs treat the chat as the artifact. The user types a question, gets a response, scrolls through history later if they want to find something. The work disappears into chat logs.

Think Tank treats the **structured project state** as the artifact. The chat happens, but it's the substrate, not the product. As you ask questions, the engine maintains a representation of what's accumulated — what's been claimed, what's been questioned, what's still open, where the models agreed, where they disagreed. You can return to a workspace days or weeks later and see where you left off, what's been decided, what still needs work.

That structured state is what enables everything else: synthesis across multi-agent responses, glossary capture, search across transcripts, eventually rich artifacts that visualize how the ideas connect. The CLI is small on purpose — it's the input surface to a richer system, not the system itself.

---

## A walk through a project

The clearest way to understand Think Tank is to walk through a session. The example below is fictional — it shows what a workspace would look like after several sessions of real use.

### Day 1 — the workspace

You make a workspace for an idea you want to think through:

```bash
think new ./tenant-organizing-strategy
```

You ask a question, fanning out to multiple models in parallel:

```bash
think ask "Should we prioritize building-by-building outreach or a single citywide push?" \
  --project ./tenant-organizing-strategy \
  --profile frontier
```

Each model responds with its own framing. The synthesizer reads across them, surfaces consensus and disagreement, and proposes updates to `state.json`. The workspace now has three claims (one of them flagged as a disagreement between models), two open questions, and the start of a glossary entry for "social capital" because two models used the term and you weren't sure they meant the same thing.

You read `gist.md` in the workspace. Three paragraphs. Bottom line: the models lean toward building-by-building outreach but disagree on how to scale it. Open questions noted.

### Day 3 — pushback on a claim

Two days later, you've talked to a real organizer. They told you something that contradicts one of the claims the synthesizer captured. You run:

```bash
think ask "An organizer told me that building-by-building outreach plateaus at 15-20 buildings without a citywide identity to anchor it. This contradicts claim_002. Reconsider." \
  --project ./tenant-organizing-strategy
```

The synthesizer revises state. A `git diff state.json` shows:

```diff
- {
-   "id": "claim_002",
-   "text": "Building-by-building outreach scales linearly with effort.",
-   "status": "active",
-   "confidence": "medium"
- }
+ {
+   "id": "claim_002",
+   "text": "Building-by-building outreach scales linearly with effort.",
+   "status": "superseded",
+   "confidence": "medium",
+   "superseded_by": "claim_007"
+ }
+ {
+   "id": "claim_007",
+   "text": "Building-by-building outreach plateaus at 15-20 buildings without a citywide identity to anchor it.",
+   "status": "active",
+   "confidence": "high",
+   "supporting_evidence": ["organizer conversation, 2026-04-30"],
+   "supersedes": ["claim_002"]
+ }
```

That's the durable record. Two weeks from now, you can answer "why did I change my mind on this?" by reading the supersession chain — not by scrolling through chat logs.

### Day 5 — capturing a definition

Mid-session, an agent uses the phrase "deep canvassing" in a way that suggests it's a term of art. You half-know what it means but want to be sure. Without breaking flow:

```bash
think elaborate "deep canvassing" --as define --project ./tenant-organizing-strategy
```

A glossary entry gets added to `state.json`:

```json
{
  "id": "term_004",
  "term": "deep canvassing",
  "definition": "A canvassing technique that focuses on extended two-way conversations about lived experience, rather than persuasion through information. Distinct from traditional canvassing in its emphasis on listening and emotional connection.",
  "captured_from": "transcripts/2026-05-04T1402.jsonl",
  "captured_at": "2026-05-04T14:09:00Z"
}
```

You keep going. The next session, when you ask a question that touches on canvassing strategy, every agent has access to the captured definition as context. The conversation doesn't have to re-establish what you mean.

### Day 10 — visualizing accumulation

A week and a half in, the project has accumulated enough that you want to see how the strategy has taken shape. You ask for a visualization:

```bash
think visualize --of decisions --as timeline --project ./tenant-organizing-strategy
```

The artifact-generator role produces a Mermaid timeline showing decisions in order — which superseded which, which led to which. The artifact is saved to `artifacts/diagrams/decision-timeline.mmd` and linked in `state.json` to the decisions it represents.

You open `render.html` in your browser. The timeline is rendered inline alongside the claims it visualizes. You see one branch of the timeline that's suspiciously empty — that's an open question you didn't realize you had.

### What you can answer two weeks later

| Question | How |
|---|---|
| "How has my view of X changed?" | `git log -p state.json` filtered by claim id |
| "Where did I first say Y?" | grep across `transcripts/` |
| "What did I decide about Z?" | `decisions[]` in `state.json` |
| "Which claims am I least confident in?" | query `state.json` by `confidence` |
| "What questions are still open?" | `questions[]` in `state.json` |
| "What does this project look like as a whole?" | open `render.html` — claims, glossary, and artifacts in one view |
| "Which visualizations are out of date?" | query `artifacts[]` by `stale: true` |
| "Show me the supersession history" | `think visualize --of claims --as graph` |

The product is the answer to those questions, not the chat that produced them.

---

## What the engine does

These are the engine's capabilities, organized by what they produce.

### Multi-agent fanout

A single question, sent to multiple models in parallel through OpenRouter. Each model responds independently. The user reads across all responses, or asks the synthesizer to consolidate them. Models are addressed by their OpenRouter identifiers (`openrouter/anthropic/claude-opus-4`); profiles in config name common lineups.

### Modes

A single fanout is one *mode* of multi-agent interaction. The engine supports several:

- `blind_parallel` — same prompt to multiple agents, no cross-talk, synthesized after. The default.
- `critique` — one agent's output reviewed by another.
- `red_team` — adversarial pass against a stated position.
- `research_review` — evidence-gathering, sources surfaced where models can.
- `synthesis` — collapse multi-agent output into a consolidated view.
- `debate_optional` — sequential cross-talk, used sparingly.

Modes are orthogonal to the prompts; the same models can play different modes turn-to-turn. The mode determines what kind of pass this is, the prompt determines the substance.

### Roles

A *role* is the job an agent is doing on a given turn. Same model, different role, different work. Claude doesn't *become* a skeptic — Claude is run with a system prompt that puts it in the skeptic role for that turn. One OpenRouter API key can run every role backed by every model.

The roles the engine supports:

- **Skeptic** — finds weaknesses, prefers pointed questions over confident assertions, surfaces assumptions the user hasn't named.
- **Researcher** — gathers evidence, cites sources where possible, distinguishes what's known from what's inferred.
- **Concretizer** — produces specific examples, real-world analogies, edge cases that test abstractions.
- **Synthesizer** — consolidates multi-agent responses, surfaces disagreements rather than hiding them, proposes updates to `state.json`.
- **Artifact generator** — produces visualizations (diagrams, charts, mind maps) representing concepts in the project.

Roles are orthogonal to modes. A skeptic can run in critique mode (critique someone's claim) or red-team mode (attack a stated position). A researcher can run in research_review mode (gather evidence) or synthesis mode (consolidate findings). The cartesian product is large; not every combination makes sense, but the ones that do are the engine's expressive surface.

Configuration names which role plays which model. The user can set a default role-to-model mapping in their config, override per-call with flags, or let a profile imply both at once. Roles are not persistent agent objects — they're labels that determine which prompt template gets composed for a given turn.

### The synthesizer

The synthesizer is the role that mutates project state. It reads multi-agent responses, identifies what's genuinely new, what's a restatement, what's a real disagreement worth tracking, and proposes updates to `state.json`. It's the single most consequential prompt in the system because it's the only one whose output becomes durable record.

Synthesis is split from narrative summary. *Narrative synthesis* writes prose for the user to read; *state mutation* proposes specific edits to structured state. They're different jobs and they're separate prompts.

### Inline elaboration

Anywhere text appears in the workspace — agent responses, transcripts, notes — the user can elaborate on a phrase or idea using a verb that determines both what kind of follow-up gets generated and where in state it lands.

| Verb | What it does | Lands in |
|---|---|---|
| `define` | "What does this mean?" | glossary |
| `concretize` | "Real-world examples?" | glossary |
| `simplify` | "Plain-English version?" | glossary |
| `deepen` | "Go further on this." | notes |
| `compare-to` | "How does this differ from X?" | claims |
| `cite` / `source` | "Where does this come from?" | evidence |
| `steelman` | "Best version of this argument?" | claims-to-verify |
| `critique` | "Strongest objection?" | claims-to-verify |
| `branch` | "Related concepts worth exploring?" | open questions |
| `visualize` | "Show me this as a diagram / chart / mind map." | artifacts (linked to source concept) |

The verb is the gesture; the destination is what makes it durable. Define a term once, it's in your glossary forever and every subsequent agent has access to it. Steelman a claim, it goes to claims-to-verify. Branch on a concept, you've got a new open question waiting next time you sit down.

### Structured project state

Each workspace has a `state.json` that the engine maintains as the project develops. Schema-versioned from commit one. The shape evolves with use, but the core elements are stable:

- **Claims** — assertions the project has accumulated, with confidence levels, evidence, supersession history.
- **Questions** — open issues the project is working through.
- **Assumptions** — things the project is taking as given, marked as such.
- **Decisions** — choices the user has made, with rationale and what they superseded.
- **Disagreements** — places where models or sessions disagreed, surfaced rather than collapsed.
- **Evidence** — citations and sources, linked to the claims they support.
- **Glossary** — captured definitions, terms of art, project-specific vocabulary.
- **Artifacts** — generated diagrams, charts, visualizations linked to the concepts they represent.

A provisional shape:

```json
{
  "schema_version": 1,
  "project": {
    "name": "Tenant organizing strategy",
    "one_sentence_description": "",
    "current_thesis": "",
    "status": "exploring"
  },
  "claims": [
    {
      "id": "claim_001",
      "text": "...",
      "status": "active",
      "confidence": "medium",
      "supporting_evidence": [],
      "objections": [],
      "supersedes": [],
      "superseded_by": null,
      "created_at": "...",
      "updated_at": "..."
    }
  ],
  "questions": [],
  "assumptions": [],
  "decisions": [],
  "disagreements": [],
  "evidence": [],
  "glossary": [],
  "artifacts": [],
  "change_log": []
}
```

Two principles govern how the schema evolves:

**Schema-versioned from day one.** The `schema_version` field is present in the first version of `state.json` ever written, even when the schema is small. Adding versioning later, after dozens of workspaces exist with schemaless state files, is annoying enough that migrations get avoided and the codebase calcifies. Migration functions take a `version: N` dict and return `version: N+1`; they run on load.

**Don't design the schema up front; let it emerge.** The shape above is provisional. The right granularity for a "claim" is unknown until real use surfaces edge cases. Whether `glossary_entry` is its own type or just a `claim` with `type: "definition"` is unknown. Whether `decision` differs from `current_thesis` is unknown. Resist the urge to flesh out every field before the slice that needs it. The schema grows from where the code is fighting back, not from imagined needs.

The state file is the durable answer to "what does this project look like right now." The user can open it directly. The engine reads it as context for every new turn.

### Hierarchical summaries

Each workspace produces several read-views, regenerated as state changes:

- `verdict.md` — one line. The current bottom line.
- `gist.md` — a short human overview. A few paragraphs.
- `brief.md` — structured summary with major reasoning surfaced.
- `deep_dive.md` — full synthesis of accumulated work.
- `state.json` — the canonical structured representation.
- `transcripts/` — every interaction, append-only.

The user picks the level appropriate to the moment. A quick check uses verdict; a return-to-the-project uses gist; a serious working session uses brief or deep_dive. The engine maintains all of them; the user reads what they need.

### Artifact generation

Eventually, the engine produces visualizations as part of the work — diagrams, charts, mind maps, flow charts, structured data. These are *part of* the structured state, not separate from it: each artifact is linked to the concepts it represents, marked stale when those concepts change, regenerable on request.

The agents producing artifacts work in established formats (Mermaid, GraphViz DOT, Vega-Lite chart specs, SVG, CSV) so the outputs are inspectable as text and renderable in standard tools. An HTML render bundle in each workspace lets the user view all of it inline in any browser without server infrastructure.

Image generation is deferred. The cheaper text-based formats need to prove their worth first.

### Hierarchy of summary, hierarchy of detail

The combination of structured state plus hierarchical summaries plus inline elaboration produces something close to "an IDE for ideas." Not in the sense of a chat with projects — in the sense that the engine offers idea-equivalents of what makes IDEs useful for code:

| Code IDE feature | Think Tank equivalent |
|---|---|
| Jump to definition | Jump to original claim, source, decision in `state.json` |
| Find references | Where else have I discussed this concept? Across transcripts and state. |
| Refactor | Rename or reframe a concept across the project |
| Type-checking | Check claim consistency — does this claim contradict existing ones? |
| Linting | Detect stale, unsupported, vague, or contradictory claims |
| Git diff | Show how my position has changed over time |
| Dependency graph | Show claims and the evidence, assumptions, objections that support them |
| Tests | Validate claims against sources or examples |

These are graph operations, not chat features. The chat is one input surface; the graph is the product. The user works at whatever level of detail the moment calls for, and the project remembers all of them.

---

## What this is not

- **Not a wrapper around your existing chat subscriptions.** Subscription auth (Claude, ChatGPT, Gemini accounts) is out of scope. OpenRouter is the provider boundary; one HTTP API, one key.
- **Not a multi-agent autonomous system.** Agents don't talk to each other unsupervised. The user runs each round; the synthesizer is invoked deliberately, not on a schedule.
- **Not a chat interface.** The interaction model is "ask, get N responses, see what accumulates." Continuous conversation lives in transcripts and your editor, not in a chat loop.
- **Not a hosted product.** Local-first, single-user, runs on your machine. Workspaces are directories you own.

---

## Design commitments

These are the principles the engine answers to.

### Local-first

Workspaces, state, transcripts, config — all on your machine. Git is the version control layer. No cloud sync, no account, no telemetry, no server-side state.

### One provider boundary

OpenRouter is the only way models get called. The engine has no per-provider auth, no provider abstraction layer below OpenRouter, no fallback routing across providers in code. `OPENROUTER_API_KEY` is the only credential the tool reads. Models are addressed by their OpenRouter identifiers.

**OpenRouter is the provider abstraction.** The engine treats it as one HTTP API speaking the OpenAI Chat Completions protocol; this is the entire abstraction the engine needs. Don't build a layer that wraps OpenRouter in a "ModelProvider" interface designed to support other providers later. If support for direct provider auth ever becomes worth the cost, that's a different project.

This trades a small markup over direct provider rates for radical simplification of the provider boundary. For a personal tool, the trade is worth it: it makes the engine work — fanout, synthesis, state mutation, artifacts — meaningfully cheaper to build.

### Engine first; CLI is one adapter

The engine returns structured data. Adapters format it for whatever surface they live on. Future adapters (HTTP API, eventually a UI) talk to the same engine without duplicating its logic. The CLI is kept lean — minimal surface, only what's needed for current capabilities — so engine work has room to progress.

### Sensible defaults that are easy to override

The tool ships with reasonable defaults where the user hasn't expressed a preference. Defaults are visible (in `--help`, in the example config) and trivially overridable. Always pick something sensible when nothing is specified. Always honor the user's explicit choice over a default.

### The tool reads config; it doesn't write it

The config file is text the user owns. The tool may create the file on first run with comments and example values. After that, only reads. There are no commands for managing config.

**Config is for durable user choices, not active state.** If something is being modified in response to commands or accumulating as work happens, it's not config — it's project state, and it belongs in the workspace's `state.json` or transcripts. The line is sharp: config files are read by the tool, never written by the tool. This rule is what prevents the config surface from becoming a managed product feature.

### Setup commands may use interactive prompts; work commands must not

Setup commands (`new`, future setup-related) may prompt where it materially helps. Work commands (`ask`, `elaborate`, `visualize`, etc.) accept all input via arguments and flags. Output is plain text by default with model attribution; `--json` for scripting. The engine itself never prompts.

### The CLI surface grows only when typing the alternative becomes genuinely tedious

Not when "it would be nice." Not when documentation says it should exist. Only when the user reports actual friction. CLI growth is earned, not anticipated.

---

## Configuration shape

A single global config file at `~/.config/think-tank/config.toml`. The tool creates it on first run if absent and reads it thereafter; the user edits it in their editor.

```toml
[defaults]
profile = "frontier"

[profiles.frontier]
models = [
  "openrouter/anthropic/claude-opus-4",
  "openrouter/openai/gpt-5",
  "openrouter/google/gemini-2.5-pro",
]

[profiles.fast]
models = ["openrouter/openai/gpt-5-mini"]

[profiles.diverse]
models = [
  "openrouter/anthropic/claude-opus-4",
  "openrouter/deepseek/deepseek-r1",
  "openrouter/meta-llama/llama-3.3-70b-instruct",
]
```

That's the full config shape for the early slices. No per-project config. No provider sections. No auth metadata. No model registries. The file is small on purpose, and the tool's interaction with it is small on purpose: read at startup, validate, use the values.

### What the config is allowed to grow into

If real use surfaces project-specific friction — particular workspaces wanting different default profiles than the global one — the eventual shape is **two-layer with project overrides only**:

- **Global config** at `~/.config/think-tank/config.toml` is canonical. Profile definitions live here. Adding a model to `profiles.frontier` updates it everywhere.
- **Per-workspace config** at `<workspace>/.think-tank/config.toml` is optional and *overrides only*. It can change `[defaults]` for that workspace (e.g., this project uses `fast` by default). It does **not** redefine profiles. It does **not** hold secrets. It does **not** mirror the global config.

Profile definitions never live per-workspace. Only the choice of which profile is the default for that workspace.

This is direction, not current scope. Don't build the per-workspace config layer until typing `--profile X` repeatedly for the same workspace becomes a real friction point. When that friction surfaces, the lookup rule is dead simple: profiles always come from global; defaults come from project-local first, then global, then error if neither has one.

### What the config will not grow into

The following are explicit non-goals for the config file. If a future feature seems to want them, the answer is "that's project state, put it in the workspace" — not "expand the config schema."

- **Auth metadata.** The only credential the tool reads is `OPENROUTER_API_KEY` from the environment. Config does not record auth methods, env var names, provider readiness, or anything related to credentials.
- **Provider definitions.** OpenRouter is the only provider boundary; the config doesn't enumerate providers, validate them, or hold provider-specific settings.
- **Model registries.** Models are addressed by their OpenRouter identifiers at the point of use. Config doesn't maintain a list of available models, fetch them from OpenRouter, or validate them ahead of time.
- **Mutable state.** Anything the tool would modify in response to commands belongs in workspace state, not config.

The earlier attempt at this project drifted into all four of these. Each individual addition seemed reasonable; the cumulative effect was that config management became the dominant product surface. Not here.

---

## Workspace shape

A workspace is a directory the user creates with `think new`. It accumulates state, transcripts, summaries, and artifacts as the work develops.

```
my-idea/
  state.json           # structured project state, schema-versioned
  verdict.md           # one-line bottom line
  gist.md              # short human overview
  brief.md             # structured summary with reasoning
  deep_dive.md         # full synthesis
  transcripts/         # JSONL records of every interaction
  notes/               # human and agent notes
  artifacts/
    diagrams/          # Mermaid sources
    charts/            # Vega-Lite chart specs
    mindmaps/          # Mermaid mindmaps
    flows/             # GraphViz DOT
    mocks/             # SVG, HTML mocks
    data/              # CSV, JSON datasets
  render.html          # generated browseable view of the project
  .git/                # versioning
```

`state.json` and `transcripts/` exist from the first version. The summaries get generated as state mutates. Artifacts and the render bundle come later. The user can open any of these files directly; the engine doesn't gatekeep the workspace.

---

## CLI shape

The CLI's surface is intentionally small. Two commands for the early slices, growing only as friction earns it.

```bash
think new <path>                                          # create a workspace
think ask "<question>" --model <openrouter-model-id>      # one model
think ask "<question>" --model A --model B --model C      # fanout
think ask "<question>" --profile frontier                 # named lineup
think ask "<question>"                                    # uses default profile
think ask --project <path> "<question>"                   # writes to workspace
```

Future work commands (when their slices ship) follow the same shape:

```bash
think elaborate "<phrase>" --as <verb> --project <path>
think visualize --of <concept> --as <type> --project <path>
think summarize --project <path> --level <verdict|gist|brief|deep>
```

Output is plain text with model attribution by default. `--json` returns structured output for scripting and embedding.

---

## The build path

Vertical slices, each shipping a noticeably more capable Think Tank. The early slices establish the foundation; the engine's distinctive capabilities arrive in steady accumulation across the slices that follow.

**Slice 1 — single-model ask.** `think ask` works end-to-end against one OpenRouter model. No workspace required, no config required, no profiles. Validates the OpenRouter integration, the engine/CLI separation, the async pattern.

**Slice 2 — multi-model fanout.** `--model` becomes repeatable. Concurrent calls via `asyncio.gather`. Output shows all responses with model attribution. The first slice that's recognizably Think Tank.

**Slice 3 — workspace and persistent transcripts.** `think new` creates a workspace; `think ask --project <path>` writes interactions to `transcripts/`. `state.json` exists as schema-versioned scaffold but isn't yet mutated.

**Slice 4 onward — synthesis and structured state.** The synthesizer arrives. Multi-agent responses get consolidated. `state.json` starts accumulating claims, questions, decisions. The narrative-vs-mutation split gets implemented as two distinct passes.

**Then — inline elaboration.** The verb-driven capture mechanism. Define, concretize, steelman, critique, branch — each with its destination in state. Builds the personal knowledge graph as a side effect of normal use.

**Then — hierarchical summaries.** The verdict/gist/brief/deep_dive read-views, regenerated as state mutates.

**Then — search.** Across transcripts and state. Ripgrep-fast for the common cases, vector when the work earns it.

**Then — artifacts.** Mermaid first, GraphViz and chart specs after, SVG and richer when the foundation supports them. The HTML render bundle for in-browser viewing without server infrastructure.

The order isn't fixed past slice 3. What ships next depends on what real use surfaces as the most valuable next step. The point is that the destination is rich and the path to it is incremental.

---

## Open questions

These are deliberately unresolved — they're the questions whose answers should emerge from real use rather than from up-front design. Listed here so future-me knows which uncertainties are intentional.

- **What's the right granularity for a "claim"?** When does a long agent response become one claim versus many?
- **Do questions need hierarchy, or is a flat list sufficient?**
- **How does state degrade gracefully when an agent confidently writes nonsense into it?** What signals catch low-quality synthesis?
- **Is "decision" different from "conclusion"? From "current thesis"?** Or do these collapse into one type with status fields?
- **Does the change log need to be human-readable, or is git diff enough?**
- **How does this scale across multiple related projects?** Cross-project search? Shared glossary? Or are projects strictly siloed?
- **Where does the workspace boundary actually fall?** Per-idea, per-domain, per-month?
- **What's the right capture cadence for the glossary so it doesn't become a graveyard?** What's the review surface?
- **Which artifact types earn their keep?** Mermaid is cheap and widely useful. SVG is harder to produce reliably. Image generation is a different beast. The artifact type registry probably starts conservative.
- **How do artifacts relate to claims?** One-to-one (each claim has one canonical visualization)? Many-to-many (artifacts can represent groups of claims)?
- **Staleness propagation.** When a claim is superseded, every artifact representing it is potentially stale. How aggressively should the engine flag this? Should regeneration be automatic, prompted, or manual?
- **Render bundle vs. interactive UI.** Does `render.html` cover enough that interactive UI is actually optional, or does the visualization workflow only really click when artifacts are zoomable and editable in a real frontend?

---

## Risks

> [!CAUTION]
> - **UX overload.** Multi-agent output is verbose. Hierarchical summaries are not optional; they're load-bearing.
> - **False consensus.** Same-family models converge. Need explicit roles with meaningfully different framings, not just multiple models in parallel.
> - **Cost and latency.** Frontier-model fanout isn't cheap. Design for restraint — parallel-then-synthesize over long debates, on-demand over scheduled.
> - **Capture-without-review.** Glossary and state files become graveyards if there's no review surface. Build the review path early, even if it's just a digest command.
> - **Schema rigidity.** A premature `state.json` schema collects empty fields you dutifully populate instead of the fields you actually need. Let it emerge.
> - **Hallucinated artifact sources.** Models produce broken Mermaid, malformed SVG, invalid chart specs. Validation is mandatory, not optional. Failed validation should retry rather than silently writing broken output.
> - **Artifact staleness.** Visualizations that drift from the state they represent are worse than no visualizations — they look authoritative but mislead. Staleness must be tracked and surfaced.
> - **Visual sprawl.** It's easy for agents to over-produce diagrams that look impressive but obscure rather than clarify. The tool should encourage *fewer, more meaningful* visualizations, not generate-on-every-turn.
> - **Workspace agent boundaries.** Agents read and write inside the workspace freely; outside the workspace, never. This needs to be enforced, not assumed.

---

## Repository layout

```
docs/think_tank/
  README.md         (this file)
```

Companion documents — domain model, prompts, rich outputs, stack decisions — will be added as their topics earn detailed treatment from real implementation. For now, this README captures the engine vision and the build path.

---

## Status & next steps

- [x] OpenRouter-only commitment made
- [x] Engine vision captured
- [x] Configuration shape decided (global, read-only by tool)
- [x] CLI shape sketched
- [x] Workspace shape sketched
- [x] Build path mapped
- [ ] Code repo created at https://github.com/ajeless/think-tank
- [ ] AGENTS.md drafted at root of code repo
- [ ] Slice 1 — single-model ask
- [ ] Slice 2 — multi-model fanout
- [ ] Slice 3 — workspace and persistent transcripts
- [ ] Slice 4+ — synthesis and structured state