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
APP SPEC → FEATURE SPECS → STORIES → PLAN → APPROVE → IMPLEMENT → TEST → REVIEW → PR
```

### 0. App Spec (Human + spec-writer agent)
The spec-writer agent interviews you about the whole application (vision, tech stack, scope), then produces a comprehensive app spec covering technology stack, core features, database schema, API endpoints, UI layout, design system, and implementation phases.

```bash
# Tell Claude Code:
# "Use the spec-writer agent — I want to build [describe your application]"
```

The app spec goes to `specs/app_spec.md`. After approval, the spec-writer decomposes it into individual feature specs at `specs/features/*.md`, one per feature group. You choose which feature to implement first.

## Feature Workflow (New Features)

For adding features to an existing application.

```
SPEC → STORIES → PLAN → APPROVE → IMPLEMENT → TEST → REVIEW → PR
```

### 1. Spec (Human + spec-writer agent)
The spec-writer agent interviews you about the feature, then drafts a feature spec for your approval.

```bash
# Collaborative (recommended)
# Claude Code: "Use the spec-writer agent to brainstorm a spec for [feature idea]"

# Manual
cp .claude/templates/feature_spec.md specs/features/<name>.md
# Or use the lite template for small features:
cp .claude/templates/feature_spec_lite.md specs/features/<name>.md
```

### 2. Stories (Agent — spec-writer)
After the spec is approved, the spec-writer decomposes it into user stories:
1. Break the spec into small, implementable stories
2. Build a dependency graph — stories creating types/models come first
3. Identify parallel groups — stories with no shared dependencies
4. Write stories to `specs/stories/<feature-name>.md`

### 3. Plan (Agent — requires human approval)
The agent writes an execution plan with small tasks, exact file paths, and verification steps. **No code is written until you approve the plan.**

### 4. Implement (Agent — implementer)
The implementer writes code following the approved plan:
1. Read the spec, stories, and approved execution plan
2. If stories exist: implement story-by-story in dependency order
3. If no stories: implement layer-by-layer (Types → Config → Repo → Service → Runtime → UI)
4. Write tests alongside each story/layer
5. Run linters: `bash .claude/lint_all.sh`
6. Run tests: `pytest tests/ --cov=src --cov-fail-under=80`

### 5. Test (Agent — test-writer, if needed)
If coverage falls below 80% or acceptance criteria lack test coverage, the test-writer agent fills gaps.

### 6. Review (Agents — spec-reviewer + code-reviewer)
Two independent passes:
- **Spec review** (spec-reviewer) — Did we build what the spec says?
- **Code review** (code-reviewer) — Is the code well-written? Any security/performance issues?

Both must pass before proceeding to PR.

### 7. PR (Agent — pr-writer)
After both reviews pass, the pr-writer creates a structured pull request with story-based commits.

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
