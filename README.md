# Claude Code Production Scaffold v2

A production-ready scaffolding template for Claude Code projects using **Spec-Driven Software Lifecycle (SDSL)**.

> **Philosophy**: Humans steer. Agents execute. Specs are the source of truth.
> Humans write zero lines of code — they write specs, review PRs, and evolve the harness.

## What's Included

- **CLAUDE.md** — Concise map pointing to detailed docs
- **3 hooks** — Pre-write checks, post-write linting, spec enforcement
- **5 agents** — Specialized sub-agents for specs, implementation, testing, review, and refactoring
- **5 custom linters** — Layer deps, naming, file size, logging, spec coverage
- **Dual-track spec system** — XML app_spec or direct feature spec writing
- **Execution plans** — Living documents tracking progress, decisions, and surprises
- **CI/CD** — GitHub Actions with lint + test pipeline
- **Infrastructure** — Makefile, Dockerfile, pyproject.toml pre-configured

## Stack

- **Backend**: Python 3.12 / FastAPI
- **Layer Architecture**: Types → Config → Repo → Service → Runtime → UI
- **Coverage**: Mechanically enforced at 80% minimum

## Your Role: Harness Engineer

> Inspired by [OpenAI — Harness Engineering](https://openai.com/index/harness-engineering/)

You are a **harness engineer**. You write zero lines of application code. Your job:

1. **Write specs** — Fill in `specs/templates/feature_spec.md` with data models, API contracts, UI layout, acceptance criteria
2. **Orchestrate agents** — Tell Claude Code which agent to use and which spec to implement
3. **Review output** — Run linters, run tests, check acceptance criteria
4. **Evolve the harness** — When agents make mistakes, fix linter rules / agent instructions / spec templates — not code

See [docs/workflow.md](docs/workflow.md) for the full orchestration guide.

## Workflow

```
SPEC (collaborative) → PLAN (agent) → APPROVE (human) → IMPLEMENT + TEST (agent) → SPEC REVIEW + CODE REVIEW (agent)
```

The implementer writes both code and tests in a single pass. The test-writer agent fills coverage gaps afterward if needed.

## Quickstart

```bash
# 1. Clone and enter
git clone <this-repo> my-project
cd my-project

# 2. Validate scaffold integrity
bash scripts/validate-scaffold.sh

# 3. Option A: Start from XML app spec
cp specs/templates/app_spec_template.xml specs/app_spec.xml
# Edit specs/app_spec.xml with your app definition
bash scripts/init-from-app-spec.sh specs/app_spec.xml

# 3. Option B: Write feature specs directly
cp specs/templates/feature_spec.md specs/features/my-feature.md

# 4. Implement via Claude Code agents
# Use the implementer agent to generate code + tests from specs
```

## Project Structure

```
.claude/
  hooks/          # 3 automated hooks
  agents/         # 5 sub-agents
  settings.json   # Hook wiring + permissions
specs/
  templates/      # app_spec.xml, feature_spec.md, design_doc.md, execution_plan.md
  features/       # Feature specs (source of truth)
docs/
  architecture.md # Layer model, intentional constraints, testing strategy
  workflow.md     # Full SDSL workflow with orchestration model
  conventions.md  # Coding standards and type conventions
  linters.md      # All 5 linters documented
  spec-system.md  # Dual-track spec architecture
scripts/
  linters/        # 5 custom linter scripts
  lint_all.sh     # Master linter runner
  validate-scaffold.sh  # Scaffold integrity checker
  init-from-app-spec.sh # XML spec → feature spec stubs
src/
  types/          # Shared types and schemas
  config/         # Configuration
  repo/           # Data access layer
  service/        # Business logic
  runtime/        # Server bootstrap
  ui/             # Presentation layer
tests/
  unit/
  integration/
  e2e/
```

## Agents

| Agent | Role |
|-------|------|
| `spec-writer` | Intent → structured specs |
| `implementer` | Code + tests from spec in one pass |
| `test-writer` | Coverage gap filling after implementation |
| `refactorer` | Continuous debt reduction |
| `code-reviewer` | Spec compliance and quality review |

## Custom Linters

Run all linters: `bash scripts/lint_all.sh`

| Linter | Enforces |
|--------|----------|
| `layer_deps` | Forward-only layer imports |
| `structured_logging` | No raw print/console |
| `naming_conventions` | snake_case/PascalCase rules |
| `file_size` | 300-line file / 50-line function limits |
| `spec_coverage` | Service modules trace to specs |

All 5 linters produce actionable error messages with remediation instructions. See [docs/linters.md](docs/linters.md) for details.

## License

MIT
