#!/usr/bin/env python3
"""Warn agents reading scaffold files during exploration.

PreToolUse hook for Read operations. Advisory only (exit 0).
"""
import json
import sys


def main() -> None:
    raw = sys.stdin.read()
    try:
        data = json.loads(raw)
    except json.JSONDecodeError:
        return

    file_path = data.get("tool_input", {}).get("file_path", "")
    if ".claude/" in file_path:
        print(
            f"SCAFFOLD FILE: '{file_path}' is scaffold infrastructure,"
            " not application code. If you are exploring the codebase,"
            " skip all .claude/ files."
        )


if __name__ == "__main__":
    main()
