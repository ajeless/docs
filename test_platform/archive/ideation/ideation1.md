# TEST EVERYTHING: AI-Native Testing Platform
## Research & Ideation Document

---

## 1. The Vision

An AI-native, containerized, cloud-native testing platform with one attitude: **TEST EVERYTHING**.

**Core premise:** Coding agents writing application code cannot be trusted to test their own work thoroughly. A separate, adversarial testing system must exist that can be pointed at any repo or website and autonomously figure out *what* to test, *how* to test it, generate test cases including edge cases, execute them, and report results.

**What makes this different from what exists today:** No single platform currently combines all of these capabilities. Existing tools are either narrow (just unit tests, just E2E, just security) or require heavy manual configuration. The gap is an *orchestration layer* — an AI brain that understands a codebase or running application holistically, selects the right tools for each testing dimension, generates tests autonomously, and coordinates execution across all of them.

---

## 2. Landscape Research: What Already Exists

### 2.1 AI-Powered Test Generation

| Tool | Type | What It Does | License |
|------|------|-------------|---------|
| **Keploy** | OSS | Records real API traffic via eBPF, replays as tests + mocks. Language-agnostic, zero-code. Generates integration tests from actual production behavior. | Apache 2.0 |
| **EvoMaster** | OSS | Evolutionary algorithm-based test generation for REST/GraphQL/RPC APIs. White-box and black-box modes. | LGPL |
| **Diffblue Cover** | Commercial | AI-generated unit tests for Java. Analyzes bytecode to produce JUnit tests. | Proprietary |
| **Keploy UT Gen** | OSS | LLM-powered unit test generation across languages. | Apache 2.0 |
| **Magnitude** | OSS | AI-native E2E testing framework using dual-agent architecture (Planner + Navigator). Natural language test definitions. Uses Gemini/Claude/OpenAI. | OSS |
| **TestDriver.ai** | Hybrid | Tests web apps, native desktop apps, Chrome extensions via computer vision. Broad cross-platform. | Apache 2.0 (agent) |
| **Tusk** | Commercial | AI unit test generation from PR diffs. | Proprietary |

**Key insight:** Keploy is particularly interesting for our platform — it captures real traffic at the network layer and converts it into deterministic tests without any code changes. This could be a core component.

### 2.2 E2E / Browser Testing Frameworks

| Tool | What It Does | Key Strength |
|------|-------------|-------------|
| **Playwright** | Microsoft's browser automation. Chromium, Firefox, WebKit. | Best-in-class API, auto-waits, trace viewer, codegen |
| **Cypress** | JavaScript E2E testing with time-travel debugging. | Developer experience, real-time reloads |
| **Selenium/WebDriver** | The original. Widest language + browser support. | Ecosystem size, legacy compatibility |
| **Appium** | Mobile testing (native, hybrid, mobile web). iOS + Android. | Cross-platform mobile via WebDriver protocol |

**Recommendation:** Playwright as the primary browser engine. It has the best performance, supports all major browsers, and integrates cleanly with Lighthouse for performance auditing.

### 2.3 Real Browser Performance Testing

| Tool | What It Does |
|------|-------------|
| **Lighthouse** (Google) | Open-source auditing for performance, accessibility, SEO, best practices. Measures Core Web Vitals (LCP, FCP, CLS, TBT). |
| **playwright-lighthouse** | NPM package that integrates Lighthouse directly into Playwright tests. Set performance score thresholds as pass/fail gates. |
| **k6 browser** | k6's browser module enables real-browser load testing alongside protocol-level testing. |
| **Unlighthouse** | Scans entire sites with Lighthouse audits per page. |
| **WebPageTest** | Open-source web performance testing with real browsers from multiple locations. |

**Architecture for real browser perf testing:**
```
Playwright navigates (handles auth, state) 
  → Lighthouse connects via CDP (Chrome DevTools Protocol) on remote debugging port
  → Audits run against authenticated/stateful pages
  → Core Web Vitals extracted programmatically
  → Thresholds enforced as CI gates
```

### 2.4 Load / Performance Testing

| Tool | Language | Strength | License |
|------|----------|----------|---------|
| **k6** | JavaScript (Go engine) | Developer-centric, efficient, Grafana integration, 29.9k GitHub stars | AGPL-3.0 |
| **Locust** | Python | Pythonic, distributed, event-based | MIT |
| **Gatling** | Scala/Java/JS | High concurrency, great HTML reports | Apache 2.0 (community) |
| **JMeter** | Java | Most protocols, largest ecosystem | Apache 2.0 |
| **Artillery** | Node.js | Modern, YAML-based, serverless support | MPL-2.0 |
| **k6 Studio** | Desktop app | Records browser traffic → generates k6 scripts automatically | OSS |

**Recommendation:** k6 as the primary performance engine. JavaScript scripting is accessible, the Go engine is extremely efficient, and Grafana Cloud integration gives us observability. k6 Studio can auto-generate load test scripts from browser recordings.

### 2.5 API Testing

| Tool | What It Does |
|------|-------------|
| **Postman/Newman** | Collections, environments, CLI runner for CI |
| **Bruno** | Open-source API client, Git-friendly (files stored as plain text) |
| **Hoppscotch** | Open-source API development ecosystem |
| **REST Assured** | Java library for REST API testing |
| **Dredd** | Tests API against its OpenAPI/Swagger documentation |
| **Schemathesis** | Property-based API testing from OpenAPI specs. Auto-generates test cases. |

### 2.6 Contract Testing

| Tool | What It Does | License |
|------|-------------|---------|
| **Pact** | Consumer-driven contract testing for HTTP + messaging. The industry standard. Multi-language. | MIT |
| **Pact Broker** | Stores and manages contracts, enables `can-i-deploy` checks. | MIT |
| **PactFlow** | Commercial hosted Pact Broker with bi-directional contract testing. | SaaS |
| **Dredd** | Validates API implementations against OpenAPI specs (provider contract testing). | MIT |

### 2.7 Security Testing

| Tool | Type | What It Does | License |
|------|------|-------------|---------|
| **ZAP (Zed Attack Proxy)** | DAST | Open-source web app security scanner. Automated + manual. Docker images for CI. OWASP Top 10. | Apache 2.0 |
| **Semgrep** | SAST | Static analysis, custom rules, 2000+ community rules. | LGPL |
| **Trivy** | Container/IaC | Container image scanning, filesystem, Kubernetes, IaC scanning. | Apache 2.0 |
| **Bandit** | SAST (Python) | Python-specific security linter. | Apache 2.0 |
| **Grype** | SCA | Vulnerability scanner for container images and filesystems. | Apache 2.0 |
| **Syft** | SBOM | Generates software bill of materials from containers/filesystems. | Apache 2.0 |
| **Nuclei** | DAST | Fast, template-based vulnerability scanner. 20k+ community templates. | MIT |
| **StackHawk** | DAST | Developer-first DAST built on ZAP, optimized for CI/CD. | SaaS (free for OSS) |
| **Atheris** | Fuzzing | Google's coverage-guided Python fuzzer built on libFuzzer. | Apache 2.0 |
| **WuppieFuzz** | API Fuzzing | Coverage-guided REST API fuzzer built on LibAFL. | OSS |

### 2.8 BDD / Specification Testing

| Tool | Language | What It Does |
|------|----------|-------------|
| **Cucumber** | Multi-lang | The OG BDD tool. Gherkin syntax (Given/When/Then). Feature files as executable specs. |
| **Behave** | Python | Python BDD framework using Gherkin. |
| **SpecFlow** | .NET | BDD for .NET ecosystem. |
| **JBehave** | Java | Java BDD framework. |
| **Godog** | Go | Official Cucumber for Go. |

**AI opportunity:** An LLM can read requirements/specs/user stories and auto-generate Gherkin feature files. The step definitions can then be auto-generated using Playwright/API calls. This is the "testing ideas and specs" capability.

### 2.9 Visual Regression Testing

| Tool | What It Does | License |
|------|-------------|---------|
| **Playwright** (built-in) | `toHaveScreenshot()` for pixel-level visual comparison. | Apache 2.0 |
| **Percy (BrowserStack)** | Cloud visual testing, cross-browser snapshots. | Free tier |
| **Applitools Eyes** | AI-powered visual validation. | Commercial |
| **BackstopJS** | Headless visual regression via Puppeteer/Playwright. | MIT |
| **Recheck** | Golden master / snapshot testing for reducing E2E flakiness. | OSS |

### 2.10 Test Data Generation

| Tool | What It Does | License |
|------|----------|---------|
| **Faker.js** | Generates realistic fake data (names, addresses, emails, etc.) in 60+ locales. | MIT |
| **Faker (Python)** | Python equivalent. | MIT |
| **Hypothesis** | Property-based testing for Python. Generates inputs that explore edge cases automatically. | MPL-2.0 |
| **fast-check** | Property-based testing for JavaScript/TypeScript. | MIT |
| **Synth** | Declarative synthetic data generation from JSON schemas. | Apache 2.0 |
| **Mimesis** | High-performance Python fake data library. | MIT |
| **LLM-generated** | Use Claude/GPT to generate domain-specific, culturally-aware test data based on schemas. | N/A |

### 2.11 Code Quality & Static Analysis

| Tool | What It Does |
|------|-------------|
| **SonarQube** | Code quality, bug detection, code smells, coverage tracking. |
| **ESLint/Prettier** | JavaScript/TypeScript linting and formatting. |
| **Ruff** | Extremely fast Python linter (replaces flake8/pylint/isort). |
| **Hadolint** | Dockerfile linting. |
| **ShellCheck** | Shell script static analysis. |

### 2.12 Accessibility Testing

| Tool | What It Does | License |
|------|-------------|---------|
| **axe-core** | Accessibility testing engine. Integrates with Playwright/Cypress. | MPL-2.0 |
| **pa11y** | Automated accessibility testing CLI. | LGPL |
| **Lighthouse** | Includes accessibility audits as part of its scoring. | Apache 2.0 |

### 2.13 Chaos Engineering / Resilience

| Tool | What It Does |
|------|-------------|
| **Chaos Mesh** | Kubernetes chaos engineering platform. Fault injection. |
| **Litmus** | Cloud-native chaos engineering with pre-built experiments. |
| **Toxiproxy** | TCP proxy for simulating network conditions (latency, disconnects). |

---

## 3. Platform Architecture: The AI Brain

### 3.1 Core Architecture

```
┌──────────────────────────────────────────────────────────┐
│                    TEST EVERYTHING                        │
│                  AI Orchestration Layer                   │
│                                                          │
│  ┌──────────┐  ┌──────────┐  ┌───────────┐  ┌────────┐ │
│  │  Repo     │  │  Live    │  │   Spec/   │  │  API   │ │
│  │ Analyzer  │  │  Site    │  │  Docs     │  │  Disc- │ │
│  │           │  │ Crawler  │  │  Parser   │  │  overy │ │
│  └─────┬────┘  └────┬─────┘  └─────┬─────┘  └───┬────┘ │
│        │            │              │             │       │
│        └────────────┴──────────────┴─────────────┘       │
│                          │                               │
│                 ┌────────▼────────┐                      │
│                 │  Test Strategy  │                      │
│                 │    Generator    │                      │
│                 │   (LLM-based)  │                      │
│                 └────────┬───────┘                      │
│                          │                               │
│        ┌────────┬────────┼────────┬────────┐            │
│        ▼        ▼        ▼        ▼        ▼            │
│   ┌────────┐┌───────┐┌───────┐┌───────┐┌───────┐       │
│   │  Unit  ││ Integ ││  E2E  ││ Perf  ││  Sec  │       │
│   │ Tests  ││ Tests ││ Tests ││ Tests ││ Tests │       │
│   └────────┘└───────┘└───────┘└───────┘└───────┘       │
│   ┌────────┐┌───────┐┌───────┐┌───────┐┌───────┐       │
│   │Contract││Visual ││Access-││ Chaos ││  BDD  │       │
│   │ Tests  ││ Regr. ││ ible  ││ Tests ││ Specs │       │
│   └────────┘└───────┘└───────┘└───────┘└───────┘       │
│                          │                               │
│                 ┌────────▼────────┐                      │
│                 │    Unified      │                      │
│                 │   Dashboard     │                      │
│                 │   & Reports     │                      │
│                 └─────────────────┘                      │
└──────────────────────────────────────────────────────────┘
```

### 3.2 How It Works

**Step 1: Discovery & Analysis**
- Point at a repo → Analyze language, framework, dependencies, existing tests, API specs, OpenAPI/Swagger docs, database schemas
- Point at a website → Crawl, discover pages/routes, identify forms/inputs, detect API endpoints, capture traffic patterns
- Ingest specs → Parse PRDs, user stories, Jira tickets, README files, Gherkin feature files, OpenAPI specs

**Step 2: AI Test Strategy Generation**
- LLM analyzes the codebase/application and generates a comprehensive test plan
- Identifies critical paths, edge cases, boundary conditions
- Determines which testing tools to deploy for each dimension
- Generates test data schemas and fixtures using Faker + LLM-generated domain data

**Step 3: Autonomous Test Generation**
- **Unit tests:** LLM generates tests for each function/method with edge cases
- **Integration tests:** Keploy records traffic; LLM generates additional scenarios
- **E2E tests:** LLM writes Playwright scripts or Gherkin scenarios
- **Performance tests:** k6 scripts generated from traffic patterns
- **Security tests:** ZAP/Nuclei scans configured based on tech stack
- **Contract tests:** Pact contracts derived from API specs and actual usage
- **Visual tests:** Playwright screenshots with baseline comparisons
- **Accessibility:** axe-core + Lighthouse audits
- **BDD specs:** Gherkin feature files generated from requirements/docs

**Step 4: Containerized Execution**
- Each test type runs in its own Docker container
- Orchestrated via Docker Compose or Kubernetes
- Parallel execution across testing dimensions
- Results aggregated in real-time

**Step 5: Reporting & Feedback**
- Unified dashboard showing all test results
- Coverage maps across code and testing dimensions
- Actionable fix suggestions (LLM-generated)
- CI/CD integration with pass/fail gates

### 3.3 Container Architecture

```yaml
services:
  # Core
  brain:           # AI orchestrator (Python/Node)
  dashboard:       # Web UI (React)
  
  # Test Runners
  unit-runner:     # pytest / Jest / JUnit
  playwright:      # E2E + Visual + Accessibility + Lighthouse
  k6:              # Load/Performance testing
  zap:             # OWASP ZAP for DAST
  keploy:          # Traffic recording + replay
  pact-broker:     # Contract management
  
  # Infrastructure
  postgres:        # Test results storage
  redis:           # Job queue
  grafana:         # Performance dashboards
  minio:           # Artifact storage (screenshots, reports)
```

---

## 4. Key Capabilities Matrix

| Capability | Primary Tool | Backup/Alt | AI Role |
|-----------|-------------|-----------|---------|
| Unit testing | pytest/Jest/JUnit | Language-specific | Generate tests, identify edge cases |
| Integration testing | Keploy | Custom HTTP tests | Record traffic, generate scenarios |
| E2E browser testing | Playwright | Cypress | Generate test scripts from user flows |
| Real browser perf | Playwright + Lighthouse | k6 browser | Set thresholds, identify regressions |
| Load testing | k6 | Locust/Gatling | Generate load profiles from traffic |
| API testing | Schemathesis + Bruno | Postman/Newman | Generate from OpenAPI, fuzz inputs |
| Contract testing | Pact | Dredd | Generate contracts from specs/traffic |
| Security (DAST) | ZAP | Nuclei | Configure scans, triage findings |
| Security (SAST) | Semgrep | Bandit/ESLint | Custom rules, prioritize findings |
| Security (SCA) | Trivy + Grype | Snyk (SaaS) | Identify exploitable paths |
| Visual regression | Playwright screenshots | BackstopJS | Identify meaningful vs noise changes |
| Accessibility | axe-core + Lighthouse | pa11y | Generate accessible alternatives |
| BDD / Spec testing | Cucumber + Gherkin | Behave | Generate feature files from specs |
| Chaos/Resilience | Toxiproxy | Chaos Mesh | Design failure scenarios |
| Test data gen | Faker + Hypothesis | LLM-generated | Domain-aware synthetic data |
| Code quality | SonarQube + Ruff | ESLint | Suggest fixes |
| Fuzzing | Atheris + WuppieFuzz | AFL | Coverage-guided input generation |

---

## 5. SaaS / Third-Party API Integrations

| Service | Integration Method | What We Get |
|---------|-------------------|------------|
| **BrowserStack** | REST API + Selenium/Playwright grid | Real device testing, 3500+ browser/OS combos |
| **LambdaTest** | REST API + Playwright grid | Cross-browser cloud execution |
| **Grafana Cloud k6** | k6 CLI + API | Distributed load testing, observability |
| **PactFlow** | Pact Broker API | Hosted contract management |
| **Snyk** | CLI + REST API | Vulnerability database, fix PRs |
| **SonarCloud** | REST API + CI plugins | Hosted code quality analysis |
| **Percy** | SDK + API | Cloud visual regression |
| **GitHub/GitLab** | REST/GraphQL API + Webhooks | CI/CD triggers, PR comments with results |
| **Jira** | REST API | Import specs as test scenarios, file bugs |
| **Slack** | Webhook API | Test result notifications |

---

## 6. Novel Ideas: What Hasn't Been Done

### 6.1 Adversarial Test Agent
An LLM agent that actively tries to break the application — not just test happy paths but think like a malicious user. It uses chain-of-thought reasoning to discover attack vectors, weird state transitions, and race conditions.

### 6.2 Spec-to-Test Pipeline
Feed in a PRD, RFC, or even a Slack conversation about a feature → LLM generates Gherkin specs → auto-generates step definitions → runs them against the application. **Test the idea before the code exists** by validating specs against mocks.

### 6.3 Differential Testing Against Coding Agents
Compare the output of different coding agents (Claude Code, Codex, Cursor) by running the same test suite against each implementation. Identify which agent produces the most robust code.

### 6.4 Living Test Knowledge Base
The platform learns from every test run. Failed tests feed back into the LLM context for future test generation. The system learns that "this API always fails with Unicode input" or "this component breaks at exactly 1024 items" and proactively generates those edge cases for new code.

### 6.5 Production Traffic Shadow Testing
Use Keploy to capture production traffic, replay it against staging/dev with mutations (corrupted inputs, missing fields, extreme values) to discover how the system degrades.

---

## 7. Recommended Tech Stack

### Core Platform
- **Language:** Python (orchestrator) + TypeScript (dashboard)
- **Container Orchestration:** Docker Compose (dev), Kubernetes (prod)
- **AI Engine:** Claude API (test generation, analysis, strategy)
- **Job Queue:** Redis + Celery or Bull
- **Database:** PostgreSQL (results) + Redis (cache)
- **Storage:** MinIO (artifacts, screenshots, reports)

### Test Execution Engines
- **Playwright** — E2E, visual, accessibility, browser performance
- **k6** — Load and performance testing
- **pytest / Jest** — Unit test runners
- **ZAP** — Security scanning
- **Keploy** — Traffic capture and replay
- **Pact** — Contract testing
- **Cucumber** — BDD execution
- **Schemathesis** — API property testing
- **axe-core** — Accessibility
- **Lighthouse** — Web performance auditing
- **Faker/Hypothesis** — Test data generation

### Observability
- **Grafana** — Dashboards
- **Allure** — Test reporting
- **OpenTelemetry** — Distributed tracing of test execution

---

## 8. Next Steps

1. **Validate the architecture** — Build a minimal POC that takes a simple repo, analyzes it, and generates + runs unit tests and E2E tests
2. **Prioritize testing dimensions** — Start with unit + E2E + security as the MVP triad
3. **Design the AI orchestrator prompt architecture** — How does the LLM decide what to test and how?
4. **Containerize the first three engines** — Playwright, pytest, ZAP in Docker Compose
5. **Build the unified reporting layer** — Aggregate results from all engines into a single view
6. **Open source strategy** — Decide what's open-source core vs. commercial features

---

*Document generated April 7, 2026 — Research covers tools and landscape as of this date.*