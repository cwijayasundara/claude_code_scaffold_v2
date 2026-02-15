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

Backward imports are **forbidden** and enforced by `.claude/linters/layer_deps.sh`.
Details: [.claude/docs/architecture.md](.claude/docs/architecture.md)

## Spec-Driven Workflow

**No manual code.** All code is agent-generated from specs. Humans write specs and review.

```
SPEC → STORIES → PLAN → APPROVE → IMPLEMENT → TEST → REVIEW → PR
(collab.)  (agent)  (agent)  (human)   (agent)   (agent)  (agent)  (agent)
```

**Plan approval is mandatory** — the agent writes the execution plan, the human reviews and approves it before any code is written.

Details: [.claude/docs/workflow.md](.claude/docs/workflow.md) | [.claude/docs/spec-system.md](.claude/docs/spec-system.md)

## Conventions

- **Naming**: `snake_case` files/functions, `PascalCase` classes/types
- **Logging**: Structured only — no raw `print()` or `console.log()`
- **File size**: Max 300 lines/file, 50 lines/function
- **Types**: Refined Pydantic types for domain concepts — no raw `str`/`int` for IDs, emails, etc.
- **Tests**: Every service function needs a test in `tests/` mirroring `src/`. Coverage minimum: 80%
- **Git workflow**: Feature branches per spec, merge after both reviews pass. See `.claude/docs/git-workflow.md`.

Details: [.claude/docs/conventions.md](.claude/docs/conventions.md)

## Scaffolding Structure

All framework files live in `.claude/`. The project root stays clean for application code.

| Path | Purpose |
|------|---------|
| `.claude/agents/` | Sub-agent definitions (7 agents) |
| `.claude/docs/` | Framework documentation |
| `.claude/hooks/` | Pre/post write hooks |
| `.claude/linters/` | Custom linters |
| `.claude/templates/` | Spec, plan, story, and test plan templates |
| `.claude/scripts/` | Utility scripts (validate, init-from-spec) |
| `.claude/lint_all.sh` | Master linter runner |
| `specs/features/` | Feature specifications |
| `specs/stories/` | User stories with dependency graphs |
| `specs/plans/` | Execution plans (must be Approved) |
| `specs/tests/` | Test plans per user story |
| `specs/architecture.md` | Project-level technical design |

## Linters (5 custom)

Run all: `bash .claude/lint_all.sh`

| Linter | Enforces |
|--------|----------|
| `layer_deps` | Forward-only layer imports |
| `structured_logging` | No raw print/console |
| `naming_conventions` | snake_case/PascalCase rules |
| `file_size` | 300-line file / 50-line function limits |
| `spec_coverage` | Service modules trace to specs |

All linter errors include **remediation instructions**. Details: [.claude/docs/linters.md](.claude/docs/linters.md)

## Agents (7)

| Agent | Role |
|-------|------|
| `spec-writer` | Brainstorming interviewer: collaborates with human to produce specs and user stories |
| `implementer` | Code + tests from spec, story-by-story or layer-by-layer |
| `refactorer` | Continuous debt reduction |
| `spec-reviewer` | Validates implementation against spec (did we build what the spec says?) |
| `code-reviewer` | Validates code quality, conventions, security, and performance |
| `test-writer` | Coverage gap filling after implementation |
| `pr-writer` | Creates structured PRs with story-based commits |

**Two-stage review**: spec-reviewer (spec compliance) + code-reviewer (code quality) — both must pass.

## Agent Instructions

1. **Read the relevant spec** in `specs/` before implementing
2. **Read files** before modifying them
3. **If the spec is ambiguous, stop and ask** — do not guess
4. **Plan approval is mandatory** — write the execution plan, wait for human approval, then implement
5. **Run linters** after writing code: `bash .claude/lint_all.sh`
6. When a linter fails, read the error — it contains the fix
7. Keep changes small and focused on a single spec
8. Never fix code directly — fix the harness (linters, agents, docs) to prevent recurrence
9. Humans write zero application code — they write specs, review, and evolve the harness

## Key References

| Resource | Location |
|----------|----------|
| Full workflow | [.claude/docs/workflow.md](.claude/docs/workflow.md) |
| Architecture | [.claude/docs/architecture.md](.claude/docs/architecture.md) |
| Conventions | [.claude/docs/conventions.md](.claude/docs/conventions.md) |
| Linter docs | [.claude/docs/linters.md](.claude/docs/linters.md) |
| Spec system | [.claude/docs/spec-system.md](.claude/docs/spec-system.md) |
| Git workflow | [.claude/docs/git-workflow.md](.claude/docs/git-workflow.md) |
| Onboarding | [.claude/docs/onboarding.md](.claude/docs/onboarding.md) |
