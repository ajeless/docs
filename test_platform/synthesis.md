# Tactical Starship Combat Game — Ideation State

*Working document. Nothing here is decided unless explicitly labeled as such. This is a snapshot of an ongoing ideation conversation, preserving forks, leanings, reasoning, and open questions.*

*This is a full rewrite of an earlier version. The setting frame has shifted materially, some previous "leans" have either firmed up or been held in reserve, and several new design disciplines have been established. Patching the old doc would have produced a mess; a clean rewrite is cleaner.*

---

## The premise

A videogame homage to tactical ship-to-ship starship combat board games and RPGs — Star Fleet Battles, Federation Commander, Attack Vector: Tactical, Full Thrust, Triplanetary, Traveller's Mayday/Brilliant Lances, Starmada, Squadron Strike, Silent Death, Renegade Legion: Leviathan, Jovian Chronicles, Saganami Island, Babylon 5 Wars, and the rest of that lineage — that takes full advantage of what the digital and networked medium offers. Tactical combat is front and center. Full Ship System Display (SSD) depth: energy allocation, damage readouts, casualty reports, the whole nine yards.

The game uses **turn planning + animated execution** — not full real-time combat, which would be information overload.

---

## The market landscape

The space currently has a specific gap that this concept maps to:

- **Battlestar Galactica: Deadlock** is the closest living relative — WEGO 3D fleet combat with a plot-and-resolve loop. Notably, it is being **permanently delisted November 15, 2025** due to a licensing expiration. The audience is about to be orphaned. This is both a warning about licensed IP and an opening for a spiritual successor.
- **NEBULOUS: Fleet Command** occupies the other pole — real-time with pause, simulation-heavy, realistic radar and electronic warfare, component-level damage. Hardcore, PvP-focused, and fundamentally real-time.
- **Star Fleet Command** series and similar older digital SFB-lineage games were real-time-with-pause and didn't honor the cardboard / turn-based spirit.
- **The SFB lineage itself** (Federation Commander, AVT, etc.) lives mostly on tabletop or in legacy adaptations.

**Nobody is currently occupying the quadrant of: SFB-level system depth + WEGO turn structure + modern digital UX + original IP.** Deadlock came closest and it's disappearing.

---

## Core thesis

A tactical starship game that treats the SSD as the primary game interface, the turn as a planning problem, and the execution phase as an animated film you can re-watch from any perspective. Built async-native from day one so it can scale from hot-seat to real-time PvP to (optionally, someday) persistent play, without architectural rewrites.

Three load-bearing ideas:

1. **SSD-as-primary-interface.** The ship schematic is where the player plays. Energy allocation, weapon arming, damage control, casualty reports — all live on a living SSD, not a secondary pop-out screen.
2. **Plot → Commit → Execute-animated → Debrief** as the sacred loop. The execute phase is a *show*, not a chore. Scrubbable, slow-down-able, camera-switchable.
3. **Async by default.** Every battle is a plot submission + a replay. Hot-seat, PBEM-style async, real-time synchronous, and any future persistent play are all just different timer settings on the same engine.

---

## The scope decision

**Scope is capped at v0-v2.** No tech trees. No empire layer. No 4X.

Reasoning (this was a real conversation and landed firmly):

- The tactical game alone — deep SSD, WEGO resolution, fog of war, ship designer, community-shareable replays — is already several games of scope stacked together. Genuinely on the edge of feasibility for a small team.
- The cognitive load on the *player* is already heavy. Adding an empire layer adds cognitive scope on top of already-complex tactical decisions.
- "Slow growth to MMOG" is seductive but creates design pressure on every v0-v2 decision to preserve paths that may never be walked. That constraint is expensive.
- Pure tactical games have the longest competitive lives — chess, Go, fighting games. Players express themselves through *choice* within fixed rules, not through accumulation.
- If in year three the tactical game is alive and loved, the campaign layer becomes a natural next step — much smaller leap than jumping to 4X.

**The roadmap as it stands:**

- **v0 — Duel.** One ship vs. one ship, skirmish only. Proof that the core loop is fun for an hour.
- **v1 — Squadron skirmish.** 2-4 ships per side, single map. PvP and vs-AI.
- **v2 — Ship designer + community.** Workshop-style sharing, point-cost balancing.
- *Future versions (v3+): campaign, persistent sector, etc. are "architecturally possible, not committed."*

---

## The IP decision

**Original IP, not licensed.**

- The Deadlock delisting is a sobering case study — a beautiful game can become unpurchasable because of a contract decision.
- For a project with a multi-year horizon, owning the IP is the only way to guarantee it stays alive.
- Original IP lets **mechanics drive the setting** rather than the reverse. Factions can be designed as mechanical archetypes first, with lore grown around them.

---

## Setting frame

This is where the creative identity of the game lives. It took several passes to find the right frame. What we settled on:

**The solar system, roughly 500 years from now.** Humanity has mostly colonized the system — Earth, Luna, Mars, the Belt, the Jovian and Saturnian moons, habitats in high orbit and at the Lagrange points, frontier outposts further out. There is no FTL. No aliens have been encountered. The solar system is humanity's entire stage, and it is a very large one.

Humanity is **plural**. Centuries of life in radically different gravitational and radiation environments have produced genuinely different peoples — dense high-g Terran lineages, leaner Mars-adapted bloodlines, long-limbed low-density Belters, Europan aquatic-subculture engineers, microgravity-native populations who can't survive planetary surfaces unassisted. Politically, the old national and corporate structures have fragmented, recombined, and diverged. The solar system is a patchwork of sovereignties — national successor-states, Martian republics, Belter collectives, corporate sovereign zones, post-state networked polities, frontier outposts with idiosyncratic governance.

Technologically, the setting is **one careful step beyond The Expanse**. Fusion torch drives, gigawatt lasers, serious coilguns and railguns, sophisticated missiles and drones, widespread industrial automation, robust AI. The tech is extrapolative rather than speculative — everything is continuous with trajectories visible from now.

At the **edge of known space**, something is wrong. Exactly what is not said and is not important for v0.1 — but people have disappeared, signals have been classified, ships have come back changed or have not come back at all. The setting *knows about* mystery. The mystery is not played on-screen at launch.

### Why 500 years, not 1000

A 500-year horizon lets humanity diverge meaningfully without fracturing into essentially different species. At 500 years:

- Physiological adaptation is real but not speciation — Belters and Earthers are different, but they're still human, and crews can mix on long voyages.
- Political fragmentation is mature — no single Earth government, a patchwork of polities with distinct identities.
- Tech has grown substantially but continuously — nothing in the setting requires speculative physics breakthroughs.
- AI is ubiquitous, sophisticated, and *integrated into human life* — not transcendent or post-human.
- Nobody has uploaded. Nobody is a hive mind. Nobody experiences time non-linearly.

A 1000-year horizon makes it too tempting to introduce humans-that-aren't-really-humans-anymore, and that slide is exactly what we want to avoid.

---

## The continuity-of-humanity principle

This is a **design discipline**, not just a setting detail. Naming it explicitly because it has operational consequences:

> **Every faction must be comprehensible as "people making hard choices under real pressures" rather than as "what if we became something else." The player's empathy must remain continuous across all factions. You should be able to imagine sitting down to dinner with any faction's crew and recognizing them as people.**

Things this principle rules out at v0.1:

- **Uploaded consciousness as a faction identity.** Plausible in the timeframe, but it cracks the "people in ships" frame — the gameplay experience of fighting uploaded-crew warships necessarily pushes toward alien cognition, different tempo, different values. That is exactly the slide this principle blocks.
- **Distributed / hive minds across multiple bodies.** Same reason.
- **Full-AI-autonomous warships as a faction.** Autonomous ships exist in the setting as *tools*, but no faction is constituted *as* autonomous ships.
- **Speciation-level physiological divergence.** Adaptation is fine; speciation is not.
- **Vat-grown clones with pre-loaded memories as a reproductive strategy.** Too far.

What the principle *allows*:

- Heavy cybernetic integration, up to and including neural interfaces, replaced organs, augmented reflexes, pharmaceutical combat cocktails — but the person is still recognizably a person who dies when the hull breaches and has family waiting at home.
- Strong physiological adaptation to native environments — dense high-g Terrans, leaner Mars-adapted bloodlines, long-limbed low-density Belters, pressure-adapted Europans.
- Radical political, cultural, ideological, religious divergence.
- Radically different doctrinal and industrial approaches to warfare.
- Ship crews that are mostly automated, with skeleton human complements.

The principle is a **guardrail for future design**. When a future faction concept starts to feel exciting, check it against the principle. If the excitement is coming from the "alien-feeling" vector, it may be the held-in-reserve idea bleeding through.

---

## AI in the setting

**AIs are part of humanity's story, not a separate story.**

The setting's premise is that AI development went reasonably well over the 500 years. There were incidents, debates, ethical disasters, probably some limited conflicts — but the net arc was *integration*, not conquest, not uprising. AIs came up alongside humans through the solar system's colonization. They are of humanity in the same root-sense that Belters and Martians are of humanity, even though they arrived through silicon rather than biology.

In day-to-day setting texture:

- Physical AI — humanoid robots, autonomous drones, damage-control swarms, tactical computers with personalities — is **ubiquitous and unremarkable**.
- AIs work alongside humans at every scale, from personal assistants to warship command support.
- A nearly-conscious 8-foot service droid is a normal sight, not a marvel.

### The emerging question

The status of AI personhood is **legally and ethically contested across the solar system.** Not resolved one way; genuinely contested. Different factions have taken different positions:

- Some treat their ship AIs as crew, with names, ranks, and memorial honors when lost.
- Some treat the same AI legally as a depreciating corporate asset.
- Most are somewhere in between, or have incoherent positions they haven't fully examined.

This is a **faction-flavor axis**, not a faction-defining one. No faction is "the AI faction." But every faction has a position on the question, and that position tells you something about who they are.

Narrative hooks this opens up without requiring resolution:

- A Belter captain whose sister is a ship AI.
- A corporate officer with private opinions about her ship's personhood that diverge from her employer's policy.
- Mixed-crew dynamics across factions with different AI-status positions.

### Why this matters for the edge-mystery

Because AIs and humans are on the same side of the "us" line in this setting, when something from *outside* arrives, the asymmetry is clean and powerful. Humans and their droids stand side by side and are equally strangers to whatever has just appeared. That's the dramatic move. It only works because we've established AI-human continuity first.

---

## The edge-mystery

There is something at the edge of known space. It does not play by the rules. The setting carries this knowledge as a **background weight**, not as gameplay.

At v0.1:

- **Present in lore** — loading-screen fiction, briefings, classified-file flavor text, reference to a lost ship.
- **Absent from gameplay** — no alien presence in any battle, no mysterious wreckage you can examine, no classified-file scenarios that actually run.
- **Unresolved** — the game does not explain what it is. Different factions have different rumors. Some factions deny anything is there.

The **dread scales with the cozy-familiar frame holding in the foreground**. If v0.1 opens with any direct manifestation of the edge-mystery, the asymmetry is spent before it's earned. The full first-contact experience is reserved for future expansions where it can have real dramatic weight.

This is a **promise to the future game**, not a feature of this one.

---

## Movement model

**Continuous Newtonian physics, free coordinates (no hex grid), with rich digital planning visualization.**

This was one of the more significant design shifts in the conversation. An earlier pass had been leaning toward momentum-hex (Triplanetary/Mayday lineage). The push that flipped it: if the game's identity is about honoring Newtonian physics as an authentic civilizational choice, hex-quantization of facing and velocity *undercuts* that identity. The ships would be doing hex physics with a Newtonian flavor, not Newtonian physics. The continuous model is more honest to the fiction.

The grid was a solution to a problem the computer has already solved. Paper games used hexes because humans can't do trigonometry at the table. The computer can, and should.

### The concerns the hex was solving, and how to solve them without it

Three concerns justified hex in the earlier pass. All three have good continuous-space solutions:

**"WEGO wants discrete end-states."** The deeper need is *bounded, visualizable* end-states, not literally discrete ones. In continuous space, the opponent has a **reachable region** each turn — a specific skewed-oval shape defined by their velocity and thrust budget. The UI draws this shape during planning. Players plot against the *shape*, which communicates more information than a hex cluster (a fast maneuverable ship's region is round and wide; a heavy committed ship's region is narrow and skewed). This is a *richer* tactical vocabulary than hex reasoning.

**"SSD is already complex, so movement must be legible."** The bookkeeping problem with continuous space on a tabletop is real. Digital eliminates it entirely. The player never sees a number. They see their ship, a velocity arrow, a ghost projection of where they'll drift to next turn, thrust handles they drag, and live constraint feedback (handle goes red at thrust limit, collision warnings highlight). Trigonometry-free, visually immediate, matches physical intuition.

**"Information warfare needs crisp geometry."** Solution: **quantize the effects, not the positions.** Ships have continuous positions, but sensor ranges, firing arcs, and weapon ranges are displayed as specific meaningful threshold-circles, cones, and bands. "Inside lock-on range / inside tracking range / inside passive-detection range" are visible, crossable boundaries. You never think in meters; you think in "inside missile envelope / outside missile envelope." This is how Command: Modern Operations, DCS, and similar modern sims work, and it works beautifully.

### The one honest downside

Continuous-coordinate movement makes **verbal after-action descriptions harder**. Hex games have natural shorthand ("turned 60° starboard, advanced 2 hexes, fired") that forum AARs can use. Continuous games don't.

Mitigation: replays are first-class shareable URLs. Players link the moment rather than describe it. The social infrastructure works around the descriptive limitation — but the hex-game community culture of written AARs remains slightly less natural. This is an accepted cost.

### Digital planning UI elements

- Velocity arrow on each ship (length and direction = current velocity).
- Ghost projection showing end-of-next-turn position with no thrust applied.
- Draggable thrust handles, with live update of the resulting ghost.
- Reachable-region envelope around the ghost (edge of what's possible this turn).
- Collision warnings and constraint feedback (red handles at limits, highlighted obstacles).
- Opponent's reachable region displayed during planning (estimated from known velocity and inferred thrust budget).

### Key open sub-questions

Still open:

- Symmetric vs. asymmetric thrust budgets (main drive vs. maneuvering thrusters as separate pools). Asymmetric is more flavorful and physically realistic but adds another system to teach.
- Plotted whole-turn thrust vs. per-impulse thrust (8-32 impulses per turn). Per-impulse is more expressive and SFB-authentic; plotted is simpler. Tentative lean: per-impulse with presets.
- Does a ship ever meaningfully reach zero velocity? Answer shapes map sizing and engagement ranges.
- How large are the engagement volumes? Expanse-scale light-seconds-apart battles are dramatically different from Deadlock-scale kilometer-range slugfests. The choice affects weapon design and sensor design and pacing.
- 2D or pseudo-3D? Earlier pass suggested elevation bands (high/mid/low layers) as a v1.5+ addition. Still tentatively deferred, but worth revisiting once continuous-coordinate implications are clearer.

---

## The SSD — proposed features

Drawing from SFB and Federation Commander, doing what paper can't:

- **Live energy curve across the impulse track.** A line graph per system, drawable and re-editable. Want to surge lasers on impulse 16? Draw it. Reactor has max sustained output plus a peak with heat cost.
- **Heat as a second resource.** Paper games mostly hide this; digital shows heat accumulating per subsystem, requiring coolant or venting (which lights you up on sensors).
- **Subsystem health with mechanical consequences.** Hit to starboard laser capacitor reduces that arc's damage by 40% for 3 turns. Hit to life support causes crew casualties unless vented/patched.
- **Damage control as automated-with-priorities.** Player sets standing orders in plot phase; DC parties move between compartments during execution, triaging by those orders.
- **Casualty reports with named crew.** Minor morale effects next mission. Optional narrative layer — memorial plaque in the ready room.
- **Faction-flavored SSD presentation.** All ships share the same underlying systems engine, but the UI emphasis differs per faction. A Belter ship's SSD prominently features rad shielding and reaction-mass status; a heavily-automated corporate corvette's SSD emphasizes autonomous-system health and cyber-intrusion resistance; a high-g Terran warship foregrounds crew g-load tolerance and compartment pressurization. Same mechanics underneath, different felt experience at the interface.

---

## Weapons — rough categories

The WEGO structure makes certain weapon categories sing. All plausible, all Newtonian-compatible:

- **Direct-fire (lasers, particle beams, coilgun/railgun rounds at close range).** Resolved on the impulse they fire. Arc-limited, range-falloff, predictable but punishing. Lightspeed-lag at long range introduces real tactical texture.
- **Kinetic projectiles (coilgun/railgun rounds at long range, casaba howitzer bus rounds).** Travel-time weapons. Fire a volley now, it arrives in three turns — opponent has time to dodge or intercept. This is an especially beautiful fit for WEGO plotting.
- **Missiles and torpedoes.** Seeking weapons with their own mini-SSDs — fuel, seeker head, warhead, terminal burn capacity. Launched in plot phase, maneuver during execution. Counterable with point defense, decoys, terrain, EW.
- **Drones / loitering munitions.** Deployed, then patrol or pursue. Some are kinetic-kill, some are sensor platforms, some are ECM.
- **Mines, sensor probes, jammer drones.** Pre-deployed battlefield elements. Rewards forethought.
- **Nuclear-pumped X-ray lasers / casaba howitzers.** Plausibly-real one-shot beam weapons derived from nuclear charges. High-damage, short-effective-range, morally loaded in-setting.
- **Point defense — CIWS, interceptors, flak.** The counter to kinetics and missiles. Critical layer of the tactical game.
- **Electronic warfare — jamming, spoofing, signature management, decoys.** Degrades opponent's plot certainty, which is especially valuable in WEGO.

All of these are grounded in real or plausibly-real physics. No exotic technology required.

---

## Information asymmetry

A pure digital superpower:

- Your own SSD: fully legible.
- Enemy SSD: **estimated** — silhouette, emissions signatures, observed weapon flashes, inferred mounts.
- Sensor operators build a dossier over the course of a battle, and that dossier **persists across battles if your fleet survives**. "We know that cruiser has coilguns on the port arc; we saw it at Eros."
- Emissions management is a real in-combat decision — run cool to hide (at the cost of functionality) or run hot and be seen.

---

## Digital-medium superpowers

Features no cardboard game can do, baked in from v0.1:

- Perfect bookkeeping — no manual energy allocation on paper.
- Conditional orders / standing orders — scales complexity without scaling tedium ("if shields drop below 30%, rotate starboard"; "if locked by seekers, launch decoys").
- Replays as first-class shareable objects with URLs. The best battles become legend.
- Ghost runs — re-plot your orders post-battle to see how it would have gone. Great for learning.
- Fog of war with persistent memory.
- Async PBEM play with configurable turn timers.
- Ship designer with live physics validation.
- Community-shareable ship designs.
- Persistent wear — ammo, armor, crew carry between battles in campaigns.

---

## Faction architecture

**Authored factions on a publicly-visible design framework, drawing from a narrow set of plausible-human variation axes.**

The faction architecture evolved substantially across the conversation. Early versions imagined factions with genuinely different physics (Inertialists, Gravitics, Jumpers, etc.) composed across many metaphysical dimensions. That approach is now **held in reserve** for possible future expansion or sequel — it remains a strong idea, but not for this game's v0.1. See "Held in reserve" below.

What remains: a narrower faction architecture grounded in the 500-year human-plural setting.

### The axes (the "narrowed spheres")

Each faction is a point across roughly five axes, all plausibly human:

- **Gravitational origin.** Earth-heavy, Mars-medium, Belter-microgravity, Europan, Jovian-orbital, Mercurian, free-orbital habitat, frontier-mixed. Shapes ship design, crew rotation, acceleration tolerance, medical requirements.
- **Political/economic structure.** Old-Earth national bloc, Martian republic, Belter collective, corporate sovereign zone, post-state network, frontier polity. Shapes industrial base, doctrinal tradition, fleet composition, strategic tempo.
- **Doctrinal tradition.** Decisive-battle, attritional, distributed-swarm, commerce-raiding, defensive-denial. Shapes tactical behavior and ship role mix.
- **Industrial base philosophy.** Centralized/dreadnought, distributed/swarm, modular/reconfigurable, scavenger-refit. Shapes what ships the faction can field and how they're maintained.
- **AI-integration philosophy.** Where the faction sits on AI-personhood and AI-automation questions. Affects crew-to-automation ratios, AI-assisted tactical decision speed, damage-control approaches, and the character of the fleet.

A sixth candidate axis — **augmentation-level of the crew** — exists but is *capped* by the continuity-of-humanity principle. Factions can vary from baseline to heavily cyborg, but not into uploaded/post-human territory.

### The architectural approach

The conversation considered three forks for how to express faction identity:

- **Fork A: Fixed authored factions, monolithic.** Small roster, no visible axes structure. Tight and balanced but the richness is invisible to the player.
- **Fork B: Full player composition.** Each axis has a menu; players build factions by picking options. Maximally flexible; combinatorially explosive in matchup space; likely unbalanceable.
- **Fork C: Authored factions on a publicly visible axis-framework.** 4-6 curated factions at launch, but the axes-structure is exposed in UI and lore. Each faction is shown as a specific point across the axes, so the framework's shape is visible to the player. New factions added over time as new combinations. **This is the working lean.**

### Why Fork C

- At launch, players get a clean curated experience — authored factions with voice.
- The metaphysics is *legible* — players can see that two factions differ on political structure but share doctrinal tradition. The universe's structure is visible.
- New factions over time feel like illuminating new corners of the map rather than piling on flavor.
- Architecture supports future composition without committing to it.
- **Design discipline follows automatically** — each faction is forced to be a specific point in a shared design language, rather than a messy pile of cool ideas.

### What Fork C means for the first-faction sketch

When we sketch the first faction, the specification takes the form of a declared combination, not a monolithic blob. Example stub (for shape-illustration only, not commitment):

> "First Expeditionary Fleet of the Ceres Collective — Belter-gravitational-origin, Belter-collective political structure, attritional doctrine, distributed-swarm industrial base, AI-integrated philosophy ('ship AIs are crew')."

Every subsequent design decision about these ships — crew-to-automation ratio, habitat module sizing, acceleration ceilings, armor philosophy, weapon mix, UI flavor — flows from that specification. The axes do real work.

---

## Held in reserve

This is a new section, and it's important. Several genuinely strong ideas surfaced in the ideation that are **not** for this game's v0.1. They are preserved here explicitly so that future design (expansions, sequels, or other games) can pick them up cleanly.

### Exotic-physics factions

The idea that different civilizations play under genuinely different physical rules — Inertialists on momentum-hex-or-Newtonian; Gravitics with inertial-compensation and a reactor-budget tradeoff; Jumpers who teleport; Swarms with flocking formation-unit identity; Drifters who manipulate ambient momentum. This is a *strong* idea. It is being held for possible non-human expansion or for a separate future game.

*Why not now:* Multi-physics factions cost roughly as much as multi-games. Each is a separate balance problem, AI development effort, art pipeline, and tutorial. They also strain the WEGO core loop in specific ways (Jumpers break positional reasoning; temporally-aware factions break plot symmetry). Committing to the human-plural-single-physics setting preserves the loop and the scope.

### Full sphere-composition cosmology

The idea of civilizations as vectors across many metaphysical spheres — movement physics, biology, cultural doctrine, temporal relationship, sensor paradigm, power source, scale philosophy, damage-relationship. Players would build custom factions by picking an option in each sphere. Combinatorially rich, structurally original, probably unique in the genre.

*Why not now:* This is the Fork B approach. Beautiful as a cosmological conceit but catastrophic as a launch architecture. A narrower version (the axes above) is in the game. The full version is preserved for future development.

### Uploaded consciousness / post-human factions

Plausible within a 500-1000 year horizon. Genuinely interesting. Explicitly ruled out by the continuity-of-humanity principle because the gameplay experience of fighting uploaded-crew warships would necessarily push toward alien cognition and would crack the "people in ships" frame the rest of the setting depends on.

*Why not now:* Would collapse the asymmetry that makes the edge-mystery work. Preserved for future non-human expansions where that asymmetry can be deliberately crossed.

### First contact with the edge-mystery

The thing at the edge. Whatever it is. Its presence in the gameplay rather than just in the lore.

*Why not now:* Its dramatic weight scales with how long the player has lived inside the cozy-familiar frame of human-vs-human combat. Cashing it in at v0.1 spends it before it's earned. Reserved for an expansion where it can be the center of the experience.

### Empire / strategic / persistent-sector layers

The campaign, the tech tree, the 4X. Originally sketched as a v3-v5 roadmap.

*Why not now:* The tactical game alone is the game at v0.1-v2. Scaling above it is a future optionality if the base game thrives.

---

## Open questions

Forks still genuinely open, roughly in priority order:

### On setting

1. **Political posture at v0.1 opening.** What is actually happening in the solar system when the game starts? Cold war? Active hot war? Pirate suppression? Great powers action? Civil war within a faction? Frontier incidents? This shapes what kind of battles v0.1 is even *about* and should probably be the next substantive conversation.
2. **Edge-mystery specifics in lore.** Even as background flavor, what is the texture? A ship lost with all hands? A signal nobody can classify? A derelict of unknown construction? Something more? How much does the player learn even indirectly?
3. **Tone register.** Grounded-procedural (Expanse-like, professional naval dignity), grim-gritty (Battlestar Galactica bleakness), operatic (Honor Harrington social weight), baroque (Alastair Reynolds strangeness). The setting can support several of these; a choice shapes UI, art, writing voice.
4. **Aesthetic direction.** The Expanse's industrial working-spacecraft look? Something sleeker, like Mass Effect? Something more varied per faction? What about the edge-mystery design language (if/when it appears in lore imagery)?

### On factions

5. **How many factions at launch?** 3? 4? 6? Affects scope substantially and shapes the entire v0-v2 roadmap.
6. **Which specific factions at launch?** The axes constrain the space but don't pick the points. Which combinations get the authored treatment first?
7. **What is the first faction to sketch in detail?** Probably informed by the political posture question.

### On movement and tactical mechanics

8. Symmetric vs. asymmetric thrust budgets (main drive vs. maneuvering thrusters as separate pools)?
9. Plotted whole-turn thrust vs. per-impulse thrust (8-32 impulses per turn)?
10. Engagement scale — light-seconds apart (Expanse-scale) or kilometers apart (Deadlock-scale)?
11. Does a ship ever meaningfully reach zero velocity in the gameplay?
12. 2D or pseudo-3D (elevation bands) at launch?
13. Impulse count per turn — 8 (FedCom-streamlined), 32 (SFB-granular), or between?
14. How expressive should the conditional/standing-order language be? Too simple = limiting; too expressive = a programming language.

### On scope and positioning

15. **Solo-first (campaign) or PvP-first (skirmish)?** Deadlock leaned solo; Nebulous leaned PvP. Tentative lean: solo-first with PvP added once AI is strong. Still contested.
16. How loud is the RPG knob at v1? Named crew, captain careers, ship logs — how deep?
17. Map terrain — asteroids, debris fields, radiation zones, ECM-scattering gas clouds, gravity wells. Which make v1? Does battle wreckage persist as terrain within a battle?
18. What is the v0.1 scenario set? A one-ship-vs-one-ship duel is the proof-of-concept; what fiction does it sit in?

---

## Decided / Leaning / Open summary

### Decided

- **Scope:** Capped at v0-v2. No empire layer, no tech tree.
- **IP:** Original, not licensed.
- **Turn structure:** WEGO plot-and-execute.
- **Primary interface:** SSD-centric gameplay.
- **Architecture:** Async-native from day one.
- **Replays:** First-class shareable objects.
- **Setting horizon:** 500 years from now, solar system, no FTL.
- **Humanity:** Plural, diverged within continuity — physiologically, politically, culturally, technologically.
- **Continuity-of-humanity principle:** Factions must be recognizably "people making hard choices." Uploaded consciousness, hive minds, full-AI factions, speciation-level divergence are out of scope.
- **AI in setting:** Integrated into humanity's story, not separate. Personhood is contested in-universe, not resolved.
- **Edge-mystery:** Present in lore only at v0.1. Reserved for future expansions.
- **Movement model:** Continuous Newtonian, free coordinates, with rich digital planning UI (velocity arrows, ghost projections, reachable-region envelopes, quantized effect thresholds).
- **No exotic-physics factions at launch.** Held in reserve.

### Working leans (argued for but not formally committed)

- Fork C for faction structure (authored factions on publicly visible axes).
- Faction axes: gravitational origin, political/economic structure, doctrinal tradition, industrial base philosophy, AI-integration philosophy (+ capped augmentation as a sixth).
- Per-impulse thrust with presets.
- Solo-first campaign with PvP strong from launch.
- Elevation bands deferred to post-launch.
- Faction-flavored SSD presentation on a shared underlying systems engine.

### Wide open

- Political posture at v0.1 opening.
- Number and identities of launch factions.
- Tone and aesthetic direction.
- Edge-mystery specifics in lore.
- All the remaining tactical sub-questions (thrust budget structure, engagement scale, impulse count, etc.).
- First-faction-sketch target.

---

## Suggested next ideation sessions

Two candidates for the next session, in recommended order:

1. **Political posture at v0.1 opening.** What is actually happening in the solar system when the game begins? This answer shapes what battles v0.1 is about, which shapes which factions need to exist for launch, which shapes what the first faction sketch should look like. This is probably the next step.
2. **First-faction sketch**, once the political posture is set. Pick a specific combination across the faction axes and design a real faction — ship roles, SSD flavor, doctrinal behavior, signature weapons, visual identity. This pressure-tests whether the axes framework actually produces interesting distinct factions under the continuity-of-humanity constraint.

Both should happen before committing to any engine work.