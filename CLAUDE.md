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

## Spec-Driven Workflow (Recommended)

```
SPEC → STORIES → PLAN → APPROVE → IMPLEMENT → TEST → REVIEW → PR
```

**When to use full SDLC**: New features, project bootstrap, large cross-cutting changes.
**When to skip**: Bug fixes, refactoring, small improvements — just write code and let quality gates catch issues.

| Request | Action |
|---|---|
| "Build me an app that..." / "Create a clone of X" | Invoke **spec-writer** agent — starts with **app spec** (whole application) |
| "Add feature X" / "Build X feature" | Invoke **spec-writer** agent — starts with **feature spec** |
| "Here's a spec for X" | Verify spec, create stories + plan, wait for approval |
| "Fix bug in X" | Fix directly, or create a bug-fix spec for complex bugs |

Details: [.claude/docs/workflow.md](.claude/docs/workflow.md)

## Conventions

- **Naming**: `snake_case` files/functions, `PascalCase` classes/types
- **Logging**: Structured only — no raw `print()` or `console.log()`
- **File size**: Max 300 lines/file, 50 lines/function
- **Types**: Refined Pydantic types for domain concepts — no raw `str`/`int` for IDs, emails, etc.
- **Tests**: Every service function needs a test in `tests/` mirroring `src/`. Coverage minimum: 80%

Details: [.claude/docs/conventions.md](.claude/docs/conventions.md)

## Scaffolding Structure

Framework: `.claude/` (`agents/`, `docs/`, `hooks/`, `linters/`, `templates/`, `scripts/`, `lint_all.sh`).
Specs: `specs/` (`features/`, `stories/`, `plans/`).

## Agents (7)

| Agent | Role |
|-------|------|
| `spec-writer` | Brainstorming interviewer: collaborates with human to produce specs and user stories |
| `implementer` | Code + tests from spec, story-by-story or layer-by-layer |
| `refactorer` | Continuous debt reduction |
| `spec-reviewer` | Validates implementation against spec |
| `code-reviewer` | Validates code quality, conventions, security, and performance |
| `test-writer` | Coverage gap filling after implementation |
| `pr-writer` | Creates structured PRs with story-based commits |

**Two-stage review**: spec-reviewer (spec compliance) + code-reviewer (code quality) — both must pass.

## Agent Instructions

1. **For new features**: use the spec-writer agent to create a spec first (recommended)
2. **Read the relevant spec** in `specs/` before implementing (if one exists)
3. **Read files** before modifying them
4. **If the spec is ambiguous, stop and ask** — do not guess
5. **Use Claude Code plan mode** for complex changes
6. **Run linters** after writing code: `bash .claude/lint_all.sh`
7. **Run tests** after implementation: `make test`
8. When a linter fails, read the error — it contains the fix
9. Keep changes small and focused
10. Never fix code directly — fix the harness (linters, agents, docs) to prevent recurrence

## Key References

Docs: [workflow](.claude/docs/workflow.md) | [architecture](.claude/docs/architecture.md) | [conventions](.claude/docs/conventions.md) | [linters](.claude/docs/linters.md) | [spec-system](.claude/docs/spec-system.md) | [git-workflow](.claude/docs/git-workflow.md) | [onboarding](.claude/docs/onboarding.md)
