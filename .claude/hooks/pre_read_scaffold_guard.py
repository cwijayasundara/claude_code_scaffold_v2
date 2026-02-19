#!/usr/bin/env python3
"""Block subagents from reading scaffold files.

PreToolUse hook for Read operations.
- Subagents (transcript in /subagents/): exit 2 → blocks the tool call
- Main conversation: exit 0 → allows the read
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

    if ".claude/" not in file_path:
        return  # Not a scaffold file, allow

    transcript = data.get("transcript_path", "")
    is_subagent = "/subagents/" in transcript

    if is_subagent:
        print(
            f"BLOCKED: '{file_path}' is scaffold infrastructure. "
            "Scaffold info is in CLAUDE.md. Skip all .claude/ files.",
            file=sys.stderr,
        )
        sys.exit(2)

    # Main conversation — allow


if __name__ == "__main__":
    main()
