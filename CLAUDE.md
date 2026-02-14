# Claude Code Production Scaffold v2

> **Philosophy**: Humans are harness engineers. Agents write all code. Specs are the source of truth.
> Ref: [OpenAI — Harness Engineering](https://openai.com/index/harness-engineering/)
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

Backward imports are **forbidden** and enforced by `scripts/linters/layer_deps.sh`.
Details: [docs/architecture.md](docs/architecture.md)

## Spec-Driven Workflow

**No manual code.** All code is agent-generated from specs. Humans write specs and review.

```
SPEC (collaborative) → PLAN (agent) → APPROVE (human) → IMPLEMENT + TEST (agent) → SPEC REVIEW (agent) → CODE REVIEW (agent)
```

**Plan approval is mandatory** — the agent writes the execution plan, the human reviews and approves it before any code is written.

Details: [docs/workflow.md](docs/workflow.md) | [docs/spec-system.md](docs/spec-system.md)

## Conventions

- **Naming**: `snake_case` files/functions, `PascalCase` classes/types
- **Logging**: Structured only — no raw `print()` or `console.log()`
- **File size**: Max 300 lines/file, 50 lines/function
- **Types**: Refined Pydantic types for domain concepts — no raw `str`/`int` for IDs, emails, etc.
- **Tests**: Every service function needs a test in `tests/` mirroring `src/`. Coverage minimum: 80%
- **Git workflow**: Feature branches per spec, merge after both reviews pass. See `docs/git-workflow.md`.

Details: [docs/conventions.md](docs/conventions.md)

## Linters (5 custom)

Run all: `bash scripts/lint_all.sh`

| Linter | Enforces |
|--------|----------|
| `layer_deps` | Forward-only layer imports |
| `structured_logging` | No raw print/console |
| `naming_conventions` | snake_case/PascalCase rules |
| `file_size` | 300-line file / 50-line function limits |
| `spec_coverage` | Service modules trace to specs |

All linter errors include **remediation instructions**. Details: [docs/linters.md](docs/linters.md)

## Agents (6)

| Agent | Role |
|-------|------|
| `spec-writer` | Brainstorming interviewer: collaborates with human to produce specs through Socratic dialogue |
| `implementer` | Code + tests from spec in one pass |
| `refactorer` | Continuous debt reduction |
| `spec-reviewer` | Validates implementation against spec (did we build what the spec says?) |
| `code-reviewer` | Validates code quality and conventions (is the code well-written?) |
| `test-writer` | Coverage gap filling after implementation |

### Two-Stage Review

Review is split into two independent passes:
1. **Spec review** (spec-reviewer) — checks spec compliance: acceptance criteria, business rules, edge cases
2. **Code review** (code-reviewer) — checks code quality: architecture, conventions, test quality, linters

Both must pass before a feature is considered complete.

## Agent Instructions

1. **Read the relevant spec** in `specs/` before implementing
2. **Read files** before modifying them
3. **If the spec is ambiguous, stop and ask** — do not guess
4. **Plan approval is mandatory** — write the execution plan, wait for human approval, then implement
5. **Run linters** after writing code: `bash scripts/lint_all.sh`
6. When a linter fails, read the error — it contains the fix
7. Keep changes small and focused on a single spec
8. Never fix code directly — fix the harness (linters, agents, docs) to prevent recurrence
9. Humans write zero application code — they write specs, review, and evolve the harness

## Key References

| Resource | Location |
|----------|----------|
| Full workflow | [docs/workflow.md](docs/workflow.md) |
| Architecture | [docs/architecture.md](docs/architecture.md) |
| Conventions | [docs/conventions.md](docs/conventions.md) |
| Linter docs | [docs/linters.md](docs/linters.md) |
| Spec system | [docs/spec-system.md](docs/spec-system.md) |
| Git workflow | [docs/git-workflow.md](docs/git-workflow.md) |
