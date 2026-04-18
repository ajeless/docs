# Feasibility Boundary

This document exists to keep the project grounded.

A recurring risk in a project like this is allowing useful metaphors to drift into claims that software cannot realistically satisfy. To avoid that, the project distinguishes between three categories of reality.

## 1. Hard Reality

Things the platform can directly enforce in software.

Examples:

- space and coordinates
- time progression
- collision and movement
- causality and event ordering
- information propagation rules
- ownership and permissions
- persistence policies
- simulation fidelity policies

This is the most technologically concrete layer. It is the domain of systems engineering, runtime architecture, data representation, and performance constraints.

## 2. Institutional / Mechanic Reality

Things the platform can strongly shape through explicit rules, incentives, constraints, and protocols.

Examples:

- faction systems
- governance mechanics
- tax or fee structures
- markets and auction rules
- crafting transforms
- scarcity and spawn policy
- reputation mechanisms
- witness or gossip mechanics
- communication topology

This is still software, but it is not reality in the same sense as space or collision. It is better understood as the authored rule-structure within which behavior unfolds.

## 3. Emergent Reality

Things that arise from repeated interaction among humans and agents inside the first two categories.

Examples:

- culture
- trust
- prestige
- etiquette
- black markets
- alliances
- betrayal
- myths
- local norms
- “vibe”

These are not directly encoded by the platform. They are the result of interaction over time.

## The practical rule

The platform directly implements the first category, strongly shapes the second, and only hosts the conditions for the third.

That means:

- do not promise to “encode society”
- do not confuse mechanics with culture
- do not assume that a reputation variable equals trust
- do not assume that a market model equals a living economy

## Why this matters

This distinction prevents two failure modes:

### 1. Vaporware drift

When everything is treated as a “law,” the project can start sounding omnipotent. That is intellectually seductive and technically dangerous.

### 2. Category confusion

Gravity and a tax system are not the same kind of thing. A chat permission model and a culture of mutual aid are not the same kind of thing. The platform should not pretend otherwise.

## A note on AI agents

AI agents complicate the picture in an interesting way.

They are not magic social reality generators. But they can meaningfully participate in the world by acting as:

- traders
- witnesses
- bureaucrats
- rumor spreaders
- logistics actors
- service providers
- simulated populations
- story participants

That means they may help create pressure inside emergent systems without eliminating the distinction between mechanics and emergence.

## Feasibility discipline for future docs

When proposing a feature, ask:

1. Is this software-enforceable?
2. Is this an authored mechanic or institutional rule?
3. Is this an emergent outcome that the platform can only host, not guarantee?

If a proposal mixes these without distinction, it should be revised.
