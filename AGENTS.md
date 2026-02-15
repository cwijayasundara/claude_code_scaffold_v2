# SDSL Production Scaffold — Codex Instructions

> **Philosophy**: Humans are harness engineers. Agents write all code. Specs are the source of truth.
> This scaffold is tool-agnostic. All docs, templates, linters, and agent definitions live in `.claude/` as plain markdown and bash — readable by any AI tool.

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

Backward imports are **forbidden**. Run `bash .claude/linters/layer_deps.sh` to check.

## Spec-Driven Workflow

All code is agent-generated from specs. Humans write specs and review.

```
SPEC → STORIES → PLAN → APPROVE → IMPLEMENT → TEST → REVIEW → PR
```

**Plan approval is mandatory** — write the execution plan, wait for human approval, then implement.

## Working Agreements

1. **Read the relevant spec** in `specs/features/` before implementing
2. **Read files** before modifying them
3. **If the spec is ambiguous, stop and ask** — do not guess
4. **Plan approval is mandatory** — no code without an approved plan in `specs/plans/`
5. **Run linters** after writing code: `bash .claude/lint_all.sh`
6. When a linter fails, read the error — it contains the fix
7. Keep changes small and focused on a single spec
8. Humans write zero application code — they write specs, review, and evolve the harness

## Conventions

- **Naming**: `snake_case` files/functions, `PascalCase` classes/types
- **Logging**: Structured only — no raw `print()` or `console.log()`
- **File size**: Max 300 lines/file, 50 lines/function
- **Types**: Refined Pydantic types for domain concepts — no raw `str`/`int` for IDs, emails, etc.
- **Tests**: Every service function needs a test. Coverage minimum: 80%
- **Git**: Feature branches per spec, story-based commits (`feat(US-XXX): description`)

## Enforcement

Codex CLI does not support hooks. Linter enforcement relies on:
1. **These instructions** — you MUST run `bash .claude/lint_all.sh` after every file write
2. **CI/CD** — `.github/workflows/ci.yml` runs all linters on every push
3. **Approval policy** — `.codex/config.toml` sets `approval_policy = "on-failure"`

If you skip linters locally, CI will catch violations before merge.

## Agent Roles (reference)

Read the agent definitions in `.claude/agents/` for detailed instructions:

| Agent | File | Role |
|-------|------|------|
| spec-writer | `.claude/agents/spec-writer.md` | Interview human, produce specs and user stories |
| implementer | `.claude/agents/implementer.md` | Code + tests, story-by-story or layer-by-layer |
| code-reviewer | `.claude/agents/code-reviewer.md` | Code quality, security, performance |
| spec-reviewer | `.claude/agents/spec-reviewer.md` | Spec compliance |
| test-writer | `.claude/agents/test-writer.yaml` | Coverage gap filling |
| refactorer | `.claude/agents/refactorer.md` | Debt reduction |
| pr-writer | `.claude/agents/pr-writer.md` | Structured PRs with story-based commits |

## Key Paths

| Resource | Location |
|----------|----------|
| Feature specs | `specs/features/` |
| User stories | `specs/stories/` |
| Execution plans | `specs/plans/` |
| Test plans | `specs/tests/` |
| Architecture | `specs/architecture.md` |
| Workflow guide | `.claude/docs/workflow.md` |
| Conventions | `.claude/docs/conventions.md` |
| Linter docs | `.claude/docs/linters.md` |
| Templates | `.claude/templates/` |
| Linters | `bash .claude/lint_all.sh` |
