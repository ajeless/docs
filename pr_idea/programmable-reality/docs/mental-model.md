# Mental Model

This document captures the current conceptual framing of the project. It is a map for thinking, not a final architecture.

## The top-level idea

The best current umbrella term is **Programmable Reality**.

That framing is broader and more accurate than “game engine,” because the ambition is not only to build content or simulate objects. It is to create a platform where authors can shape core properties of a world, including scale, simulation, information, memory, and modifiability.

## Spatial OS as subsystem, not whole identity

“Spatial OS” remains a useful mental model, especially for:

- locality
- scale
- coordinate representation
- nested reference frames
- streaming
- transitions between contexts

But it should be treated as one important subsystem inside the larger vision, not as the full identity of the project.

## Working conceptual buckets

These buckets are not final layers. They are current areas of thought.

### Spatial OS

A working concept for how the platform handles:

- coordinates
- locality
- scale
- nested frames of reference
- seamless movement between contexts
- streaming and world activation

### Reality Kernel

A working concept for the platform’s most software-enforceable rules.

Likely responsibilities include:

- time progression
- state transition
- causality/order of events
- simulation execution
- possibly core orchestration of lower-level services

### Information Layer

A working concept for what can be observed or transmitted in a world.

This includes questions like:

- what can be known
- what can be seen or heard
- how fast information propagates
- how delayed, hidden, or lossy information should be
- whether observation itself changes what must be simulated

### Persistence Layer

A working concept for how the world remembers.

This includes questions like:

- what is saved
- what decays
- what is reconstructed
- what is abstracted while unattended
- whether persistence is absent, partial, or deep

### Authoring Layer

A working concept for how different creators interact with the platform.

This includes:

- low-friction modification
- systems composition
- high-level world authoring
- deep substrate forking

### Agent Orchestration Layer

A working concept for AI-assisted management of complexity.

Possible roles include:

- fidelity management
- handoff between direct and abstract simulation
- background world evolution
- reconstruction and prewarming
- world participation as actors, witnesses, administrators, or populations

## A useful distinction: reality, simulation, experience

One reason the conversation advanced was that it became helpful to separate three things that often get blurred together.

### Reality

What rules exist.

### Simulation

How those rules are executed in software.

### Experience

What the author and player actually feel.

These are connected, but not identical. Two worlds may share similar simulation strategies while producing very different experiences. Likewise, two worlds may feel similar while relying on very different underlying rules.

## Candidate tensions to keep watching

The current model contains several useful tensions that should not be prematurely “resolved” by naming alone:

- deterministic vs agent-managed
- direct simulation vs abstract simulation
- local simplicity vs global scale
- ephemeral sessions vs deep persistence
- grounded realism vs authored impossibility
- openness to deep forks vs coherent shared tooling

These tensions are not design failures. They may be part of the core design space.

## Current confidence level

High confidence:

- “Programmable Reality” is a better umbrella than “game engine.”
- “Spatial OS” is helpful, but narrower than the full vision.
- The project benefits from thinking in terms of services, policies, and scopes rather than one monolithic world model.

Lower confidence:

- whether the current bucket names will survive
- whether “kernel” is the right metaphor
- which concerns are true layers versus cross-cutting concerns
- how much AI should be conceptualized as orchestration versus participation
