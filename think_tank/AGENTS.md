# AGENTS.md

You are working in the Think Tank code repository. Treat this file as a living document — rules earn their place from real friction.

The user fills this in further over time. The skeleton below is the minimum to start.

---

## What Think Tank is

An engine for ideating with multiple LLMs through a single OpenRouter API key. The engine maintains structured project state across multi-agent ideation sessions — workspaces, transcripts, claims, questions, decisions, eventually artifacts. The state is the durable artifact of the work.

The CLI is the first adapter that lets a human drive the engine from a terminal. The engine is the product; the CLI is one way to drive it.

---

## Direction

Design notes live at https://github.com/ajeless/docs/tree/main/think_tank.

These docs describe what the engine is *toward*. They are direction, not a build spec. Implement only what the current task asks for. If you find yourself building infrastructure to support something the docs describe but the task didn't ask for, stop and surface it.

---

## Stack

Decided. Don't propose alternatives unless something specific blocks one of these choices.

| Layer | Choice |
|---|---|
| Language | Python (3.12+) |
| Toolchain | `uv` |
| Provider boundary | OpenRouter via `openai` SDK pointed at `https://openrouter.ai/api/v1` |
| Concurrency | `asyncio` |
| CLI framework | `typer` |
| Terminal output | `rich` |
| Test framework | `pytest` + `pytest-asyncio` |
| Config | TOML at `~/.config/think-tank/config.toml`, read-only by the tool |
| Storage | JSON + JSONL files in per-workspace directories, git for versioning |

---

## Toolchain rules

Python with `uv`. Rules are literal.

**Always use:** `uv add`, `uv add --dev`, `uv remove`, `uv run python`, `uv run pytest`, `uv run think`, `uv sync`.

**Never use:** `pip`, `python` or `python3` directly, `python -m pip`, manual `venv`/`virtualenv`, `poetry`, `pipenv`, `conda`.

If something doesn't fit these patterns, ask before reaching for the older toolchain.

---

## Design principles

**Engine first; CLI is one adapter.** Engine functions return structured data. They don't print, don't read environment variables unless given a config object, don't depend on Typer or Rich, and don't prompt interactively. Adapters format engine output for their surface.

**OpenRouter is the only provider boundary.** Models are addressed by their OpenRouter identifiers. No per-provider auth, no provider abstraction below OpenRouter. `OPENROUTER_API_KEY` is the only credential the tool reads.

**Sensible defaults that are easy to override.** Pick reasonable defaults when nothing is specified. Make defaults visible (in `--help`, in the example config). Always honor explicit user choice over a default.

**The tool reads config; it doesn't write it.** No `config set` commands. Config is text the user owns. If something needs to be persisted as a result of work, it's project state — it lives in the workspace.

**Setup commands may prompt; work commands must not.** Work commands accept all input via arguments and flags. Missing input → clear error. The engine itself never prompts.

**The CLI surface grows only when typing the alternative becomes genuinely tedious.** Not anticipated. Earned.

---

## Branching and commits

- Never work in or commit directly to `main`. Open a working branch.
- Commit and push directly to the working branch — no approval needed.
- When the slice is ready for review, create a PR and raise it in chat.
- Commit messages describe what changed and why, not how.

---

## What to do first

1. Read this file completely.
2. Wait for me to give you a task.
3. When given a task, write a short plan first. Wait for approval before writing code.