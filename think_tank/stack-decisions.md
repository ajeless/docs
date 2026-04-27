<div align="center">

<img src="assets/divider-blueprint.svg" alt="" width="100%">

# Stack decisions

*Companion document to [README.md](./README.md). The reasoning behind Python + aisuite + CLI-first, including what was rejected and why.*

<img src="assets/divider-blueprint.svg" alt="" width="100%">

</div>

## The decisions

| Layer | Choice | What was rejected |
|---|---|---|
| Engine language | **Python** | Go (good concurrency, wrong ecosystem) |
| Provider abstraction | **[aisuite](https://github.com/andrewyng/aisuite)** | LiteLLM (over-engineered), LangChain (opaque), roll-your-own (re-creates aisuite) |
| Concurrency model | **`asyncio` + `httpx`** | Threads, Go-style channels |
| CLI framework | **`typer`** (or `click`) | argparse (verbose), bare-bones |
| Future API | **FastAPI** | Flask (older), Django (overkill) |
| Storage | **JSONL + JSON** | SQLite (premature), Postgres (way premature) |
| Versioning | **git** | Custom revision history (reinventing the wheel) |

The rest of this doc is the reasoning. Each decision is justified independently so any single one can be revisited without unwinding the others.

<img src="assets/divider-blueprint.svg" alt="" width="100%">

## Provider abstraction: why aisuite

The core problem: every LLM provider has a different SDK, different auth conventions, different message formats, different streaming protocols, different error semantics, different ways of expressing tool use and structured output. "Send the same prompt to N providers" is, mechanically, N different operations.

There are four ways to handle this:

### Option A — Roll your own

Write a thin adapter for each provider directly against their official SDK. Anthropic adapter, OpenAI adapter, Google adapter, OpenRouter adapter, each with its own translation from a unified prompt structure to that provider's specific API call.

**Pros:** Total control. No external dependency. You understand every byte of what's happening.

**Cons:**
- Every new provider is several hundred lines of work, plus tests.
- Provider APIs change. Your code has to chase those changes — and you'll find out about a breaking change when something fails in production.
- The unified-to-specific translation has subtle pitfalls (system prompt placement, role naming conventions, content-block formats) that aren't obvious until they bite.
- You're maintaining a thing that has nothing to do with Think Tank's actual value proposition.

This is the path that *sounds* clean for a "weekend prototype" because it minimizes dependencies, but is actually the most expensive option over any meaningful timeline.

### Option B — LangChain

LangChain provides high-level abstractions over LLMs and a chaining model for building workflows on top. It's the most widely-used framework in this space.

**Pros:** Mature. Large community. Built-in support for memory, retrieval, agents, tool use.

**Cons:**
- The abstractions are designed for chaining, which Think Tank doesn't fundamentally need at this stage. Modes can be implemented as plain function calls; we don't need a chain DSL.
- LangChain hides what's actually being sent to the model. For a system that wants to see and control prompt assembly, this is a real cost. Debugging a chain that produced unexpected output means digging through the framework's prompt manipulation layers.
- Heavy dependency. LangChain pulls in a substantial dependency tree.
- Version churn is real — common feedback is that upgrading LangChain breaks existing code in ways that require non-trivial fixes.

LangChain solves a problem we don't have (orchestration) at the cost of opacity over a problem we do have (knowing exactly what prompt went to which model).

### Option C — LiteLLM

LiteLLM is a Python SDK and proxy server providing one OpenAI-compatible interface to 100+ LLM providers, with cost tracking, fallbacks, retries, load balancing, and an admin dashboard.

**Pros:** Most mature in this space. Production-ready. Handles edge cases (rate limiting, retries, fallback chains across providers) that we'd otherwise have to handle ourselves. Migration path: if we start with aisuite and need more, the calling pattern is similar.

**Cons:**
- Designed for production AI gateways serving teams, not personal CLI tools. Most of its features (admin dashboard, virtual keys, spend tracking, RBAC) are irrelevant for our case.
- The proxy mode introduces a separate process. Library mode is fine but you're carrying production-grade infrastructure for a personal tool.
- Latency overhead has been noted in benchmarks; less relevant when used as a library locally, but it tells us something about the design priorities.

LiteLLM is the right answer for "AI gateway for a team building production AI applications." We're building a personal idea workspace.

### Option D — aisuite *(chosen)*

aisuite is a thin wrapper around official provider Python SDKs. The model selection pattern is a single string: `openai:gpt-4o`, `anthropic:claude-opus-4-7`, `ollama:llama3.1:8b`. Modeled after OpenAI's API style, so the calling code is familiar to anyone who's touched any LLM SDK in the last two years.

**Pros:**
- Truly thin. ~100 lines of dispatch logic, not a separate process. `uv add aisuite[anthropic,openai,google]` and you're done.
- The `provider:model` string is exactly the kind of identifier you'd want to store in `state.json` to record "this turn used `anthropic:claude-opus-4-7`." The library's identifier becomes our data identifier.
- API is OpenAI-shaped — minimal learning curve.
- Wraps each provider's *official* SDK rather than reimplementing — provider updates flow through naturally.
- Simple installation. `pip install aisuite[anthropic]` or `pip install aisuite[all]`.

**Cons / known limitations:**
- Streaming support is limited. For our use case (parallel fanout, gather all responses, synthesize) streaming isn't critical. If/when it becomes critical (TUI live updates), this is the migration trigger to LiteLLM.
- Less feature-rich than LiteLLM around rate limit handling, cost tracking, fallback chains. We can add these layered on top if needed; we don't need them on day one.
- Newer than LiteLLM. Smaller community.

**For Think Tank's first weekend, this is clearly the right call.** The hassle of `uv add aisuite` is approximately zero. The cost of writing your own adapters across multiple providers is meaningful (each has different message formats, different system-prompt handling, different streaming protocols, different error semantics). The cost of *fixing* a homegrown abstraction six months in when a provider changes their API is even larger.

If aisuite later turns out to be too thin, the migration path to LiteLLM is well-documented and the calling pattern is similar. Picking aisuite now doesn't lock us out of LiteLLM later.

<img src="assets/divider-blueprint.svg" alt="" width="100%">

## Engine language: why Python over Go

The instinct to consider Go is good — Go's concurrency story (goroutines, channels, `errgroup`, structured concurrency with `context`) is genuinely cleaner than Python's, and "send the same prompt to N providers in parallel and gather the results" is exactly the kind of thing Go was built for. Two-line `errgroup.WithContext` and you're done.

But there's a hidden cost: **the LLM provider ecosystem is overwhelmingly Python-first.**

- Anthropic, OpenAI, Google all ship Python SDKs as their primary language.
- aisuite is Python. LiteLLM is Python. There's no Go aisuite-equivalent that's mature.
- Every example, every tutorial, every fix-this-edge-case StackOverflow answer is Python.
- Go SDKs exist for the major providers but they lag — usually weeks or months behind on new features, sometimes longer on niceties like streaming protocol updates.

So if you build the engine in Go, you're either:
- Using each provider's Go SDK directly — back to writing the abstraction layer aisuite already finished.
- Shelling out to a Python helper — adds IPC complexity for no win.
- Calling LiteLLM-as-a-proxy from Go — adds a daemon and HTTP hop for every model call.

Each of those reintroduces complexity that picking Python sidesteps.

### The honest read on Python's concurrency limitations

For Think Tank's actual workload, Python is fine.

The workload is **I/O-bound, not CPU-bound.** Each model call spends 99% of its time blocked on the network waiting for the provider's API to respond. The GIL isn't a problem because you're not contending for CPU; you're waiting on remote services. `asyncio.gather` over a list of `httpx`-based coroutines handles this case extremely well — the Python event loop is genuinely good at fanning out concurrent HTTP requests.

The Go advantage shows up when you have:
- CPU-bound parallelism (computational work that needs real OS threads)
- Complex pipelining of channels (data flowing through multiple stages)
- Sub-millisecond latency requirements (where GC pauses matter)
- A need for true OS-level parallelism

None of which describe Think Tank's workload.

### Where Go might actually fit later

The case where Go earns its keep is something like: a long-running daemon that watches the project folder, indexes transcripts in real time, serves search queries with sub-millisecond latency, runs as a system service. That's a different component than the engine — it's an indexer — and it would talk to the Python engine over a queue or local socket.

That's a "month six, if even then" component, not a weekend-prototype concern. If we ever build it, it lives alongside the Python engine, not instead of it.

<img src="assets/divider-blueprint.svg" alt="" width="100%">

## CLI first, then HTTP API

The engine knows nothing about UI. The CLI is a thin adapter. When a UI eventually exists, it talks to the same engine through HTTP.

```
┌──────────┐   ┌──────────┐   ┌──────────────────┐
│ CLI      │   │ HTTP API │   │ Future TUI / Web │
│ (typer)  │   │ (FastAPI)│   │ (any language)   │
└────┬─────┘   └────┬─────┘   └────────┬─────────┘
     │              │                  │
     └──────────────┼──────────────────┘
                    │
            ┌───────▼─────────┐
            │  Engine (Python)│
            │  - state ops    │
            │  - agent calls  │
            │  - synthesis    │
            │  - persistence  │
            └────────┬────────┘
                     │
            ┌────────▼────────┐
            │  aisuite        │
            └────────┬────────┘
                     │
        ┌────────────┼────────────┐
        ▼            ▼            ▼
   Anthropic     OpenAI       Google
```

### The discipline

Engine functions:
- Return data, never `print`.
- Don't read environment unless explicitly given a config object.
- Don't know whether they're being called from a CLI handler or an HTTP handler.
- Can be unit-tested without standing up either layer.

CLI handlers:
- Parse argv, call engine functions, format the result for terminal display.
- That's it. Anything more complex than ~10 lines per command is a sign the logic should move into the engine.

HTTP handlers (when added):
- Parse request, call engine functions, format the result as JSON.
- ~10 lines per endpoint, same shape as CLI handlers but for HTTP.

The test: **you should be able to delete the CLI and write a new one in another language by reading the engine's public surface.** If you can't, the CLI is doing something the engine should be doing.

### Why typer over click

`typer` is built on top of `click` and adds type hint inference for argument parsing. Cleaner code, less boilerplate, full click power available when needed. If you have strong opinions about click already, click is fine — they're equivalent in capability. Both are vastly preferable to argparse.

### Why FastAPI for the eventual API

- Async-native, which matches the engine's concurrency model.
- Auto-generated OpenAPI schema, which makes future frontend work easier.
- Type hints map directly to request/response shapes.
- Mature, well-documented, low ceremony.

The whole HTTP layer is probably ~100 lines once the engine exists. Don't write it before you need it.

<img src="assets/divider-blueprint.svg" alt="" width="100%">

## Storage: JSONL + JSON, with git on top

For the prototype:

- `state.json` — the canonical project state. JSON, plain dict shape, schema-versioned. See [`domain-model.md`](./domain-model.md).
- `transcripts/*.jsonl` — append-only log of every model call. One line per call.
- `notes/`, `artifacts/` — markdown and other files, freeform.
- `.git/` — every meaningful state change is a commit. Git provides versioning, diff, rollback, branch.

What was rejected:

- **SQLite.** Premature. Adds query expressiveness we don't yet have queries for. The moment we want to ask "show me all claims with confidence < medium that haven't been touched in 30 days," SQLite earns its keep. Until then, JSON + ripgrep handles every realistic query.
- **A vector database.** Way premature. We don't yet know what kind of search the workflow actually needs. Likely answer: ripgrep over transcripts and notes covers 90% of the search load; vector search becomes a Layer 3 question.
- **Custom revision history.** Reinventing git for no win. Git is already on every developer's machine, every IDE has integrations, and the `git log -p state.json` workflow for "how has my view of X changed?" is exactly the kind of thing that just works.

### Schema versioning

`state.json` carries a `schema_version` field from the very first commit. Migrations are functions that take a `schema_version: N` dict and return a `schema_version: N+1` dict, run in sequence on load. Adding this on day one is free. Adding it after the first dozen projects exist is annoying enough that people avoid migrations and the codebase calcifies.

<img src="assets/divider-blueprint.svg" alt="" width="100%">

## Migration paths between options

Decisions aren't permanent. Each one has a clear migration trigger and path:

### aisuite → LiteLLM

**Trigger:** Need streaming, or need fallback chains across providers, or need rate-limit handling that aisuite doesn't expose, or need cost tracking baked into the call layer.

**Path:** LiteLLM's calling pattern is similar to aisuite's. The provider:model string convention is the same. Most engine code that calls aisuite would call LiteLLM with minor adjustments. Could be a half-day migration if we've kept the engine clean.

### CLI → CLI + HTTP API

**Trigger:** Building a TUI, web frontend, mobile client, or any UI that isn't the CLI.

**Path:** Add FastAPI as a dependency. Wrap each engine function in an endpoint. Maybe 100 lines plus tests. The CLI doesn't change.

### JSONL/JSON → SQLite

**Trigger:** Wanting to ask queries that ripgrep can't answer cleanly. Likely candidates: "all superseded claims and what superseded them," "every state change in the last 30 days affecting claim_007," "claims by confidence level."

**Path:** Write a script that imports the JSON state into SQLite. Switch the engine's read path to SQLite, keep the write path going to both for a transition period, then drop JSON for canonical storage but keep transcripts as JSONL.

### Python → Python + Go indexer

**Trigger:** Real performance pressure on search/indexing. Not before then.

**Path:** Build the indexer as a separate Go process. It watches `~/thinktank/<project>/` for changes, maintains its own search index. The Python engine queries it via local socket or HTTP. The engine remains Python.

<img src="assets/divider-blueprint.svg" alt="" width="100%">

## What to track during real use

A running notes file about stack pain points:

- [ ] Did aisuite cover every provider need, or did we have to drop down to provider SDKs?
- [ ] Did `asyncio.gather` over `httpx` actually feel ergonomic, or did concurrency become annoying?
- [ ] Did the engine/CLI separation hold, or did logic leak into CLI handlers?
- [ ] Did JSON+git as storage scale, or did query needs outgrow it?
- [ ] Were there migrations to schema that exposed missing structure?
- [ ] Did any provider-specific quirks need handling that aisuite didn't expose?
- [ ] When did each layer's "trigger to migrate" actually fire, if it did?

These answers inform the Layer 3 decisions about whether and when to migrate any of these choices.

<img src="assets/divider-blueprint.svg" alt="" width="100%">

<div align="center">

*Companion doc to [README.md](./README.md). See also [`domain-model.md`](./domain-model.md), [`prompts.md`](./prompts.md), and [`rich-outputs.md`](./rich-outputs.md).*

</div>
