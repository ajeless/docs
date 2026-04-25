# TEST EVERYTHING: AI-Native Software Testing Platform
## Research & Ideation Document

---

## 1. The Vision

**Point → Analyze → Test → Report.** You give the platform a repo URL or a live website, and an AI orchestrator figures out what the codebase does, generates comprehensive test cases (including edge cases), selects the right testing tools, executes tests in containers, and delivers a unified report. No test left unwritten.

This is fundamentally different from existing tools because:
- Existing AI testing tools focus on **one layer** (unit OR e2e OR performance). We unify them all.
- Existing tools require human-authored test plans. We **generate** the plan, the cases, AND the edge cases.
- We're not building a testing framework — we're building an **AI testing agent** that orchestrates many frameworks.

---

## 2. Landscape Analysis: What Exists Today

### 2.1 Open-Source Testing Frameworks (Our Execution Layer)

| Testing Type | Best-in-Class OSS Tools | Notes |
|---|---|---|
| **Unit Testing** | pytest, Jest, Vitest, JUnit 5, Go test | Language-specific; LLMs generate these well |
| **Integration Testing** | pytest + testcontainers, Jest | Container-based isolation |
| **API Testing** | Keploy, EvoMaster, Hurl, Bruno, Postman (via Newman) | Keploy uses eBPF to record real traffic and replay as tests. EvoMaster uses evolutionary algorithms to auto-generate API tests from OpenAPI specs. |
| **E2E Browser Testing** | **Playwright** (dominant in 2026), Cypress, Selenium | Playwright is the clear winner: fastest, cross-browser (Chromium/Firefox/WebKit), free parallelism, multi-language, built-in tracing |
| **AI-Driven E2E** | Shortest, Magnitude (testing fw), Midscene.js, TestDriver.ai | Natural language test authoring → Playwright execution. Shortest uses Anthropic's API. Magnitude uses a planner/executor dual-agent architecture. |
| **Visual Regression** | Playwright screenshots, BackstopJS, Recheck, Percy (freemium) | Pixel-diff and AI-based visual comparison |
| **Performance / Load** | **k6** (JS scripting, Go engine), Locust (Python), Gatling, Artillery, JMeter | k6 is the modern standard: JS scripting, minimal resources, Grafana integration. Locust is ideal for AI-generated scripts (pure Python). k6 also has browser-based performance testing via k6-browser. |
| **Security (SAST)** | **Semgrep**, Bandit (Python), CodeQL, SpotBugs | Semgrep is the gold standard for custom rule-based static analysis |
| **Security (DAST)** | **OWASP ZAP**, Nuclei, WuppieFuzz | ZAP is battle-tested, Dockerized, CI-friendly. Nuclei is template-driven and fast. |
| **Security (SCA)** | **Trivy**, Grype, OWASP Dependency-Check | Trivy scans containers, IaC, repos, and dependencies |
| **Security (Secrets)** | GitLeaks, TruffleHog | Pre-commit and repo scanning |
| **Accessibility** | axe-core, pa11y, Lighthouse | Can be integrated into Playwright runs |
| **BDD / Spec Testing** | Cucumber + Gherkin, Behave (Python), SpecFlow (.NET) | AI can generate Gherkin from requirements/specs, then execute via Cucumber |
| **Fuzzing** | Atheris (Python), libFuzzer (C/C++), go-fuzz, EvoMaster (API) | Coverage-guided input mutation |
| **Contract Testing** | Pact | Consumer-driven contract testing for microservices |
| **Infrastructure/IaC** | Checkov, Terrascan, tfsec | Scan Terraform, Kubernetes, CloudFormation |
| **Code Quality** | SonarQube (community), ESLint, Ruff, Pylint | Static analysis + code smells |
| **Mutation Testing** | Stryker (JS/TS), mutmut (Python), PIT (Java) | Tests the quality of your tests by introducing code mutations |

### 2.2 Existing AI-Native Testing Platforms (Competitive Landscape)

| Platform | What It Does | Gap We Fill |
|---|---|---|
| **Keploy** | Records real API traffic via eBPF → replays as tests + mocks. Open source. | Only API/integration layer. No unit, no E2E, no perf, no security. |
| **EvoMaster** | Evolutionary algorithm generates API test cases from OpenAPI schemas. | API-only. No broader testing strategy. |
| **Shortest** (by Antiwork) | Natural language → Playwright E2E tests, uses Anthropic API. | E2E only. No test plan generation, no multi-layer testing. |
| **Magnitude** (testing fw) | Dual-agent (planner + executor) AI E2E testing for web apps. | E2E only. |
| **Mabl** | Cloud-native AI test automation (web + API). Commercial SaaS. | Proprietary, expensive, no self-hosting. |
| **Katalon / ACCELQ / Testim** | Low-code/AI test automation suites. | Commercial, vendor lock-in, single-layer focus. |
| **QA Wolf** | Playwright-based QA-as-a-service. | Service, not a platform you own. |
| **BrowserStack / LambdaTest / Sauce Labs** | Cloud browser/device grids. | Infrastructure, not intelligence. Good to integrate with. |

**Key Insight**: Nobody has built an open-source, self-hosted, AI-native **orchestrator** that ties all these layers together. That's our opportunity.

---

## 3. Architecture: How It Works

### 3.1 Core Workflow

```
┌──────────────┐     ┌───────────────────┐     ┌──────────────────┐
│  INPUT        │────▶│  AI ANALYZER       │────▶│  TEST PLANNER    │
│  - Git repo   │     │  - Language detect  │     │  - Test strategy  │
│  - Website URL│     │  - Framework detect │     │  - Coverage plan  │
│  - API spec   │     │  - Dependency scan  │     │  - Edge cases     │
│  - Spec doc   │     │  - Architecture map │     │  - Risk assessment│
└──────────────┘     └───────────────────┘     └──────────────────┘
                                                         │
                     ┌───────────────────┐               │
                     │  TEST GENERATOR    │◀──────────────┘
                     │  - Unit tests      │
                     │  - Integration     │
                     │  - E2E scenarios   │
                     │  - Perf scripts    │
                     │  - Security scans  │
                     │  - BDD features    │
                     │  - Fuzz inputs     │
                     └───────────────────┘
                              │
                     ┌───────────────────┐     ┌──────────────────┐
                     │  TEST EXECUTOR     │────▶│  REPORT ENGINE   │
                     │  (Containerized)   │     │  - Unified dash   │
                     │  - Parallel runs   │     │  - Coverage maps  │
                     │  - Tool dispatch   │     │  - Trend tracking │
                     │  - Result collect  │     │  - CI/CD gates    │
                     └───────────────────┘     └──────────────────┘
```

### 3.2 Component Breakdown

**1. Repo/Target Analyzer (AI Agent)**
- Clones repo, detects languages, frameworks, build systems
- Parses OpenAPI/GraphQL schemas if present
- Maps architecture (monolith vs microservices, frontend vs backend)
- For websites: crawls sitemap, identifies forms, auth flows, dynamic content
- For specs: parses PRDs, user stories, Gherkin, or formal specs (TLA+, Alloy)
- Output: a structured "target profile" JSON

**2. Test Strategy Planner (AI Agent)**
- Takes the target profile and generates a comprehensive test plan
- Decides which testing types apply (you don't load-test a CLI tool)
- Generates test cases including:
  - Happy path scenarios
  - Boundary/edge cases (nulls, empty strings, max values, Unicode, injection)
  - Negative test cases (invalid auth, missing fields, malformed data)
  - Concurrency scenarios
  - State machine transitions
- Prioritizes by risk (auth flows > cosmetic issues)
- Outputs a test plan in a structured format (JSON/YAML + human-readable Gherkin)

**3. Test Generator (AI + Templates)**
- Translates test cases into executable tests using the right framework:
  - Python backend → pytest with fixtures and parametrize
  - React frontend → Playwright E2E + Vitest component tests
  - REST API → k6 load scripts + EvoMaster fuzzing + Keploy replay tests
  - Security → Semgrep rule selection + ZAP scan config + Trivy scan
  - BDD → Cucumber/Gherkin feature files + step definitions
- Uses LLM (Claude) for generation, with tool-specific templates as scaffolding
- Generates test data (faker/factory patterns, edge case data sets)

**4. Test Executor (Container Orchestration)**
- Each test type runs in its own Docker container (isolation + reproducibility)
- Orchestrated via Docker Compose or Kubernetes Jobs
- Parallel execution with dependency ordering
- Browser tests run in headed or headless Playwright containers
- Performance tests can scale across multiple containers
- Collects: stdout, exit codes, coverage reports, screenshots, HAR files, traces

**5. Report & Dashboard**
- Unified view across ALL test types
- Coverage heatmaps (line, branch, path)
- Performance baselines and regression detection
- Security vulnerability summary (CVSS scoring)
- Flaky test detection
- Trend tracking across runs
- CI/CD integration (GitHub Actions, GitLab CI status checks)

### 3.3 Spec & Idea Testing

This is a unique capability — testing **before code exists**:

- **Input**: A PRD, user story, or design spec
- **AI generates**: Gherkin BDD scenarios that define expected behavior
- **Validation**: Cross-check spec completeness (missing error states? no mention of auth? no edge cases?)
- **Formal methods (advanced)**: For critical systems, translate specs into TLA+ or Alloy models and check for invariant violations
- **Output**: A "testability report" — gaps in the spec, ambiguities, suggested test cases
- **Benefit**: When the code is eventually written, the test suite is already waiting

---

## 4. Technology Stack

### 4.1 Core Platform

| Component | Technology | Rationale |
|---|---|---|
| **AI Backbone** | Claude API (Anthropic) + local models (Ollama) | Claude for planning/generation, local for fast classification |
| **Orchestrator** | Python (FastAPI) | Your team's strength, AI library ecosystem |
| **Container Runtime** | Docker + Docker Compose (dev), K8s (prod) | Standard cloud-native |
| **Task Queue** | Celery + Redis or Temporal | For async test execution and workflow management |
| **Storage** | PostgreSQL (results/metadata) + S3-compatible (artifacts) | Standard, scalable |
| **Dashboard** | React + Recharts or Grafana | Unified reporting UI |
| **CLI** | Python (Click/Typer) | `testall scan https://github.com/user/repo` |

### 4.2 Testing Tool Containers

Pre-built Docker images for each testing tool, with standardized input/output interfaces:

```yaml
# Example: docker-compose.test.yml
services:
  unit-tests:
    image: testall/pytest-runner:latest
    volumes: [./repo:/app, ./results:/results]
    
  e2e-tests:
    image: testall/playwright-runner:latest
    volumes: [./tests:/tests, ./results:/results]
    
  load-tests:
    image: grafana/k6:latest
    volumes: [./perf:/scripts, ./results:/results]
    
  security-sast:
    image: semgrep/semgrep:latest
    volumes: [./repo:/src, ./results:/results]
    
  security-dast:
    image: ghcr.io/zaproxy/zaproxy:stable
    volumes: [./results:/results]
    
  security-sca:
    image: aquasec/trivy:latest
    volumes: [./repo:/src, ./results:/results]
```

### 4.3 SaaS Integrations (via API)

| Service | Integration | Purpose |
|---|---|---|
| **BrowserStack / LambdaTest** | API + Playwright remote | Real device/browser grid for cross-browser E2E |
| **Grafana Cloud k6** | k6 CLI + API | Distributed load testing from multiple regions |
| **Percy / Chromatic** | API + Playwright screenshots | Visual regression as a service |
| **Snyk** | CLI + API | SCA with vulnerability database |
| **SonarCloud** | API | Code quality tracking |
| **GitHub / GitLab** | Webhooks + API | PR status checks, issue creation for failures |

---

## 5. Key Innovations / Differentiators

### 5.1 "Zero-Config" Test Discovery
The AI analyzes the repo structure and automatically determines:
- Which files are testable
- What frameworks are in use
- What test patterns already exist (and what's missing)
- How to build and run the application

### 5.2 Edge Case Generation Engine
Uses structured techniques beyond naive LLM generation:
- **Equivalence partitioning**: Identify input classes, test one from each
- **Boundary value analysis**: Test at limits (0, 1, -1, MAX_INT, empty string)
- **Decision tables**: Combinatorial logic for multi-condition scenarios
- **State transition testing**: Model stateful components as FSMs
- **Error guessing**: Common failure patterns per framework/language
- **Pairwise/combinatorial**: Use PICT or AllPairs for parameter combinations

### 5.3 Test Data Generation
- **Faker-based**: Realistic names, addresses, emails, phone numbers
- **Schema-aware**: Generate valid + invalid payloads from OpenAPI/JSON Schema
- **Adversarial**: SQL injection strings, XSS payloads, Unicode edge cases, oversized inputs
- **Deterministic seeds**: Reproducible test data across runs

### 5.4 Real Browser Performance Testing
Using k6-browser + Playwright:
- Measure Core Web Vitals (LCP, FID, CLS) under load
- Simulate real user journeys with concurrent users
- Record HAR files and filmstrips for performance debugging
- Compare against baselines to catch regressions

### 5.5 Mutation Testing Integration
After generating tests, validate their quality:
- Run Stryker/mutmut to introduce code mutations
- Check if the generated tests catch the mutations
- Report a "test strength score" alongside coverage

### 5.6 Continuous Testing Mode
- Watch mode for local development
- GitHub Action / GitLab CI integration for PR-level testing
- Nightly full sweeps (security, performance, mutation)
- Progressive test expansion: AI identifies new code paths and generates additional tests

---

## 6. Implementation Phases

### Phase 1: Foundation (Weeks 1-4)
- CLI tool: `testall init`, `testall scan <repo-url>`
- Repo analyzer: language/framework detection, dependency mapping
- Unit test generator: pytest and Jest via Claude API
- Basic containerized execution
- JSON/HTML report output

### Phase 2: Breadth (Weeks 5-8)
- API test generation (from OpenAPI specs) using EvoMaster + custom
- E2E test generation using Playwright + natural language (Shortest-style)
- Security scanning pipeline (Semgrep + Trivy + ZAP)
- Unified dashboard (React)

### Phase 3: Depth (Weeks 9-12)
- Performance testing (k6 scripts from AI analysis)
- BDD generation (Gherkin from specs/requirements)
- Spec/idea testing (pre-code validation)
- Edge case engine (structured techniques)
- Test data generation

### Phase 4: Intelligence (Weeks 13-16)
- Mutation testing integration
- Real browser performance (k6-browser)
- SaaS integrations (BrowserStack, Grafana Cloud)
- CI/CD pipeline templates
- Trend tracking and flaky test detection
- Accessibility testing (axe-core integration)

### Phase 5: Polish (Weeks 17-20)
- Web UI for configuration and monitoring
- Team/project management features
- Custom rule libraries
- Plugin system for additional tools
- Documentation and onboarding

---

## 7. Open Questions to Resolve

1. **Naming**: "TestAll"? "OmniTest"? "TestForge"? "Panoptic"?
2. **Licensing**: MIT or Apache 2.0 for the orchestrator?
3. **LLM dependency**: How much works offline? Can we use Ollama/local models for fast-path tasks (classification, data generation) and reserve Claude for complex planning/generation?
4. **Scope per scan**: Full repo scan could be expensive (API tokens). Do we offer tiered scans (quick/standard/comprehensive)?
5. **Test maintenance**: When the codebase changes, how do we update generated tests? Regenerate? Diff-based patching?
6. **Multi-repo/monorepo**: How do we handle monorepos with multiple services?

---

## 8. Tool Reference Quick-Sheet

### Must-Integrate (Core)
- **Playwright** — E2E browser testing (primary browser automation layer)
- **pytest / Jest / Vitest** — Unit/integration testing
- **k6** — Performance and load testing (+ k6-browser for real browser perf)
- **Semgrep** — SAST code scanning
- **OWASP ZAP** — DAST web app scanning
- **Trivy** — Container, IaC, and dependency scanning
- **Cucumber** — BDD/Gherkin test execution
- **axe-core** — Accessibility testing

### Should-Integrate (High Value)
- **Keploy** — Record/replay API tests from real traffic (eBPF-based)
- **EvoMaster** — Evolutionary API test generation from OpenAPI
- **Locust** — Python-native load testing (great for AI-generated scripts)
- **Stryker / mutmut** — Mutation testing
- **Pact** — Contract testing for microservices
- **GitLeaks** — Secrets detection
- **Lighthouse** — Web performance + SEO + accessibility audits
- **Checkov** — IaC security scanning

### Nice-to-Have (Extended)
- **Atheris** — Python fuzzing
- **BackstopJS** — Visual regression testing
- **Nuclei** — Template-based vulnerability scanning
- **SonarQube Community** — Code quality metrics
- **Ruff / ESLint** — Fast linting
- **testcontainers** — Spin up real databases/services for integration tests
- **Faker** — Test data generation library

---

*Document generated April 7, 2026. Based on research of the current testing landscape, open-source tooling, and competitive analysis.*