#!/usr/bin/env python3
"""Run reviewer evaluation samples to verify reviewer agents catch known patterns.

Validates the eval sample inventory. Actual agent evaluation requires invoking
the code-reviewer agent against each sample via Claude Code:

    claude -p "You are the code-reviewer agent (.claude/agents/code-reviewer.md).
      Review the file at .claude/evals/code-reviewer/bad/missing_logger.py as if
      it were src/service/user_service.py. Output your verdict."

Expected verdicts:
    good/* -> APPROVE
    bad/*  -> REQUEST_CHANGES
"""
import sys
from pathlib import Path

EVAL_DIR = Path(".claude/evals/code-reviewer")

pass_count = 0
fail_count = 0


def pass_(msg: str) -> None:
    global pass_count
    print(f"  PASS: {msg}")
    pass_count += 1


def fail_(msg: str) -> None:
    global fail_count
    print(f"  FAIL: {msg}")
    fail_count += 1


def main() -> None:
    print("=== Reviewer Eval Inventory Check ===")
    print()

    # Check directory structure
    good_dir = EVAL_DIR / "good"
    bad_dir = EVAL_DIR / "bad"

    if not good_dir.is_dir():
        fail_(f"{good_dir}/ directory missing")
    else:
        pass_(f"{good_dir}/ exists")

    if not bad_dir.is_dir():
        fail_(f"{bad_dir}/ directory missing")
    else:
        pass_(f"{bad_dir}/ exists")

    # Check that eval samples exist
    good_samples = sorted(good_dir.glob("*.py")) if good_dir.is_dir() else []
    bad_samples = sorted(bad_dir.glob("*.py")) if bad_dir.is_dir() else []

    if len(good_samples) >= 1:
        pass_(f"{len(good_samples)} good sample(s) found")
    else:
        fail_(f"no good samples in {good_dir}/")

    if len(bad_samples) >= 2:
        pass_(f"{len(bad_samples)} bad sample(s) found")
    else:
        fail_(
            f"need at least 2 bad samples in {bad_dir}/"
            f" (found {len(bad_samples)})"
        )

    # Verify each sample has metadata comments
    print()
    print("--- Sample metadata check ---")

    for sample in good_samples + bad_samples:
        name = sample.name
        dir_name = sample.parent.name
        content = sample.read_text()

        if "Expected reviewer verdict:" in content:
            pass_(f"{dir_name}/{name} has expected verdict")
        else:
            fail_(
                f"{dir_name}/{name} missing"
                " 'Expected reviewer verdict:' comment"
            )

        if dir_name == "bad":
            if "Expected finding:" in content:
                pass_(f"{dir_name}/{name} has expected finding")
            else:
                fail_(
                    f"{dir_name}/{name} missing"
                    " 'Expected finding:' comment"
                )

        if "Violations:" in content or "Conventions demonstrated:" in content:
            pass_(f"{dir_name}/{name} documents what it tests")
        else:
            fail_(
                f"{dir_name}/{name} missing 'Violations:' or"
                " 'Conventions demonstrated:' section"
            )

    print()
    print("=== Summary ===")
    print(f"  PASS: {pass_count}")
    print(f"  FAIL: {fail_count}")
    print(f"  Good samples: {len(good_samples)}")
    print(f"  Bad samples: {len(bad_samples)}")
    print()

    if fail_count == 0:
        print("All eval samples are well-formed.")
        print()
        print(
            "To run actual agent evaluation, invoke the code-reviewer agent"
        )
        print(
            "against each sample and compare verdicts to expected outcomes."
        )
    else:
        print(
            f"Eval inventory has {fail_count} issue(s)."
            " Fix before running agent evals."
        )
        sys.exit(1)


if __name__ == "__main__":
    main()
