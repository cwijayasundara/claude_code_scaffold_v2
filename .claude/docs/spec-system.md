# Spec System

> Specs are the source of truth. All code traces back to a spec.

## Two-Level Spec Architecture

### App Spec (Greenfield)

For new applications, start with a comprehensive app spec that captures the entire application:

```
specs/app_spec.md → specs/features/*.md (one per feature group)
```

**Template**: `.claude/templates/app_spec.md`

Covers: overview, technology stack, core features, database schema, API endpoints, UI layout, design system, key interaction flows, implementation phases, success criteria.

```bash
# Tell your agent: "Use the spec-writer agent — I want to build [your app idea]"
```

### Feature Specs

For individual features (either decomposed from an app spec or standalone):

**Templates**:
- `.claude/templates/feature_spec.md` — comprehensive template for complex features
- `.claude/templates/feature_spec_lite.md` — lightweight template for small features and bug fixes

```bash
# Collaborative (recommended)
# Tell your agent: "Use the spec-writer agent to brainstorm a spec for [feature idea]"

# Manual (full)
cp .claude/templates/feature_spec.md specs/features/my-feature.md

# Manual (lite)
cp .claude/templates/feature_spec_lite.md specs/features/my-feature.md
```

All specs converge at `specs/features/<name>.md` — from there, the workflow is identical.

## Feature Spec Anatomy

See `.claude/templates/feature_spec.md` and `.claude/templates/feature_spec_lite.md` for the complete section layouts.

## Spec-to-Code Traceability

```
specs/features/auth.md         → specs/stories/auth.md (user stories)
                               → specs/design/auth.md (design doc)
                               → specs/tests/auth.md (test plan)
                               → specs/plans/auth.md (execution plan)
                               → src/service/auth.py
                               → tests/unit/test_auth.py
specs/features/user-profile.md → specs/stories/user-profile.md
                               → specs/design/user-profile.md
                               → specs/tests/user-profile.md
                               → specs/plans/user-profile.md
                               → src/service/user_profile.py
                               → tests/unit/test_user_profile.py
```

## Spec Lifecycle

```
draft → stories → review → approved → implemented → verified
```

| Status | Meaning |
|--------|---------|
| draft | Initial creation, may have gaps |
| stories | Decomposed into user stories in `specs/stories/` |
| review | Ready for human review |
| approved | Accepted, ready for implementation |
| implemented | Code written and tests passing |
| verified | Acceptance criteria validated end-to-end |
