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
- **Agents specialize** — 7 purpose-built agents handle different phases of the lifecycle

---

## What's Included

| Category | Count | Purpose |
|---|---|---|
| **Agents** | 7 | Specialized sub-agents for every workflow phase |
| **Custom linters** | 2 | Architecture (layer_deps) and file size enforcement |
| **Hooks** | 3 | Real-time advisory checks on every file write |
| **Templates** | 7 | App spec, feature specs (full + lite), plans, stories, test plans, design docs |
| **Framework docs** | 7 | Workflow, architecture, conventions, linters, spec-system, git-workflow, onboarding |
| **CI/CD** | 2 | GitHub Actions for linting and testing on every push |

**Stack**: Python 3.12, FastAPI, Pydantic, pytest, ruff, mypy. Coverage enforced at 80% minimum.

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

Use this when bootstrapping a new application from scratch. The spec-writer agent interviews you, produces a comprehensive **app spec** (tech stack, features, database schema, API, UI layout, design system, implementation phases), then decomposes it into individual feature specs.

```
APP SPEC → FEATURE SPECS → STORIES → PLAN → APPROVE → IMPLEMENT → TEST → REVIEW → PR
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
3. It decomposes the app spec into individual feature specs at `specs/features/*.md`
4. You choose which feature to implement first
5. For each feature: stories, plan, implement, test, review, PR

### New Feature (Feature SDLC)

Use this when adding a significant feature to an existing application.

**Example prompts:**

```
"Use the spec-writer agent to create a spec for user authentication"
"Use the spec-writer agent to brainstorm a spec for payment processing"
```

**What happens:**
1. The **spec-writer** agent interviews you (intent, behavior, data/integration)
2. It drafts a feature spec at `specs/features/<name>.md` for your approval
3. It decomposes the spec into user stories and an execution plan
4. You approve the plan
5. The **implementer** agent builds from the approved plan, story by story
6. The **code-reviewer** and **spec-reviewer** agents validate the output
7. The **pr-writer** agent creates a structured PR

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

**What if I don't want all 7 agents?**
Start with spec-writer, implementer, and code-reviewer. Add others as your workflow matures.

**How is this different from just using CLAUDE.md?**
`CLAUDE.md` tells the agent about your project. This scaffold adds mechanical enforcement (linters + hooks), standardized templates, specialized agents, and CI/CD integration.

---

## License

MIT
