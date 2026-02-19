# Workflow Guide

> Specs are the source of truth; agents implement from them.
> **Humans write specs and review. Agents do everything else.**

## The Harness Engineer's Role

You are a **harness engineer**, not a coder. Your job is to design the environment that makes agents productive.

### What You Do

1. **Write specs** — Collaborate with the spec-writer agent or fill in templates manually.
2. **Approve plans** — Review execution plans before implementation begins.
3. **Review output** — Read the agent's code, run `bash .claude/lint_all.sh`, run `make test`.
4. **Evolve the harness** — When agents make mistakes, fix the harness: linter rules, agent instructions, spec templates.

### What You Never Do

- Write application code directly
- Fix bugs by editing `src/` — write a bug-fix spec instead
- Skip review — every agent output gets human review before merge

## Everyday Workflow

For bug fixes, refactoring, and small changes — just write code and let quality gates catch issues:

```
Write code → Pre-write reminders → Post-write linters → Run tests → Commit
```

Quality gates run automatically on every write:
- **Pre-write hook**: Layer import reminders, spec suggestions, test reminders
- **Post-write hook**: Targeted linters (`layer_deps`, `file_size`), test file existence check
- **CI**: `bash .claude/lint_all.sh` + `make test`

## Greenfield Workflow (New Applications)

For new applications, start with an app spec that captures the whole application before writing any code.

```
APP SPEC → FEATURE SPECS → STORIES → DESIGN → TEST PLAN → PLAN → APPROVE → IMPLEMENT → TEST → REVIEW → PR
```

### 0. App Spec (Human + spec-writer agent)
The spec-writer agent interviews you about the whole application (vision, tech stack, scope), then produces a comprehensive app spec covering technology stack, core features, database schema, API endpoints, UI layout, design system, and implementation phases.

```bash
# Tell Claude Code:
# "Use the spec-writer agent — I want to build [describe your application]"
```

The app spec goes to `specs/app_spec.md`. After approval, the spec-writer decomposes it into individual feature specs at `specs/features/*.md`, one per feature group. You choose which feature to implement first.

## Feature Workflow (New Features)

For adding features to an existing application. Same pipeline, scoped to one feature.

```
SPEC → STORIES → DESIGN → TEST PLAN → PLAN → APPROVE → IMPLEMENT → TEST → REVIEW → PR
```

**Getting started:**
```bash
# Collaborative (recommended)
# Claude Code: "Use the spec-writer agent to brainstorm a spec for [feature idea]"

# Manual
cp .claude/templates/feature_spec.md specs/features/<name>.md
# Or use the lite template for small features:
cp .claude/templates/feature_spec_lite.md specs/features/<name>.md
```

Phase-by-phase details: [pipeline.md](pipeline.md)

## Post-Spec Pipeline (Automatic Continuation)

After the spec-writer completes phases 1-5, the main conversation **automatically continues** through the remaining phases. The human does not need to manually trigger each phase.

### What Happens After Spec-Writer Completes

The pipeline orchestrator ([pipeline.md](pipeline.md)) drives the following phases:

| Phase | Agent | Human Role |
|-------|-------|------------|
| 6. Implement | implementer (or team) | Wait — agents work autonomously |
| 7. Test Fill | test-writer | Wait — auto-triggered if coverage < 80% |
| 8. E2E Tests | e2e-writer | Wait — generates from test plan |
| 9. DevOps | devops | Wait — generates CI/CD and infra configs |
| 10. Review | spec-reviewer + code-reviewer | Review verdicts presented for awareness |
| 11. PR | pr-writer | Merge the PR |

### Human Approval Checkpoints

The pipeline pauses at exactly **two points** for human approval:
1. **Before implementation** (after phase 5) — review the execution plan
2. **Before PR** (after phase 10) — review the review verdicts and changes summary

### Resuming Across Conversation Turns

If a conversation ends mid-pipeline:
1. Start a new conversation
2. Say "Continue the pipeline" or "What's next?"
3. The main conversation reads `specs/pipeline_status.md` and resumes from the next incomplete phase

The pipeline status file is updated after every phase, so no progress is lost.

## Feedback Loops — Evolving the Harness

**When something fails, don't "try harder" — ask what capability is missing and make it enforceable.**

| You notice... | You fix... | By... |
|---|---|---|
| Agent violates a convention | Linter rules | Adding a check to `.claude/linters/` |
| Agent misunderstands architecture | Agent instructions | Updating `.claude/agents/*.md` |
| Spec was ambiguous | Spec template | Adding a section to `.claude/templates/` |
| Reviewer catches a pattern | CLAUDE.md or conventions | Encoding the pattern in docs |

**Never fix code directly. Fix the harness that prevents the class of error from recurring.**

## Quality Guardrails

Advisory hooks and linters run on every write, providing continuous feedback without blocking work.

### Advisory Pre-Write Hook

`.claude/hooks/pre-write-check.sh` runs before every Write/Edit tool call. It provides reminders (always exits 0):

| Write target | Behavior |
|---|---|
| `src/<layer>/*` | Layer import reminder |
| `src/service/*` (new module) | Spec suggestion if no spec exists |
| `src/*` or `tests/*` | Test reminder |

### Post-Write Linters

`.claude/hooks/post-write-lint.sh` runs after every Write/Edit. It runs targeted linters and checks for missing test files.
