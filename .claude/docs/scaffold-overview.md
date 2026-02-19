# Scaffold Overview (Agent Quick Reference)

> **Read this file to understand the scaffold. Do NOT broadly explore `.claude/` directories.**
> Only read individual `.claude/docs/` files when working on a specific pipeline phase.

## Architecture

Layer model with strict forward-only dependencies (enforced by `.claude/linters/layer_deps.sh`):

```
Types (src/types/) → Config (src/config/) → Repo (src/repo/) → Service (src/service/) → Runtime (src/runtime/) → UI (src/ui/)
```

- **Types**: Shared types, enums, Pydantic schemas. No project imports.
- **Config**: Env parsing, `BaseSettings`. Imports: Types.
- **Repo**: Data access, external APIs, all I/O. Imports: Types, Config.
- **Service**: Business logic, no direct I/O. Imports: Types, Config, Repo.
- **Runtime**: Server bootstrap, middleware. Imports: all lower layers.
- **UI**: Presentation, routes, CLI. Imports: all layers.

Key constraints: Service has no I/O (delegates to Repo). No raw primitives for domain concepts — use refined Pydantic types. No global mutable state.

## Pipeline (11 Phases)

```
1.Spec → 2.Stories → 3.Design → 4.TestPlan → 5.ExecPlan → [APPROVE] → 6.Implement → 7.TestFill → 8.E2E → 9.DevOps → 10.Review → [APPROVE] → 11.PR
```

- **Phases 1-5**: spec-writer agent (produces specs, stories, design, test plan, execution plan)
- **Phase 6**: implementer agent(s) — code + tests from spec
- **Phase 7**: test-writer — fills coverage gaps (skip if >= 80%)
- **Phase 8**: e2e-writer — Playwright/httpx E2E tests
- **Phase 9**: devops — CI/CD, infra, Dockerfile
- **Phase 10**: three-stage review: spec-reviewer → code-reviewer → security-reviewer (all must pass, max 3 cycles)
- **Phase 11**: pr-writer — structured PR with story-based commits

Two human approval checkpoints: before phase 6 and before phase 11.
Track progress in `specs/pipeline_status.md`.

## Team Orchestration (Mandatory Threshold)

When **4+ stories AND 2+ parallel groups**: MUST use TeamCreate + implementer agents per group.
This is mechanical — count stories and groups, do not skip based on size/complexity judgment.

## Agent Roster (10)

| Agent | Role |
|-------|------|
| spec-writer | Brainstorming interview → specs, stories, design, test plan, exec plan |
| implementer | Code + tests from spec, story-by-story |
| refactorer | Continuous debt reduction |
| spec-reviewer | Validates implementation matches spec |
| code-reviewer | Code quality, conventions, performance |
| security-reviewer | OWASP Top 10, auth flows, secrets, dependencies |
| test-writer | Coverage gap filling |
| e2e-writer | Playwright E2E + API contract tests |
| devops | CI/CD, deployment, infrastructure-as-code |
| pr-writer | Structured PRs with story-based commits |

## Conventions

- **Naming**: `snake_case` files/functions, `PascalCase` classes/types, `UPPER_SNAKE_CASE` constants
- **Logging**: Structured only (`logging.getLogger(__name__)`), never `print()`
- **File limits**: 300 lines/file, 50 lines/function
- **Types**: Refined Pydantic types for domain concepts (e.g., `UserId`, `Email`)
- **Type hints**: All function signatures, no `Any`/`any`
- **Error handling**: Catch specific exceptions in Repo layer, log with context, custom exception classes from Types

## Testing Rules

- **Coverage**: 80% minimum (`pytest --cov-fail-under=80`)
- **Naming**: `test_<function>_<scenario>_<expected>`
- **Fixtures**: Check conftest.py first, reuse before creating, extract shared fixtures at 2+ uses
- **Assertions**: Must verify specific values — no vacuous `is not None` or truthiness checks
- **Markers**: `@pytest.mark.unit`, `@pytest.mark.integration`, `@pytest.mark.e2e`
- **Mock strategy**: Types=none, Config=mock env, Repo=mock DB, Service=mock repo, Runtime=TestClient, UI=Playwright

## Spec System

Two-level: App spec (greenfield) → Feature specs (per feature group).
Templates in `.claude/templates/` (app_spec, feature_spec, feature_spec_lite, design_doc, execution_plan, user_stories, test_plan).
Lifecycle: `draft → stories → review → approved → implemented → verified`.
Traceability: `specs/features/<name>.md` → `specs/stories/`, `specs/design/`, `specs/tests/`, `specs/plans/` → `src/` + `tests/`.

## Git Workflow

- Feature branches: `feature/<spec-name>` off main
- Commit style: `<type>(<story-id>): <imperative description>` — types: feat, fix, refactor, test, docs, chore
- One logical change per commit. PR required for all merges to main.
- Story-based commits when user stories exist: `feat(US-001): add user registration endpoint`

## Quality Gates

- **Pre-write hook** (`.claude/hooks/pre-write-check.sh`): Layer import reminders, spec suggestions, test reminders
- **Post-write hook** (`.claude/hooks/post-write-lint.sh`): Runs `layer_deps` + `file_size` linters, checks test file existence
- **CI**: `bash .claude/lint_all.sh` + `make test` on every push
- Run all linters manually: `bash .claude/lint_all.sh`
