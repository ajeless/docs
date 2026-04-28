# Think Tank

> **Status:** Design notes for a forthcoming code repository.
> Implementation will live at https://github.com/ajeless/think-tank (to be created). A retired earlier attempt is at https://github.com/ajeless/idea001 with its docs at https://github.com/ajeless/docs/tree/main/idea001.

A local-first engine for ideating with multiple LLMs, accessed through a single OpenRouter API key. Think Tank turns a conversation with several models into durable, structured project state — transcripts, claims, questions, evidence, eventually artifacts — that the user owns and can return to.

The first adapter is a lean CLI. Other adapters (an HTTP API, eventually a UI) may come later. The engine is the product; the CLI is one way to drive it.

---

## The shape of the thing

You start a workspace for an idea you want to think through. You ask a question. Multiple models respond in parallel. Their responses get written to durable transcripts. Over time, as you keep asking, the engine maintains a structured representation of the project — what's been claimed, what's been questioned, what's been decided, what's still open. You can return to a workspace days later and see where you left off, what's accumulated, what still needs work.

That's the destination. Not all of it ships in slice one. The early slices establish the foundation: workspace, fanout, transcripts. Later slices add state mutation, synthesis, glossary capture, eventually artifacts (diagrams, charts, mind maps). The engine is what enables all of that; the CLI is what lets the user drive it.

---

## What this is

- An engine that maintains durable, structured project state from your interactions with multiple LLMs.
- A lean CLI as the first adapter — kept small on purpose so engine work has room to progress.
- A workspace per idea: state file, transcripts, eventually artifacts, all in plain files on your machine.
- Local-first. Single user. Your config, your transcripts, your machine.
- OpenRouter-only at the provider boundary. One HTTP endpoint, one API key, every model worth using.

## What this is not

- Not a wrapper around your existing chat subscriptions. Subscription auth (Claude, ChatGPT, Gemini accounts) is explicitly out of scope. If subscription auth ever becomes worth solving, it's a different project.
- Not a multi-agent autonomous system. Agents don't talk to each other unsupervised. The user runs each round.
- Not a chat interface. The interaction model is "ask once, get N responses, see what accumulates." Continuous chat lives in your transcripts and your editor, not in a chat loop.
- Not a hosted product. Local-first, single-user, runs on your machine.

---

## Why OpenRouter only

The earlier attempt (idea001) tried to support direct provider auth across seven providers, plus subscription paths, plus aggregators. The auth and config complexity dominated the project — 16 of 18 commands shipped were config CRUD, not engine features. The actual product never got built because the infrastructure for the product ate the slices.

Committing to OpenRouter as the single provider boundary collapses that complexity to one HTTP API and one environment variable. Everything downstream — multi-model fanout, synthesis, state mutation, eventually artifact generation — becomes cheaper to build. The engine work that didn't happen in idea001 becomes the work that *does* happen in idea002.

The trade-off: a small markup over direct provider rates, and you can't reuse subscriptions you already have. For a personal tool, this is the right exchange. The constraint isn't a limitation on the engine's capabilities; it's a friction reducer that lets the engine actually get built.

---

## Design commitments

These are the principles the project answers to. Each one is a constraint with teeth — meaning it can and will rule out features that violate it.

### Engine first; CLI as one adapter

Think Tank is an engine. The CLI is the first adapter that lets a human drive it from a terminal. The engine returns structured data; adapters format it for whatever surface they live on. This separation means future adapters (an HTTP API, eventually a UI) talk to the same engine without duplicating its logic.

The CLI is kept lean — minimal surface, only what's needed for current slices — so engine work has room to progress. Adding CLI surface is a deliberate decision; it's not the default response to "we need a way for the user to do X."

### Local-first

Workspaces, state, transcripts, config — all on your machine. Git is the version control layer. No cloud sync, no account, no telemetry, no server-side state.

### One provider boundary

OpenRouter is the only way models get called from the engine. Models are addressed by their OpenRouter identifiers (`openrouter/anthropic/claude-opus-4`). The engine does not maintain provider-specific code paths, provider-specific auth, or provider-abstraction layers below OpenRouter.

### Sensible defaults that are easy to override

The tool ships with reasonable defaults where the user hasn't expressed a preference. Defaults are visible (printed in `--help`, documented in the example config file) and trivially overridable.

This is a deliberate calibration of the principle from idea001 ("no opinions imposed on the user"). That earlier framing forbade defaults entirely, which generated friction every time the user had to specify something obvious. The right form is: *defaults are fine; defaults that override user-supplied values are not*. Always pick something sensible when nothing is specified. Always honor the user's explicit choice over the tool's default.

### The tool reads config; it doesn't write it

The config file is text the user owns. The tool may create the file on first run with comments and example values. After that, it only reads. There are no `config set` commands. There are no commands that mutate config based on user actions. If something needs to be persisted as a result of work, that's project state — it lives in the workspace's `state.json` or transcripts, not in the global config.

This rule is what would have prevented the worst of idea001's drift. It's load-bearing.

### The CLI surface grows only when typing the alternative becomes genuinely tedious

Not when "it would be nice to have." Not when documentation says it should exist. Only when the user finds themselves wishing for a shortcut and reaching for the same long flag combination repeatedly. Idea001 shipped 18 commands; the right number for the early slices is two. CLI growth is earned, not anticipated.

---

## Configuration shape

A single global config file at `~/.config/think-tank/config.toml`. No per-project config until friction earns it.

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
```

The user edits this file in their editor. The tool reads it. There are no commands for managing config.

---

## CLI shape

Two commands for the early slices:

```bash
think new <path>                                          # creates a workspace
think ask "<question>" --model <openrouter-model-id>      # one model
think ask "<question>" --model A --model B --model C      # fanout
think ask "<question>" --profile frontier                 # named lineup
think ask "<question>"                                    # uses default profile
think ask --project <path> "<question>"                   # writes to workspace
```

That's the surface for slices 1-3. Output is plain text by default with model attribution; `--json` returns structured output for scripting.

What comes after depends on what real use surfaces. New commands or flags are added when typing the alternative is genuinely tedious — not before.

---

## Workspace shape

A workspace is a directory the user creates with `think new`. It accumulates state and transcripts as the user works in it.

```
my-idea/
  state.json           # structured project state, schema-versioned
  transcripts/         # JSONL records of every interaction
  notes/               # human and agent notes (slice TBD)
  artifacts/           # diagrams, charts, etc. (slice TBD)
  .git/                # versioning
```

`state.json` starts as a small scaffold (schema version, project metadata) and grows as engine features earn their place. The earliest version is read-only context for `think ask`. Later versions get mutated by synthesis passes that consolidate multi-agent responses into structured claims, questions, and decisions. Even later versions track artifacts and the concepts they represent.

The workspace structure above shows the destination. The early slices ship a smaller version — `state.json` plus `transcripts/` — and grow it as needed.

---

## The build path

Vertical slices, each shipping a noticeably more capable Think Tank.

**Slice 1 — single-model ask.** `think ask` works end-to-end against one OpenRouter model. No workspace required, no config file required, no profiles. Question and `--model` as inputs; response as output; `OPENROUTER_API_KEY` from environment. Validates the OpenRouter integration, the engine/CLI separation, and the async pattern.

**Slice 2 — multi-model fanout.** `--model` becomes repeatable. Concurrent calls via `asyncio.gather`. Output shows all responses with model attribution. This is the slice where Think Tank becomes recognizably itself.

**Slice 3 — workspace + persistent transcripts.** `think new` creates a workspace. `think ask --project <path>` writes the interaction to `transcripts/` so it can be referenced later. `state.json` exists as schema-versioned scaffold but isn't mutated yet.

**Slice 4 onward — engine work.** The slices that build the engine's core capabilities. Candidates include: state mutation (synthesizer pass updates `state.json` with claims, questions, decisions), structured response shape, glossary capture, search across transcripts. The order depends on what slices 1-3 reveal as the next friction.

**Later — artifacts and richer outputs.** Eventually: agents produce diagrams, charts, mind maps as part of working on the project. Each artifact is linked to the concepts in `state.json` it represents. This is direction, not commitment for the early slices — it informs the engine's shape but doesn't get built until the foundation supports it.

The key discipline: each slice ships a usable improvement. Internal refactoring that doesn't change user-visible capability is allowed but should be in service of the next user-visible slice, not an end in itself. Idea001 accumulated 39 commits with most of the user-visible capability landing in the first five; the rest was infrastructure that never got connected to a product feature.

---

## What's salvageable from idea001

The earlier attempt accumulated meaningful architectural work, even though the product never shipped. Worth carrying forward at the architectural level:

- The engine-returns-data discipline, with adapters formatting the result
- The async pattern for model calls
- The fake-client testing approach (mock the SDK boundary, no network in unit tests)
- The workspace folder as the unit of project state
- Schema-versioned `state.json` from the first commit, even when state is minimal

What gets left behind:

- Multi-provider direct auth (replaced by OpenRouter-only)
- The config CRUD command surface (replaced by config-file-as-interface)
- Subscription auth and OAuth flows (out of scope)
- aisuite (OpenRouter is the abstraction)
- Per-provider validation, doctor, models-list commands (deferred indefinitely)
- The "no opinions imposed on the user" principle (replaced by sensible-defaults-easy-to-override)

---

## Repository layout

```
docs/think_tank/
  README.md         (this file)
```

Companion documents (domain model, prompts, rich outputs, stack decisions) will be added as their topics earn detailed treatment from real implementation experience. Writing them ahead of slices repeated the failure mode that contributed to idea001's stall.

---

## Status & next steps

- [x] Idea001 retired and renamed
- [x] OpenRouter-only commitment made
- [x] CLI shape sketched
- [x] Config shape decided (global, read-only by tool)
- [x] Engine-first framing recovered
- [ ] Code repo created at https://github.com/ajeless/think-tank
- [ ] AGENTS.md drafted at the root of the code repo
- [ ] Slice 1 — single-model ask
- [ ] Slice 2 — multi-model fanout
- [ ] Slice 3 — workspace + transcripts
- [ ] Slice 4+ — engine work toward state mutation and synthesis