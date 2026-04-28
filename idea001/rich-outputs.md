<div align="center">

<img src="assets/divider-blueprint.svg" alt="" width="100%">

# Rich outputs

*Companion document to [README.md](./README.md). Agents producing visualizations, diagrams, charts, and mind maps as first-class outputs alongside text.*

<img src="assets/divider-blueprint.svg" alt="" width="100%">

</div>

## Why this is core, not a side feature

A lot of ideation is text — like the conversations that produced this README. But a lot of it isn't. Some ideas only become legible when you can *see* them:

- The supersession history of a claim renders as a graph
- The project's open questions form a mind map
- An architectural sketch lives as a diagram
- Comparative data wants a chart, not a table-in-prose
- A user flow needs to be drawn, not described

These visualizations are not summaries of work — they *are* the work, captured in a form that text cannot carry. Treating them as "files agents happen to write" buries the most distinctive thing the product can do. Treating them as a primary output reshapes the engine.

The framing in [README.md](./README.md):

> Agents are research assistants, not chat partners. They produce visualizations alongside their textual responses. Visualization is a first-class output, not a side feature.

This document is the design behind that framing.

<img src="assets/divider-blueprint.svg" alt="" width="100%">

## What "rich outputs" means concretely

The artifact types Think Tank cares about, from cheapest to hardest:

| Type | Format | Why this one | Cost / risk |
|---|---|---|---|
| **Mermaid diagrams** | `.mmd` text | Flowcharts, sequence diagrams, state machines, class diagrams. Models produce it well; renders everywhere. | Low. Validation is "does it parse?" |
| **Mermaid mindmaps** | `.mmd` text | Hierarchical thinking, brainstorm capture, project topology. Cheap and effective. | Low. |
| **GraphViz DOT** | `.dot` text | When the graph is too dense or non-tree-shaped for Mermaid. Better layout for complex graphs. | Low–medium. Models are competent. |
| **Vega-Lite chart specs** | `.json` | Comparison charts, scatter plots, bar charts, time series. Spec-driven, declarative. | Medium. Schema validation is real. |
| **Markmap mindmaps** | `.md` with frontmatter | Markdown-native mindmap; convertible to/from outlines. | Low. |
| **Tables** | Markdown or CSV | Structured comparisons. Already in agent output naturally. | Trivial. |
| **SVG** | `.svg` text | Custom illustrations, mocks, schematic drawings. | Medium–high. Models hallucinate SVG more than text-based formats. |
| **HTML mocks** | `.html` | UI mocks, layout sketches, interactive examples. | Medium. |
| **Structured data** | `.json`, `.csv` | Datasets agents produce or curate as part of research. | Low. |
| **Image generation** | `.png`, `.jpg` | When pure text-based formats can't carry the idea. | High. Different APIs (DALL-E, Stable Diffusion via API), different costs, different failure modes. Defer. |

The first batch (Mermaid, GraphViz, Vega-Lite, tables, markmap) is where the artifact subsystem starts. They share important properties: text-based sources, cheap to produce, easy to validate, render anywhere. Image generation is deferred until the cheaper formats prove their worth.

<img src="assets/divider-blueprint.svg" alt="" width="100%">

## The artifact subsystem

In the current design, `artifacts/` is a folder. With rich outputs as core, it becomes a real subsystem with several responsibilities.

### Identity and metadata

Every artifact has a record in `state.json`:

```json
{
  "id": "art_004",
  "type": "mindmap",
  "format": "mermaid",
  "path": "artifacts/mindmaps/design-commitments.mmd",
  "represents": ["claim_001", "claim_002", "claim_007"],
  "generated_by": "anthropic:claude-opus-4-7",
  "generated_at": "2026-04-29T15:42:00Z",
  "generated_from_prompt": "prompts/visualize/mindmap.md",
  "stale": false,
  "stale_reason": null
}
```

The `represents` field is the link back to the structured concepts in `state.json`. It's how the engine knows which artifacts to mark stale when claims change, which artifacts to render alongside which sections, and which artifacts need regenerating.

### The artifact type registry

Each supported artifact type has a registry entry:

```python
artifact_types = {
    "mermaid_flowchart": {
        "extension": ".mmd",
        "subdirectory": "diagrams",
        "validator": validate_mermaid,
        "renderer_html": render_mermaid_to_html,
        "preferred_models": [
            "anthropic:claude-opus-4-7",
            "openai:gpt-5",
        ],
        "fallback_models": ["google:gemini-3"],
        "max_retries_on_validation_failure": 2,
    },
    "vega_lite_chart": {
        "extension": ".json",
        "subdirectory": "charts",
        "validator": validate_vega_lite_schema,
        "renderer_html": render_vega_inline,
        "preferred_models": ["anthropic:claude-opus-4-7"],
        "fallback_models": ["openai:gpt-5"],
        "max_retries_on_validation_failure": 2,
    },
    # ...
}
```

Why the registry matters:

- **Validators are different per type.** Mermaid is "does it parse?" Vega-Lite is "does it match the schema?" SVG is more involved. Each type owns its validation.
- **Models have different competence per type.** Real evaluation will tell you that Anthropic is better at Mermaid mindmaps and OpenAI is better at Vega-Lite, or vice versa. The registry encodes this so artifact-generation passes route to the right model automatically.
- **Renderers are per type.** Mermaid renders via mermaid.js; Vega-Lite via vega-embed; charts via chart.js. The HTML render bundle picks the right renderer per artifact type without the engine caring.
- **Subdirectory placement is consistent.** Agents always know where to put a flowchart (`artifacts/diagrams/`) vs. a chart (`artifacts/charts/`). The render layer always knows where to find them.

### Validation is mandatory, not optional

Hallucinated artifact sources are a real risk. A Mermaid diagram that doesn't parse looks fine in `git diff` (it's text!) but renders as nothing. A Vega-Lite spec that's missing a required field renders as an error. The engine validates every artifact before committing it:

```
1. Agent produces source
2. Engine validates source against the type's validator
3. If valid: write to disk, record in state.json
4. If invalid: retry with the same prompt up to max_retries
5. If still invalid: route to fallback model
6. If still invalid: surface the failure to the user; do not write
```

The discipline: better to have no artifact than a broken one. Broken artifacts that get committed are worse than no artifacts because they look authoritative and are silently wrong.

### Staleness tracking

When `state.json` changes — a claim is superseded, an open question is resolved, a decision is reversed — the engine identifies which artifacts are tied to the affected concepts and flags them stale:

```json
{
  "id": "art_004",
  "stale": true,
  "stale_reason": "Represents claim_007, which was superseded by claim_011 on 2026-05-04."
}
```

Stale artifacts:
- Are visually marked in the HTML render bundle (faded, with a "regenerate" hint)
- Show up in `tt review --stale` for sweep-and-regenerate workflows
- Are never silently auto-regenerated — that would burn provider calls without user awareness

The user decides whether stale artifacts get regenerated, archived, or simply marked as historical.

<img src="assets/divider-blueprint.svg" alt="" width="100%">

## Artifact generation as a separate role

The synthesizer's job is already complex: read multiple agent responses, surface disagreements, propose state mutations, decide claim supersessions. Adding "produce visualizations" to the synthesizer would push quality down across the board.

So artifact generation is its own role with its own prompt, its own model preferences, and its own validation:

```
USER: "Visualize the project's design commitments as a mindmap."

ENGINE assembles:
  [base system prompt]
  [role: artifact_generator]
  [mode: visualize]
  [artifact type spec: mermaid_mindmap, with format examples]
  [project context: relevant claims, glossary terms]
  [user turn: visualize design commitments]

AGENT (claude-opus-4-7) produces Mermaid source.

ENGINE validates → success.
ENGINE writes artifacts/mindmaps/design-commitments.mmd
ENGINE updates state.json with art_004 record.
```

The artifact-generator role is also where future specialization lives:

- "Visualize as a mindmap" routes to the model that's best at Mermaid mindmaps
- "Visualize as a graph" routes to the model that's best at GraphViz DOT
- "Compare X and Y as a chart" routes to the model that's best at Vega-Lite

This is the same pattern as the synthesizer being potentially configurable per project — different roles want different models, and the registry encodes that without requiring per-call decisions.

<img src="assets/divider-blueprint.svg" alt="" width="100%">

## Render targets

The engine produces sources. Rendering happens above the engine, at the consumer layer. This is the "rich data, not display strings" discipline applied to artifacts.

| Consumer | What it does with an artifact |
|---|---|
| CLI | Prints the path; optionally opens in `$EDITOR` or via `open <path>` |
| HTML render bundle | Renders inline alongside the claim it represents |
| Future TUI | Shows source code or a rendered preview if terminal supports it |
| Future web UI | Renders interactively; allows zoom, edit, regenerate |
| Future API consumers | Serve the source; let frontend render |

The engine never decides how an artifact is displayed. The same `art_004` Mermaid source serves all five consumers.

### The HTML render bundle

The intermediate step between "CLI only" and "real UI" is a single HTML file the engine generates:

```
~/thinktank/<project>/render.html
```

This file is self-contained — embedded CSS, embedded mermaid.js / vega-embed / chart.js, links to all artifacts in the project. Open it in any browser and you see:

- The current `verdict.md` and `gist.md` rendered at the top
- Each claim with its associated artifacts rendered inline
- The glossary with cross-links
- The supersession graph as a rendered diagram (regenerated automatically)
- Stale artifacts visually marked

Regenerated by `tt render` or automatically after every state change. No server, no build step, no frontend framework. Just one HTML file you open.

This is critical for two reasons:

**It gets rich-output viewing working before any UI investment.** You can see whether the visualization workflow is actually valuable without committing to a Vue / React / Svelte frontend. If `render.html` does the job for the first six months, that's six months of avoided UI work.

**It generates the data needed to decide whether real UI is worth building.** If you keep wishing you could "click on a claim and edit it inline," the render bundle has earned its way into needing to become interactive. If you don't, it hasn't.

<img src="assets/divider-blueprint.svg" alt="" width="100%">

## Why this is Layer 2.5, not Layer 3

In the original [build plan](./README.md#build-plan), visualization was a single bullet near the end of Layer 3, alongside UI work and search and sub-agents. That ordering was wrong.

The correct sequencing:

- **Layer 2** (weekend prototype): Text-only loop. Agents respond, synthesizer mutates state, summaries get generated. Validate that the basic workflow has value.
- **Layer 2.5** (artifact subsystem): Add rich outputs. Agents produce visualizations alongside text. HTML render bundle for viewing. *No UI yet.*
- **Layer 3** (schema and interface): Schema refinement, interactive UI if needed, advanced features.

Why 2.5 comes before any UI:

- Rich outputs are part of *what the product does*, not part of *how you view it*. They belong with the engine work, not the interface work.
- The HTML render bundle proves whether visualizations are useful before any frontend decisions get made.
- Building UI before knowing what kinds of artifacts the product produces is backwards — the UI's job is to render the artifacts, so the artifacts have to come first.
- Adding rich outputs after a UI is built is harder than adding them before — every artifact type requires UI work as well as engine work.

Layer 2.5 is what turns Think Tank from "structured text deliberation" into "research assistant with visual outputs." It's the smaller of the two transitions; the bigger one is from Layer 2 to 2.5.

<img src="assets/divider-blueprint.svg" alt="" width="100%">

## Cost and restraint

Visualizations are expensive — both per-call cost (artifact-generation passes are extra model calls beyond the synthesis pass) and cognitive cost (too many diagrams obscure rather than clarify).

Design choices that follow:

- **Visualizations are on-demand, not automatic.** The engine doesn't generate diagrams every turn. The user (or a synthesizer suggestion) explicitly requests them.
- **One visualization per concept, regenerated when stale.** Not "three competing visualizations of the same claim from three agents." The synthesis pattern (multiple agents → one consolidated output) applies here too: multiple agents could produce competing visualizations, but the artifact-generator role consolidates them into one canonical output.
- **Bias toward fewer, richer artifacts.** The tool should encourage one well-thought-out mindmap of the whole project's structure over twenty tiny diagrams. The synthesizer can suggest "this might be worth visualizing" rather than auto-generating.
- **Cost surfacing.** When a visualization would be expensive (image generation, especially), show the user what it would cost before committing.

<img src="assets/divider-blueprint.svg" alt="" width="100%">

## What to track during real use

A running notes file specifically about rich outputs:

- [ ] Which artifact types got used most? Those are the ones to invest in.
- [ ] Which artifact types got requested but produced bad output? Those need better validation, better prompts, or different model preferences.
- [ ] Did the HTML render bundle do the job, or did you keep wishing for interactivity?
- [ ] Did you feel like the project was over-visualized (sprawl) or under-visualized (text-heavy)?
- [ ] Did stale-marking surface real problems, or was it noise?
- [ ] Did one model dominate as best-at-visualizations, or did it vary by type?
- [ ] Were there artifact types you wanted that aren't in the registry yet?
- [ ] Did artifacts as part of the structured state actually help, or did they feel grafted on?

These answers feed the decision about whether to invest in interactive UI in Layer 3 or whether the render bundle is sufficient long-term.

<img src="assets/divider-blueprint.svg" alt="" width="100%">

<div align="center">

*Companion doc to [README.md](./README.md). See also [`domain-model.md`](./domain-model.md), [`prompts.md`](./prompts.md), and [`stack-decisions.md`](./stack-decisions.md).*

</div>
