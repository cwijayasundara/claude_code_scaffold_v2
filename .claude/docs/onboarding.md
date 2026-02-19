# Onboarding: Adopting SDSL in Existing Projects

> You don't need to reorganize your codebase. Start small and adopt incrementally.

## Adoption Tiers

### Tier 1: Minimal (15 minutes)

Add a `CLAUDE.md` to your project root. This single file gives any AI coding tool enough context to work effectively.

**What to include**:
- Project description and purpose
- Architecture overview (your actual structure, not the 6-layer model)
- File/folder conventions
- How to run tests
- How to run the app locally
- Key dependencies and their purposes

**What you get**: Any AI tool can read CLAUDE.md and understand your project.

### Tier 2: Standard (30 minutes)

Add spec-driven workflow on top of Tier 1.

**Copy from this scaffold**:
- `.claude/agents/` — spec-writer, implementer, reviewer agents
- `.claude/templates/` — feature spec (full + lite) and execution plan templates
- Create `specs/features/` directory

**Edit**:
- Update agent instructions if your project uses different conventions
- Adjust the feature spec template to match your domain

**What you get**: Structured spec, plan, implement, review workflow with reusable agents.

### Tier 3: Full (1 hour)

Add quality guardrails on top of Tier 2.

**Copy from this scaffold**:
- `.claude/hooks/` + `.claude/settings.json` — advisory hooks for real-time feedback
- `.claude/linters/` + `.claude/lint_all.py` — custom linters

**Customize**:
- `layer_deps.py` — edit layer definitions to match your architecture, or remove if not applicable
- `file_size.py` — adjust limits if 300 lines/file is too strict

**What you get**: Automated quality guardrails that provide continuous feedback on your conventions.

## FAQ

**Do I need the 6-layer model?**
No. The 6-layer model (Types, Config, Repo, Service, Runtime, UI) is a recommendation for new projects. For existing codebases, describe your own architecture in CLAUDE.md.

**Can I adopt this gradually?**
Yes. Start with Tier 1 today. Add Tier 2 when you're ready for spec-driven workflow. Add Tier 3 when you want quality guardrails. Each tier is independently useful.
