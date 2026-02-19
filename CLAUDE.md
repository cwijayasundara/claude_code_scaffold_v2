# Claude Code Production Scaffold v2

> **Philosophy**: Humans are harness engineers. Agents write all code. Specs are the source of truth.
> This file is a map, not a manual. Follow pointers to deeper docs.

## Architecture

**Layer model** (strict forward-only dependencies):

```
Types → Config → Repo → Service → Runtime → UI
```

| Layer   | Path           | Purpose                            |
|---------|----------------|------------------------------------|
| Types   | `src/types/`   | Shared types, enums, schemas       |
| Config  | `src/config/`  | Env parsing, defaults              |
| Repo    | `src/repo/`    | Data access, external API clients  |
| Service | `src/service/` | Business logic, domain rules       |
| Runtime | `src/runtime/` | Server bootstrap, middleware       |
| UI      | `src/ui/`      | Presentation, CLI, user-facing     |

Backward imports are **forbidden** and enforced by `.claude/linters/layer_deps.sh`.
Details: [.claude/docs/architecture.md](.claude/docs/architecture.md)

## Quality Gates (Always Active)

Every write to `src/` or `tests/` triggers automated quality checks:

- **Pre-write reminders**: Layer import rules, spec suggestions for new service modules, test reminders
- **Post-write linters**: `layer_deps` (architecture), `file_size` (max 300 lines/file, 50 lines/function)
- **CI enforcement**: `bash .claude/lint_all.sh` + `make test` on every push

Run all linters manually: `bash .claude/lint_all.sh`

## Request Routing (MANDATORY)

**STOP. Before writing ANY code, classify the user's request and follow the matching action. Do NOT skip this step.**

| Request pattern | REQUIRED action |
|---|---|
| "Build me ..." / "Create a ..." / "I want an app that ..." | **MUST follow the Full Pipeline.** Start with the spec-writer agent interview, then continue through ALL phases per [pipeline.md](.claude/docs/pipeline.md). Do NOT stop after specs. |
| "Add feature X" / "Build X feature" / "Add X to the app" | **MUST follow the Full Pipeline.** Start with the spec-writer agent interview for a feature spec, then continue through ALL phases per [pipeline.md](.claude/docs/pipeline.md). |
| "Continue the pipeline" / "What's next?" / "Resume" | Read `specs/pipeline_status.md` and resume from the next incomplete phase. |
| "Here's a spec for X" / user provides a spec | Verify the spec, create stories + plan, wait for human approval before implementing. Then continue through remaining pipeline phases. |
| "Fix bug in X" / "Refactor X" / "Add validation to X" | Fix directly — quality gates provide feedback automatically. |

**Violation**: If you start writing code, exploring the codebase, or making a plan for a "Build me" / "Add feature" request without first running the spec-writer interview, you are violating this workflow.

## Full Pipeline

```
SPEC → STORIES → DESIGN → TEST PLAN → PLAN → [APPROVE] → IMPLEMENT → TEST FILL → E2E → DEVOPS → REVIEW → [APPROVE] → PR
```

**Key rules**:
1. **Verify artifacts** before advancing — check files exist at expected paths
2. **Update `specs/pipeline_status.md`** after each phase (copy template from `.claude/templates/pipeline_status.md` if it doesn't exist)
3. **Wait for human approval** at two checkpoints: before implementation and before PR
4. **Loop on review failures** — if spec-review or code-review fails, re-invoke implementer, then re-review (max 3 cycles)
5. **Use teams for parallel stories (mandatory)** — when 4+ stories AND 2+ parallel groups, you MUST create a team with implementer agents per group. This is a mechanical threshold, not a judgment call — count stories and groups, then follow the rule.

Details: [.claude/docs/pipeline.md](.claude/docs/pipeline.md) | [.claude/docs/workflow.md](.claude/docs/workflow.md)

## Conventions

- **Naming**: `snake_case` files/functions, `PascalCase` classes/types
- **Logging**: Structured only — no raw `print()` or `console.log()`
- **File size**: Max 300 lines/file, 50 lines/function
- **Types**: Refined Pydantic types for domain concepts — no raw `str`/`int` for IDs, emails, etc.
- **Tests**: Coverage 80%, no vacuous assertions, fixture reuse — see [testing-standard](.claude/docs/testing-standard.md)

Details: [.claude/docs/conventions.md](.claude/docs/conventions.md) | [.claude/docs/testing-standard.md](.claude/docs/testing-standard.md)

## Scaffolding Structure

Framework: `.claude/` (`agents/`, `docs/`, `evals/`, `hooks/`, `linters/`, `templates/`, `scripts/`, `lint_all.sh`).
Specs: `specs/` (`features/`, `stories/`, `design/`, `tests/`, `plans/`).

## Agents (9)

| Agent | Role |
|-------|------|
| `spec-writer` | Brainstorming interviewer: collaborates with human to produce specs and user stories |
| `implementer` | Code + tests from spec, story-by-story or layer-by-layer |
| `refactorer` | Continuous debt reduction |
| `spec-reviewer` | Validates implementation against spec |
| `code-reviewer` | Validates code quality, conventions, security, and performance |
| `test-writer` | Coverage gap filling after implementation |
| `e2e-writer` | Playwright E2E tests and API contract tests from test plan |
| `devops` | CI/CD pipelines, deployment configs, infrastructure-as-code |
| `pr-writer` | Creates structured PRs with story-based commits |

**Two-stage review**: spec-reviewer (spec compliance) + code-reviewer (code quality) — both must pass.

## Agent Instructions

1. **NEVER skip the routing table above** — if the user says "Build me X" or "Add feature X", you MUST invoke the spec-writer agent BEFORE doing anything else. No exploring, no researching, no planning — start the interview.
2. **After spec-writer completes, continue the pipeline** — do NOT stop after producing specs. Follow [pipeline.md](.claude/docs/pipeline.md) through all remaining phases automatically.
3. **Track progress** — update `specs/pipeline_status.md` after each phase completes
4. **Use teams for parallel implementation (mandatory)** — when 4+ stories AND 2+ parallel groups, you MUST use TeamCreate and spawn implementer agents. Count the stories and parallel groups mechanically — do not skip teams based on story size or complexity.
5. **Read the relevant spec** in `specs/` before implementing (if one exists)
6. **Read files** before modifying them
7. **If the spec is ambiguous, stop and ask** — do not guess
8. **Run linters** after writing code: `bash .claude/lint_all.sh`
9. **Run tests** after implementation: `make test`
10. When a linter fails, read the error — it contains the fix
11. Keep changes small and focused
12. Never fix code directly — fix the harness (linters, agents, docs) to prevent recurrence

## Key References

Docs: [pipeline](.claude/docs/pipeline.md) | [workflow](.claude/docs/workflow.md) | [architecture](.claude/docs/architecture.md) | [conventions](.claude/docs/conventions.md) | [testing-standard](.claude/docs/testing-standard.md) | [linters](.claude/docs/linters.md) | [spec-system](.claude/docs/spec-system.md) | [git-workflow](.claude/docs/git-workflow.md) | [onboarding](.claude/docs/onboarding.md)
