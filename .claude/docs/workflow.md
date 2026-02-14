# Workflow Guide

> Spec-driven workflow. Specs are the source of truth; agents implement from them.
> **Humans write specs and review. Agents do everything else.**

## The Harness Engineer's Role

> Ref: [OpenAI — Harness Engineering](https://openai.com/index/harness-engineering/)

You are a **harness engineer**, not a coder. Your job is to design the environment that makes agents productive. You write zero lines of application code. Instead, you:

### What You Do

1. **Write specs** — Collaborate with the spec-writer agent or fill in `.claude/templates/feature_spec.md` manually.
2. **Approve plans** — Review execution plans before implementation begins.
3. **Review output** — Read the agent's code, run `bash .claude/lint_all.sh`, run `make test`.
4. **Evolve the harness** — When agents make mistakes, fix the harness: linter rules, agent instructions, spec templates.

### What You Never Do

- Write application code directly
- Fix bugs by editing `src/` — write a bug-fix spec instead
- Skip review — every agent output gets human review before merge

### Daily Workflow

```
Morning:   Review open PRs, read execution plan updates, check linter/test results
Work:      Write specs → approve plans → invoke agents → review output → iterate
Retro:     Capture review insights as linter rules, doc updates, or agent instruction changes
```

## Workflow Phases

```
SPEC → PLAN → APPROVE → IMPLEMENT+TEST → SPEC REVIEW → CODE REVIEW
(collab.)  (agent)  (human)     (agent)        (agent)       (agent)
```

## Dual-Track Spec System

```
Track A:  specs/app_spec.xml  → init-from-app-spec.sh → specs/features/*.md
Track B:  Write specs directly using .claude/templates/feature_spec.md

Both converge at:  specs/features/<name>.md → implementer agent → src/
```

### Track A: XML App Spec
1. Copy `.claude/templates/app_spec_template.xml` to `specs/app_spec.xml`
2. Define features, data model, API endpoints, non-functional requirements
3. Run `bash .claude/scripts/init-from-app-spec.sh specs/app_spec.xml` — generates feature spec stubs
4. Flesh out stubs using the spec-writer agent

### Track B: Direct Spec Writing
1. Copy `.claude/templates/feature_spec.md` to `specs/features/<name>.md`
2. Fill in description, acceptance criteria, affected layers
3. Review and approve the spec

## Phase Details

### 1. Spec (Human + spec-writer agent)
The spec-writer agent interviews you to draw out requirements, then drafts the spec section by section for your approval.

```bash
# Option A: Collaborative (recommended)
# Claude Code: "Use the spec-writer agent to brainstorm a spec for [rough idea]"

# Option B: Manual
cp .claude/templates/feature_spec.md specs/features/<name>.md
```

### 2. Plan (Agent — mandatory, requires human approval)
The agent writes an execution plan. **No implementation begins until you approve the plan.**

The plan includes:
- **Small tasks** (2-5 minutes each) with exact file paths
- **Verification steps** for each task
- **Milestones** grouping related tasks

### 3. Implement + Test (Agent — implementer)
The implementer writes both code and tests in a single pass, following the approved plan:
1. Read the spec and approved execution plan
2. Implement layer by layer: Types → Config → Repo → Service → Runtime → UI
3. **Write tests alongside each layer**
4. Run linters: `bash .claude/lint_all.sh`
5. Run tests: `pytest tests/ --cov=src --cov-fail-under=80`

### 4. Coverage Gaps (Agent — test-writer, if needed)
If coverage falls below 80% or acceptance criteria lack test coverage, the test-writer agent fills gaps.

### 5. Refactor (Agent — refactorer)
Clean up the implementation while keeping all tests green.

### 6. Spec Review (Agent — spec-reviewer)
Checks: Did we build what the spec says? Are all acceptance criteria met?

### 7. Code Review (Agent — code-reviewer)
Checks: Is the code well-written? Does it follow conventions?

## Feedback Loops — Evolving the Harness

**When something fails, don't "try harder" — ask what capability is missing and make it enforceable.**

| You notice... | You fix... | By... |
|---|---|---|
| Agent violates a convention | Linter rules | Adding a check to `.claude/linters/` |
| Agent misunderstands architecture | Agent instructions | Updating `.claude/agents/*.md` |
| Spec was ambiguous | Spec template | Adding a section to `.claude/templates/feature_spec.md` |
| Reviewer catches a pattern | CLAUDE.md or conventions | Encoding the pattern in docs |

**Never fix code directly. Fix the harness that prevents the class of error from recurring.**
