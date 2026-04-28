# AGENTS.md

You are working in the Think Tank code repository. Treat this file as a living document — rules earn their place from real friction, not from anticipation.

This is a second attempt. The first (https://github.com/ajeless/idea001) shipped a working `think ask` command but stalled because provider/auth/config infrastructure dominated the work. The rules here are calibrated against that experience.

The user will fill this in further over time. The skeleton below is the minimum needed to get started without repeating idea001's mistakes.

---

## What Think Tank is

An engine for ideating with multiple LLMs through a single OpenRouter API key. The engine maintains durable, structured project state — workspaces, transcripts, eventually claims and synthesis and artifacts. The CLI is the first adapter that lets a human drive the engine from a terminal.

The engine is the product. The CLI is one way to drive it.

---

## Direction (not gospel)

Design notes live at https://github.com/ajeless/docs/tree/main/think_tank.

These docs are direction. They are not a build spec. Read them to understand what the engine is *toward*. Do not implement anything because a doc describes it; implement only what the current task asks for. If you find yourself building infrastructure to support something the docs describe but the current task didn't ask for, stop.

The retired earlier attempt is at https://github.com/ajeless/idea001. Useful for context on what was tried and why it stalled. Not authoritative for what to build next.

---

## Stack

Decided. Don't propose alternatives unless something specific blocks one of these choices.

| Layer | Choice |
|---|---|
| Engine language | Python (3.12+) |
| Toolchain | `uv` |
| Provider boundary | OpenRouter via the `openai` SDK pointed at `https://openrouter.ai/api/v1` |
| Concurrency | `asyncio` |
| CLI framework | `typer` |
| Terminal output | `rich` |
| Test framework | `pytest` + `pytest-asyncio` |
| Config | TOML at `~/.config/think-tank/config.toml`, read-only by the tool |
| Storage | JSON + JSONL files inside per-workspace directories, git for versioning |

Deferred (do not pull in until explicitly needed):

- Provider abstraction libraries (aisuite, LiteLLM) — OpenRouter is the abstraction
- Interactive-prompt libraries (questionary) — flags and config files come first
- HTTP API framework, database, vector search, frontend frameworks
- Logging frameworks beyond standard library

---

## Toolchain rules

Python with `uv`. Rules below are literal.

**Always use:**
- `uv add <package>` to add dependencies
- `uv run python <script>` to run Python
- `uv run pytest` to run tests
- `uv run think ...` to run the CLI from a source checkout
- `uv sync` to sync the environment

**Never use:**
- `pip`, `pip install`, or `python -m pip ...`
- `python <script>` or `python3 <script>` directly (always prefix with `uv run`)
- Manual `venv`/`virtualenv`, `poetry`, `pipenv`, `conda`

If something doesn't fit these patterns, ask before reaching for the older toolchain.

---

## Design principles

Non-negotiable. New principles are added only when one earns its place from a real incident.

### Engine first; CLI is one adapter

Think Tank is an engine. The CLI is one adapter that lets a user drive the engine from a terminal. The engine returns structured data; adapters format it. Future adapters (HTTP API, eventually a UI) talk to the same engine without duplicating its logic.

Engine functions:
- Return structured data (dataclasses, TypedDicts, plain dicts). Don't print.
- Don't read environment variables unless explicitly given a config object.
- Don't depend on Typer, Rich, or any CLI-only library.
- Don't prompt interactively. Ever. Prompting is an adapter concern.

### OpenRouter is the only provider boundary

Models are addressed by their OpenRouter identifiers (`openrouter/anthropic/claude-opus-4`). The engine has no per-provider auth, no provider abstraction layer below OpenRouter, no fallback routing across providers in code. `OPENROUTER_API_KEY` is the only credential the tool reads.

Idea001 added per-provider auth, provider abstraction, and aggregator support; the resulting surface complexity dominated the project. Don't reintroduce them.

### Sensible defaults that are easy to override

The tool ships with reasonable defaults where the user hasn't expressed a preference. Defaults are visible (in `--help`, in the example config) and trivially overridable. Always pick something sensible when nothing is specified. Always honor the user's explicit choice over a default.

(This is a deliberate calibration of idea001's "no opinions imposed on the user" principle, which forbade defaults entirely and generated friction at every command.)

### The tool reads config; it doesn't write it

The config file is text the user owns. The tool may *create* it on first run (with comments and example values). After that, only reads. No `config set` commands. No commands that mutate config based on user actions. If something needs to be persisted as a result of work, it's project state — it lives in the workspace's `state.json` or `transcripts/`, not in global config.

### Setup commands may use interactive prompts; work commands must not

Setup commands (e.g., `new`) may prompt where it materially helps. Rich formatting is fine.

Work commands (e.g., `ask`) accept all input via arguments and flags. They never prompt mid-run. Missing input → clear error pointing at how to provide it. Output is plain text by default with model attribution; `--json` for scripting.

"Interactive" means *requiring user input mid-execution*. Pretty output is not interaction; it's display, and it's fine in any command.

### The CLI surface grows only when typing the alternative becomes genuinely tedious

Not when "it would be nice." Not when documentation says it should exist. Only when the user reports actual friction from typing the alternative repeatedly.

Idea001 shipped 18 commands; the right number for early slices is two. CLI growth is earned, not anticipated.

---

## What to do first

1. Read this file completely.
2. Wait for me to give you a task. Do not start working until I do.
3. When given a task, write a short plan first. Wait for approval before writing code.

---

## Working autonomy

For structural decisions (project layout, file organization, naming): propose your choice with a one-sentence rationale, then proceed.

For dependency choices: the stack above is fixed. New dependencies need approval.

For destructive or non-reversible actions (deleting files, force-pushing, modifying anything outside the repo): always wait for approval.

---

## Slice discipline

Work happens in vertical slices. Each slice ships a noticeably more capable Think Tank from the user's perspective — not a noticeably better internal architecture.

A slice is the right size when:
- It produces something the user can run and see the difference from the previous slice.
- It can be reviewed in one sitting (rough heuristic: under 300 lines of source diff, under 600 lines including tests).
- It has a clear "done" — usually a single example command that works end-to-end.

When uncertain whether something belongs in the current slice or the next, defer it. Smaller slices are almost always better. Idea001 accumulated 39 commits while user-visible capability barely changed past the first five; don't repeat that.

---

## Tests

- Unit tests aim for 100% coverage. Integration and end-to-end aim for >= 90% and >= 80% respectively, treated as loose targets — write them where they make sense.
- For code or behavior changes, run `uv run pytest` before committing. Include the test output in the commit message body. If you can't run tests in your environment, say so explicitly and don't commit.
- For docs-only changes, tests aren't required. Say so explicitly in the commit message.
- Unit tests must not hit the network. Mock the SDK boundary. Real-OpenRouter end-to-end tests are allowed but should be opt-in (gated by an env var) and not part of the default `pytest` run.

---

## Branching and commits

- Never work in or commit directly to `main`. Open a working branch.
- Commit and push directly to the working branch — no approval needed.
- When the slice is ready for review, create a PR and raise it in chat.
- Commit messages describe what changed and why, not how.

---

## Definition of done (per slice)

1. Propose any rules that emerged during the work and belong in this file. Don't edit AGENTS.md directly.
2. Audit `.md` files for staleness or inconsistency introduced by the slice. Update them where needed; if no doc changes were required, say so explicitly in the slice summary.
3. If you encountered a situation where this file was silent and you had to guess, surface it at the end of the task.
4. Commit, push, create a PR, raise in chat.

---

## When in doubt

Ask. The cost of a question is small. The cost of guessing wrong, especially early, is large.