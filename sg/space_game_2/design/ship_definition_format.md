# Ship definition format — v0.1

**Status:** decided (format), draft (specific fields)
**Scope:** v0.1 vertical slice
**Last updated:** 2026-04-20

## Summary

Ships are defined in JSON files, loaded at startup. The v0.1 format supports hull silhouette, systems with positional metadata, and the parameters needed for the resolver and the SSD renderer. The format is minimal at v0.1 but extensible; fields are added to the schema as later slices introduce new mechanics.

## Why data-driven

The resolver and the UI know nothing about specific ships. They read ship definitions and operate on whatever the files describe. This has three practical consequences worth naming because they shape later decisions:

- **Iteration speed.** Ship balance — reactor output, hull hitpoints, thrust budget — is a tuning activity, not a coding activity. Change a value in a JSON file, reload, retry. No rebuild.
- **"Two identical ships" and "two different ships" are architecturally the same.** The v0.1 scope (two identical ships) is achieved by loading one ship definition twice. No special case.
- **Future ship-designer features are not blocked.** A GUI for building new ships, whenever that becomes scope, produces JSON that conforms to the same format.

At v0.1, the game ships with exactly one ship definition file. That's the v0.1 scope. The format supporting multiple ships isn't speculative flexibility — it's the cheapest way to build the one ship, because every parameter has to live somewhere anyway.

## The format

Ships are JSON files with a top-level object. The shape:

```json
{
  "id": "css_meridian",
  "name": "CSS Meridian",
  "class": "frigate",
  "hull": { ... },
  "systems": [ ... ],
  "dynamics": { ... }
}
```

Each top-level field has a specific purpose, discussed below.

### `id` — machine-readable identifier

Used internally to reference the ship (in replay events, in save files, in other ship definitions that might later reference it). Stable across versions. Lowercase, underscores, no spaces.

### `name` and `class` — display strings

Shown in the UI. Human-readable. May be localized later.

### `hull` — the ship's silhouette and structural properties

```json
"hull": {
  "silhouette": [
    { "x": 0, "y": -0.5 },
    { "x": 0.15, "y": -0.35 },
    { "x": 0.2, "y": 0.1 },
    { "x": 0.18, "y": 0.35 },
    { "x": 0.3, "y": 0.5 },
    { "x": 0, "y": 0.6 }
  ],
  "hit_points": 100
}
```

**`silhouette`** is a closed polygon defined by points in ship-local coordinates. The ship's local origin is the geometric center of the hull. The Y axis runs from bow (negative) to aft (positive). The X axis runs port (negative) to starboard (positive). Coordinates are normalized: roughly `-0.5` to `+0.5` along the long axis. Only half the silhouette needs to be specified if we decide hulls are symmetric — the renderer can mirror it. (Mirroring is a v0.1 decision to make; current lean is to require the full polygon to allow asymmetric ships later without schema change.)

**`hit_points`** is the ship's total damage capacity. Simple scalar at v0.1. When hit points reach zero, the ship is destroyed.

### `systems` — the ship's subsystems, placed on the hull

```json
"systems": [
  {
    "id": "drive",
    "type": "drive",
    "position": { "x": 0, "y": 0.45 },
    "parameters": { "max_thrust": 1.8 }
  },
  {
    "id": "reactor",
    "type": "reactor",
    "position": { "x": 0, "y": 0.25 },
    "parameters": { "max_output_mw": 8 }
  },
  {
    "id": "bridge",
    "type": "bridge",
    "position": { "x": 0, "y": 0 },
    "parameters": {}
  },
  {
    "id": "forward_mount",
    "type": "weapon_mount",
    "position": { "x": 0, "y": -0.4 },
    "parameters": {
      "arc_degrees": 60,
      "bearing_degrees": 0,
      "range_km": 300,
      "damage": 15,
      "power_draw_mw": 3
    }
  }
]
```

Every system has four required fields:

- **`id`** — unique within the ship. Referenced by replay events ("hit registered on system X") and by ship config files.
- **`type`** — the kind of system. Determines which resolver logic applies and how the UI renders it. v0.1 types: `drive`, `reactor`, `bridge`, `weapon_mount`. Additional types (shields, sensors, damage_control, point_defense, etc.) are added as later slices introduce them.
- **`position`** — ship-local coordinates on the hull, in the same coordinate space as the silhouette. The renderer uses this to place the system visually on the schematic. The resolver uses this to determine which system gets hit when damage lands in a specific region of the hull.
- **`parameters`** — a type-specific object. Its shape depends on `type`. Validated by the resolver when the ship loads.

The `parameters` object is deliberately open-ended. New system types introduce new parameter shapes without breaking the top-level schema. Unknown parameters are ignored by the resolver (with a warning logged), which means adding a field is backward-compatible.

#### Parameters by type at v0.1

- **`drive`**: `max_thrust` (scalar, in whatever units the dynamics use).
- **`reactor`**: `max_output_mw` (scalar). Later slices add `peak_output_mw`, `heat_capacity`, `cooling_rate`, etc.
- **`bridge`**: no parameters at v0.1. Later slices add crew capacity, sensor integration, etc. Kept in the schema so the UI can render it.
- **`weapon_mount`**: `arc_degrees` (firing cone width), `bearing_degrees` (center direction relative to ship's forward, 0 = bow, 90 = starboard, etc.), `range_km` (effective maximum), `damage` (scalar applied on hit), `power_draw_mw` (reactor cost to fire).

### `dynamics` — physical properties relevant to movement

```json
"dynamics": {
  "mass": 1000,
  "moment_of_inertia": 500,
  "initial_heading_degrees": 0
}
```

Properties governing how the ship responds to thrust and external forces. `mass` and `moment_of_inertia` determine the ship's reaction to thrust and torque. `initial_heading_degrees` is the ship's starting orientation (0 = bow pointing toward positive Y, which is usually "away from the enemy" at game start).

At v0.1, `mass` and `moment_of_inertia` are simple scalars. If later slices introduce damage effects on handling (damaged drives reducing effective thrust, damaged bridges reducing turn rate), those show up as multipliers applied elsewhere rather than modifications to these base values.

## Coordinate system conventions

Two coordinate systems live in the ship file, and they share the same conventions:

- **Origin:** geometric center of the hull.
- **Y axis:** bow (negative) to aft (positive).
- **X axis:** port (negative) to starboard (positive).
- **Units:** normalized, roughly `-0.5` to `+0.5` along the ship's long dimension. The actual physical size of the ship in world coordinates is a separate concern (a `scale` field may be added later if ship size matters mechanically; v0.1 assumes one scale).

This matches the Expanse-style "rocket stack" orientation we committed to in the SSD design: bow at the top of the schematic, aft at the bottom, systems placed along the vertical axis with weapons distributed laterally.

## Validation

Ship files are validated at load time. Failures are loud — the game refuses to start if a ship file is malformed. Validation checks at v0.1:

- Required fields present.
- `silhouette` is a valid closed polygon with at least 3 points.
- All system `id`s are unique within the ship.
- All system `position`s are inside the silhouette (a warning if outside — not an error, since weapon mounts legitimately protrude).
- All system `type`s are known.
- Type-specific parameters are valid for their type.

Validation logic lives in a single module imported by both server and client. Shared validation means a client can refuse to render a ship the server would reject.

## Example: the v0.1 ship

The ship that ships with v0.1 — the one used for the two-identical-ship duel — is specified in full here as a concrete reference. Not a commitment to specific numbers; these are starting points for tuning.

```json
{
  "id": "css_meridian",
  "name": "CSS Meridian",
  "class": "frigate",
  "hull": {
    "silhouette": [
      { "x": 0, "y": -0.5 },
      { "x": 0.15, "y": -0.35 },
      { "x": 0.18, "y": 0.1 },
      { "x": 0.14, "y": 0.3 },
      { "x": 0.3, "y": 0.42 },
      { "x": 0.2, "y": 0.55 },
      { "x": 0, "y": 0.6 },
      { "x": -0.2, "y": 0.55 },
      { "x": -0.3, "y": 0.42 },
      { "x": -0.14, "y": 0.3 },
      { "x": -0.18, "y": 0.1 },
      { "x": -0.15, "y": -0.35 }
    ],
    "hit_points": 100
  },
  "systems": [
    {
      "id": "forward_mount",
      "type": "weapon_mount",
      "position": { "x": 0, "y": -0.35 },
      "parameters": {
        "arc_degrees": 60,
        "bearing_degrees": 0,
        "range_km": 300,
        "damage": 15,
        "power_draw_mw": 3
      }
    },
    {
      "id": "reactor",
      "type": "reactor",
      "position": { "x": 0, "y": 0.15 },
      "parameters": { "max_output_mw": 8 }
    },
    {
      "id": "bridge",
      "type": "bridge",
      "position": { "x": 0, "y": -0.05 },
      "parameters": {}
    },
    {
      "id": "drive",
      "type": "drive",
      "position": { "x": 0, "y": 0.45 },
      "parameters": { "max_thrust": 1.8 }
    }
  ],
  "dynamics": {
    "mass": 1000,
    "moment_of_inertia": 500,
    "initial_heading_degrees": 0
  }
}
```

The numbers here are unverified starting points — they'll change as playtesting reveals what makes for a fun duel. The *shape* of the data is what this doc commits to.

## Not decided / deferred

- **Asymmetric hulls.** The current format allows asymmetry but v0.1 doesn't exercise it. Future non-human or custom-design ships might.
- **Subsystem health models.** At v0.1, systems either work or are destroyed (when the ship dies). Graded health states (damaged → degraded → destroyed) arrive with later slices.
- **Multi-tier weapon mounts.** The `weapon_mount` type at v0.1 is generic. Future slices may distinguish between direct-fire, kinetic, seeker, and beam mounts with different parameter shapes — likely as separate `type` values rather than parameters on a common type.
- **Armor zones.** v0.1 treats the hull as a single hit-point pool. Later slices may introduce per-zone armor that modifies incoming damage based on where a hit lands.
- **Crew.** No crew modeling at v0.1. The continuity-of-humanity principle is a setting commitment that will express as mechanics later.
- **Ship scale / physical size.** v0.1 uses normalized coordinates and assumes one scale. Future multi-ship-class work will need a physical-size convention.
- **Ship identity metadata.** Faction, tech tier, cost, description — deferred until there are multiple ships worth distinguishing.
- **Visual styling.** Hull color, trim details, engine glow color — these are visual-identity decisions, not data-model decisions. Handled in a separate style layer when visual polish becomes scope.

## Upgrade paths preserved

This format does not block any of the following:

- **Multiple ship types.** Already supported — each ship is a separate file.
- **A ship designer.** GUI produces JSON conforming to this schema.
- **Ship variants / refits.** Base ship plus modifier files, merged at load time.
- **Per-faction ship variants.** Faction metadata as a top-level field, once factions exist.
- **Animated systems.** An optional `animation` block per system, added when execute-phase rendering needs it.
- **Subsystem dependencies.** An optional `depends_on` field per system, allowing e.g. a weapon to require a functioning reactor.

## Related docs

- `stack_decision.md` — confirms JSON and TypeScript as the format and language context.
- `resolver_design.md` *(next)* — the module that consumes these files and runs the simulation.
- `ssd_layout.md` *(next)* — the renderer that visualizes ships based on this data.