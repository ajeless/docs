<div align="center">

<img src="assets/divider-blueprint.svg" alt="" width="100%">

# Domain model

*Companion document to [README.md](./README.md). The discipline of letting Think Tank's vocabulary emerge from real use rather than committing to it up front.*

<img src="assets/divider-blueprint.svg" alt="" width="100%">

</div>

## What "domain model" means here

The domain model is the set of concepts the code treats as first-class — the nouns and verbs the system is built around, with rules about how they relate. In a code IDE, the domain model is `file`, `function`, `symbol`, `reference`, `diagnostic`. In an issue tracker, it's `issue`, `comment`, `label`, `assignee`, `state_transition`. The domain model isn't the database schema or the file format; those are *expressions* of it. The domain model is the conceptual vocabulary the entire system speaks.

For Think Tank, the candidate vocabulary includes:

**Nouns:** `project`, `agent`, `provider`, `mode`, `claim`, `question`, `assumption`, `decision`, `evidence`, `disagreement`, `glossary_entry`, `artifact`, `transcript`, `summary`, `change_log_entry`.

**Verbs:** `ask`, `elaborate`, `synthesize`, `supersede`, `commit`, `review`, `branch`.

The domain model is the answer to "which of these are real things in the system, and how do they relate?"

<img src="assets/divider-blueprint.svg" alt="" width="100%">

## Why "don't commit to it yet" is the right discipline

Each of those nouns *looks* obvious until you try to use it on a real problem, at which point edge cases warp the abstraction. The cost of getting the model wrong is the cost of refactoring everything that depends on it — and in a system this small, *everything* depends on the domain model.

A few examples of the kind of question only real use can answer:

### Is `claim` one thing, or three?

When an agent says *"I think X because Y"*, is that:

- one claim with embedded reasoning, or
- a claim plus a supporting argument, or
- a claim, an argument, and an inference rule connecting them?

When you write a note that says *"I'm leaning toward X"*, is that a `claim` or an `assumption` or a `decision-in-progress`?

Right now we don't know. We have intuitions. Two weeks of real use will tell us whether the intuitions hold or whether the abstraction needs to split or merge.

### Is `glossary_entry` separate from `claim`?

Both designs work:

- **Separate type.** `glossary_entry` is its own thing with `term`, `definition`, `captured_from`. Cleaner conceptually; requires more code to handle two types.
- **Same type with a flag.** A `glossary_entry` is just a `claim` with `type: "definition"`. Leaner; might collapse two genuinely different things into one bucket.

You won't know which is right until you've captured 30 of them and gone looking for one.

### Is `agent` a persistent thing, or a runtime label?

This is a *huge* design fork.

- **Persistent agents.** "I have an agent named 'skeptic' configured with this prompt and this provider." Lifecycle management, configuration, naming, sharing across projects. Agents are first-class objects.
- **Runtime labels.** "This turn used Claude with the skeptic prompt." No agent objects exist; "skeptic" is just a tag identifying which prompt template was used. Simpler.

The README *implies* persistent — "add agent skeptic" — but two weeks of use will tell you whether you actually want that or whether you'd rather just say "use Claude in skeptic mode this turn."

### What's the relationship between `mode` and `agent`?

All three of these are coherent designs:

- Mode is a property of an agent. *"The skeptic agent runs in critique mode."*
- Mode is a property of a turn. *"This turn is a critique pass, regardless of who runs it."*
- Mode is a property of a session. *"The whole conversation is in red-team mode."*

They produce different products. The right answer depends on whether modes feel like personalities (attached to agents), tactics (attached to turns), or contexts (attached to sessions).

### Does `transcript` need internal structure?

- **Dumb log.** Append-only JSONL of every model call. Structure entirely lives in `state.json`. Simpler.
- **Structured log.** Turns, threads, branches, references between turns. Now `state.json` and the transcript both claim to represent what happened, and they have to stay in sync.

Sync problems are the kind of bug that doesn't show up for two months and then never goes away.

### How does `artifact` relate to the other nouns?

With rich outputs as a first-class capability ([rich-outputs.md](./rich-outputs.md)), `artifact` is a real domain noun, not just folder content. Open questions:

- **Cardinality.** Does each claim get one canonical artifact, or can it have many? If many, how do they relate (variants? perspectives? generated-at-different-times)?
- **Ownership.** Is an artifact "owned by" the claim it represents, or is it a peer with a `represents` relationship? The latter is more flexible; the former is simpler.
- **Lifetime.** When the claim it represents is superseded, is the artifact also superseded, or just marked stale? When it's deleted, is the artifact deleted or archived?
- **Cross-referencing.** Can a single artifact represent multiple concepts (a project-wide mindmap)? If so, how does staleness propagate when only one of the represented concepts changes?

These don't have right answers yet. Real use will pressure-test the choices.

<img src="assets/divider-blueprint.svg" alt="" width="100%">

## What this means in practice

In the weekend prototype, `state.json` is a Python dict you `json.dump` and `json.load`. Not a Pydantic model with validators. Not a SQLAlchemy schema. Not a typed dataclass hierarchy. **Plain dict.**

```python
# Yes
state = json.loads(state_path.read_text())
state["claims"].append({"id": "claim_001", "text": "...", "status": "active"})
state_path.write_text(json.dumps(state, indent=2))

# Not yet
class Claim(BaseModel):
    id: str
    text: str
    status: ClaimStatus
    confidence: ConfidenceLevel
    supporting_evidence: list[EvidenceRef]
    objections: list[ObjectionRef]
    supersedes: list[ClaimRef]
    superseded_by: ClaimRef | None
    # ... 12 more fields
```

The Pydantic version is more correct in some abstract sense. It's also a commitment to a schema you don't yet have evidence for. The dict version is honest about how much you actually know.

> [!IMPORTANT]
> **The signal to extract an abstraction is when the same dict-massaging code shows up in three places.** Not two — two might be coincidence. Three is a pattern. When you find yourself writing `claim["status"] = "superseded"; claim["superseded_by"] = new_id; claim["updated_at"] = now()` in the third file, that's when `Claim.supersede(new_id)` earns its keep. Not before.

This is what "premature abstraction" actually means in practice. Not "don't ever abstract" — "don't abstract before you have the evidence to abstract correctly."

<img src="assets/divider-blueprint.svg" alt="" width="100%">

## Schema versioning from day one

One thing to commit to immediately, even though you're avoiding schema commitment generally: **`state.json` has a schema version field from the very first commit.**

```json
{
  "schema_version": 1,
  "project": { ... },
  "claims": [ ... ]
}
```

Migration is unavoidable. You will change the shape of `state.json` many times. Making migrations possible from day one is free. Adding versioning later, after the first dozen projects have schema-less state files, is annoying enough that people avoid migrations and the codebase calcifies around the original shape.

When the schema changes, write a migration function that takes a `schema_version: N` dict and returns a `schema_version: N+1` dict. Run all migrations on load. Done.

<img src="assets/divider-blueprint.svg" alt="" width="100%">

## The questions to answer in two weeks

Keep a running notes file during real use. The questions to track:

- [ ] Did `claim` need to split into multiple types, or did one type cover everything?
- [ ] Did `glossary_entry` end up feeling like a claim subtype or its own thing?
- [ ] Did "agents" want persistence, or were they fine as runtime labels?
- [ ] Did mode attach to agents, turns, or sessions in actual use?
- [ ] Did the transcript need structure beyond append-only, or was `state.json` enough?
- [ ] Did `artifact`-to-`claim` relationships feel one-to-one, many-to-many, or hierarchical?
- [ ] Were there nouns we didn't predict that turned out to matter?
- [ ] Were there nouns we predicted that turned out to be empty fields?
- [ ] Where did the code fight back? Those are the abstraction extraction points.

The answers to these become the basis for the schema commitment that happens in Layer 3.

<img src="assets/divider-blueprint.svg" alt="" width="100%">

<div align="center">

*Companion doc to [README.md](./README.md). See also [`prompts.md`](./prompts.md), [`stack-decisions.md`](./stack-decisions.md), and [`rich-outputs.md`](./rich-outputs.md).*

</div>
