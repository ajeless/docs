# Programmable Reality

An open-source, community-driven platform for creating and modding interactive worlds where authors can configure not just content, but the behavior, scale, fidelity, persistence, and information rules of reality itself.

This is not a single game, and not just a conventional game engine.

It is a platform for **authored realities**: small local co-op sessions, tactical simulations, immersive open worlds, experimental art projects, and eventually large community-run universes can all be built on the same underlying substrate.

---

## Status

This project is currently in the **ideation and research phase**.

The goal right now is not to rush into implementation or prematurely lock in architecture. The goal is to develop a coherent conceptual model, a grounded technical vocabulary, and a research roadmap that can later guide coding agents, prototypes, and eventual implementation.

Where possible, this repo separates:

- **vision**
- **working mental models**
- **ideas and hypotheses**
- **research directions**
- **open questions**
- **decisions** (when they actually exist)

That distinction matters. Much of what is written here is intentionally exploratory.

---

## The core idea

Most engines let creators build content inside a largely fixed simulation model.

This project aims at something broader:

**a platform where creators can author not only worlds and experiences, but the rules by which those worlds behave.**

That includes the ability to configure, per world or experience:

- how space is represented and traversed
- how simulation is performed directly versus abstracted
- how information propagates
- how much the world remembers
- how much behavior is deterministic versus agent-managed
- how deeply the experience can be modded
- how “realistic,” “arcade,” “tactical,” or “fantastical” a reality should feel

The same substrate should be capable of supporting:

- a small ephemeral local co-op game
- a tightly authored tactical scenario
- an immersive seamless world
- a persistent community-run simulation

without requiring a completely different mental model for each.

---

## Why this exists

Current tools often force creators into one or more of these tradeoffs:

- small scale vs massive scale
- realism vs accessibility
- polished gameplay vs deep moddability
- authored experience vs emergent systems
- high-performance substrate vs community-driven openness

This project explores whether a different kind of platform can reduce those tradeoffs by treating core aspects of reality itself as configurable.

The long-term aspiration is not “one perfect game,” but a **shared, open substrate for many different kinds of playable realities**.

---

## Working mental model

The current top-level framing is:

- **Programmable Reality** is the vision
- **Spatial OS** is one important subsystem inside that vision, not the whole thing

“Spatial OS” is useful as a working idea for handling scale, locality, nested reference frames, streaming, and seamless handoffs between contexts.

But the broader project is not only about space. It is about programmable reality more generally.

That likely includes several major layers or subsystems:

- **Spatial OS**  
  Coordinates, locality, nested reference frames, scale management, streaming, seamless transitions

- **Reality Kernel**  
  Hard world rules: time, causality, simulation execution, state transition, and possibly core system orchestration

- **Information Layer**  
  What can be known, seen, heard, transmitted, sensed, delayed, hidden, or propagated

- **Persistence Layer**  
  What the world remembers, forgets, abstracts, reconstructs, or evolves over time

- **Authoring Layer**  
  Tools and interfaces for different kinds of creators, from tinkering to deep systems work

- **Agent Orchestration Layer**  
  AI-managed abstraction, handoffs, background simulation, fidelity management, and possibly active participation inside worlds

These are **working conceptual buckets**, not final architecture.

---

## A grounded feasibility boundary

A central concern of this project is avoiding conceptual drift into vaporware.

To stay grounded, the project distinguishes between three categories:

### 1. Hard Reality

Things the platform can directly enforce in software.

Examples:

- space and coordinates
- time progression
- collision and movement
- causality and event ordering
- information propagation
- ownership and permissions
- persistence policy
- simulation fidelity rules

### 2. Institutional / Mechanic Reality

Things the platform can strongly shape through rules, costs, incentives, and constraints.

Examples:

- faction systems
- resource scarcity
- crafting transforms
- taxes and fees
- governance mechanics
- communication topology
- reputation or witness systems
- trade rules and market structure

### 3. Emergent Reality

Things that arise from repeated interaction among humans and agents.

Examples:

- culture
- trust
- status
- group norms
- betrayal
- black markets
- myths
- local etiquette
- “vibe”

The platform directly implements the first, strongly shapes the second, and only hosts the conditions for the third.

This distinction is important. The project does **not** assume that software can fully encode human society, culture, or meaning.

---

## Design principles

- **Open source and community-driven**
- **Modding-first**, not modding-as-an-afterthought
- Support both **small local experiences** and **large persistent worlds**
- Support both **low-friction tinkering** and **deep forking**
- **Persistence should be configurable**, not assumed
- **Realism should be configurable**, not assumed
- The same conceptual model should scale across wildly different experiences
- Ideas should remain explicitly exploratory until enough research exists to justify decisions
- The project should prefer **clear vocabulary and explicit boundaries** over hype

---

## Author types

At minimum, the platform should support several layers of creators:

### Tinkerer

Makes local changes to effects, assets, behaviors, and authored experiences without needing deep systems access.

### Systems Designer

Composes rules, constraints, simulation profiles, world behaviors, institutional mechanics, and interaction models.

### Deep Forker

Modifies substrate or kernel-level behavior and may alter the platform itself.

A major goal is to give all three a first-class experience, even if they interact with the platform very differently.

---

## Current ideas under exploration

These are not decisions. They are active lines of thought.

- treating persistence as a **slider or policy layer**, not a binary
- treating realism as a **profile or authored configuration**, not a fixed assumption
- using **locality and nested reference frames** to approach scale
- allowing **variable information propagation** as both a systems tool and gameplay primitive
- delegating some simulation and handoff work to **AI-assisted orchestration**
- distinguishing between **direct simulation**, **abstract simulation**, and **agent-managed approximation**
- supporting both **ephemeral private worlds** and **shared persistent worlds**
- building around a **universal grammar of reality** rather than starting from engine features alone

---

## What this is not

- not a metaverse pitch
- not locked to one genre
- not locked to one realism model
- not necessarily a single global persistent universe
- not a claim that every aspect of human reality can be encoded directly in software
- not yet a settled architecture
- not yet an implementation plan

---

## Open questions

This repo exists largely to refine questions like these:

1. What exactly counts as a programmable “law” of reality?
2. What are the core nouns of the system: entity, actor, observer, system, event, law, scope, world, reality?
3. What belongs in the kernel versus higher-level authored layers?
4. How should persistence work: off/on, slider, policies, or layered profiles?
5. How should realism, abstraction, and AI handoff be specified by authors?
6. What is the boundary between deterministic simulation and agent-managed approximation?
7. How should multiplayer/shared reality work across distance and scale?
8. What is the minimum viable form of this platform?
9. What should the creator experience look like for each author type?
10. What should be treated as research hypotheses versus architectural commitments?

---

## Documentation map

This README is only the entry point.

Deeper discussion, nuance, working theories, and unresolved ideas live in linked documents so the repo remains approachable without losing conceptual depth.

- [`docs/index.md`](docs/index.md)  
  Documentation overview and reading path

- [`docs/vision.md`](docs/vision.md)  
  Longer-form statement of the vision and why this project exists

- [`docs/principles.md`](docs/principles.md)  
  Non-negotiable design principles and guardrails

- [`docs/mental-model.md`](docs/mental-model.md)  
  Current conceptual framing: programmable reality, spatial OS, layers, and service boundaries

- [`docs/feasibility-boundary.md`](docs/feasibility-boundary.md)  
  Hard reality vs institutional/mechanic reality vs emergent reality

- [`docs/author-types.md`](docs/author-types.md)  
  Tinkerer, systems designer, deep forker, and adjacent personas

- [`docs/open-questions.md`](docs/open-questions.md)  
  The most important unresolved questions

- [`docs/ontology.md`](docs/ontology.md)  
  Draft universal grammar: entity, system, law, event, scope, observer, actor

- [`docs/research-topics.md`](docs/research-topics.md)  
  Research directions, technical precedents, candidate technologies, and prototype ideas

- [`docs/ideas/first-conversation-synthesis.md`](docs/ideas/first-conversation-synthesis.md)  
  Preserved synthesis of the early ideation without turning it into doctrine

- [`docs/ideas/README.md`](docs/ideas/README.md)  
  How speculative notes should be captured

- [`docs/decisions/README.md`](docs/decisions/README.md)  
  How actual decisions should be recorded once they exist

- [`REPO_TREE.txt`](REPO_TREE.txt)  
  Snapshot of the starter repo structure

---

## Repo philosophy

This repo should preserve nuance without pretending that every thought is a decision.

A useful rule of thumb:

- **README** explains the project
- **docs/** explores the project
- **docs/ideas/** preserves speculative thinking
- **docs/decisions/** records commitments
- **research notes** gather evidence and technical grounding

That separation should make it easier for both humans and coding agents to participate without flattening everything into premature certainty.

---

## Immediate next step

Define the project’s **universal grammar of reality** in plain language:

- What can exist?
- What can happen?
- What rules can be authored?
- Where and when do those rules apply?
- What is simulated directly?
- What is abstracted?
- What is delegated?
- What is remembered?
