# Pipeline Orchestrator

> The main conversation drives all phases after the spec-writer completes.
> This runbook tells you exactly what to do at each phase.

## Phase Sequence

```
1. Spec → 2. Stories → 3. Design → 4. Test Plan → 5. Exec Plan
→ [APPROVE] →
6. Implement → 7. Test Fill → 8. E2E Tests → 9. DevOps
→ 10. Review → [APPROVE] → 11. PR
```

**Two human approval checkpoints**: before implementation (phase 6) and before PR (phase 11).

## Phase Gate Protocol

Before advancing to the next phase:
1. **Verify artifacts exist** — check that the expected output files were created
2. **Update `specs/pipeline_status.md`** — mark the current phase complete with timestamp

If `specs/pipeline_status.md` does not exist, copy from `.claude/templates/pipeline_status.md` and fill in the feature name.

## Cross-Turn Resumption

When a conversation starts or resumes:
1. Read `specs/pipeline_status.md`
2. Find the last completed phase
3. Resume from the next phase
4. If no pipeline_status.md exists, start fresh with routing

## Phase Details

### Phase 1: Spec

**Agent**: spec-writer
**Trigger**: User says "Build me X" or "Add feature X"
**Output**: `specs/app_spec.md` (greenfield) or `specs/features/<name>.md` (feature)
**Gate**: Spec file exists and user has reviewed it

The spec-writer handles phases 1-5 in sequence. Do not interrupt it.

### Phase 2: Stories

**Agent**: spec-writer (continues)
**Output**: `specs/stories/<name>.md`
**Gate**: Stories file exists with dependency graph and parallel groups

### Phase 3: Design

**Agent**: spec-writer (continues)
**Output**: `specs/design/<name>.md`
**Gate**: Design doc exists with layer analysis and API contracts

### Phase 4: Test Plan

**Agent**: spec-writer (continues)
**Output**: `specs/tests/<name>.md`
**Gate**: Test plan exists with test cases (TC-XXX), test types, and test data

### Phase 5: Exec Plan

**Agent**: spec-writer (continues)
**Output**: `specs/plans/<name>.md`
**Gate**: Execution plan exists with tasks, file paths, and verification steps

### APPROVAL CHECKPOINT 1

**Action**: Present the execution plan to the user and wait for explicit approval.
**Show**: Summary of stories, design decisions, test coverage, and implementation plan.
**Wait**: Do NOT proceed until the user says "approved", "go ahead", "looks good", or similar.

### Phase 6: Implement

**Agent**: implementer (or team of implementers)
**Input**: Spec, stories, design, execution plan
**Output**: `src/` code + `tests/` unit/integration tests

**Team orchestration check** (MANDATORY — do not skip):
1. Read the stories file and count the total number of stories
2. Count the number of parallel groups listed in the "Parallel Groups" section
3. If story count >= 4 AND parallel group count >= 2 → you MUST use team orchestration (see Team Orchestration Protocol below). Do NOT override this based on story size, complexity, or subjective judgment.
4. Otherwise (fewer than 4 stories OR only 1 parallel group) → invoke a single implementer agent

After implementation:
- Run `bash .claude/lint_all.sh` — all linters must pass
- Run `pytest tests/ --cov=src --cov-fail-under=80` — all tests must pass

**Gate**: All linters pass, all tests pass, coverage >= 80%

### Phase 7: Test Fill

**Agent**: test-writer
**Trigger**: Coverage is below 80% or acceptance criteria lack test coverage
**Output**: Additional tests in `tests/`
**Skip**: If coverage >= 80% and all acceptance criteria have tests

**Gate**: Coverage >= 80%, all acceptance criteria covered

### Phase 8: E2E Tests

**Agent**: e2e-writer
**Input**: Test plan E2E section + design doc API contracts
**Output**: `tests/e2e/` with Playwright browser tests or httpx API tests

**Gate**: E2E test files exist, `pytest tests/e2e/ -m e2e` passes

### Phase 9: DevOps

**Agent**: devops
**Input**: App spec infrastructure section
**Output**: `infra/`, `.github/workflows/deploy.yml`, updated Dockerfile/docker-compose/Makefile

**Gate**: Infrastructure files exist, Dockerfile builds (if Docker available)

### Phase 10: Review

**Agents**: spec-reviewer + code-reviewer + security-reviewer (invoke sequentially)

1. Invoke **spec-reviewer** — does the implementation match the spec?
   - If FAIL: re-invoke implementer to fix issues, then re-review
   - If PASS: continue
2. Invoke **code-reviewer** — is the code quality acceptable?
   - If FAIL: re-invoke implementer to fix issues, then re-review
   - If PASS: continue
3. Invoke **security-reviewer** — is the code secure?
   - If FAIL: re-invoke implementer to fix security issues, then re-review
   - If PASS: continue

**Review loop**: Max 3 review cycles. If still failing after 3, present issues to user.

**Gate**: All three reviewers pass (spec-reviewer + code-reviewer + security-reviewer)

### APPROVAL CHECKPOINT 2

**Action**: Present the review results and a summary of all changes to the user.
**Show**: Review verdicts, files changed, test results, coverage report.
**Wait**: Do NOT proceed until the user approves.

### Phase 11: PR

**Agent**: pr-writer
**Input**: All changes, spec, stories, review verdicts
**Output**: Pull request with story-based commits

**Gate**: PR created successfully

## Team Orchestration Protocol

**MUST** use teams when: **4+ stories AND 2+ parallel groups** in the stories file. This is a mechanical check — count the stories and groups, then follow the rule. Do not substitute your own judgment about whether stories are "too small" or "mostly sequential."

### Setup (main conversation does this)

1. Create a feature branch: `git checkout -b feat/<feature-name>`
2. Use `TeamCreate` with team name `feat-<feature-name>`
3. Create tasks from stories using `TaskCreate`:
   - One task per story
   - Set `addBlockedBy` for stories that depend on other stories (from the dependency graph)
   - Group A stories (no dependencies) have no blockers
4. Spawn implementer agents using `Task` tool with `team_name` and `subagent_type: "general-purpose"`:
   - One agent per parallel group
   - Each agent's prompt: "You are an implementer agent. Read your assigned tasks from the task list, implement each story following `.claude/agents/implementer.md`, commit per story, and mark tasks complete."
5. Monitor progress via `TaskList`
6. After all tasks complete, run full test suite: `pytest tests/ --cov=src --cov-fail-under=80`

### Sequential Fallback

Use sequential implementation (single implementer agent) **only** when:
- Fewer than 4 stories, OR
- Only 1 parallel group (all stories form a single dependency chain), OR
- Team setup fails (after attempting team orchestration first)

**Common mistake**: An agent may rationalize skipping teams by saying stories are "small" or "mostly sequential." This is not a valid reason. The threshold is purely mechanical: count stories, count parallel groups. If both thresholds are met, use teams.

## Error Recovery

| Error | Recovery |
|-------|----------|
| Spec-writer didn't produce all artifacts | Re-invoke spec-writer for missing phases only |
| Implementation fails linters | Read error, fix code, re-run linters |
| Tests fail | Read failures, fix code, re-run tests |
| Coverage below 80% | Invoke test-writer agent |
| Review fails | Re-invoke implementer with review feedback, re-review |
| E2E tests fail | Read failures, fix tests or code, re-run |
| Docker build fails | Fix Dockerfile, re-build |
