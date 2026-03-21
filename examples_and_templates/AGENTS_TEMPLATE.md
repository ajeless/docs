# AGENTS.md Template

Use this template as a drop-in `AGENTS.md` for repositories that use AI-assisted coding agents (for example: Codex, Claude Code, Cursor Agents, Copilot Agents).

Replace all placeholders in `<UPPER_SNAKE_CASE>`.

## 1. Project Overview

### Mission
`<PROJECT_NAME>` exists to `<ONE_SENTENCE_MISSION>`.

### Goals
- `<GOAL_1>`
- `<GOAL_2>`
- `<GOAL_3>`

### Non-Goals
- `<NON_GOAL_1>`
- `<NON_GOAL_2>`

## 2. Repository Structure

### Top-Level Layout

| Path | Purpose | Agent Notes |
|---|---|---|
| `/src` | `<CORE_APPLICATION_CODE>` | `<SAFE_TO_EDIT_OR_LIMITS>` |
| `/tests` | `<AUTOMATED_TESTS>` | `<TEST_EXPECTATIONS>` |
| `/docs` | `<PROJECT_DOCUMENTATION>` | `<STYLE_OR_SCOPE>` |
| `/scripts` | `<UTILITY_SCRIPTS>` | `<EXECUTION_RULES>` |
| `/infra` | `<DEPLOYMENT_INFRA>` | `<HIGH_RISK_OR_REVIEW_RULES>` |

### Ownership Map

| Area | Primary Owner | Backup Owner | Escalation Channel |
|---|---|---|---|
| `<AREA_1>` | `<PERSON_OR_TEAM>` | `<PERSON_OR_TEAM>` | `<SLACK_OR_EMAIL>` |
| `<AREA_2>` | `<PERSON_OR_TEAM>` | `<PERSON_OR_TEAM>` | `<SLACK_OR_EMAIL>` |

## 3. Technology Stack

### Languages & Runtime
- Language(s): `<LANGUAGES>`
- Runtime(s): `<RUNTIMES_AND_VERSIONS>`

### Frameworks & Libraries
- `<FRAMEWORK_1>`
- `<FRAMEWORK_2>`
- `<KEY_LIBRARY_1>`

### Tooling
- Package manager: `<PNPM_NPM_YARN_PIP_UV_BUNDLER_ETC>`
- Linter: `<LINTER>`
- Formatter: `<FORMATTER>`
- Type checker: `<TYPECHECKER_OR_NA>`
- Test framework: `<TEST_FRAMEWORK>`
- CI: `<CI_PLATFORM>`

## 4. Environment Setup

### Prerequisites
- `<TOOL_1_AND_MIN_VERSION>`
- `<TOOL_2_AND_MIN_VERSION>`
- `<DATABASE_OR_SERVICE_REQUIREMENT>`

### First-Time Setup
1. `<CLONE_REPO_STEP>`
2. `<INSTALL_DEPENDENCIES_STEP>`
3. `<COPY_ENV_TEMPLATE_STEP>`
4. `<INITIALIZE_DB_OR_SERVICES_STEP>`
5. `<RUN_SANITY_CHECK_STEP>`

### Environment Variable Policy
- Source of truth: `<ENV_DOC_OR_PLATFORM>`
- Local env file(s): `<ENV_FILES_LIST>`
- Secrets handling: `<SECRET_MANAGER_POLICY>`
- Forbidden practices:
  - Do not commit secrets.
  - Do not log secrets or tokens.
  - Do not hardcode credentials in code or tests.

## 5. Coding Conventions

### General Rules
- Prefer small, focused changes over broad refactors.
- Keep functions/modules cohesive and readable.
- Add comments only where intent is non-obvious.

### Naming Rules

| Entity | Convention | Example |
|---|---|---|
| Files | `<FILE_NAMING_CONVENTION>` | `<EXAMPLE>` |
| Variables | `<VARIABLE_NAMING_CONVENTION>` | `<EXAMPLE>` |
| Functions | `<FUNCTION_NAMING_CONVENTION>` | `<EXAMPLE>` |
| Types/Classes | `<TYPE_CLASS_NAMING_CONVENTION>` | `<EXAMPLE>` |
| Constants | `<CONSTANT_NAMING_CONVENTION>` | `<EXAMPLE>` |

### Language-Specific Conventions
- `<LANGUAGE_1>`: `<STYLE_RULES>`
- `<LANGUAGE_2>`: `<STYLE_RULES>`

### Error Handling
- Return or throw typed/domain-appropriate errors.
- Never swallow exceptions silently.
- Include actionable context in error messages.
- Log safely (no secrets/PII).

## 6. Testing Requirements

### How to Run Tests
- Unit tests: `<COMMAND>`
- Integration tests: `<COMMAND>`
- End-to-end tests: `<COMMAND_OR_NA>`
- Full test suite: `<COMMAND>`

### Coverage Standards
- Global minimum coverage: `<PERCENTAGE_OR_RULE>`
- Critical-path coverage requirement: `<RULE>`
- New/changed code requirement: `<RULE>`

### Test Writing Guidelines
- Follow Arrange-Act-Assert (or project standard).
- Prefer deterministic tests; avoid real network calls unless explicitly required.
- Mock only external boundaries.
- Add regression tests for every bug fix.

## 7. Commit & PR Guidelines

### Commit Format (Conventional Commits)
Use:
`<type>(<scope>): <short summary>`

Allowed `type` values:
- `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`, `ci`, `build`, `perf`, `revert`

Examples:
- `feat(auth): add refresh token rotation`
- `fix(api): handle null profile payload`

### Pull Request Rules
- Keep PRs focused and reasonably small.
- Include problem statement, approach, and validation steps.
- Link issues/tickets: `<TRACKING_SYSTEM_FORMAT>`
- Attach screenshots/logs for UI/behavioral changes.
- Require passing CI before merge.

## 8. Agent Behavior Rules (Critical)

### Agents SHOULD
- Read relevant files before editing.
- Explain assumptions when context is incomplete.
- Prefer minimal diffs that solve the stated problem.
- Run lint/tests relevant to changed code.
- Preserve backward compatibility unless explicitly asked to break it.
- Update docs when behavior/configuration changes.
- Stop and escalate when encountering unexpected high-risk changes.

### Agents MUST NOT
- [MUST NOT] Fabricate test results, logs, or command outputs.
- [MUST NOT] Commit secrets, API keys, tokens, or credentials.
- [MUST NOT] Edit generated files manually when regeneration is the standard process.
- [MUST NOT] Introduce silent breaking changes without explicit approval.
- [MUST NOT] Modify deployment/infra/security settings without following approval policy.
- [MUST NOT] Revert unrelated user changes in a dirty working tree.
- [MUST NOT] Use destructive commands (`rm -rf`, hard resets, force pushes) without explicit instruction.

## 9. What Not To Do

- Do not bypass code review requirements.
- Do not trade correctness for speed on production paths.
- Do not change architecture patterns ad hoc; propose and align first.
- Do not add dependencies without justification and approval policy compliance.
- Do not ignore failing tests or lint errors.

## 10. Off-Limits Files (Human Approval Required)

Agents must request human approval before modifying any of the following:

- `<OFF_LIMITS_PATH_1>`
- `<OFF_LIMITS_PATH_2>`
- `<OFF_LIMITS_PATH_3>`
- `<SECRETS_OR_PRODUCTION_CONFIG_PATHS>`

## 11. Common Commands Cheat Sheet

### Development
- Install deps: `<COMMAND>`
- Start dev server: `<COMMAND>`
- Run linter: `<COMMAND>`
- Run formatter: `<COMMAND>`
- Typecheck: `<COMMAND>`

### Testing
- Unit: `<COMMAND>`
- Integration: `<COMMAND>`
- E2E: `<COMMAND_OR_NA>`
- Coverage report: `<COMMAND>`

### Database / Infrastructure
- Start local services: `<COMMAND>`
- Create migration: `<COMMAND>`
- Apply migration: `<COMMAND>`
- Seed data: `<COMMAND>`
- Reset local DB: `<COMMAND>`

## 12. Escalation Contacts

Use this section when blocked > `<TIME_THRESHOLD>` or when risk is high.

| Scenario | Contact | Channel | SLA/Expectation |
|---|---|---|---|
| Production incident risk | `<ONCALL_TEAM_OR_PERSON>` | `<PAGER_OR_CHANNEL>` | `<RESPONSE_TIME>` |
| Security/privacy concern | `<SECURITY_CONTACT>` | `<CHANNEL>` | `<RESPONSE_TIME>` |
| Architecture conflict | `<STAFF_ENGINEER_OR_TEAM>` | `<CHANNEL>` | `<RESPONSE_TIME>` |
| Product requirement ambiguity | `<PM_OR_OWNER>` | `<CHANNEL>` | `<RESPONSE_TIME>` |

## 13. Definition of Done (Agent Tasks)

A task is complete when all of the following are true:
- Requested behavior is implemented.
- Relevant tests pass locally (or limitation is explicitly documented).
- Lint/type checks pass for changed scope.
- Docs/config updates are included when needed.
- Risks, assumptions, and follow-ups are documented in handoff notes.

## 14. Handoff Template (For Agent Outputs)

Use this structure in final updates:

1. Summary: `<WHAT_CHANGED>`
2. Files changed: `<FILE_LIST>`
3. Validation: `<TESTS_AND_RESULTS>`
4. Risks/assumptions: `<KNOWN_LIMITATIONS>`
5. Next steps: `<OPTIONAL_FOLLOW_UPS>`

---

## Quick Start Customization Checklist

- Replace all `<PLACEHOLDERS>`.
- Remove sections that do not apply.
- Add repo-specific commands and ownership info.
- Validate off-limits paths and approval policy with humans.
- Save this file as `AGENTS.md` in the project root.
