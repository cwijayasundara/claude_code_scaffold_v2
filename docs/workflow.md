# Workflow Guide

> Spec-driven workflow. Specs are the source of truth; agents implement from them.
> **Humans write specs and review. Agents do everything else.**

## Orchestration Model

```
┌─────────┐    ┌─────────┐    ┌─────────┐    ┌─────────────────┐    ┌─────────┐
│  SPEC   │───▶│ DESIGN  │───▶│  PLAN   │───▶│ IMPLEMENT+TEST  │───▶│ REVIEW  │
│ (human) │    │ (agent) │    │ (agent) │    │    (agent)      │    │ (agent) │
└─────────┘    └─────────┘    └─────────┘    └─────────────────┘    └─────────┘
     │                                              │                     │
     │              ┌──────────┐                    │                     │
     └─────────────▶│ REFACTOR │◀───────────────────┘                     │
                    │  (agent) │                                          │
                    └──────────┘                                          │
                         ▲                                                │
                         └────────────────────────────────────────────────┘
```

**Human responsibilities**: Write specs, review PRs, evolve the harness.
**Agent responsibilities**: Design, plan, implement, test, review, refactor.

## Dual-Track Spec System

```
Track A:  specs/app_spec.xml  → init-from-app-spec.sh → specs/features/*.md
Track B:  Write specs directly using specs/templates/feature_spec.md

Both converge at:  specs/features/<name>.md → implementer agent → src/
```

### Track A: XML App Spec
1. Copy `specs/templates/app_spec_template.xml` to `specs/app_spec.xml`
2. Define features, data model, API endpoints, non-functional requirements
3. Run `bash scripts/init-from-app-spec.sh specs/app_spec.xml` — generates feature spec stubs
4. Flesh out stubs using the spec-writer agent

### Track B: Direct Spec Writing
1. Copy `specs/templates/feature_spec.md` to `specs/features/<name>.md`
2. Fill in description, acceptance criteria, affected layers
3. Review and approve the spec

## Workflow Phases

### 1. Spec (Human)
Write or generate a feature spec in `specs/features/`. Use the template.
**Key**: Be precise about acceptance criteria. Each criterion becomes a test.

### 2. Design (Agent — spec-writer)
The spec-writer agent refines rough ideas into structured specs and optionally produces a design doc in `docs/designs/`.

### 3. Plan (Agent)
Create an execution plan using `specs/templates/execution_plan.md`. The plan is a living document updated during implementation with progress, decisions, and surprises.

### 4. Implement + Test (Agent — implementer)
The implementer writes both code and tests in a single pass, layer by layer:
1. Read the spec: `specs/features/<feature>.md`
2. Read the execution plan (if exists)
3. Implement layer by layer: Types → Config → Repo → Service → Runtime → UI
4. **Write tests alongside each layer** — every service function gets a corresponding test
5. Run linters: `bash scripts/lint_all.sh`
6. Run tests: `pytest tests/ --cov=src --cov-fail-under=80` — all must pass, coverage enforced
7. Update execution plan progress checkboxes

Tests are **proof of correctness**, not ceremony. What matters is that coverage is mechanically enforced and every acceptance criterion has a corresponding test.

### 5. Coverage Gaps (Agent — test-writer, if needed)
If coverage falls below 80% or acceptance criteria lack test coverage, the test-writer agent fills gaps:
- Edge cases and error paths not covered by the implementer
- Integration tests across layer boundaries
- Regression tests for discovered bugs

### 6. Refactor (Agent — refactorer)
Clean up the implementation while keeping all tests green.

### 7. Review (Agent — code-reviewer)
1. Verify each acceptance criterion from the spec
2. Run 12-point quality checklist
3. Update execution plan Outcomes section
4. Produce verdict: APPROVE or REQUEST_CHANGES

## Feedback Loops

The key insight from harness engineering: **when something fails, don't "try harder" — ask what capability is missing and make it enforceable.**

- Linter errors → update linter rules + error messages
- Agent mistakes → update CLAUDE.md or sub-agent instructions
- Spec ambiguities → refine the spec template
- Architecture drift → add new structural tests
- Review findings → encode as linter rules

Every human review insight should be captured as either:
1. A documentation update in `docs/`
2. A new linter rule in `scripts/linters/`
3. An update to agent instructions in `.claude/agents/`

**Never fix code directly. Fix the harness that prevents the class of error from recurring.**
