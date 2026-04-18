# Author Types

This document describes the major creator personas the platform should eventually support.

These are not rigid user classes. They are design lenses that help clarify what kinds of tooling, abstraction, and access the platform may need.

## Why this matters

A central goal of the project is to avoid forcing every creator into the same mode of authorship.

Some people want to change assets or local behavior.
Some want to compose systems.
Some want to alter the substrate itself.

A platform that claims to be moddable should make room for all three.

## 1. Tinkerer

The tinkerer wants to create, remix, or personalize without digging into low-level implementation.

Typical goals:

- change effects, colors, sounds, assets, or local behaviors
- create lightweight scenarios or rulesets
- tune existing content
- build fun without managing deep engine concerns

What this persona likely needs:

- approachable tooling
- safe modification boundaries
- fast feedback
- expressive high-level interfaces
- little or no need to understand substrate internals

## 2. Systems Designer

The systems designer works at a deeper level than the tinkerer, but is not necessarily rewriting the substrate.

Typical goals:

- define gameplay rulesets
- compose mechanics and incentives
- configure persistence and realism profiles
- design economies, factions, or institutional mechanics
- tune how much simulation is direct vs abstract

What this persona likely needs:

- access to system composition tools
- clear mental models
- policy/profile authoring
- observability into outcomes
- enough power to shape worlds without requiring core-engine modification

## 3. Deep Forker

The deep forker wants to alter the platform itself.

Typical goals:

- change core runtime behavior
- swap or redesign simulation strategies
- alter substrate assumptions
- introduce new lower-level services or capabilities
- branch the project in fundamentally new directions

What this persona likely needs:

- a modular, inspectable codebase
- meaningful internal documentation
- explicit extension points
- freedom to replace deep components
- architectural clarity rather than only high-level convenience

## Other possible personas

As the project matures, other personas may prove important:

### Toolsmith
Builds authoring tools, debuggers, editors, exporters, or automation.

### World Host / Operator
Runs persistent or shared environments and cares about observability, policy, governance, and uptime.

### Research Prototyper
Builds isolated proofs of concept to test ideas without committing to a full implementation.

## Design implication

The platform does not need to provide all experiences equally at the beginning.

But it should avoid accidental architecture that only respects one persona while making the others second-class forever.
