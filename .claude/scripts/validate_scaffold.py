#!/usr/bin/env python3
"""Validate the Claude Code Production Scaffold v2 structure."""
import sys
from pathlib import Path

PASS_COUNT = 0
FAIL_COUNT = 0
WARN_COUNT = 0


def pass_(msg: str) -> None:
    global PASS_COUNT
    print(f"  PASS: {msg}")
    PASS_COUNT += 1


def fail_(msg: str) -> None:
    global FAIL_COUNT
    print(f"  FAIL: {msg}")
    FAIL_COUNT += 1


def warn_(msg: str) -> None:
    global WARN_COUNT
    print(f"  WARN: {msg}")
    WARN_COUNT += 1


def main() -> None:
    print("=== Claude Code Scaffold v2 Validation ===")
    print()

    # ---- 1. Core files ----
    print("1. Core files")
    for f in [
        "CLAUDE.md", "README.md", "Makefile", "pyproject.toml",
        "Dockerfile", ".gitignore", ".env.example", ".mcp.json",
        ".dockerignore",
    ]:
        if Path(f).exists():
            pass_(f"{f} exists")
        else:
            fail_(f"{f} missing")
    print()

    # ---- 2. CLAUDE.md structure ----
    print("2. CLAUDE.md")
    claude_md = Path("CLAUDE.md")
    if claude_md.exists():
        content = claude_md.read_text()
        line_count = len(content.splitlines())
        if line_count <= 120:
            pass_(f"CLAUDE.md is {line_count} lines (under 120)")
        else:
            fail_(f"CLAUDE.md is {line_count} lines (should be under 120)")
        if ".claude/docs/" in content:
            pass_("references .claude/docs/")
        else:
            fail_("missing .claude/docs/ references")
        if "Layer" in content:
            pass_("documents layer model")
        else:
            fail_("missing layer model")
        if "lint_all" in content:
            pass_("references lint_all")
        else:
            fail_("missing lint_all reference")
    print()

    # ---- 3. Layer directories ----
    print("3. Layer directories")
    for layer in ["types", "config", "repo", "service", "runtime", "ui"]:
        layer_dir = Path("src") / layer
        init_file = layer_dir / "__init__.py"
        if layer_dir.is_dir() and init_file.is_file():
            pass_(f"src/{layer}/")
        else:
            fail_(f"src/{layer}/ missing or incomplete")
    print()

    # ---- 4. Hooks (4 expected, Python) ----
    print("4. Hooks")
    for hook in [
        "pre_write_check", "post_write_lint",
        "post_commit_spec_check", "pre_read_scaffold_guard",
    ]:
        if Path(f".claude/hooks/{hook}.py").exists():
            pass_(f"{hook}.py")
        else:
            fail_(f"{hook}.py missing")
    hook_count = len(list(Path(".claude/hooks").glob("*.py")))
    print(f"  INFO: {hook_count} hook scripts found")
    print()

    # ---- 5. Agents (10 expected) ----
    print("5. Agents")
    for agent in ["test-writer"]:
        if Path(f".claude/agents/{agent}.yaml").exists():
            pass_(f"{agent} agent")
        else:
            fail_(f"{agent} agent missing")
    for agent in [
        "spec-writer", "implementer", "refactorer", "code-reviewer",
        "spec-reviewer", "security-reviewer", "pr-writer", "e2e-writer",
        "devops",
    ]:
        if Path(f".claude/agents/{agent}.md").exists():
            pass_(f"{agent} agent")
        else:
            fail_(f"{agent} agent missing")
    agent_count = len(list(Path(".claude/agents").iterdir()))
    print(f"  INFO: {agent_count} agent files found")
    print()

    # ---- 6. Custom linters (2 expected) ----
    print("6. Custom linters")
    for linter in ["layer_deps", "file_size"]:
        if Path(f".claude/linters/{linter}.py").exists():
            pass_(f"{linter}.py")
        else:
            fail_(f"{linter}.py missing")
    if Path(".claude/lint_all.py").exists():
        pass_("lint_all.py")
    else:
        fail_("lint_all.py missing")
    print()

    # ---- 7. Spec system ----
    print("7. Spec system")
    for tmpl in [
        ".claude/templates/app_spec.md",
        ".claude/templates/feature_spec.md",
        ".claude/templates/feature_spec_lite.md",
        ".claude/templates/design_doc.md",
        ".claude/templates/execution_plan.md",
        ".claude/templates/pipeline_status.md",
    ]:
        if Path(tmpl).exists():
            pass_(tmpl)
        else:
            fail_(f"{tmpl} missing")
    print()

    # ---- 8. Documentation ----
    print("8. Documentation")
    for doc in [
        "architecture", "workflow", "conventions", "linters",
        "pipeline", "testing-standard", "scaffold-overview",
    ]:
        path = f".claude/docs/{doc}.md"
        if Path(path).exists():
            pass_(path)
        else:
            fail_(f"{path} missing")
    print()

    # ---- 9. Settings.json hook wiring ----
    print("9. Settings.json hook wiring")
    settings = Path(".claude/settings.json")
    if settings.exists():
        pass_(".claude/settings.json exists")
        settings_content = settings.read_text()
        for hook_ref in [
            "pre_write_check", "post_write_lint",
            "post_commit_spec_check", "pre_read_scaffold_guard",
        ]:
            if hook_ref in settings_content:
                pass_(f"{hook_ref} wired")
            else:
                fail_(f"{hook_ref} NOT wired in settings.json")
    print()

    # ---- 10. Reviewer evals ----
    print("10. Reviewer evals")
    good_dir = Path(".claude/evals/code-reviewer/good")
    bad_dir = Path(".claude/evals/code-reviewer/bad")
    if good_dir.is_dir():
        pass_(".claude/evals/code-reviewer/good/ exists")
    else:
        warn_(".claude/evals/code-reviewer/good/ missing (optional)")
    if bad_dir.is_dir():
        pass_(".claude/evals/code-reviewer/bad/ exists")
    else:
        warn_(".claude/evals/code-reviewer/bad/ missing (optional)")
    good_count = len(list(good_dir.glob("*.py"))) if good_dir.is_dir() else 0
    bad_count = len(list(bad_dir.glob("*.py"))) if bad_dir.is_dir() else 0
    print(f"  INFO: {good_count} good eval(s), {bad_count} bad eval(s)")
    print()

    # ---- 11. CI pipeline ----
    print("11. CI pipeline")
    ci_yml = Path(".github/workflows/ci.yml")
    if ci_yml.exists():
        pass_("ci.yml exists")
        ci_content = ci_yml.read_text()
        if "lint_all" in ci_content:
            pass_("CI runs custom linters")
        else:
            fail_("CI missing linters")
    release_yml = Path(".github/workflows/release.yml")
    if release_yml.exists():
        pass_("release.yml exists")
    print()

    # ---- Summary ----
    print("=== Summary ===")
    print(f"  PASS: {PASS_COUNT}")
    print(f"  FAIL: {FAIL_COUNT}")
    print(f"  WARN: {WARN_COUNT}")
    print()
    if FAIL_COUNT == 0:
        print("Scaffold is correctly configured. All checks passed.")
    else:
        print(
            f"Scaffold has {FAIL_COUNT} issue(s) that need fixing."
            " See FAIL items above."
        )
        sys.exit(1)


if __name__ == "__main__":
    main()
