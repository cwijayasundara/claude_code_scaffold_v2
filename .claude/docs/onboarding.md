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

**What you get**: Any AI tool (Claude Code, Codex, Gemini CLI) can read CLAUDE.md and understand your project.

### Tier 2: Standard (30 minutes)

Add spec-driven workflow on top of Tier 1.

**Copy from this scaffold**:
- `.claude/agents/` — spec-writer, implementer, reviewer agents
- `.claude/templates/` — feature spec and execution plan templates
- Create `specs/features/` directory

**Edit**:
- Update agent instructions if your project uses different conventions
- Adjust the feature spec template to match your domain

**What you get**: Structured spec → plan → implement → review workflow with reusable agents.

### Tier 3: Full (1 hour)

Add mechanical enforcement on top of Tier 2.

**Copy from this scaffold** (pick your tool):
- **Claude Code**: `.claude/hooks/`, `.claude/linters/`, `.claude/lint_all.sh`, `.claude/settings.json`
- **Gemini CLI**: `.gemini/` directory (hooks that mirror `.claude/hooks/`) + `.claude/linters/`
- **Codex CLI**: `.codex/config.toml` (approval policy) + `.claude/linters/` (run manually)

**Customize**:
- `layer_deps.sh` — edit layer definitions to match your architecture, or remove if not applicable
- `naming_conventions.sh` — adjust for your project's naming style
- `file_size.sh` — adjust limits if 300 lines/file is too strict
- `structured_logging.sh` — remove if your project uses print-based logging intentionally

**What you get**: Automated guardrails that enforce your conventions mechanically.

## FAQ

**Do I need the 6-layer model?**
No. The 6-layer model (Types → Config → Repo → Service → Runtime → UI) is a recommendation for new projects. For existing codebases, describe your own architecture in CLAUDE.md.

**Does this work with tools other than Claude Code?**
Yes. This scaffold ships with three tool-specific configurations:

| Tool | Entry Point | Hooks | Config Dir |
|------|-------------|-------|------------|
| Claude Code | `CLAUDE.md` | Pre-write + post-write + session-end | `.claude/` |
| Gemini CLI | `GEMINI.md` | Pre-write + post-write (BeforeTool/AfterTool) | `.gemini/` |
| Codex CLI | `AGENTS.md` | None (instruction-based enforcement) | `.codex/` |

All tools share the same linters (`.claude/linters/`), docs, templates, and specs. Gemini has near-parity with Claude Code via its hooks system. Codex relies on instructions + CI for enforcement.

**Can I adopt this gradually?**
Yes. Start with Tier 1 today. Add Tier 2 when you're ready for spec-driven workflow. Add Tier 3 when you want mechanical enforcement. Each tier is independently useful.
