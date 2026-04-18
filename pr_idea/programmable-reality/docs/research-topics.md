# Research Topics

This document tracks major research fronts suggested by the project’s current mental model.

These are not implementation commitments. They are areas where research, prototypes, and comparative study could sharpen the vision.

## 1. Spatial representation and scale

Questions:

- How should large-scale coordinates be represented?
- What models best support locality and seamless transitions?
- How should nested frames of reference be understood?

Candidate areas to explore:

- floating origin strategies
- hierarchical coordinate systems
- fixed-point vs floating-point tradeoffs
- nested reference frames
- locality-aware streaming
- large-world runtime techniques

Prototype ideas:

- small proof of concept for nested coordinate handoff
- observer-centered coordinate rebasing demo
- local bubble activation around one or more observers

## 2. Variable simulation fidelity

Questions:

- What should be simulated directly?
- What can be abstracted?
- When should the system promote or demote fidelity?

Candidate areas to explore:

- level-of-detail concepts for logic, not just graphics
- interest management
- direct vs abstract simulation
- reconstruction from deltas or summaries
- staged world activation

Prototype ideas:

- active vs dormant entity registry benchmark
- abstract background simulation for distant entities
- scoped promotion/demotion rules driven by observation

## 3. Information and observability

Questions:

- What should authors be able to configure about information flow?
- How should visibility, sensing, delay, and transmission be modeled?

Candidate areas to explore:

- line of sight and sensor models
- configurable propagation delay
- hidden state and fog-of-war concepts
- information asymmetry as authored design primitive
- multiplayer synchronization vs in-world information rules

Prototype ideas:

- configurable signal delay in a small networked testbed
- observer-driven visibility model
- world rules where information speed affects tactics

## 4. Persistence and world memory

Questions:

- How much should worlds remember?
- What should be stored directly, what should decay, and what should be reconstructed?

Candidate areas to explore:

- session-based worlds vs persistent worlds
- event sourcing and deltas
- reconstruction from seeds plus changes
- decay policies
- persistence profiles

Prototype ideas:

- persistence policy matrix: ephemeral, impact-only, deep
- world reconstruction from seed plus event history
- unattended world evolution rules

## 5. Authoring and creator experience

Questions:

- What should tinkering look like?
- What should systems design look like?
- What should deep substrate access look like?

Candidate areas to explore:

- layered tooling
- editable profiles and policies
- scenario authoring vs substrate programming
- safe extension points
- high-level world configuration languages

Prototype ideas:

- human-readable reality profile format
- simple “systems designer” configuration for persistence and information policies
- sample workflow comparisons for different author types

## 6. AI orchestration and participation

Questions:

- What roles should AI play?
- Where does AI reduce complexity?
- Where does it create ambiguity or loss of control?

Candidate areas to explore:

- AI-assisted prewarming and handoff
- fidelity management
- background world simulation
- agent participation in economies or institutions
- agent tooling for creators

Prototype ideas:

- simple agent deciding what to activate near an observer
- witness/gossip mechanic driven by agents
- background logistics agents affecting resource availability

## 7. Multiplayer and shared reality

Questions:

- What should shared reality mean across scale and locality?
- How should the platform support both private sessions and larger shared worlds?

Candidate areas to explore:

- observer-centric synchronization
- local/private worlds vs hosted worlds
- authority models
- scope-aware replication
- consistency tradeoffs

Prototype ideas:

- two-observer locality model
- scoped synchronization demo
- export/import between ephemeral and persistent worlds

## 8. Data model and runtime architecture

Questions:

- What data model best matches the platform’s goals?
- How should runtime concerns be separated from authored concerns?

Candidate areas to explore:

- ECS-style designs
- data-oriented design
- event-based state transitions
- modular service architecture
- runtime observability and debugging

Note:
No commitment has yet been made to a specific implementation language or engine architecture. References to Zig, Rust, C++, ECS, or similar approaches should be treated as candidate directions, not decisions.

## 9. Comparative precedents

Questions:

- Which existing systems demonstrate pieces of this vision?
- Which combinations remain missing in open, moddable form?

Candidate comparative targets:

- large-scale/world-streaming game architectures
- moddable simulation games
- persistent sandbox worlds
- ECS/data-oriented runtimes
- open-source engines and mod platforms

Goal:
Understand what has already been demonstrated, what remains proprietary, and what is still largely unexplored in unified form.

## Research posture

This document is not a roadmap in the project management sense.

It is a set of research fronts meant to inform later decisions, prototypes, and repo structure.
