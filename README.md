# Claude Code Production Scaffold v2

A production-ready scaffolding template for Claude Code projects using **Spec-Driven Software Lifecycle (SDSL)**.

> **Philosophy**: Humans steer. Agents execute. Specs are the source of truth.
> Humans write zero lines of code — they write specs, review PRs, and evolve the harness.

## What's Included

- **CLAUDE.md** — Concise map pointing to detailed docs
- **3 hooks** — Pre-write checks, post-write linting, spec enforcement
- **6 agents** — Specialized sub-agents for specs, implementation, testing, review, and refactoring
- **5 custom linters** — Layer deps, naming, file size, logging, spec coverage
- **Dual-track spec system** — XML app_spec or direct feature spec writing
- **Infrastructure** — Makefile, Dockerfile, pyproject.toml pre-configured

## Stack

- **Backend**: Python 3.12 / FastAPI
- **Layer Architecture**: Types → Config → Repo → Service → Runtime → UI
- **Coverage**: Mechanically enforced at 80% minimum

## Your Role: Harness Engineer

> Inspired by [OpenAI — Harness Engineering](https://openai.com/index/harness-engineering/)

You are a **harness engineer**. You write zero lines of application code. Your job:

1. **Write specs** — Collaborate with the spec-writer agent or fill in `.claude/templates/feature_spec.md`
2. **Approve plans** — Review execution plans before implementation begins
3. **Review output** — Run linters, run tests, check acceptance criteria
4. **Evolve the harness** — When agents make mistakes, fix linter rules / agent instructions / spec templates — not code

See [.claude/docs/workflow.md](.claude/docs/workflow.md) for the full orchestration guide.

## Workflow

```
SPEC (collaborative) → PLAN (agent) → APPROVE (human) → IMPLEMENT+TEST (agent) → SPEC REVIEW + CODE REVIEW (agent)
```

## Quickstart

```bash
# 1. Clone and enter
git clone <this-repo> my-project
cd my-project

# 2. Validate scaffold integrity
bash .claude/scripts/validate-scaffold.sh

# 3. Option A: Start from XML app spec
cp .claude/templates/app_spec_template.xml specs/app_spec.xml
# Edit specs/app_spec.xml with your app definition
bash .claude/scripts/init-from-app-spec.sh specs/app_spec.xml

# 3. Option B: Write feature specs directly
cp .claude/templates/feature_spec.md specs/features/my-feature.md

# 4. Implement via Claude Code agents
# Use the implementer agent to generate code + tests from specs

# 5. Run linters and tests
bash .claude/lint_all.sh
make test
```

## Project Structure

```
.claude/                # All framework scaffolding
  agents/               # 6 sub-agents
  docs/                 # Framework docs (workflow, architecture, conventions, linters, spec-system)
  hooks/                # 3 automated hooks
  linters/              # 5 custom linter scripts
  templates/            # app_spec.xml, feature_spec.md, design_doc.md, execution_plan.md
  scripts/              # validate-scaffold.sh, init-from-app-spec.sh
  lint_all.sh           # Master linter runner
  settings.json         # Hook wiring + permissions
specs/
  features/             # Feature specs (source of truth)
src/
  types/ config/ repo/ service/ runtime/ ui/
tests/
  unit/ integration/ e2e/
```

## Agents

| Agent | Role |
|-------|------|
| `spec-writer` | Brainstorming interviewer: collaborates with human to produce specs |
| `implementer` | Code + tests from spec in one pass |
| `test-writer` | Coverage gap filling after implementation |
| `spec-reviewer` | Validates implementation against spec (spec compliance) |
| `code-reviewer` | Validates code quality and conventions |
| `refactorer` | Continuous debt reduction |

### Two-Stage Review

Review is split into two independent passes:
1. **Spec review** (spec-reviewer) — checks spec compliance: acceptance criteria, business rules, edge cases
2. **Code review** (code-reviewer) — checks code quality: architecture, conventions, test quality, linters

Both must pass before a feature is considered complete.

## Custom Linters

Run all linters: `bash .claude/lint_all.sh`

| Linter | Enforces |
|--------|----------|
| `layer_deps` | Forward-only layer imports |
| `structured_logging` | No raw print/console |
| `naming_conventions` | snake_case/PascalCase rules |
| `file_size` | 300-line file / 50-line function limits |
| `spec_coverage` | Service modules trace to specs |

All linters produce actionable error messages with remediation instructions. See [.claude/docs/linters.md](.claude/docs/linters.md) for details.

## License

MIT
