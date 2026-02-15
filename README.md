# SDSL Production Scaffold

**A spec-driven scaffolding framework for agentic coding assistants.**

Engineers orchestrate. Agents write all code. Specs are the source of truth.

> Inspired by OpenAI's [Harness Engineering](https://openai.com/index/harness-engineering/) — the practice of designing environments that make AI coding agents productive, rather than writing code yourself.

---

## The Problem

AI coding agents (Claude Code, Codex CLI, Gemini CLI) are powerful code generators, but without structure they produce inconsistent output: wrong architecture, missing tests, convention violations, no traceability. Every session starts from scratch.

## The Solution

This scaffold gives your agents a production-grade harness:

- **Specs define what to build** — agents can't drift from requirements
- **Linters enforce how to build** — conventions are checked mechanically, not by memory
- **Hooks catch mistakes in real-time** — before code is committed, not after review
- **Templates standardize artifacts** — specs, plans, stories, and test plans follow consistent formats
- **Agents specialize** — 7 purpose-built agents handle different phases of the lifecycle

The result: you describe what you want, agents build it correctly, and mechanical guardrails keep everything on track.

---

## Table of Contents

- [Philosophy: Harness Engineering](#philosophy-harness-engineering)
- [What's Included](#whats-included)
- [Supported Tools](#supported-tools)
- [Quickstart](#quickstart)
- [Your Role: Harness Engineer](#your-role-harness-engineer)
- [Workflow: Spec to PR](#workflow-spec-to-pr)
- [Architecture: 6-Layer Model](#architecture-6-layer-model)
- [Agents (7)](#agents)
- [Custom Linters (5)](#custom-linters)
- [Hooks (3)](#hooks)
- [Templates (6)](#templates)
- [Project Structure](#project-structure)
- [Adopting into Existing Projects](#adopting-into-existing-projects)
- [FAQ](#faq)
- [License](#license)

---

## Philosophy: Harness Engineering

Traditional development: engineers write code, reviewers catch mistakes, conventions drift over time.

Harness engineering flips this: **engineers design the environment, agents write the code, mechanical systems enforce quality.**

| Traditional Role | Harness Engineer Role |
|---|---|
| Write application code | Write specs that describe what to build |
| Manually enforce conventions | Encode conventions as linters that run automatically |
| Review code for style issues | Let automated linters catch style; review for intent |
| Fix bugs by editing source | Write a bug-fix spec; let agents implement the fix |
| Onboard new developers | Improve agent instructions and templates |

**You write zero lines of application code.** Your leverage comes from the quality of your specs, the precision of your linter rules, and the clarity of your agent instructions.

When agents make mistakes, you don't fix the code — you fix the harness (linter rules, agent instructions, spec templates) so the mistake can never recur.

---

## What's Included

| Category | Count | Purpose |
|---|---|---|
| **Agents** | 7 | Specialized sub-agents for every workflow phase |
| **Custom linters** | 5 | Mechanical enforcement of architecture and conventions |
| **Hooks** | 3 | Real-time checks on every file write |
| **Templates** | 6 | Standardized specs, plans, stories, test plans, design docs |
| **Framework docs** | 7 | Workflow, architecture, conventions, linters, spec system, git, onboarding |
| **Scripts** | 2 | Scaffold validation, XML app spec initialization |
| **Tool configs** | 3 | Pre-wired for Claude Code, Codex CLI, and Gemini CLI |
| **CI/CD** | 2 | GitHub Actions for linting and testing on every push |
| **Makefile** | 18 targets | Build, lint, test, deploy — all common operations |

**Stack**: Python 3.12, FastAPI, Pydantic, pytest, ruff, mypy. Coverage enforced at 80% minimum.

---

## Supported Tools

This scaffold provides first-class support for three AI coding CLIs. All tools share the same linters, templates, docs, and specs — only the entry points and hook mechanisms differ.

| Capability | Claude Code | Gemini CLI | Codex CLI |
|---|---|---|---|
| **Entry point** | `CLAUDE.md` | `GEMINI.md` | `AGENTS.md` |
| **Config directory** | `.claude/` | `.gemini/` | `.codex/` |
| **Pre-write hooks** | Automatic | Automatic (BeforeTool) | Not available |
| **Post-write linting** | Automatic | Automatic (AfterTool) | Manual / CI only |
| **Session-end check** | Automatic | Not available | Not available |
| **Sub-agent invocation** | Native sub-agents | Read agent definitions | Read agent definitions |
| **Approval policy** | Hook-gated | Hook-gated | `config.toml` (on-failure) |
| **Sandbox** | Configurable | Configurable | `workspace-write` |

**Claude Code** has the deepest integration (native sub-agents, 3 hooks, settings.json permissions). **Gemini CLI** has near-parity via its BeforeTool/AfterTool hooks. **Codex CLI** relies on instructions and CI/CD for enforcement.

---

## Quickstart

### Option A: Start a new project from this scaffold

```bash
# 1. Clone the scaffold
git clone https://github.com/your-org/sdsl-scaffold.git my-project
cd my-project

# 2. Validate scaffold integrity
bash .claude/scripts/validate-scaffold.sh

# 3. Install dependencies
make build

# 4a. Start from an XML app spec (for greenfield projects)
cp .claude/templates/app_spec_template.xml specs/app_spec.xml
# Edit specs/app_spec.xml with your app's features, data model, and API
bash .claude/scripts/init-from-app-spec.sh specs/app_spec.xml
# This generates feature spec stubs in specs/features/

# 4b. OR write feature specs directly
cp .claude/templates/feature_spec.md specs/features/my-feature.md
# Fill in the spec — or use the spec-writer agent to interview you

# 5. Open your AI coding tool and start the workflow
# Claude Code:  claude
# Gemini CLI:   gemini
# Codex CLI:    codex

# 6. Tell the agent to implement from the spec
# Example: "Implement the feature spec at specs/features/my-feature.md"

# 7. After implementation, verify
bash .claude/lint_all.sh   # Run all 5 custom linters
make test                  # Run unit + integration tests
```

### Option B: Adopt into an existing project

See [Adopting into Existing Projects](#adopting-into-existing-projects) for a three-tier incremental adoption path.

---

## Your Role: Harness Engineer

As a harness engineer, your daily workflow looks like this:

### What You Do

1. **Write specs** — Collaborate with the spec-writer agent or fill in templates manually
2. **Approve plans** — Review execution plans before any code is written
3. **Review output** — Run linters, run tests, check acceptance criteria
4. **Evolve the harness** — When agents make mistakes, fix linter rules, agent instructions, or templates

### What You Never Do

- Write application code directly
- Fix bugs by editing `src/` — write a bug-fix spec instead
- Skip review — every agent output gets human review before merge

### The Feedback Loop

When something goes wrong, don't fix the code — fix the system that allowed the mistake:

| You notice... | You fix... | By... |
|---|---|---|
| Agent violates a convention | Linter rules | Adding a check to `.claude/linters/` |
| Agent misunderstands architecture | Agent instructions | Updating `.claude/agents/*.md` |
| Spec was ambiguous | Spec template | Adding a section to `.claude/templates/feature_spec.md` |
| Reviewer catches a pattern | Conventions doc | Encoding the pattern in `.claude/docs/conventions.md` |

---

## Workflow: Spec to PR

Every feature follows this 8-phase lifecycle:

```
SPEC  →  STORIES  →  PLAN  →  APPROVE  →  IMPLEMENT  →  TEST  →  REVIEW  →  PR
human    agent       agent    human       agent         agent    agent       agent
```

### Phase 1: Spec (Human + spec-writer agent)

The spec-writer agent interviews you in three rounds (intent, behavior, data/integration), then drafts a spec from the template. You can also write specs directly using `.claude/templates/feature_spec.md`.

```bash
# Collaborative (recommended)
# Tell your agent: "Use the spec-writer agent to brainstorm a spec for [your idea]"

# Manual
cp .claude/templates/feature_spec.md specs/features/my-feature.md
```

### Phase 2: Stories (spec-writer agent)

The spec-writer decomposes the approved spec into user stories with dependency graphs and parallel groups. Stories go to `specs/stories/<feature>.md`.

### Phase 3: Plan (agent — requires human approval)

The agent writes an execution plan with small tasks (2-5 minutes each), exact file paths, and verification steps. **No code is written until you approve the plan.**

### Phase 4: Approve (Human)

You review the plan. Approve it, request changes, or reject it.

### Phase 5: Implement (implementer agent)

The implementer follows the approved plan:
- **Story-based**: implements in dependency order, one commit per story
- **Layer-based**: Types, then Config, then Repo, then Service, then Runtime, then UI
- Writes tests alongside code, targeting 80% coverage minimum

### Phase 6: Test (test-writer agent, if needed)

If coverage falls below 80% or acceptance criteria lack test coverage, the test-writer fills gaps.

### Phase 7: Review (spec-reviewer + code-reviewer)

Two independent review passes — both must pass:

| Review | Agent | Checks |
|---|---|---|
| **Spec review** | spec-reviewer | Acceptance criteria met? Business rules implemented? Edge cases handled? |
| **Code review** | code-reviewer | Architecture, conventions, security, performance, test quality |

### Phase 8: PR (pr-writer agent)

The pr-writer organizes commits by story ID (`feat(US-XXX): description`), pushes to a feature branch, and creates a PR via `gh pr create` with a summary, story table, and checklist.

---

## Architecture: 6-Layer Model

The scaffold enforces a strict forward-only dependency model:

```
Types → Config → Repo → Service → Runtime → UI
  0       1       2        3         4       5
```

| Layer | Path | Purpose | Can Import |
|---|---|---|---|
| **Types** | `src/types/` | Shared types, enums, Pydantic schemas | Standard library only |
| **Config** | `src/config/` | Environment parsing, defaults | Types |
| **Repo** | `src/repo/` | Data access, external API clients | Types, Config |
| **Service** | `src/service/` | Business logic, domain rules | Types, Config, Repo |
| **Runtime** | `src/runtime/` | Server bootstrap, middleware | Types through Service |
| **UI** | `src/ui/` | Presentation, CLI, user-facing | All layers |

**Backward imports are forbidden** and enforced by the `layer_deps` linter. A Service module cannot import from Runtime. A Repo module cannot import from Service. The linter checks every import statement on every run.

---

## Agents

Seven specialized agents handle different phases of the workflow. Agent definitions live in `.claude/agents/` as markdown files readable by any AI tool.

| Agent | File | Role |
|---|---|---|
| **spec-writer** | `spec-writer.md` | Socratic interviewer: collaborates with you to produce specs and user stories through structured conversation rounds |
| **implementer** | `implementer.md` | Generates code + tests from approved specs, story-by-story or layer-by-layer |
| **test-writer** | `test-writer.yaml` | Fills coverage gaps after implementation — edge cases, integration tests, fixtures |
| **refactorer** | `refactorer.md` | Continuous debt reduction — splits god files, extracts utilities, removes duplication |
| **spec-reviewer** | `spec-reviewer.md` | Validates implementation against the spec — checks acceptance criteria, business rules |
| **code-reviewer** | `code-reviewer.md` | Validates code quality — architecture, conventions, security, performance, test quality |
| **pr-writer** | `pr-writer.md` | Creates structured PRs with story-based commits, summary tables, and checklists |

### Two-Stage Review

Review is split into two independent passes. This separation ensures that spec compliance and code quality are evaluated with different lenses:

1. **Spec review** (spec-reviewer) — Did we build what the spec says? Are all acceptance criteria met? Are business rules correctly implemented?
2. **Code review** (code-reviewer) — Is the code well-structured? Does it follow conventions? Are there security or performance issues?

Both must pass before a feature is considered complete.

---

## Custom Linters

Five bash-based linters enforce conventions mechanically. All linters produce actionable error messages with remediation instructions — when a linter fails, read the error and it tells you exactly how to fix it.

Run all linters:

```bash
bash .claude/lint_all.sh
```

| Linter | File | Enforces |
|---|---|---|
| **layer_deps** | `layer_deps.sh` | Forward-only layer imports. Catches `from src.runtime import ...` inside a Service module. |
| **structured_logging** | `structured_logging.sh` | No raw `print()` or `console.log()`. Requires `import logging; logger = logging.getLogger(__name__)`. |
| **naming_conventions** | `naming_conventions.sh` | `snake_case` for files and functions, `PascalCase` for classes. Provides auto-fix suggestions. |
| **file_size** | `file_size.sh` | Max 300 lines per file (warn at 250), max 50 lines per function. |
| **spec_coverage** | `spec_coverage.sh` | Every service module in `src/service/` must have a corresponding spec in `specs/features/`. |

Linters are CI-enforced via `.github/workflows/ci.yml` — violations block merge regardless of local hook support.

---

## Hooks

Three hooks provide real-time feedback during development. Hooks are wired in `.claude/settings.json` for Claude Code and `.gemini/settings.json` for Gemini CLI.

| Hook | Trigger | Purpose |
|---|---|---|
| **pre-write-check** | Before any file write | Validates write location, reminds about spec requirements and layer rules |
| **post-write-lint** | After any file write | Runs targeted linters on the changed file, shows top 5 errors |
| **post-commit-spec-check** | Session end | Summary report: total files, source files, specs found/missing |

All hooks are advisory (exit 0) — they warn but don't block. CI provides the hard enforcement gate.

---

## Templates

Six templates standardize the artifacts produced at each workflow phase. Templates live in `.claude/templates/`.

| Template | File | Purpose |
|---|---|---|
| **Feature Spec** | `feature_spec.md` | Comprehensive spec: acceptance criteria, affected layers, data model, API endpoints, business rules, edge cases, test strategy |
| **User Stories** | `user_stories.md` | Story map with dependency graph, parallel groups, and per-story acceptance criteria |
| **Execution Plan** | `execution_plan.md` | Small atomic tasks (2-5 min each), milestones, verification steps. Requires human approval. |
| **Test Plan** | `test_plan.md` | Test cases table, fixtures, E2E scenarios, coverage targets |
| **Design Doc** | `design_doc.md` | Architecture decision record: alternatives considered, layer impact, sequence diagrams, risks |
| **App Spec (XML)** | `app_spec_template.xml` | Full-app definition: features, data model, API endpoints, non-functional requirements |

### Dual-Track Spec System

You can start from either direction:

**Track A: XML App Spec** (for greenfield projects)
```bash
cp .claude/templates/app_spec_template.xml specs/app_spec.xml
# Define your entire app: features, data model, API, NFRs
bash .claude/scripts/init-from-app-spec.sh specs/app_spec.xml
# Generates: specs/feature_list.json + specs/features/<feature-id>.md (stubs)
```

**Track B: Direct Feature Specs** (for iterative development)
```bash
cp .claude/templates/feature_spec.md specs/features/my-feature.md
# Or: use the spec-writer agent to interview you and draft the spec
```

Both tracks converge at `specs/features/<name>.md` — from there, the workflow is identical.

---

## Project Structure

```
.
├── CLAUDE.md                    # Claude Code entry point (reads this first)
├── AGENTS.md                    # Codex CLI entry point
├── GEMINI.md                    # Gemini CLI entry point
├── Makefile                     # 18 targets: build, lint, test, deploy
├── pyproject.toml               # Python 3.12 project config (ruff, mypy, pytest)
├── Dockerfile                   # Container image
├── .env.example                 # Environment variable template
│
├── .claude/                     # Framework scaffolding (shared by all tools)
│   ├── agents/                  # 7 agent definitions (markdown + yaml)
│   ├── docs/                    # 7 framework docs
│   ├── hooks/                   # 3 hooks (pre-write, post-write, session-end)
│   ├── linters/                 # 5 custom linter scripts (bash)
│   ├── templates/               # 6 templates (spec, stories, plan, test, design, XML)
│   ├── scripts/                 # validate-scaffold.sh, init-from-app-spec.sh
│   ├── lint_all.sh              # Master linter runner
│   └── settings.json            # Claude Code hook wiring + permissions
│
├── .gemini/                     # Gemini CLI configuration
│   ├── hooks/                   # Pre/post-write hooks (mirrors .claude/hooks/)
│   └── settings.json            # Gemini hook wiring
│
├── .codex/                      # Codex CLI configuration
│   └── config.toml              # Approval policy + sandbox settings
│
├── .github/workflows/           # CI/CD
│   ├── ci.yml                   # Linters + tests on every push
│   └── release.yml              # Release pipeline
│
├── specs/                       # Spec system (source of truth)
│   ├── architecture.md          # Project-level technical design
│   ├── features/                # Feature specs (one per feature)
│   ├── stories/                 # User stories with dependency graphs
│   ├── plans/                   # Execution plans (must be approved)
│   └── tests/                   # Test plans per user story
│
├── src/                         # Application code (6-layer model)
│   ├── types/                   # Layer 0: Shared types, enums, schemas
│   ├── config/                  # Layer 1: Environment parsing, defaults
│   ├── repo/                    # Layer 2: Data access, external APIs
│   ├── service/                 # Layer 3: Business logic, domain rules
│   ├── runtime/                 # Layer 4: Server bootstrap, middleware
│   └── ui/                      # Layer 5: Presentation, CLI
│
└── tests/                       # Test suite
    ├── conftest.py              # Shared fixtures
    ├── unit/                    # Unit tests (fast, mocked)
    ├── integration/             # Integration tests (real components)
    └── e2e/                     # End-to-end tests (Playwright)
```

---

## Adopting into Existing Projects

You don't need to start from scratch or reorganize your codebase. Adopt incrementally.

### Tier 1: Minimal (15 minutes)

Add a `CLAUDE.md` to your project root describing your architecture, conventions, and how to run tests. This single file gives any AI coding tool enough context to work effectively.

**What you get**: Structured context for any AI tool.

### Tier 2: Standard (30 minutes)

Copy from this scaffold:
- `.claude/agents/` — spec-writer, implementer, reviewer agents
- `.claude/templates/` — feature spec, execution plan, and user story templates
- Create a `specs/features/` directory

Edit the agent instructions and templates to match your project's conventions.

**What you get**: Spec-driven workflow with reusable agents.

### Tier 3: Full (1 hour)

Add mechanical enforcement:
- `.claude/linters/` and `.claude/lint_all.sh` — customize thresholds and rules
- `.claude/hooks/` + `.claude/settings.json` (Claude Code) or `.gemini/settings.json` (Gemini)
- `.codex/config.toml` (Codex — instruction-based enforcement + CI)

Customize each linter for your project: adjust `layer_deps.sh` for your architecture, `file_size.sh` for your limits, or remove linters that don't apply.

**What you get**: Automated guardrails that enforce conventions mechanically.

---

## Makefile Reference

```bash
make help              # Show all available targets
make build             # Install dependencies (pip install -e ".[dev]")
make lint              # Run ruff + mypy
make format            # Auto-fix lint issues
make lint-custom       # Run 5 custom linters
make test              # Run unit + integration tests (default)
make test-unit         # Unit tests with 80% coverage gate
make test-integration  # Integration tests
make test-e2e          # End-to-end tests (Playwright)
make ci                # Full CI suite: lint + custom linters + tests
make validate          # Validate scaffold integrity
```

---

## FAQ

**Do I need the 6-layer model?**

No. The 6-layer model (Types, Config, Repo, Service, Runtime, UI) is a recommendation for new projects. For existing codebases, describe your own architecture in `CLAUDE.md` and customize the `layer_deps.sh` linter (or remove it).

**Can I use this with TypeScript / Go / other languages?**

The scaffold is configured for Python 3.12 out of the box, but the framework is language-agnostic: agents, specs, templates, and most linters work with any language. You'd need to update `pyproject.toml`, the Makefile, and language-specific linters (naming conventions, structured logging).

**What if I don't want all 7 agents?**

Start with the ones you need. The minimum viable set is: spec-writer (to define what to build), implementer (to build it), and code-reviewer (to validate it). Add others as your workflow matures.

**How is this different from just using CLAUDE.md?**

`CLAUDE.md` tells the agent about your project. This scaffold goes further: it provides mechanical enforcement (linters + hooks), standardized templates, specialized agents for each workflow phase, a spec system with traceability, and CI/CD integration. It's the difference between giving instructions and building a production system.

**Does plan approval actually work?**

Yes. The agent writes the plan to `specs/plans/`, then waits for your approval before implementing. This is enforced in the agent instructions and supported natively in Claude Code's plan mode. For Codex and Gemini, it's instruction-based (the agent is told to stop and wait).

**Can I mix tools? Use Claude Code for some tasks and Gemini for others?**

Yes. All tools read the same specs, templates, linters, and docs. The only differences are the entry point files (`CLAUDE.md` vs `GEMINI.md` vs `AGENTS.md`) and the hook mechanisms. You can switch tools freely within the same project.

---

## License

MIT
