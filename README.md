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
- **Agents specialize** — 9 purpose-built agents handle different phases of the lifecycle

---

## Framework Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                            CLAUDE.md                                │
│         (Routing, Architecture, Conventions, Pipeline Rules)        │
│  ┌───────────────────────────────────────────────────────────────┐  │
│  │                       Agents (9)                              │  │
│  │  spec-writer → implementer → test-writer → e2e-writer        │  │
│  │  devops → spec-reviewer → code-reviewer → pr-writer          │  │
│  │  refactorer                                                   │  │
│  │  ┌─────────────────────────────────────────────────────────┐  │  │
│  │  │                    Hooks (3)                             │  │  │
│  │  │  PreToolUse:  pre-write-check (layer rules, reminders)  │  │  │
│  │  │  PostToolUse: post-write-lint (layer_deps, file_size)   │  │  │
│  │  │  Stop:        post-commit-spec-check                    │  │  │
│  │  │  ┌───────────────────────────────────────────────────┐  │  │  │
│  │  │  │              Custom Linters (2)                   │  │  │  │
│  │  │  │  layer_deps.sh — forward-only layer imports      │  │  │  │
│  │  │  │  file_size.sh  — max 300 lines/file, 50/func    │  │  │  │
│  │  │  │  ┌─────────────────────────────────────────────┐ │  │  │  │
│  │  │  │  │          Templates (8)                      │ │  │  │  │
│  │  │  │  │  app_spec | feature_spec | feature_lite    │ │  │  │  │
│  │  │  │  │  design_doc | execution_plan | stories     │ │  │  │  │
│  │  │  │  │  test_plan | pipeline_status               │ │  │  │  │
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
 │tests/    │  │(gaps)    │  │Playwright│  │Dockerfile│
 └──────────┘  └──────────┘  └──────────┘  └─────┬────┘
                                                   │
                           ┌───────────────────────┘
                           ▼
  Phase 10
 ┌──────────────────────────┐
 │         REVIEW           │  spec-reviewer: does code match spec?
 │                          │  code-reviewer: quality, security, perf?
 │  ┌─────────┐ ┌────────┐ │
 │  │  SPEC   │ │  CODE  │ │  If FAIL ──▶ re-invoke implementer
 │  │ REVIEW  │ │ REVIEW │ │              then re-review (max 3x)
 │  └─────────┘ └────────┘ │
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
 │  PreToolUse  │───▶│  pre-write-check.sh (advisory — never blocks)│
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
 │ PostToolUse  │───▶│  post-write-lint.sh                         │
 │  Write|Edit  │    │                                              │
 │              │    │  layer_deps.sh ──▶ Backward import? ── WARN │
 │              │    │  file_size.sh  ──▶ Over 300 lines?  ── WARN │
 │              │    │  Missing test? ──▶ Test reminder     ── WARN │
 └──────────────┘    └──────────────────────────────────────────────┘
  │
  ▼
 ┌──────────────┐    ┌──────────────────────────────────────────────┐
 │    Stop      │───▶│  post-commit-spec-check.sh                  │
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
| **Agents** | 9 | Specialized sub-agents for every workflow phase |
| **Custom linters** | 2 | Architecture (layer_deps) and file size enforcement |
| **Hooks** | 3 | Real-time advisory checks on every file write |
| **Templates** | 8 | App spec, feature specs (full + lite), plans, stories, test plans, design docs, pipeline status |
| **Framework docs** | 8 | Pipeline, workflow, architecture, conventions, linters, spec-system, git-workflow, onboarding |
| **CI/CD** | 2 | GitHub Actions for linting, testing, and E2E on every push |

**Stack**: Python 3.12, FastAPI, Pydantic, pytest, ruff, mypy, Playwright. Coverage enforced at 80% minimum.

---

## Quickstart

```bash
# 1. Clone the scaffold
git clone https://github.com/your-org/sdsl-scaffold.git my-project
cd my-project

# 2. Validate scaffold integrity
bash .claude/scripts/validate-scaffold.sh

# 3. Install dependencies
make build

# 4. Write a feature spec (or use the spec-writer agent)
cp .claude/templates/feature_spec_lite.md specs/features/my-feature.md

# 5. Open your AI coding tool and implement
# Claude Code: claude
# Tell the agent: "Implement the feature spec at specs/features/my-feature.md"

# 6. Verify
bash .claude/lint_all.sh   # Custom linters
make test                  # Unit + integration tests
```

---

## Your Role: Harness Engineer

1. **Write specs** — Collaborate with the spec-writer agent or fill in templates manually
2. **Approve plans** — Review execution plans before any code is written
3. **Review output** — Run linters, run tests, check acceptance criteria
4. **Evolve the harness** — When agents make mistakes, fix linter rules, agent instructions, or templates

**You write zero lines of application code.** When something goes wrong, don't fix the code — fix the harness.

---

## Workflow

This scaffold supports two modes. Your prompt wording is the switch.

### Greenfield / New Application (Full SDLC)

Use this when bootstrapping a new application from scratch. The pipeline runs **automatically from spec to PR** -- you only pause at two approval checkpoints.

```
SPEC → STORIES → DESIGN → TEST PLAN → PLAN → [APPROVE] → IMPLEMENT → TEST FILL → E2E → DEVOPS → REVIEW → [APPROVE] → PR
```

**Example prompts:**

```
"Use the spec-writer agent to create a spec for a task management app"
"Use the spec-writer agent — I want to build a clone of Notion"
"Build me an AI chat interface with conversation management and artifacts"
```

**What happens:**
1. The **spec-writer** agent interviews you (vision, tech shape, scope/priority)
2. It drafts a comprehensive app spec at `specs/app_spec.md` for your approval
3. It produces stories, design doc, test plan, and execution plan
4. **You approve the plan** (checkpoint 1)
5. The **implementer** agent(s) build from the plan (teams for parallel stories)
6. The **test-writer** fills coverage gaps, **e2e-writer** generates Playwright tests
7. The **devops** agent generates CI/CD, Dockerfile, and deployment configs
8. **spec-reviewer** + **code-reviewer** validate (auto-loop on failures)
9. **You approve for PR** (checkpoint 2)
10. The **pr-writer** creates a structured PR with story-based commits

### New Feature (Feature SDLC)

Use this when adding a significant feature to an existing application. Same full pipeline, scoped to one feature.

**Example prompts:**

```
"Use the spec-writer agent to create a spec for user authentication"
"Use the spec-writer agent to brainstorm a spec for payment processing"
```

**What happens:**
1. The **spec-writer** agent interviews you (intent, behavior, data/integration)
2. It produces feature spec, stories, design, test plan, and execution plan
3. **You approve the plan** (checkpoint 1)
4. The **implementer** agent builds from the approved plan, story by story
5. **e2e-writer** and **devops** agents generate tests and configs
6. **spec-reviewer** + **code-reviewer** validate the output
7. **You approve for PR** (checkpoint 2)
8. The **pr-writer** agent creates a structured PR

### Day-to-Day (Quality Gates Only)

Use this for bug fixes, refactoring, small improvements, and iterative changes. Just ask directly — no specs needed. Quality gates (advisory hooks + linters + CI) provide feedback automatically on every write.

**Example prompts:**

```
"Fix the token refresh bug in src/service/auth.py"
"Add input validation to the create_user endpoint"
"Refactor the payment module to reduce duplication"
"Add pagination to the list_orders endpoint"
```

**What happens:**
1. Claude Code writes code directly
2. Pre-write hook reminds about layer rules and tests
3. Post-write hook runs linters (`layer_deps`, `file_size`)
4. You run `make test` to verify

### When to Use Which

| Situation | Mode | Why |
|---|---|---|
| New application from scratch | Greenfield SDLC | App spec first — captures tech stack, schema, API, UI, phases |
| Major new feature (auth, payments, etc.) | Feature SDLC | Feature spec — captures one feature's requirements fully |
| Bug fix | Day-to-day | Direct fix, linters catch regressions |
| Refactoring | Day-to-day | Structure changes, not new behavior |
| Small improvement (add a field, tweak validation) | Day-to-day | Too small for a full spec |
| Cross-cutting change (logging, error handling) | Either | Use spec if it touches 5+ files, otherwise day-to-day |

See [.claude/docs/workflow.md](.claude/docs/workflow.md) for details.

---

## Adopting into Existing Projects

You don't need to start from scratch or reorganize your codebase. Adopt incrementally.

### Tier 1: Minimal (15 minutes)

Add a `CLAUDE.md` to your project root describing your architecture, conventions, and how to run tests.

### Tier 2: Standard (30 minutes)

Copy `.claude/agents/` and `.claude/templates/`. Create a `specs/features/` directory. Edit agent instructions to match your conventions.

### Tier 3: Full (1 hour)

Add `.claude/linters/`, `.claude/hooks/`, `.claude/lint_all.sh`, and `.claude/settings.json`. Customize linter thresholds for your project.

See [.claude/docs/onboarding.md](.claude/docs/onboarding.md) for details.

---

## Makefile Reference

```bash
make help              # Show all available targets
make build             # Install dependencies
make lint              # Run ruff + mypy
make lint-custom       # Run custom linters
make test              # Run unit + integration tests
make ci                # Full CI suite: lint + custom linters + tests
make validate          # Validate scaffold integrity
```

---

## FAQ

**Do I need the 6-layer model?**
No. Describe your own architecture in `CLAUDE.md` and customize the `layer_deps.sh` linter.

**Can I use this with TypeScript / Go / other languages?**
The framework is language-agnostic. You'd need to update `pyproject.toml`, the Makefile, and language-specific linters.

**What if I don't want all 9 agents?**
Start with spec-writer, implementer, and code-reviewer. Add others as your workflow matures.

**How is this different from just using CLAUDE.md?**
`CLAUDE.md` tells the agent about your project. This scaffold adds mechanical enforcement (linters + hooks), standardized templates, specialized agents, and CI/CD integration.

---

## License

MIT
