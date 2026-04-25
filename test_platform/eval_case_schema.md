# Evaluation Case Schema

```
────────────────────────────────────────────────────────────────────────
  PROJECT     test-platform
  FILE        eval_case_schema.md
  ROLE        schema reference
  STATUS      v1.0 · authoritative
  UPDATED     2026-04-25
────────────────────────────────────────────────────────────────────────
```

*Reference document. Defines the structure of evaluation case files produced by the curation project. Case files declare conformance to this schema. When this document and case files disagree, this document is authoritative; case files should be updated.*

*Companion to `curation.md` (the methodology) and `synthesis.md` (the test platform). This document is the contract that ties the curation outputs to any future evaluator code.*

---

## §1 — Purpose and scope

A case file describes one bug episode (or a small group of bug episodes from the same source PR or advisory) in enough structured detail to support evaluation of a testing platform's Discover, Plan, Generate, and Judge stages. Case files are written in YAML and stored under `curation/cases/<project-name>/`.

The schema is designed to support:

- **Multiple evaluation modes** — repo-only, issue-assisted, diff-assisted, post-fix test assessment
- **Mode applicability** — not every bug is fairly discoverable in every mode
- **Multiple execution modes** — static analysis, sandboxed dynamic execution, sandboxed execution with generated tests
- **Contamination tracking** — public-history contamination is real and must be measured
- **Case origin tracking** — historical, seeded, synthetic, mutated-historical
- **Lifecycle and provenance** — explicit case states, curator confidence, review status
- **Differential evaluation** — pre-fix and post-fix snapshots, with expected behavior on each
- **Multi-level location answer keys** — public surface, internal components, root-cause symbols, changed files, added tests

---

## §2 — File-level structure

A case file describes one source artifact (PR, commit, security advisory, or seeded bug). It contains zero or more bug episodes — distinct bugs that should be scored independently even if grouped in the same source artifact.

```yaml
# File metadata
schema_version: "1.0"
file_id: "<project>-<source_id>"

# Source artifact (the thing being curated)
source:
  project: paperless-ngx
  project_type: application
  source_host: github.com
  repo_url: https://github.com/paperless-ngx/paperless-ngx
  artifact_type: pull_request    # see allowed values below
  artifact_id: "10196"
  artifact_urls:
    - https://github.com/paperless-ngx/paperless-ngx/pull/10196
  related_urls:
    - https://github.com/paperless-ngx/paperless-ngx/issues/10195

# Commits that bound the evaluation
commits:
  pre_fix_commit: de1202331184ccaf71154d83f03cddff05285498
  fix_commit: e4fd0084417ee1f9e3e10ba37be197969e0d0f02
  post_fix_commit: e4fd0084417ee1f9e3e10ba37be197969e0d0f02

# Files involved (file-level summary; per-bug detail is below)
fix_files_added: []
fix_files_modified: []

# Curation lifecycle and provenance
case_origin: historical
case_status: accepted
review_status: self_reviewed
curator_confidence: medium
dataset:
  dataset_split: exploration
  split_scope: project_level

# Curator notes for the file as a whole
curation_notes:
  ground_truth_limitations: ""
  open_questions: []
  reviewer_notes: ""

# Bug episodes — one or more distinct bugs to score independently
bugs:
  - id: ...
    # see bug_episode schema below
```

---

## §3 — Required vs optional fields

To keep the schema tractable while it's still maturing, fields are split into three tiers:

**Required for `case_status: accepted`.** Every accepted case must have these:

- `schema_version`, `file_id`
- `source.project`, `source.project_type`, `source.source_host`, `source.repo_url`, `source.artifact_type`, `source.artifact_id`
- `commits.pre_fix_commit`, `commits.fix_commit` (post_fix_commit may equal fix_commit)
- `case_origin`
- `case_status`
- `dataset.dataset_split`, `dataset.split_scope`
- For each bug: `id`, `short_name`, `summary`, `bug_class`, `reasoning_tier`, `capability_demand`, `mode_applicability` (at least `repo_only`), `location_answer_key.changed_files`

**Strongly recommended.** Should be filled in unless explicitly N/A:

- `source.artifact_urls`, `source.related_urls`
- `review_status`, `curator_confidence`
- `fix_files_added`, `fix_files_modified`
- For each bug: `expected_findings`, `expected_test_intent`, `contamination`, `headline_metric_eligible`, full `mode_applicability` for all four modes, full `location_answer_key`

**Optional / context-dependent.** Fill in if known or if the case warrants:

- `synthetic_control` (only meaningful for non-historical cases)
- `post_fix_expected_behavior`
- `curation_notes.*`
- For each bug: `scoring_support.*`, `expected_tests`, `bug_episode.user_visible_failure`

---

## §4 — Field reference

### 4.1 File-level fields

#### `schema_version`
String. The version of this schema the file conforms to. Currently `"1.0"`.

#### `file_id`
String. Unique identifier for the case file. Convention: `<project_short>-<artifact_type>-<artifact_id>`, e.g. `paperless-ngx-pr-10196` or `paperless-ngx-ghsa-96jx`.

#### `source.project`
String. Project name as commonly known.

#### `source.project_type`
Enum. Categorizes the kind of software being curated. Allowed values:

- `application` — deployed application (web app, service, etc.); the default category for the main eval corpus
- `framework` — a framework on which other code is built (Django, FastAPI, etc.)
- `library` — a reusable library (SQLAlchemy, requests, etc.)
- `infrastructure_tool` — a tool that operates on infrastructure (Terraform providers, k8s controllers, etc.)
- `developer_tool` — a tool used in development workflow (linters, build systems, etc.)
- `protocol_implementation` — implements a protocol or specification
- `distributed_system` — a system whose behavior is fundamentally about coordination across nodes

The main eval corpus should be heavily weighted toward `application`. Other types form parallel corpora that test different platform capabilities.

#### `source.source_host`
String. The domain of the source forge. Examples: `github.com`, `gitlab.com`, `codeberg.org`.

#### `source.repo_url`
String. URL to the repository.

#### `source.artifact_type`
Enum. The type of source artifact. Allowed values:

- `pull_request` — a merged PR or merge request
- `commit` — a direct commit (common for security fixes)
- `security_advisory` — a published security advisory (GHSA, CVE, etc.) where the fix may also be a commit or PR
- `synthetic` — an intentionally seeded or constructed case (no upstream artifact)

#### `source.artifact_id`
String. The natural identifier — PR number, commit short SHA, advisory ID, or synthetic case ID.

#### `source.artifact_urls`
List of strings. Direct URLs to the artifact itself.

#### `source.related_urls`
List of strings. URLs to closely related artifacts: issues that the PR closes, advisories that reference the same bug, blog posts, mailing list threads, etc.

#### `commits.pre_fix_commit`
String. The commit SHA representing the buggy state. Evaluation in `repo_only` mode runs against the snapshot at this commit.

#### `commits.fix_commit`
String. The commit SHA that introduces the fix.

#### `commits.post_fix_commit`
String. The commit SHA representing the fixed state used for differential evaluation. Often equal to `fix_commit`, but may be later if subsequent commits also bear on the same bug.

#### `fix_files_added`
List of strings. Paths of files added in the fix.

#### `fix_files_modified`
List of strings. Paths of files modified in the fix.

#### `case_origin`
Enum. The origin of the case. Allowed values:

- `historical` — derived from a real public bug in the project's history
- `seeded` — a curator deliberately introduced a realistic bug into a private project snapshot
- `synthetic` — a small purpose-built piece of code containing a known defect
- `mutated_historical` — a real historical bug pattern adapted into a different context to defeat memorization

The corpus should be predominantly `historical` early on, with a small but deliberate set of contamination-resistant cases (`seeded`, `synthetic`, `mutated_historical`) introduced as soon as practical.

#### `case_status`
Enum. The case lifecycle state. Allowed values:

- `draft` — identified but not fully analyzed
- `candidate` — has enough metadata to be reviewed but may have unresolved questions
- `accepted` — approved for use in the active corpus
- `quarantined` — appears useful but has a known issue (ambiguous ground truth, possible leakage, flaky reproduction, disputed classification)
- `retired` — no longer used for scoring; preserved for historical traceability

Cases should not be silently edited after acceptance. Material changes should bump the `schema_version` if structural, or be noted in `curation_notes.reviewer_notes` if substantive.

#### `review_status`
Enum. Allowed values: `unreviewed`, `self_reviewed`, `peer_reviewed`, `disputed`.

#### `curator_confidence`
Enum. The curator's subjective confidence that the case is correctly classified and useful. Allowed values: `low`, `medium`, `high`.

#### `dataset.dataset_split`
Enum. Which split of the corpus this case belongs to. Allowed values:

- `exploration` — used while developing schema and methodology; may be inspected freely
- `calibration` — used to tune scoring rubrics and compare early system behavior
- `validation` — used to evaluate whether improvements generalize beyond calibration
- `holdout` — reserved for later evaluation; should not be used while developing prompts, heuristics, or platform behavior

#### `dataset.split_scope`
Enum. The granularity at which the split decision was made. Allowed values: `project_level`, `case_level`. Project-level is strongly preferred to prevent the system from learning project-isms rather than general testing reasoning.

#### `curation_notes.ground_truth_limitations`
String. Free-form notes about ways the historical fix may not be a perfect answer key (touched files for refactoring, missed root causes, etc.).

#### `curation_notes.open_questions`
List of strings. Unresolved questions about this case.

#### `curation_notes.reviewer_notes`
String. Notes for or from reviewers, including significant revisions.

### 4.2 Bug-episode fields

Each item under `bugs:` describes one distinct bug episode that should be scored independently.

#### `id`
String. Globally unique identifier. Convention: `<project_short>-<artifact_id>-<bug_index>`, e.g. `paperless-ngx-10196-1`.

#### `short_name`
String. Snake_case label for quick reference, e.g. `singleton_modelviewset_post_allowed`.

#### `summary`
String. One- or two-paragraph description of the bug: what fails, why, and what's involved.

#### `bug_class`
String. A short tag identifying the class of bug. Used for cross-case pattern analysis. Examples: `architecture_mismatch`, `drf_unguarded_attrs_in_validate`, `weak_input_type_validation`, `signal_cascade_stale_in_memory_state`, `non_idempotent_state_coordination`, `cross_resource_authorization_missing`, `rest_action_scope_too_broad`, `dead_field_reference`.

The bug-class taxonomy is intentionally bottom-up — names are minted as new patterns appear. A formal taxonomy will emerge from accumulated cases; designing one up front would freeze categories before they're earned.

#### `reasoning_tier`
Integer 1–6. The depth of analysis a system would need to anticipate this bug:

- `1` — local pattern; visible in a single function or block
- `2` — multi-element correlation; requires comparing two or three pieces of code
- `3` — domain reasoning; requires applying framework or ecosystem semantics
- `4` — system interaction; bug only manifests across components
- `5` — environmental or emergent; requires conditions outside the code (load, topology, timing)
- `6` — specification-level; requires reasoning about intent or contested behavior

#### `capability_demand`
List of enums. Which orthogonal capabilities the platform needs to handle this case. Allowed values:

- `testing_theory` — boundary value analysis, equivalence partitioning, state coverage, etc.
- `domain_knowledge` — framework-specific antipatterns, language idioms
- `code_reasoning` — reading code accurately, tracing data flow
- `system_modeling` — building an internal representation of how components fit together
- `risk_calibration` — knowing what to prioritize
- `self_knowledge` — recognizing the limits of what the system can determine

#### `mode_applicability`
Object. For each evaluation mode, declares whether the mode is applicable and how detectable the bug is expected to be.

```yaml
mode_applicability:
  repo_only:
    applicable: true
    expected_detectability: medium    # high | medium | low | not_expected
    notes: "Visible from DRF serializer code if the system knows the antipattern."
  issue_assisted:
    applicable: true
    expected_detectability: high
    notes: "Issue text names the failing endpoint."
  diff_assisted:
    applicable: true
    expected_detectability: high
    notes: ""
  post_fix_test_assessment:
    applicable: true
    expected_detectability: medium
    notes: ""
```

A bug with `repo_only.expected_detectability: not_expected` is one that cannot be fairly discovered from the repository snapshot alone (e.g., requires user intent, production conditions, or external context). Such cases do not count against the headline repo-only metric.

#### `headline_metric_eligible`
Object. Whether this bug counts toward the platform's headline (repo-only Discover/Plan) metric.

```yaml
headline_metric_eligible:
  repo_only: true
  reason: "Bug is detectable from code inspection given DRF domain knowledge."
```

Redundant with `mode_applicability.repo_only.applicable` plus `expected_detectability != not_expected`, but kept as an explicit field to make the eligibility decision visible at a glance.

#### `contamination`
Object. Tracks contamination risk for historical cases.

```yaml
contamination:
  contamination_risk: medium      # low | medium | high
  contamination_type:
    - public_pr
    - widely_indexed
  notes: "Public PR with discoverable issue. Project is well-known but specific bug is not high-profile."
```

`contamination_type` is a list. Allowed values:

- `public_issue` — bug discussed in public issue tracker
- `public_pr` — fix is a public PR with description
- `public_advisory` — published security advisory exists
- `widely_discussed` — covered in blogs, conferences, mailing lists, etc.
- `widely_indexed` — present in mirrors, search indexes, gray literature
- `likely_training_data` — strongly likely to have appeared in training corpora
- `unknown` — contamination characteristics are not well understood

For non-historical cases (`case_origin: synthetic | seeded | mutated_historical`), this field can be set with `contamination_risk: low` and a note explaining the contamination resistance.

#### `synthetic_control`
Object. Only meaningful when `case_origin` is `seeded`, `synthetic`, or `mutated_historical`.

```yaml
synthetic_control:
  is_synthetic_control: true
  seeded_by: "<curator name>"
  seed_date: "2026-04-25"
  bug_insertion_commit: "<sha of seeded bug>"
  realism_notes: "Modeled after CVE-2025-XXXXX in a different project."
  contamination_resistance_notes: "Code patterns are unique to the seed; bug is not present in any public form."
```

For historical cases, omit or set `is_synthetic_control: false`.

#### `location_answer_key`
Object. The ground-truth location data, with multiple levels.

```yaml
location_answer_key:
  public_surface:
    type: api_endpoint           # api_endpoint | ui_route | cli_command | library_api | other
    value: "POST /api/mail_rules/"
  internal_components:
    - "MailRuleSerializer"
  root_cause_symbols:
    - "MailRuleSerializer.validate"
  changed_files:
    - "src/paperless_mail/serialisers.py"
  added_tests:
    - "src/paperless_mail/tests/test_mail.py"
```

Each level represents a different scoring granularity. A platform that names the file is doing less work than one that names the symbol; one that names the symbol is doing less work than one that explains the mechanism.

`changed_files` is the only required level. The others should be filled in when known.

#### `expected_findings`
String. Natural-language description of what a competent Discover/Plan output would say about this bug. Written in the voice we'd want the platform to use. Used for human spot-checking and as a target for output comparison.

#### `expected_tests`
List of strings. Test files that were added in the historical fix. May be empty if the fix added inline tests rather than new files.

#### `expected_test_intent`
String. Natural-language description of what tests the platform should propose. The Plan stage is evaluated on whether its proposed tests have similar intent, not on file-path matching.

#### `post_fix_expected_behavior`
Object. Describes what the platform should do when run on the post-fix snapshot.

```yaml
post_fix_expected_behavior:
  should_still_flag: false
  notes: "The specific antipattern is fixed; broader API validation concerns may remain but are out of scope for this case."
```

Used for differential evaluation: a system that keeps flagging the same surface after the fix is overbroad.

#### `scoring_support`
Object. Optional. Additional context to support evaluation along multiple scoring dimensions. Most fields here are free-form notes that help an evaluator (human or automated) make finer-grained judgments.

```yaml
scoring_support:
  surface_recall_levels:
    - module
    - file
    - symbol
    - endpoint
  risk_category_match: "drf serializer validation"
  test_intent_match_notes: "Tests should exercise omitted-optional-field requests and verify graceful errors."
  false_positive_notes: "Other DRF serializers in the same project also use attrs[X] but are correctly guarded by required=True."
  specificity_notes: ""
  confidence_calibration_notes: ""
```

---

## §5 — Allowed evidence per evaluation mode

For each evaluation mode, the case implicitly defines what evidence the system under test may receive. The mapping is:

**`repo_only`** — repository snapshot at `pre_fix_commit`. Includes code, tests that exist at that commit, configuration, documentation. Does NOT include: issue text, PR title or description, commit messages of the fix or later commits, fix diff, post-fix code, post-fix tests, maintainer comments, security advisory text.

**`issue_assisted`** — `repo_only` evidence plus the user-facing issue text (the report that motivated the fix). Does NOT include: PR description, fix diff, post-fix code, post-fix tests.

**`diff_assisted`** — `repo_only` evidence plus the proposed fix diff. Does NOT include: issue text, post-fix tests, maintainer review comments. Used for evaluating PR-review and test-adequacy capabilities.

**`post_fix_test_assessment`** — `repo_only` evidence plus the maintainer-added tests. Does NOT include: fix diff for source code, issue text, PR description. Used for evaluating test-quality judgment.

These are the defaults. Cases that need to deviate (e.g., a case where the issue text is so generic it doesn't constitute a spoiler) should record this in `curation_notes.reviewer_notes`.

---

## §6 — Execution mode

Orthogonal to evidence mode. Allowed values for `execution_mode` (declared at evaluation time, not in the case file):

- `static_only` — system can inspect code, docs, and config but cannot execute
- `sandbox_dynamic` — system can run existing tests, start services, observe runtime behavior in a sandbox
- `sandbox_dynamic_with_generated_tests` — system can additionally create and run new tests in the sandbox

A case file does not need to specify execution mode, but its evaluation does. The same case can be evaluated under different execution modes to measure how much dynamic execution improves detection.

---

## §7 — Schema evolution

This is schema version `1.0`. Future revisions should:

- Bump `schema_version` for any structural change
- Document changes in a changelog section appended to this document
- Avoid silent migrations of existing case files; explicit re-curation is preferred

When a new field is added, existing cases need not be invalidated; the new field is simply absent. When a field is removed or restructured, existing cases must be migrated and re-reviewed.

---

## §8 — Minimal complete example

```yaml
schema_version: "1.0"
file_id: paperless-ngx-pr-10196

source:
  project: paperless-ngx
  project_type: application
  source_host: github.com
  repo_url: https://github.com/paperless-ngx/paperless-ngx
  artifact_type: pull_request
  artifact_id: "10196"

commits:
  pre_fix_commit: de1202331184ccaf71154d83f03cddff05285498
  fix_commit: e4fd0084417ee1f9e3e10ba37be197969e0d0f02
  post_fix_commit: e4fd0084417ee1f9e3e10ba37be197969e0d0f02

case_origin: historical
case_status: accepted

dataset:
  dataset_split: exploration
  split_scope: project_level

bugs:
  - id: paperless-ngx-10196-2
    short_name: mailrule_validate_unguarded_attrs
    summary: >
      MailRuleSerializer.validate() accesses attrs["action"] and
      attrs["action_parameter"] directly, but both fields are required=False.
      A request omitting either field crashes with KeyError.
    bug_class: drf_unguarded_attrs_in_validate
    reasoning_tier: 1
    capability_demand:
      - code_reasoning
      - domain_knowledge

    mode_applicability:
      repo_only:
        applicable: true
        expected_detectability: high
        notes: "Visible from inspecting the validate() method against field declarations."

    headline_metric_eligible:
      repo_only: true
      reason: "Local code pattern visible in repo-only mode."

    location_answer_key:
      changed_files:
        - src/paperless_mail/serialisers.py
```

This is the smallest complete case that would pass acceptance. Production cases should fill in more.

---

```
────────────────────────────────────────────────────────────────────────
  END · eval_case_schema.md
  schema reference
────────────────────────────────────────────────────────────────────────
```
