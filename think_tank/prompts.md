<div align="center">

<img src="assets/divider-blueprint.svg" alt="" width="100%">

# Prompts

*Companion document to [README.md](./README.md). The prompt assembly pipeline that sits at the heart of Think Tank.*

<img src="assets/divider-blueprint.svg" alt="" width="100%">

</div>

## The hidden subsystem

Think Tank is, mechanically, a system for sending prompts to LLMs and processing their output. The README has good abstractions for *what* the prompts are organized around — modes, verbs, project state, glossary entries — but the prompts themselves are doing more work than the rest of the system. The prompt subsystem is going to be the dominant source of complexity in the first month, and it's worth being explicit about why.

A few realities about working with LLMs that shape this:

- Small wording changes have outsized effects on output quality, structure, and tone.
- The same model with two different system prompts produces results so different they could be different products.
- Prompts get iterated on more than code does. You'll change `prompts.py` more often than `engine.py`.
- Provider-specific quirks matter — Anthropic, OpenAI, and Google handle system prompts, structured output, and message formatting differently in ways that show up in subtle output differences.

The product has a hidden subsystem inside it: a **prompt assembly pipeline**. Naming it makes it manageable. Ignoring it makes it the thing that quietly dominates your time.

<img src="assets/divider-blueprint.svg" alt="" width="100%">

## The layers of every model call

Every call to a model is some composition of these layers:

```
[base system prompt] — what Think Tank is, how to behave generally
[role prompt]        — you are the skeptic / researcher / synthesizer
[mode prompt]        — you are doing critique / blind_parallel / red_team this turn
[project context]    — current state.json or a summary of it
[conversation context] — what happened earlier in this session
[user turn]          — the actual question or instruction
```

Not every layer applies to every call. The first turn of a session has no conversation context. A blind parallel call doesn't include the other agents' answers. The synthesizer's role might bypass the skeptic's role entirely. But every call is a composition of some subset of these layers, in some order.

### The base system prompt

The most important text in the whole product. This is where you tell every model:

- We're working in a structured deliberation tool, not a chat
- The `state.json` file is the durable artifact, not the transcript
- Output should be claim-shaped where possible
- Here's how to format mutations to state
- When uncertain, say so explicitly rather than guessing
- Disagreement with other agents is welcome and expected
- The human stays in control — we propose, they decide

Plan for this prompt to be 500–1000 tokens. Plan to revise it weekly. Plan for it to be the file you're proudest of and most embarrassed by simultaneously. The base system prompt is doing the work of *making the system feel like one product instead of three model APIs in a trench coat*.

### Role prompts

What the agent's job is in this conversation:

- **Skeptic** — find weaknesses, prefer pointed questions over confident assertions, surface assumptions the user hasn't named.
- **Researcher** — gather evidence, cite sources where possible, distinguish what's known from what's inferred.
- **Synthesizer** — collapse multiple agent responses into a consolidated view, surface disagreements rather than hiding them, propose updates to `state.json`.
- **Concretizer** — give specific examples, real-world analogies, edge cases.

The same provider/model can play multiple roles in a single session. Claude doesn't *become* a skeptic; Claude gets a system prompt that puts Claude in the skeptic role for that turn. So when the README says "agents" and the design discusses "providers" — strictly, *prompts* have roles, providers/models execute them. One Anthropic API key can run all roles backed by Claude.

### Mode prompts

What kind of pass this turn is:

- `blind_parallel` — same prompt to multiple agents, no cross-talk, results joined later.
- `critique` — review a previous turn's output for weaknesses.
- `red_team` — adversarial pass against a stated position.
- `research_review` — evidence-gathering, find supporting and contradicting sources.
- `synthesis` — collapse multi-agent output into one consolidated view.
- `debate_optional` — sequential cross-talk, used sparingly.

Mode is orthogonal to role. A skeptic can run in critique mode (critique someone else's claim) or red_team mode (attack a stated position). A researcher can run in research_review mode (gather evidence) or synthesis mode (consolidate findings). The cartesian product of roles and modes is large; not all combinations make sense. The ones that do, do.

### Project context

The current state of the idea, fed back into every call so agents can be coherent across turns. Two open design questions here:

- **How much state to include?** Including the full `state.json` blows up token counts; including too little means agents repeat themselves or contradict prior decisions. A summarized form (the `gist.md` or a structured extract) probably wins, with a "view full state" tool call as escape hatch.
- **Read-only or read-write?** Most agents see project context as read-only — they propose; the synthesizer mutates. The synthesizer is the only role with a prompt that says "here's the current state, here are the new responses, return the updated state." Keep that asymmetry strict.

### User turn — multiple kinds

The "user turn" from the model's perspective isn't always the human's prompt. There are several kinds:

| Kind | Example |
|---|---|
| Human-asked | "Is Think Tank worth building?" |
| Synthesizer-fed | "Here are 3 agent responses to '<original question>'. Produce updated state reflecting consensus, disagreements, new claims." |
| Glossary-trigger | "Define 'semantic zoom' in the context of this conversation. Capture as a glossary entry." |
| State-mutation | "User edited claim_003 manually. Validate consistency with the rest of state and flag anything affected." |
| Background-elaboration | "User flagged 'this needs more concrete examples.' Generate 3 concrete examples for claim_007." |

Each has its own template. The synthesizer-fed prompt is the most sophisticated and most consequential — it's the only one whose output changes durable state.

<img src="assets/divider-blueprint.svg" alt="" width="100%">

## The synthesizer is special

Of all the prompts in the system, the synthesizer's prompt is the one to obsess over.

Reasons:

- **It's the only role whose output mutates durable state.** Everyone else proposes; the synthesizer commits. A bad synthesizer prompt doesn't just produce a bad turn — it corrupts the project's accumulated knowledge.
- **It does the hardest cognitive work.** Reading multiple agent responses, identifying genuine consensus vs. surface agreement, surfacing disagreements that might be important, deciding which proposed claims belong in state and which are restatements of existing ones, deciding when to mark a claim superseded vs. when to add a new one.
- **It's the user's perceived quality of the whole product.** Users don't read every agent response. They read `state.json` and the summary files. Those are synthesizer output. Synthesizer quality dominates user-perceived quality.

Two design choices that follow:

**Separate "narrative synthesis" from "state mutation."** They're different jobs that get conflated by default. Narrative synthesis is "summarize what these agents said in prose for `gist.md`." State mutation is "propose specific edits to `state.json` based on what these agents said." Asking one prompt to do both produces worse output than asking two prompts to do one each. The first month's debugging will probably surface this; might as well design for it now.

**Make the synthesizer's provider/model configurable per project.** A user might want Claude as synthesizer (good at structured output, careful with state mutations) for some projects and GPT for others. The synthesizer is the one role where letting the user choose actually matters, because it's the only role whose mistakes accumulate.

<img src="assets/divider-blueprint.svg" alt="" width="100%">

## Prompt management — three stages

How prompts are stored and edited evolves through three stages. Each is only adopted when the previous one is fighting back.

### Stage 1: Hardcoded in `prompts.py`

```python
BASE_SYSTEM = """You are participating in Think Tank, a structured
deliberation tool. The durable artifact is state.json, not this
conversation. ..."""

ROLES = {
    "skeptic": "Your job is to find weaknesses in the user's reasoning...",
    "researcher": "Your job is to gather evidence and cite sources...",
    "synthesizer": "Your job is to consolidate multi-agent responses...",
}

MODES = {
    "critique": "Review the previous turn for weaknesses...",
    "red_team": "Argue against the stated position...",
    # ...
}
```

Every prompt change is a code change. That's a feature in stage 1, not a bug — you want code review and git history on prompts that matter this much.

**This is the right starting point.** Easy to read, easy to grep, easy to change. The worst case is "I want to experiment with prompts without editing source," and that pain shows up later, not earlier.

### Stage 2: Files in `~/.config/thinktank/prompts/`

```
~/.config/thinktank/prompts/
  base.md
  roles/
    skeptic.md
    researcher.md
    synthesizer.md
  modes/
    critique.md
    red_team.md
    synthesis.md
```

Now you can edit prompts without touching code, version-control them separately from the engine, and have per-project overrides ("this project's skeptic is more aggressive than the default").

The migration from stage 1 to stage 2 is straightforward: read prompt strings from files at startup, fall back to hardcoded defaults if files don't exist. ~50 lines.

### Stage 3: Prompts as part of project state

```
~/thinktank/<project>/
  prompts/
    skeptic.md         # this project's skeptic — overrides global
    synthesizer.md     # this project's synthesizer
  state.json
```

Prompts become part of the project, versioned alongside the work they shape. *"Which prompt produced this state mutation?"* becomes a question you can answer from git log.

Stage 3 is interesting because it makes prompt experimentation a first-class part of the workflow — you can fork a project, tweak its skeptic prompt, and watch how the deliberation changes. But it adds complexity (prompts come from three places now: per-project, per-user, hardcoded fallback) and most of the time you don't need it. **Defer until the case is proven by use.**

<img src="assets/divider-blueprint.svg" alt="" width="100%">

## Provider quirks

The "send the same prompt to N providers in parallel" pattern is really N slightly different operations, even with [aisuite](./stack-decisions.md) handling the dispatch.

A few things to watch for:

- **System prompt handling.** Anthropic treats the system prompt as a separate top-level field. OpenAI accepts it as the first message with `role: "system"`. Google has its own conventions. aisuite normalizes most of this, but provider-specific behavior around how heavily the system prompt is weighted varies.
- **Structured output.** Asking for JSON specifically works differently across providers. Some support a `response_format` parameter, some prefer "respond with JSON only" in the prompt itself, some have native tool-use APIs that produce structured output more reliably than free-text JSON. The synthesizer's state-mutation prompt cares about this a lot.
- **Refusals and safety.** Different providers refuse different things. A red-team prompt that works against Claude might trigger refusals on GPT, or vice versa. Plan for synthesizer logic that can distinguish "model refused" from "model produced unusable output."
- **Token limits and cost.** Even within the same nominal model, providers have different context windows, different output limits, and different pricing per token. The dispatcher should know each model's limits and surface meaningful errors when prompts blow past them.

The right place for provider-specific tweaks is a thin per-provider adapter layer that takes a unified prompt structure and applies provider-specific adjustments before the call. aisuite handles the basic dispatch; you write the adapter shim only when a specific quirk needs handling that aisuite doesn't expose.

<img src="assets/divider-blueprint.svg" alt="" width="100%">

## Agents start as config dicts

Until real use proves richer agent semantics earn their keep, "agent" is a config dict, not a domain object:

```python
agents = {
    "skeptic": {
        "role_prompt": "...",  # or path to prompts/roles/skeptic.md
        "preferred_provider_model": "anthropic:claude-opus-4-7",
        "fallback_provider_model": "openai:gpt-5",
    },
    "researcher": { ... },
    "synthesizer": {
        "role_prompt": "...",
        "preferred_provider_model": "anthropic:claude-opus-4-7",
        # synthesizer is special — see above
        "structured_output": True,
        "temperature": 0.2,  # lower for state mutations
    },
}
```

This is enough to make the abstraction feel real without committing to "agent" as a full domain object with lifecycle, persistence, and inheritance. If real use shows you want richer semantics — agents that learn, agents that share across projects, agents with their own memory — the dict grows. If it shows you don't actually need named agents at all, the dict goes away and we just compose role + mode + provider per turn.

See [`domain-model.md`](./domain-model.md) for the broader question of how agent semantics get decided.

<img src="assets/divider-blueprint.svg" alt="" width="100%">

## What to track during real use

A running notes file specifically about prompt iteration:

- [ ] Which prompts got rewritten most? Those are the load-bearing ones.
- [ ] Which prompt changes had the biggest quality impact? Often surprising.
- [ ] Did the base system prompt converge, or did it drift?
- [ ] Did the synthesizer need its prompt split into narrative vs. mutation?
- [ ] Did per-project prompts feel necessary, or was global enough?
- [ ] Did any provider-specific prompts emerge, or did one prompt work everywhere?
- [ ] Were there modes you predicted that turned out to be unused?
- [ ] Were there modes that emerged from use that you didn't predict?

These answers feed the stage 1 → stage 2 migration decision and the eventual schema decisions in Layer 3.

<img src="assets/divider-blueprint.svg" alt="" width="100%">

<div align="center">

*Companion doc to [README.md](./README.md). See also [`domain-model.md`](./domain-model.md) and [`stack-decisions.md`](./stack-decisions.md).*

</div>
