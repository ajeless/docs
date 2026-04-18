# Tactical Starship Combat Game — Ideation State

*Working document. Nothing here is decided. This is a snapshot of an ideation conversation, preserving the forks, the leanings, and the open questions.*

---

## The premise

A videogame homage to tactical ship-to-ship starship combat board games and RPGs — Star Fleet Battles, Federation Commander, Attack Vector: Tactical, Full Thrust, Triplanetary, Traveller's Mayday/Brilliant Lances, Starmada, Squadron Strike, Silent Death, Renegade Legion: Leviathan, Jovian Chronicles, Saganami Island, Babylon 5 Wars, and the rest of that lineage — that takes full advantage of what the digital and networked medium offers. Tactical combat is front and center. Full Ship System Display (SSD) depth: energy allocation, damage readouts, casualty reports, the whole nine yards.

The game uses **turn planning + animated execution** — not full real-time combat, which would be information overload.

---

## The market landscape (as surveyed)

The space currently has a specific gap that this concept maps to:

- **Battlestar Galactica: Deadlock** is the closest living relative — WEGO 3D fleet combat with a plot-and-resolve loop. Notably, it is being **permanently delisted November 15, 2025** due to a licensing expiration. The audience is about to be orphaned. This is both a warning about licensed IP and an opening for a spiritual successor.
- **NEBULOUS: Fleet Command** occupies the other pole — real-time with pause, simulation-heavy, realistic radar and electronic warfare, component-level damage. Hardcore, PvP-focused, and fundamentally real-time.
- **Star Fleet Command** series and similar older digital SFB-lineage games were real-time-with-pause and didn't honor the cardboard / turn-based spirit.
- **The SFB lineage itself** (Federation Commander, AVT, etc.) lives mostly on tabletop or in legacy adaptations.

**Nobody is currently occupying the quadrant of: SFB-level system depth + WEGO turn structure + modern digital UX + original IP.** Deadlock came closest and it's disappearing.

---

## Core thesis (working stake-in-the-ground)

A tactical starship game that treats the SSD as the primary game interface, the turn as a planning problem, and the execution phase as an animated film you can re-watch from any perspective. Built async-native from day one so it can scale from hot-seat to real-time PvP to (optionally, someday) persistent play, without architectural rewrites.

Three load-bearing ideas:

1. **SSD-as-primary-interface.** The ship schematic is where the player plays. Energy allocation, weapon arming, damage control, casualty reports — all live on a living SSD, not a secondary pop-out screen.
2. **Plot → Commit → Execute-animated → Debrief** as the sacred loop. The execute phase is a *show*, not a chore. Scrubbable, slow-down-able, camera-switchable.
3. **Async by default.** Every battle is a plot submission + a replay. Hot-seat, PBEM-style async, real-time synchronous, and any future persistent play are all just different timer settings on the same engine.

---

## The scope decision

**Scope is capped at v0-v2.** No tech trees. No empire layer. No 4X.

This was a real conversation and landed firmly here. The reasoning:

- The tactical game alone — momentum-based movement, full SSD depth, WEGO resolution, fog of war, ship designer, community-shareable replays — is already five Steam games stacked in a trench coat. It is genuinely on the edge of feasibility for a small team.
- The cognitive load on the *player* is already heavy. Adding an empire layer adds cognitive scope on top of already-complex tactical decisions.
- "Slow growth to MMOG" is seductive but creates design pressure on every v0-v2 decision to preserve paths that may never be walked. That constraint is expensive.
- A pure tactical game is a purer design. Players express themselves through *choice* within a fixed physics, not through *progression*. Chess and Go have no tech tree and have the longest competitive lives.
- If in year three the tactical game is alive and loved, the campaign layer becomes a natural next step — much smaller leap than jumping to 4X.

**The roadmap as it stands:**

- **v0 — Duel.** One ship vs. one ship, skirmish only. Proof that the core loop is fun for an hour.
- **v1 — Squadron skirmish.** 2-4 ships per side, single map. PvP and vs-AI.
- **v2 — Ship designer + community.** Workshop-style sharing, point-cost balancing.
- *Future versions (v3+): campaign, persistent sector, etc. are "architecturally possible, not committed."*

---

## The IP decision

**Original IP, not licensed.**

Reasoning:

- The Deadlock delisting is a sobering case study — a beautiful game can become unpurchasable because of a contract decision.
- For a project with a multi-year horizon, owning the IP is the only way to guarantee it stays alive.
- Original IP lets **mechanics drive the setting** rather than the reverse. Factions can be designed as mechanical archetypes first, with lore grown around them, rather than being locked into "Klingons cloak because the show said so."

---

## Movement model — working lean

**Working lean: momentum-hex (Triplanetary / Mayday / Brilliant Lances lineage), with an optional elevation-band system deferred to post-launch.**

Not finalized, but the argument is strong. The full spectrum we considered:

- **(A) Pure hex, no momentum** (SFB / FedCom style). Crisp, teachable, chess-like. But doesn't feel like space — ships stop on a dime.
- **(B) Pure Newtonian vector in 3D** (Attack Vector: Tactical / Squadron Strike). Real physics, genuinely deeper gameplay, but cognitively expensive. In WEGO specifically, the opponent's next-turn position becomes a fuzzy volume rather than a specific location, which fights the "chess problem with hidden intent" feel that makes WEGO plotting satisfying.
- **(C) Continuous sim with hex overlay.** Rejected on reflection — reads hex to new players, Newtonian to nerds, pleases neither. The grid has to be doing real work or it shouldn't exist.
- **(D) Hex + momentum vectors** (Triplanetary / Mayday lineage). Each ship has a velocity arrow; thrust modifies it within a delta-v budget. Legibility of hex + feel of space. Discrete end-states preserve the chess quality of WEGO. Facing and velocity vector decoupled — you can drift one way while pointing another. **This is the current lean.**
- **(E) Hex + momentum + elevation bands** (three layers: high/mid/low, with thrust cost to change). Cheap approximation of 3D that recovers some of the dorsal/ventral arc richness AVT has, without requiring real 3D vector math from the player. **Deferred to v1.5+.**

### Why momentum-hex specifically for this game

Three reasons, ranked:

1. **WEGO wants discrete end-states.** The pleasure of plot-and-execute is inversely proportional to how fuzzy the prediction problem is. Hex-based momentum produces a finite, enumerable set of possible end positions — the opponent will land on one of these ~7 hexes. That preserves the chess feel.
2. **The SSD is already complex.** Movement must be legible so the player has cognitive budget left for ship operations, where the depth actually lives.
3. **Information warfare needs crisp geometry.** "Did I get a lock? What's my arc? Am I in range?" must have clean hex answers for EW play to feel tactical rather than spreadsheet-y.

### Key digital-medium enabler

The paper versions of momentum-hex (Triplanetary, Mayday) stayed niche because of the learning curve — new players fly into asteroids because they mispredict drift. **Ghost-trajectory preview in the planning UI** — showing end-hex and next-turn vector live as the player drags thrust handles — is the affordance this mechanic was literally waiting for. The computer is the thing that unlocks this design.

### Open sub-questions on movement

- Symmetric vs. asymmetric thrust budgets (main drive vs. maneuvering thrusters as separate pools). Asymmetry is more flavorful and realistic but another system to teach.
- Plotted course (one shot per turn) vs. per-impulse thrust (spread across 8-32 impulses). Per-impulse is more expressive and more SFB-authentic; plotted is simpler. Tentative lean: per-impulse with "ease of use" presets.
- Does a ship ever meaningfully "stop"? Whether zero-velocity is a real tactic or just a theoretical state tells us a lot about map sizes and engagement ranges.

---

## The SSD — proposed features

Drawing unapologetically from SFB and Federation Commander, but doing what paper can't:

- **Live energy curve across the impulse track.** Not one static allocation per turn — a line graph per system, drawable and re-editable. Want to surge phasers on impulse 16? Draw it in. Reactor has max sustained output plus a peak with heat cost.
- **Heat as a second resource.** Paper games mostly hide this. Digital shows heat accumulating per subsystem, glowing red, requiring coolant or venting (which lights you up on sensors).
- **Subsystem health with mechanical consequences.** A hit to the starboard phaser capacitor reduces that arc's damage output by 40% for 3 turns until repaired. A hit to life support causes crew casualties unless vented/patched.
- **Damage control as automated-with-priorities.** Player sets standing orders in plot phase; DC parties move between compartments during execution, triaging by those orders. Re-prioritize each turn, not mid-resolution.
- **Casualty reports with named crew.** Minor morale effects next mission. Optional narrative layer — memorial plaque in the ready room, etc.

---

## Weapons — rough categories

The WEGO structure makes certain weapon categories sing:

- **Direct-fire** (phasers, beams, disruptors) — resolved on the impulse they fire. Arc-limited, range-falloff, predictable but punishing.
- **Seeking weapons** (drones, plasma torpedoes, missiles) — launched in plot phase, maneuver during execution. Their own mini-SSDs (fuel, seeker head, warhead). Counterable with PD, decoys, terrain.
- **Mines, probes, ECM drones** — pre-deployed terrain. Rewards forethought.
- **Tractor beams, boarding, transporters** — the weird SFB stuff. Digital handles the bookkeeping cardboard couldn't.
- **Fighters / shuttles** — mini-ships with tiny SSDs. Managed as squadrons, not individuals.
- **Electronic warfare** — sensor spoofing, jamming, decoys, signature management. Especially powerful in WEGO because it degrades the certainty of the opponent's plot.

---

## Information asymmetry

A pure digital superpower that tabletop cannot match:

- Your own SSD: fully legible.
- Enemy SSD: **estimated** — silhouette, emissions signatures, observed weapon flashes, inferred mounts.
- Sensor operators build a dossier over the course of a battle, and that dossier *persists across battles if your fleet survives*. "We know that cruiser has disruptors on the port arc; we saw it at Deneb."

---

## Digital-medium superpowers to lean on hard

Features no cardboard game can do, to be baked in from v0.1:

- Perfect bookkeeping — no manual energy allocation on paper SSDs.
- Conditional orders / standing orders — scales complexity without scaling tedium.
- Replays as first-class shareable objects — with URLs. The best battles become legend.
- Ghost runs — re-plot your orders post-battle to see how it would have gone. Great for learning.
- Fog of war with memory.
- Async PBEM play with configurable turn timers.
- Ship designer with live physics validation.
- Community-shareable ship designs.
- Persistent wear — ammo, armor, crew carry between battles in campaigns.

---

## The faction-identity idea (the big one)

This is where the conversation got most generative, and it's still partially open. The progression:

### First move: faction = physics

The question arose: if momentum-hex is the core movement model, what happens when an opponent has inertial compensators / gravity control? They wouldn't be bound by momentum-hex.

Rather than treating this as a workaround, promote it to the *central creative conceit of the setting*: different civilizations have climbed different tech trees to get to space, and each tech tree commits its civilization to different physical realities. **Factions don't share a common chassis with different stat blocks — they play under genuinely different rulesets.**

Sketched faction archetypes (illustrative only, not committed):

- **Inertialists** — reaction drives, momentum-hex, Newtonian. Big fuel tanks, long burns, committed trajectories. Raw efficiency. Battleship-feeling.
- **Gravitics** — manipulate local gravity. Not momentum-constrained; maneuver freely but every course change costs reactor power not going to weapons/shields. Squirrely, hard to corner.
- **Jumpers** — teleportation/displacement. Don't move; blink within a limited radius with cooldown. Fragile because they've never needed armor. Peekaboo gameplay: appear, salvo, vanish.
- **Swarm** — no one ship is interesting; swarm health and formation are the unit.
- **Drifters / Solar-Sailors** — little active propulsion; manipulate existing momentum and environment. Strong near stars, nebulae, gravity wells; helpless in empty space.

### Second move: civilizations are vectors across multiple spheres

The next realization: movement physics is just one sphere of a civilization's identity. There are others:

- **Biology / crew** (organic, machine, hive-mind, uploaded, symbiotic)
- **Cultural / warfare doctrine** (honor culture, pragmatic, swarm, scavenger, ritualized, apocalyptic)
- **Temporal / causal relationship** (linear, limited precog, non-linear)
- **Information / sensor paradigm** (EM radar, gravitic sensing, psionic, hive-consciousness shared perception)
- **Energy / power source** (fusion, zero-point, bio-reactor, harvested ambient)
- **Scale philosophy** (one big ship, many small ships, modular combine/split, ships that *are* their crew)
- **Relationship to damage** (in-combat repair, regrow, modular hot-swap, don't care because you're digital)

Each sphere produces *different mechanics at the table*, not just different flavor. Biology changes whether the game even has a crew casualty system. Temporal changes whether plotting is symmetric between the two players.

### Three implementation forks for the spheres idea

- **Fork A: Fixed authored factions.** Small roster of curated, monolithic factions. Spheres exist only as the designer's internal tool. How most games handle this. Tight and balanced, but the combinatorial richness is invisible to the player.
- **Fork B: Full player composition.** Each sphere has a menu; players build factions by picking options. Maximally rich and original, but combinatorial explosion in matchup space (5 spheres × 4 options = 1024 factions, ~500K matchups). Balance likely unsolvable; some combinations degenerate.
- **Fork C: Authored factions on a public metaphysics.** 4-6 curated factions at launch, but the spheres-structure is exposed in UI and lore. Each faction shown as a specific point in a visible combinatorial map. New factions added over time as new combinations. Custom composition possibly unlocked v2+ as a workshop feature. **This is the current lean.**

### Why Fork C is the working lean

- At launch, players get a clean curated experience — authored factions with voice.
- But the metaphysics is *legible* — players can see that the Gravitics differ from the Inertialists on propulsion and sensors but share biology and temporality. The universe's structure is visible.
- The lore has explicit shape — different civilizations walked different tech pathways, and each one in the game is a historical record of one such walk.
- New factions feel like illuminating new corners of the map rather than piling on flavor text.
- The architecture supports future composition without committing to it.
- **Design discipline follows automatically** — each faction is forced to be a specific point in a shared design language, rather than a messy pile of cool ideas.

### The temporal trap (flagged)

Temporal/causal factions are a design trap that must be addressed, not deferred. A faction that literally re-plots after seeing the opponent's orders, or sends a unit backward in time, **breaks WEGO symmetry** and cracks the core loop. Temporal abilities should manifest as small asymmetric information advantages — "sees a probability distribution of enemy plot before committing," "can spend energy to force a damage re-roll" — not literal time travel. The spheres framework forces this conversation early, which is itself a point in its favor.

---

## Open questions

Forks still unresolved, roughly in priority order:

### On faction / civilization structure

1. **Commit to Fork C for the spheres idea?** (Currently leaning yes, not decided.)
2. **What's the final list of spheres?** Movement, biology, doctrine, temporality, sensors, power, scale, damage-relationship — is that the right set? Too many? Missing ones?
3. **How many options within each sphere at launch?** (Three? Four? Fewer?)
4. **Which sphere-combinations are off-limits** to preserve WEGO integrity and game coherence?
5. **How many authored factions at launch?** Four? Six? Which specific combinations?
6. **Does a first-faction sketch (Inertialists) happen before or after the spheres pass?** (Current lean: after, so the sketch is a declared combination rather than a monolithic blob that bakes in implicit sphere-choices.)

### On movement mechanics

7. Symmetric vs. asymmetric thrust budgets (main drive vs. maneuvering thrusters as separate pools)?
8. Plotted course (one shot per turn) vs. per-impulse thrust (8-32 impulses)?
9. Does a ship ever meaningfully reach zero velocity?
10. Elevation bands at v1 or deferred to v1.5+?

### On turn mechanics

11. Impulse count per turn — SFB's 32 (granular, heavy), FedCom's 8 (clean, streamlined), or somewhere between?
12. Conditional orders — how expressive should the standing-order language be? Too simple = limited; too expressive = a programming language.

### On scope and positioning

13. Solo-first (campaign) or PvP-first (skirmish) at launch? Deadlock leaned solo; Nebulous leaned PvP. Tentative lean: solo-first with PvP added once AI is strong enough to pass a decent Turing test, but contested.
14. How loud is the RPG knob? Named crew, captain careers, ship logs — how deep in v1?
15. Map terrain — asteroids, nebulae, gravity wells, debris fields. Which make v1? Do battle wreckage fields persist?

### On the setting

16. What is the metaphysical framing of the universe? Why do different civilizations have different relationships to physics? Is there a deeper underlying physics, or are the sphere-options genuinely just incompatible truths?
17. What is the in-universe reason civilizations encounter each other despite incompatible physics? (Neutral space where all physics work? Shared discoveries that bridge?)
18. Tone — grim-gritty, operatic, scientific-optimistic, weird-baroque?

---

## What's decided vs. leaning vs. open

**Decided:**

- Original IP, not licensed.
- Scope capped at v0-v2. No tech tree, no empire layer.
- WEGO plot-and-execute turn structure.
- SSD as primary game interface.
- Async-native architecture from day one.
- Replays as first-class shareable objects.

**Working leans (argued for but not committed):**

- Momentum-hex movement (Triplanetary lineage).
- Elevation bands deferred post-launch.
- Fork C for faction structure (authored factions on a public spheres-metaphysics).
- Spheres-pass happens before first-faction sketch.
- Solo-first, PvP-strong.
- Per-impulse thrust with presets.

**Wide open:**

- Everything about specific factions and their specific combinations.
- The metaphysical framing of the setting.
- All the open-questions list above.
- The tone and aesthetic of the universe.

---

## Suggested next ideation session

If/when we pick this up: do the spheres pass. Name the five or six spheres definitively, enumerate three or four options each, flag the off-limits combinations. That gives us a map of the universe before picking our first point on it. Then — and only then — sketch the first faction (probably Inertialists) as a declared combination across all spheres.