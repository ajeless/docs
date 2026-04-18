# Ontology Draft

This document captures a first pass at the platform’s “universal grammar of reality.”

These definitions are intentionally provisional. The goal is to create shared language for ideation, research, and future prompting.

## Why ontology matters

Without shared nouns, the project risks talking past itself.

A good ontology will not solve the architecture, but it will make architectural discussion more coherent.

## Core nouns

### Entity

A unit of existence in the world.

Examples may include:

- a rock
- a vehicle
- a door
- a projectile
- a player avatar
- a planet
- possibly a zone, marker, or abstract world object

Open question: should all of these be entities in the same sense, or do some belong to different categories?

### Actor

An entity capable of initiating or participating in actions.

Examples:

- player-controlled characters
- AI agents
- autonomous systems
- possibly organizations or abstract controllers, depending on model depth

### Observer

A center of observation or active relevance.

Examples:

- a player
- an AI agent
- a camera
- a simulation authority
- possibly a sensor network

Why it matters: observation may affect what becomes high-fidelity, visible, synchronized, or “real enough” to simulate directly.

### Component

Data attached to an entity.

Examples:

- position
- velocity
- ownership
- health
- power level
- faction
- inventory
- visibility state

This term is especially useful if the platform eventually adopts an ECS-like model, but the word may still be useful even before that decision exists.

### System

Logic that processes state and causes change.

Examples:

- movement
- gravity
- damage
- trade
- communication
- perception
- weather
- decay

Open question: should “system” include both low-level runtime systems and higher-level authored rule systems, or should those be distinguished?

### Event

A meaningful occurrence or state transition.

Examples:

- an object collides
- a message is sent
- a sensor detects a target
- a market order is filled
- a rule threshold is crossed

### Law

A rule, constraint, or transformation that governs how systems behave within a scope.

Examples:

- gravity is weaker in this region
- information cannot exceed a configured propagation speed
- objects tagged as contraband trigger inspection
- energy weapons behave differently in vacuum

Open question: should “law” be reserved for low-level world rules, while other categories use words like policy, mechanic, or institution?

### Scope

The where/when/for-whom boundary within which a rule applies.

Examples:

- a world
- a zone
- a vehicle interior
- a faction-controlled region
- a time window
- a simulation layer
- a single authored experience

### World

A coherent authored or hosted reality instance.

A world may be:

- ephemeral or persistent
- local or shared
- tiny or vast
- realistic or fantastical

Open question: what is the relationship between world, shard, simulation instance, and authored experience?

### Reality Profile

A higher-level authored configuration that bundles multiple rules and policies.

Examples:

- tactical high-determinism profile
- arcade mobility profile
- low-persistence session profile
- delayed-information profile

This term may become useful if the platform needs creator-friendly packaging of many lower-level settings.

## Core verbs

These are not exhaustive, but they suggest the kinds of actions the platform may care about.

- exist
- observe
- move
- collide
- transmit
- perceive
- change
- remember
- forget
- decay
- construct
- destroy
- delegate
- reconstruct
- synchronize
- authorize

## A useful distinction

Not every rule should be called a law.

Candidate split:

- **law** for deep or world-defining rules
- **policy** for platform or runtime behavior choices
- **mechanic** for authored gameplay/institutional rules
- **constraint** for scoped limitations
- **profile** for bundles of choices

This distinction may help keep language precise as the project matures.

## Current status

This ontology is only a draft.

Its purpose is not to lock terminology. Its purpose is to give humans and coding agents a common starting language for exploration.
