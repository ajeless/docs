# Resolver design — v0.1

**Status:** decided (architecture), draft (specific event schemas)
**Scope:** v0.1 vertical slice
**Last updated:** 2026-04-20

## Summary

The resolver is a pure TypeScript module that takes a battle state and both players' plots and returns the next state plus a sequence of replay events. It uses discrete sub-tick simulation (60 sub-ticks per turn), server-authoritative execution at v0.1, and floating-point math with upgrade paths to fixed-point preserved. The resolver is the heart of the game; everything else feeds into it or consumes its output.

## The resolver's contract

The resolver is a single pure function:

```
resolve(state, plotA, plotB, seed) → (nextState, events)
```

- **Inputs:** current battle state, plot submissions from both players, a deterministic seed.
- **Outputs:** the battle state at the end of the turn, and an ordered list of replay events describing what happened during the turn.
- **Side effects:** none. No network calls, no file I/O, no wall-clock reads, no UI dependencies, no logging to external systems.

This purity is the most important property of the whole codebase. It's what makes every upgrade path in the stack decision doc possible. The resolver doesn't know whether it's running on a server, a client, a test runner, or a CI job. It takes data in, returns data out.

## Why purity matters

A pure resolver enables:

- **Server-authoritative play** (the v0.1 model) — the host's server calls the resolver and broadcasts events.
- **Client-side resolution later** — the same resolver runs in the browser for offline play, single-player, or replay scrubbing.
- **Peer cross-checking later** — both peers run the resolver on identical inputs and compare hashes.
- **Deterministic replays** — a recorded plot log plus the seed reproduces the battle exactly.
- **Unit testing** — the resolver is testable without any game infrastructure running.
- **Debugging** — any bug is reproducible from inputs alone.

Anything that compromises purity compromises all of these at once.

## Sub-tick structure

A turn is divided into **60 discrete sub-ticks**.

- The player never sees this number. It's an internal simulation detail.
- The turn's real-world duration at playback is independent; the animation player maps sub-ticks to wall-clock time at whatever playback speed the player chooses.
- 60 is chosen as the sweet spot: fine enough that quantization is invisible on a minimalist tactical display, coarse enough to keep the event log small and CPU cost trivial. The number is a tunable constant, not a commitment.

### The sub-tick loop

For each sub-tick from 0 to 59, the resolver runs six phases in order:

1. **Intent** — read the plot commands scheduled for this sub-tick for each ship (thrust vectors, weapon fire attempts, standing orders).
2. **Dynamics** — advance each ship's velocity (applying thrust) and position. Physical properties (mass, moment of inertia) come from the ship definition. Damaged systems may reduce effective capability.
3. **Sensing** — update computed values for each ship-pair: range, bearing, relative velocity, sensor state (detected, tracked, locked, or unknown).
4. **Events** — evaluate scheduled weapon fires. For each attempt, check firing conditions (in arc, in range, mount ready, power available, target acquired). If satisfied, resolve the shot — compute damage, select impacted system, apply damage.
5. **State updates** — apply damage consequences (subsystem offline, reactor output reduced, drive thrust reduced). Check destruction conditions.
6. **Log** — append all events emitted this sub-tick to the replay log with timestamp T.

Each phase is pure and self-contained. The whole sub-tick is a function `(stateIn, plots) → (stateOut, newEvents)`. Composing 60 of these gives a turn resolution.

## The event format

An event is a structured record:

```typescript
{
  sub_tick: number;           // 0..59
  type: string;               // event type discriminator
  actor?: string;             // ship id, if applicable
  target?: string;            // ship id, if applicable
  details: object;            // type-specific payload
}
```

The event log is an ordered list of events produced during a turn. Each event has enough data to be both **rendered** (the animation player consumes it to draw the turn) and **audited** (a debugger can reproduce the computation from the log).

## Event types at v0.1

Seven types. Each is specified here in enough detail that an implementer can produce a faithful TypeScript interface.

### `plot_committed`

Emitted at sub-tick 0 for each ship. Records the plot as accepted by the resolver, so replays can show what each player intended independent of what actually happened.

```
{ type: "plot_committed", actor: shipId, details: { plot: <plot object> } }
```

### `thrust_applied`

Emitted whenever a ship's velocity changes due to thrust. May be emitted every sub-tick during active thrust.

```
{ type: "thrust_applied", actor: shipId, details: {
    thrustVector: { x, y },
    resultingVelocity: { x, y },
    resultingPosition: { x, y }
  } }
```

Position is included for renderer convenience, even though it's recoverable from the resolver's state; redundancy is cheap in event logs and saves the renderer from maintaining parallel state.

### `weapon_fired`

Emitted when a weapon successfully fires.

```
{ type: "weapon_fired", actor: shipId, target: shipId, details: {
    mountId: string,
    mountPosition: { x, y },     // world coordinates at fire time
    targetPosition: { x, y },    // world coordinates at fire time
    damageRolled: number
  } }
```

### `hit_registered`

Emitted when a hit is resolved on a target ship.

```
{ type: "hit_registered", target: shipId, details: {
    fromActor: shipId,
    impactPoint: { x, y },       // world coordinates
    impactSystemId: string,      // which system absorbed the hit
    damageApplied: number
  } }
```

At v0.1, damage resolution is simple: the weapon's damage value is applied to the target's hull, and if the impact point is near a specific system, that system is flagged for damage consequences.

### `subsystem_damaged`

Emitted when a system's state changes.

```
{ type: "subsystem_damaged", actor: shipId, details: {
    systemId: string,
    previousState: "operational" | "damaged" | "destroyed",
    newState: "operational" | "damaged" | "destroyed"
  } }
```

At v0.1, states are binary (operational or destroyed, with "damaged" reserved for later slices that introduce graded health). The field is a string enum to avoid re-schema-ing when graded states arrive.

### `ship_destroyed`

Emitted when a ship reaches zero hull.

```
{ type: "ship_destroyed", target: shipId, details: {
    causeActor: shipId,
    finalPosition: { x, y }
  } }
```

### `turn_ended`

Emitted at sub-tick 60 (one past the last simulated sub-tick) to mark the end of the turn.

```
{ type: "turn_ended", details: {
    turnNumber: number,
    winner: shipId | null       // null if no winner yet
  } }
```

## Plot submission format

A plot is the input from one player for one turn. Its rough shape:

```typescript
{
  shipId: string;
  thrust: Array<{
    sub_tick: number;            // 0..59
    vector: { x: number, y: number };
  }>;
  weapons: Array<{
    mountId: string;
    fire: boolean;               // simple v0.1 intent; fires as soon as conditions met
  }>;
}
```

Thrust is specified per-sub-tick. The planning UI exposes coarser controls (draggable handles, total thrust budget) and translates them into per-sub-tick values. This means the resolver's input format doesn't constrain how sophisticated the planning UI gets — new UI affordances translate down to the same per-sub-tick schema.

Weapons at v0.1 are simple: the player marks which mounts are permitted to fire; the resolver fires them at the first sub-tick where firing conditions are met. No "fire at sub-tick X" specificity at v0.1 — the conditional/standing-order language arrives in a later slice.

## Determinism discipline

The resolver must produce bit-identical outputs given bit-identical inputs, so that:

- Replays always play back the same way.
- Future peer cross-checking works when added.
- Debugging is reproducible from recorded inputs.

The rules:

- **No wall-clock reads inside the resolver.** Ever. Time is measured in sub-ticks, not milliseconds.
- **No system RNG.** All randomness uses a seeded, deterministic stream derived from the turn's seed. The seed is part of the resolver's input.
- **Explicit iteration order.** When iterating over a collection of ships, systems, or events, iterate in sorted order by `id`. Never rely on `Map` or `Set` insertion order implicitly; sort explicitly before iterating.
- **No floating-point transcendentals where avoidable.** IEEE 754 basic operations (+, -, \*, /, sqrt) are reliable across implementations. `sin`, `cos`, `tan`, `atan2`, `exp`, `log` are not guaranteed to produce bit-identical results across engines. When needed (e.g., rotations), prefer precomputed tables or bounded-precision polynomial approximations. At v0.1 with server-authoritative play only, this is aspirational — the resolver runs on one machine, so cross-implementation consistency doesn't bite yet. But the discipline is established now so it doesn't have to be retrofitted later.
- **No shared mutable state between calls.** The resolver doesn't keep any memory across invocations. Every call is independent.

### Fixed-point vs. floating-point

At v0.1: **floating-point (f64) is fine.** Server-authoritative play means only one implementation of the resolver ever runs for a given match. Cross-platform determinism isn't required.

**Reserved upgrade path:** if a future slice needs peer cross-checking or cross-platform replay reproducibility, the resolver's math is migrated to fixed-point. Because the resolver is a well-isolated module, this migration is bounded work — probably a few weeks of focused effort. The cost of choosing floating-point now is that migration cost, paid only if it's ever justified.

## Where the resolver runs

At v0.1: **only on the host's server.**

- The host collects both players' plots over WebSockets.
- The host calls the resolver.
- The host broadcasts the resulting events to both clients.
- Each client renders the events.

This is "Option B" from the resolver discussion — server-authoritative execution. Simplest possible model; no determinism concerns across machines because only one machine computes.

### Preserved upgrade paths

The resolver's purity means the following are all reachable without changing the resolver itself:

- **Client-side prediction.** Client runs the resolver speculatively on the local plot while waiting for server authority.
- **Peer cross-checking.** Both peers run the resolver; hashes compared.
- **Fully offline play.** The client invokes the resolver locally against a local AI's plot.
- **AI opponents.** An AI module produces plot submissions like any other player.
- **Hot-seat.** Both plots collected on one device, resolver runs locally.
- **Headless simulation / batch AAR generation.** The resolver can be called from scripts for game balancing or AI training.

None of these require the resolver to know they exist. The networking and UI layers around the resolver change; the resolver doesn't.

## Testing strategy

The resolver is the most test-worthy module in the codebase. Tests live alongside it as `.test.ts` files using Vitest (from the stack decision).

**Categories of test:**

- **Unit tests per event type.** Given a setup, does the right event fire with the right payload?
- **Unit tests per sub-tick phase.** Does dynamics update positions correctly? Does sensing compute range correctly?
- **End-to-end turn resolution tests.** A handcrafted plot, a handcrafted state, the expected event log. Run the resolver, assert the log matches.
- **Determinism tests.** Run the same inputs twice; assert outputs are bit-identical. Run them 1000 times in a loop; assert no drift.
- **Invariant tests.** After any turn resolution, hit points never go negative, positions are finite, velocities are finite, ship counts are conserved unless destruction events happened.

Shared between server and client, so the resolver is tested identically on both sides. Any test that passes on the server must pass on the client.

## Module boundaries and file layout

The resolver lives in a shared folder imported by both server and client. Rough layout:

```
shared/
  resolver/
    index.ts           # public API: the resolve() function
    types.ts           # Plot, Event, State, etc.
    sub_tick.ts        # the sub-tick loop
    phases/
      intent.ts
      dynamics.ts
      sensing.ts
      events.ts
      state_updates.ts
      logging.ts
    validation.ts      # input validation
    determinism.ts     # seeded RNG, sorted iteration helpers
    resolver.test.ts   # tests
```

The server imports `shared/resolver` and calls it. The client imports `shared/resolver` only if and when client-side resolution becomes needed (v0.1 doesn't exercise this, but the option is preserved).

Nothing outside the `resolver/` folder reaches into it. Nothing inside the folder reaches out (no imports from `server/` or `client/` folders).

## Not decided / deferred

- **The specific physics model for dynamics.** At v0.1, the dynamics phase assumes simple Newtonian point-mass physics: `velocity += thrust / mass * dt`, `position += velocity * dt`. More sophisticated models (torque, rotational dynamics, drag near nebulae) arrive with later slices.
- **Collision handling.** At v0.1, ships are point masses with no collision checking. Later slices add collision detection; the sub-tick phase structure already has a natural place for it (a new phase between Dynamics and Sensing).
- **Sub-tick count.** 60 is a starting value. May be tuned up (120 for finer precision) or down (30 for simpler games) based on playtest feel.
- **Turn duration.** In-fiction, a turn represents some amount of simulated time (probably 10-30 seconds). The exact mapping from sub-ticks to in-fiction time is a balance decision, not an architecture decision.
- **Damage model sophistication.** At v0.1, a hit applies a fixed damage value to hull and possibly flags a system as destroyed. Later slices introduce damage spread, armor, subsystem-specific vulnerability, and so on.
- **The seed source.** At v0.1, the seed can be as simple as a hash of the match ID plus the turn number. Production-grade seeding (for tournament play, adversarial robustness) is a future concern.
- **Event versioning.** The event format may grow new fields. A `version` field on the event log is probably wise eventually; not worth it at v0.1 with one ship type and seven event types.

## Related docs

- `stack_decision.md` — language, networking, and deployment context.
- `ship_definition_format.md` — the data the resolver consumes.
- `ssd_layout.md` *(next)* — the renderer that consumes the resolver's events.
- `idea_capture.md` (in sibling folder) — preserved design context, not binding.