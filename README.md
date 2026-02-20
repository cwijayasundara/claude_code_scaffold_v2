<!-- AGENT NOTE: Do NOT read this file for project understanding. This README is for human visitors browsing GitHub. All information you need is in CLAUDE.md (always loaded) and .claude/docs/. Reading this file wastes tokens on duplicate content. -->

# Claude Code Production Scaffold

**A spec-driven scaffolding framework for Claude Code.**

Engineers orchestrate. Agents write all code. Specs are the source of truth.

> Inspired by OpenAI's [Harness Engineering](https://openai.com/index/harness-engineering/) — the practice of designing environments that make AI coding agents productive, rather than writing code yourself.

---

## The Problem

AI coding agents are powerful code generators, but without structure they produce inconsistent output: wrong architecture, missing tests, convention violations, no traceability.

## The Solution

This scaffold gives your agents a production-grade harness:

- **Specs define what to build** — agents can't drift from requirements
- **Linters enforce how to build** — conventions are checked mechanically
- **Hooks catch mistakes in real-time** — before code is committed
- **Templates standardize artifacts** — specs, plans, stories follow consistent formats
- **Agents specialize** — 10 purpose-built agents handle different phases of the lifecycle

---

## Framework Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                            CLAUDE.md                                │
│         (Routing, Architecture, Conventions, Pipeline Rules)        │
│  ┌───────────────────────────────────────────────────────────────┐  │
│  │                       Agents (10)                             │  │
│  │  spec-writer → implementer → test-writer → e2e-writer        │  │
│  │  devops → spec-reviewer → code-reviewer → security-reviewer  │  │
│  │  pr-writer → refactorer                                       │  │
│  │  ┌─────────────────────────────────────────────────────────┐  │  │
│  │  │                    Hooks (4)                             │  │  │
│  │  │  PreToolUse:  pre_write_check (layer rules, reminders)  │  │  │
│  │  │               pre_read_scaffold_guard (scaffold warn)   │  │  │
│  │  │  PostToolUse: post_write_lint (layer_deps, file_size)   │  │  │
│  │  │  Stop:        post_commit_spec_check                    │  │  │
│  │  │  ┌───────────────────────────────────────────────────┐  │  │  │
│  │  │  │              Custom Linters (2)                   │  │  │  │
│  │  │  │  layer_deps.py — forward-only layer imports      │  │  │  │
│  │  │  │  file_size.py  — max 300 lines/file, 50/func    │  │  │  │
│  │  │  │  ┌─────────────────────────────────────────────┐ │  │  │  │
│  │  │  │  │  Templates (8 spec + 9 E2E) + Evals (6)   │ │  │  │  │
│  │  │  │  │  app_spec | feature_spec | feature_lite    │ │  │  │  │
│  │  │  │  │  design_doc | execution_plan | stories     │ │  │  │  │
│  │  │  │  │  test_plan | pipeline_status               │ │  │  │  │
│  │  │  │  │  e2e/ (conftest, page objects, factories)  │ │  │  │  │
│  │  │  │  │  .claude/evals/ (reviewer calibration)       │ │  │  │  │
│  │  │  │  └─────────────────────────────────────────────┘ │  │  │  │
│  │  │  └───────────────────────────────────────────────────┘  │  │  │
│  │  └─────────────────────────────────────────────────────────┘  │  │
│  └───────────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────────┘
```

## 6-Layer Architecture

```
┌───────────────────────────────────────────────────────────────────┐
│                        src/ (Application Code)                    │
│                                                                   │
│  ┌──────────┐    ┌──────────┐    ┌──────────┐    ┌──────────┐   │
│  │  Types   │───▶│  Config  │───▶│   Repo   │───▶│ Service  │   │
│  │          │    │          │    │          │    │          │   │
│  │ schemas  │    │ env vars │    │ data     │    │ business │   │
│  │ enums    │    │ defaults │    │ access   │    │ logic    │   │
│  │ models   │    │          │    │ API      │    │ rules    │   │
│  └──────────┘    └──────────┘    │ clients  │    └────┬─────┘   │
│                                  └──────────┘         │         │
│                                                       ▼         │
│                                  ┌──────────┐    ┌──────────┐   │
│                                  │    UI    │◀───│ Runtime  │   │
│                                  │          │    │          │   │
│                                  │ present- │    │ server   │   │
│                                  │ ation    │    │ boot     │   │
│                                  │ CLI      │    │ middle-  │   │
│                                  └──────────┘    │ ware     │   │
│                                                  └──────────┘   │
│                                                                   │
│     ───▶  = allowed import direction (forward only)              │
│     ◀╌╌╌  = FORBIDDEN (enforced by layer_deps linter)           │
└───────────────────────────────────────────────────────────────────┘
```

## Full SDLC Pipeline

```
  Phase 1        Phase 2        Phase 3        Phase 4        Phase 5
 ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐
 │   SPEC   │─▶│ STORIES  │─▶│  DESIGN  │─▶│TEST PLAN │─▶│EXEC PLAN │
 │          │  │          │  │          │  │          │  │          │
 │spec-     │  │spec-     │  │spec-     │  │spec-     │  │spec-     │
 │writer    │  │writer    │  │writer    │  │writer    │  │writer    │
 │          │  │          │  │          │  │          │  │          │
 │specs/    │  │specs/    │  │specs/    │  │specs/    │  │specs/    │
 │app_spec  │  │stories/  │  │design/   │  │tests/    │  │plans/    │
 └──────────┘  └──────────┘  └──────────┘  └──────────┘  └─────┬────┘
                                                                │
                           ┌────────────────────────────────────┘
                           ▼
                  ┌─────────────────┐
                  │  APPROVE PLAN   │  ◀── Human reviews execution plan
                  │  (checkpoint 1) │      Must say "approved" to proceed
                  └────────┬────────┘
                           │
  Phase 6        Phase 7   ▼    Phase 8        Phase 9
 ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐
 │IMPLEMENT │─▶│TEST FILL │─▶│ E2E TESTS│─▶│  DEVOPS  │
 │          │  │          │  │          │  │          │
 │implement-│  │test-     │  │e2e-      │  │devops    │
 │er (team) │  │writer    │  │writer    │  │          │
 │          │  │          │  │          │  │          │
 │src/      │  │tests/    │  │tests/e2e/│  │infra/    │
 │tests/    │  │(gaps)    │  │templates │  │Dockerfile│
 └──────────┘  └──────────┘  └──────────┘  └─────┬────┘
                                                   │
                           ┌───────────────────────┘
                           ▼
  Phase 10
 ┌──────────────────────────┐
 │         REVIEW           │  spec-reviewer: does code match spec?
 │                          │  code-reviewer: quality + performance?
 │  ┌──────┐┌──────┐┌────┐ │  security-reviewer: OWASP + auth + secrets?
 │  │ SPEC ││ CODE ││SEC │ │
 │  │REVIEW││REVIEW││REV │ │  If FAIL ──▶ re-invoke implementer
 │  └──────┘└──────┘└────┘ │              then re-review (max 3x)
 └─────────────┬────────────┘
               │
               ▼
      ┌─────────────────┐
      │   APPROVE PR    │  ◀── Human reviews verdicts + changes
      │  (checkpoint 2) │      Must approve to proceed
      └────────┬────────┘
               │
               ▼
  Phase 11
 ┌──────────────────────┐
 │          PR           │
 │                       │
 │  pr-writer creates    │
 │  structured PR with   │
 │  story-based commits  │
 └──────────────────────┘
```

## Parallel Implementation (Agent Teams)

```
 specs/stories/<feature>.md
 ┌────────────────────────────────────────────────────────────────┐
 │  Dependency Graph              Parallel Groups                │
 │                                                               │
 │  US-001 ──▶ US-004            Group A: [US-001, US-002, US-003] │
 │  US-002 ──▶ US-005    ───▶   Group B: [US-004, US-005]       │
 │  US-003 ──┘                   Group C: [US-006]               │
 │  US-005 ──▶ US-006                                            │
 └────────────────────────────────────────────────────────────────┘

 Team mode triggers when: 4+ stories AND 2+ parallel groups

 ┌────────────────────────────────────────────────────────────────┐
 │  Main Conversation (orchestrator — coordinates, does NOT code)│
 │                                                               │
 │  1. git checkout -b feat/<feature-name>                       │
 │  2. TeamCreate: feat-<feature-name>                           │
 │  3. TaskCreate: one task per story (with dependency blockers) │
 │  4. Spawn implementer agents per parallel group               │
 │                                                               │
 │  ┌─────────────────┐  ┌─────────────────┐  ┌──────────────┐  │
 │  │  Implementer 1  │  │  Implementer 2  │  │Implementer 3 │  │
 │  │                 │  │                 │  │              │  │
 │  │  US-001         │  │  US-002         │  │  US-003      │  │
 │  │  TDD cycle      │  │  TDD cycle      │  │  TDD cycle   │  │
 │  │  commit per     │  │  commit per     │  │  commit per  │  │
 │  │  story          │  │  story          │  │  story       │  │
 │  └────────┬────────┘  └────────┬────────┘  └──────┬───────┘  │
 │           │                    │                   │          │
 │           ▼                    ▼                   ▼          │
 │  ┌────────────────────────────────────────────────────────┐   │
 │  │       Group A complete → unblocks Group B tasks        │   │
 │  └────────────────────────────────────────────────────────┘   │
 │                                                               │
 │  5. Monitor via TaskList                                      │
 │  6. All tasks done → pytest tests/ --cov=src --cov-fail-under=80 │
 └────────────────────────────────────────────────────────────────┘
```

## Quality Gates (Hook Enforcement)

```
  Claude Code Tool Call (Write / Edit)
  │
  ▼
 ┌──────────────┐    ┌──────────────────────────────────────────────┐
 │  PreToolUse  │───▶│  pre_write_check.py (advisory — never blocks) │
 │  Write|Edit  │    │                                              │
 │              │    │  src/<layer>/* ──▶ Layer import reminder      │
 │              │    │  src/service/* ──▶ Spec suggestion (new mod) │
 │              │    │  src/* | tests/* ──▶ Test file reminder      │
 └──────────────┘    └──────────────────────────────────────────────┘
  │
  ▼
 [Tool executes — file is written]
  │
  ▼
 ┌──────────────┐    ┌──────────────────────────────────────────────┐
 │ PostToolUse  │───▶│  post_write_lint.py                         │
 │  Write|Edit  │    │                                              │
 │              │    │  layer_deps.py ──▶ Backward import? ── WARN │
 │              │    │  file_size.py  ──▶ Over 300 lines?  ── WARN │
 │              │    │  Missing test? ──▶ Test reminder     ── WARN │
 └──────────────┘    └──────────────────────────────────────────────┘
  │
  ▼
 ┌──────────────┐    ┌──────────────────────────────────────────────┐
 │    Stop      │───▶│  post_commit_spec_check.py                  │
 │   (on exit)  │    │                                              │
 │              │    │  Spec coverage check before session ends     │
 └──────────────┘    └──────────────────────────────────────────────┘
  │
  ▼
 ┌──────────────┐    ┌──────────────────────────────────────────────┐
 │     CI       │───▶│  .github/workflows/ci.yml                   │
 │  (on push)   │    │                                              │
 │              │    │  lint ──▶ ruff + mypy + custom linters       │
 │              │    │  test ──▶ unit + integration (coverage 80%)  │
 │              │    │  e2e  ──▶ Playwright browser + API tests     │
 └──────────────┘    └──────────────────────────────────────────────┘
```

## Pipeline Status Tracking

```
 ┌──────────────────────────────────────────────────────────────────┐
 │                   specs/pipeline_status.md                       │
 │                                                                  │
 │  Tracks current phase, artifacts, and blocking issues            │
 │  Updated after every phase completion                            │
 │                                                                  │
 │  Conversation 1               Conversation 2                    │
 │  ┌──────────────────┐         ┌──────────────────┐              │
 │  │ Phase 1: Spec  ✓ │         │ Read pipeline     │              │
 │  │ Phase 2: Story ✓ │         │ status.md         │              │
 │  │ Phase 3: Design✓ │  ───▶   │                   │              │
 │  │ Phase 4: Test  ✓ │  save   │ Last completed: 6 │              │
 │  │ Phase 5: Plan  ✓ │  state  │ Resume from: 7    │              │
 │  │ Phase 6: Impl  ✓ │         │ (Test Fill)       │              │
 │  │ Phase 7: ...     │         │                   │              │
 │  └──────────────────┘         └──────────────────┘              │
 │                                                                  │
 │  "Continue the pipeline" or "What's next?" triggers resumption  │
 └──────────────────────────────────────────────────────────────────┘
```

---

## What's Included

| Category | Count | Purpose |
|---|---|---|
| **Agents** | 10 | Specialized sub-agents for every workflow phase |
| **Custom linters** | 2 | Architecture (layer_deps) and file size enforcement |
| **Hooks** | 4 | Real-time advisory checks on file writes, scaffold read guards, and spec coverage on commit |
| **Spec templates** | 8 | App spec, feature specs (full + lite), plans, stories, test plans, design docs, pipeline status |
| **E2E templates** | 9 | Conftest fixtures, BasePage page object, DictFactory base, example factories/page objects/tests |
| **Reviewer evals** | 6 | Known-good and known-bad code samples for calibrating code-reviewer accuracy |
| **Framework docs** | 10 | Pipeline, workflow, architecture, conventions, testing-standard, linters, spec-system, git-workflow, onboarding, scaffold-overview |
| **CI/CD** | 2 | GitHub Actions for linting, testing, and E2E on every push |

**Dev tooling** (bundled): Python 3.12, pytest, ruff, mypy, Playwright, httpx, factory-boy. **Recommended app frameworks** (add to `dependencies`): FastAPI, Pydantic. Coverage enforced at 80% minimum.

---

## Quickstart

```bash
# 1. Clone the scaffold
git clone https://github.com/your-org/sdsl-scaffold.git my-project
cd my-project

# 2. Validate scaffold integrity
python3 .claude/scripts/validate_scaffold.py

# 3. Validate reviewer eval samples
python3 .claude/scripts/run_reviewer_evals.py

# 4. Install dependencies
make build

# 5. Write a feature spec (or use the spec-writer agent)
cp .claude/templates/feature_spec_lite.md specs/features/my-feature.md

# 6. Open your AI coding tool and implement
# Claude Code: claude
# Tell the agent: "Implement the feature spec at specs/features/my-feature.md"

# 7. Verify
python3 .claude/lint_all.py   # Custom linters
make test                  # Unit + integration tests
```

---

## Your Role: Harness Engineer

1. **Write specs** — Collaborate with the spec-writer agent or fill in templates manually
2. **Approve plans** — Review execution plans before any code is written
3. **Review output** — Run linters, run tests, check acceptance criteria
4. **Evolve the harness** — When agents make mistakes, fix linter rules, agent instructions, or templates

**You write zero lines of application code.** When something goes wrong, don't fix the code — fix the harness.

5. **Calibrate reviewers** — maintain eval samples in `.claude/evals/` so reviewer agents stay accurate as rules evolve

---

## Workflow

Your prompt wording is the switch. The agent classifies your request and routes to the correct workflow automatically.

### Trigger Words

| What you say | What happens |
|---|---|
| `"Build me ..."` / `"Create a ..."` / `"I want an app that ..."` | **Full Pipeline** — spec-writer interviews you, then runs all 11 phases automatically |
| `"Add feature X"` / `"Build X feature"` / `"Add X to the app"` | **Feature Pipeline** — same 11 phases, scoped to one feature |
| `"Here's a spec for X"` / paste a spec | **Spec-provided** — verifies spec, creates stories + plan, waits for approval, then implements |
| `"Continue the pipeline"` / `"What's next?"` / `"Resume"` | **Resume** — reads `specs/pipeline_status.md` and picks up from the next incomplete phase |
| `"Fix bug in X"` / `"Refactor X"` / `"Add validation to X"` | **Day-to-day** — direct code changes, quality gates run automatically |

### Full / Feature Pipeline

```
SPEC → STORIES → DESIGN → TEST PLAN → PLAN → [APPROVE] → IMPLEMENT → TEST FILL → E2E → DEVOPS → REVIEW → [APPROVE] → PR
```

The pipeline pauses at two human checkpoints: before implementation (approve the plan) and before PR (approve the review verdicts).

### Example Prompts

```bash
# Greenfield — builds entire app from scratch
"Build me a task management API with user auth and team workspaces"
"Create a CLI tool that monitors AWS costs and sends Slack alerts"
"I want an app that tracks inventory across multiple warehouses"

# Feature — adds to existing app
"Add feature: email notifications when tasks are overdue"
"Build a CSV export feature for the reports page"
"Add OAuth2 login to the app"

# Resume — continues across conversations
"Continue the pipeline"
"What's next?"

# Day-to-day — no pipeline, just code
"Fix the 500 error in the /users endpoint"
"Refactor the notification service to use the strategy pattern"
```

See [.claude/docs/workflow.md](.claude/docs/workflow.md) for detailed mode descriptions.

---

## Adopting into Existing Projects

You don't need to start from scratch or reorganize your codebase. Adopt incrementally.

### Tier 1: Minimal (15 minutes)

Add a `CLAUDE.md` to your project root describing your architecture, conventions, and how to run tests.

### Tier 2: Standard (30 minutes)

Copy `.claude/agents/` and `.claude/templates/`. Create a `specs/features/` directory. Edit agent instructions to match your conventions.

### Tier 3: Full (1 hour)

Add `.claude/linters/`, `.claude/hooks/`, `.claude/lint_all.py`, and `.claude/settings.json`. Customize linter thresholds for your project.

See [.claude/docs/onboarding.md](.claude/docs/onboarding.md) for details.

---

## E2E Test Templates

The `e2e-writer` agent bootstraps E2E infrastructure by copying templates from `.claude/templates/e2e/` into `tests/e2e/`:

```
.claude/templates/e2e/
├── conftest.py                  # Fixtures: base_url, browser, browser_context, page, api_client, test_data
├── page_objects/
│   ├── __init__.py              # Re-exports BasePage
│   ├── base_page.py             # BasePage: navigate, locator helpers, actions, assertions
│   └── example_page.py          # Reference: how to extend BasePage
├── factories/
│   ├── __init__.py
│   ├── base.py                  # DictFactory: factory-boy producing dicts for API payloads
│   └── user_factory.py          # Reference: example Faker-based factory
├── test_example_ui.py           # Reference: Playwright UI tests using page objects
└── test_example_api.py          # Reference: httpx API contract tests using factories
```

**Core files** (conftest, base_page, base factory) are copied as-is. **Reference files** (examples) are patterns — the agent replaces them with feature-specific implementations.

---

## Makefile Reference

```bash
make help              # Show all available targets
make build             # Install dependencies
make lint              # Run ruff + mypy
make format            # Auto-fix lint issues
make lint-custom       # Run custom linters (layer_deps, file_size)
make test              # Run unit + integration (gracefully skips if no tests exist)
make test-unit         # Run unit tests only (80% coverage enforced)
make test-integration  # Run integration tests only
make test-e2e          # Run E2E tests (requires running server at BASE_URL)
make test-e2e-headed   # Run E2E tests with visible browser
make test-e2e-trace    # Run E2E tests with trace recording
make test-smoke        # Run smoke tests (health checks)
make test-perf         # Run performance tests (load/stress)
make ci                # Full CI suite: lint + custom linters + tests
make run               # Start the application server (customize for your framework)
make validate          # Validate scaffold integrity
make deploy-staging    # Deploy to staging (customize for your infra)
make deploy-production # Swap staging to production
```

---

## Reviewer Calibration (Evals)

The code-reviewer agent is calibrated against known-good and known-bad code samples in `.claude/evals/code-reviewer/`. This ensures the reviewer catches the patterns it should and approves code that follows conventions.

```
.claude/evals/code-reviewer/
  good/                  # Should get APPROVE verdict
    clean_service.py     # Proper logging, types, layer imports
    clean_tests.py       # Meaningful assertions, spec references
  bad/                   # Should get REQUEST_CHANGES verdict
    missing_logger.py    # print() instead of structured logging
    backward_import.py   # Types layer importing from Service
    vacuous_tests.py     # assert result is not None (no real verification)
    bare_except.py       # Bare except: with no context
```

Each sample includes metadata comments documenting the expected verdict, expected findings, and which conventions it tests. When modifying reviewer rules, run `python3 .claude/scripts/run_reviewer_evals.py` to verify the eval inventory, then invoke the code-reviewer against samples to check for regressions.

To add a new eval: create a `.py` file in the appropriate directory with `Expected reviewer verdict:` and `Violations:` (or `Conventions demonstrated:`) comments.

---

## FAQ

**Do I need the 6-layer model?**
No. Describe your own architecture in `CLAUDE.md` and customize the `layer_deps.py` linter.

**Can I use this with TypeScript / Go / other languages?**
The framework is language-agnostic. You'd need to update `pyproject.toml`, the Makefile, and language-specific linters.

**What if I don't want all 10 agents?**
Start with spec-writer, implementer, and code-reviewer. Add others as your workflow matures.

**How is this different from just using CLAUDE.md?**
`CLAUDE.md` tells the agent about your project. This scaffold adds mechanical enforcement (linters + hooks), standardized templates, specialized agents, and CI/CD integration.

---

## License

MIT
