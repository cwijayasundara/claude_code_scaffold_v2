#!/usr/bin/env python3
"""Post-write lint hook — run targeted custom linters after writes.

PostToolUse hook for Write/Edit operations. Advisory only (exit 0).
All hooks and linters are Python for cross-platform compatibility.
"""
import json
import subprocess
import sys
from pathlib import Path

SCRIPT_DIR = Path(__file__).resolve().parent
PROJECT_ROOT = SCRIPT_DIR.parent.parent
LINTER_DIR = PROJECT_ROOT / ".claude" / "linters"


def run_linter(linter: str, target: str) -> None:
    script = LINTER_DIR / f"{linter}.py"
    if not script.exists():
        return
    try:
        result = subprocess.run(
            [sys.executable, str(script), target],
            capture_output=True,
            text=True,
            timeout=30,
        )
        if result.returncode != 0:
            lines = result.stdout.strip().splitlines()[:5]
            print(f"post-write-lint [{linter}]:")
            print("\n".join(lines))
    except (subprocess.TimeoutExpired, FileNotFoundError):
        pass


def main() -> None:
    raw = sys.stdin.read()
    try:
        data = json.loads(raw)
    except json.JSONDecodeError:
        return

    file_path = (
        data.get("tool_input", {}).get("file_path")
        or data.get("tool_input", {}).get("path")
        or ""
    )
    if not file_path:
        return

    ext = Path(file_path).suffix.lstrip(".")
    file_dir = str(Path(file_path).parent)

    if ext == "py":
        run_linter("layer_deps", file_dir)
        run_linter("file_size", file_dir)
    elif ext in ("ts", "tsx", "js", "jsx"):
        run_linter("file_size", file_dir)

    # Test file existence check for service modules
    if "src/service/" in file_path and ext == "py":
        base = Path(file_path).stem
        if base not in ("__init__", "conftest"):
            test_file = PROJECT_ROOT / "tests" / "service" / f"test_{base}.py"
            if not test_file.exists():
                print(
                    f"post-write-lint: No test file found at"
                    f" tests/service/test_{base}.py"
                    " — consider adding tests."
                )


if __name__ == "__main__":
    main()
