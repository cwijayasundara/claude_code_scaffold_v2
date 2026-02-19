#!/bin/bash
# Run reviewer evaluation samples to verify reviewer agents catch known patterns.
# Usage: bash .claude/scripts/run-reviewer-evals.sh
#
# This script validates the eval sample inventory. Actual agent evaluation
# requires invoking the code-reviewer agent against each sample via Claude Code:
#
#   claude -p "You are the code-reviewer agent (.claude/agents/code-reviewer.md).
#     Review the file at .claude/evals/code-reviewer/bad/missing_logger.py as if
#     it were src/service/user_service.py. Output your verdict."
#
# Expected verdicts:
#   good/* → APPROVE
#   bad/*  → REQUEST_CHANGES

set -euo pipefail

EVAL_DIR=".claude/evals/code-reviewer"
PASS=0
FAIL=0

echo "=== Reviewer Eval Inventory Check ==="
echo ""

# Check directory structure
if [[ ! -d "$EVAL_DIR/good" ]]; then
  echo "  FAIL: $EVAL_DIR/good/ directory missing"
  FAIL=$((FAIL + 1))
else
  echo "  PASS: $EVAL_DIR/good/ exists"
  PASS=$((PASS + 1))
fi

if [[ ! -d "$EVAL_DIR/bad" ]]; then
  echo "  FAIL: $EVAL_DIR/bad/ directory missing"
  FAIL=$((FAIL + 1))
else
  echo "  PASS: $EVAL_DIR/bad/ exists"
  PASS=$((PASS + 1))
fi

# Check that eval samples exist
GOOD_COUNT=$(find "$EVAL_DIR/good" -name "*.py" 2>/dev/null | wc -l | tr -d ' ')
BAD_COUNT=$(find "$EVAL_DIR/bad" -name "*.py" 2>/dev/null | wc -l | tr -d ' ')

if [[ "$GOOD_COUNT" -ge 1 ]]; then
  echo "  PASS: $GOOD_COUNT good sample(s) found"
  PASS=$((PASS + 1))
else
  echo "  FAIL: no good samples in $EVAL_DIR/good/"
  FAIL=$((FAIL + 1))
fi

if [[ "$BAD_COUNT" -ge 2 ]]; then
  echo "  PASS: $BAD_COUNT bad sample(s) found"
  PASS=$((PASS + 1))
else
  echo "  FAIL: need at least 2 bad samples in $EVAL_DIR/bad/ (found $BAD_COUNT)"
  FAIL=$((FAIL + 1))
fi

# Verify each sample has metadata comments
echo ""
echo "--- Sample metadata check ---"

for sample in "$EVAL_DIR"/good/*.py "$EVAL_DIR"/bad/*.py; do
  [[ -f "$sample" ]] || continue
  name=$(basename "$sample")
  dir=$(basename "$(dirname "$sample")")

  if grep -q "Expected reviewer verdict:" "$sample"; then
    echo "  PASS: $dir/$name has expected verdict"
    PASS=$((PASS + 1))
  else
    echo "  FAIL: $dir/$name missing 'Expected reviewer verdict:' comment"
    FAIL=$((FAIL + 1))
  fi

  if [[ "$dir" == "bad" ]] && grep -q "Expected finding:" "$sample"; then
    echo "  PASS: $dir/$name has expected finding"
    PASS=$((PASS + 1))
  elif [[ "$dir" == "bad" ]]; then
    echo "  FAIL: $dir/$name missing 'Expected finding:' comment"
    FAIL=$((FAIL + 1))
  fi

  if grep -q "Violations:\|Conventions demonstrated:" "$sample"; then
    echo "  PASS: $dir/$name documents what it tests"
    PASS=$((PASS + 1))
  else
    echo "  FAIL: $dir/$name missing 'Violations:' or 'Conventions demonstrated:' section"
    FAIL=$((FAIL + 1))
  fi
done

echo ""
echo "=== Summary ==="
echo "  PASS: $PASS"
echo "  FAIL: $FAIL"
echo "  Good samples: $GOOD_COUNT"
echo "  Bad samples: $BAD_COUNT"
echo ""

if [[ "$FAIL" -eq 0 ]]; then
  echo "All eval samples are well-formed."
  echo ""
  echo "To run actual agent evaluation, invoke the code-reviewer agent"
  echo "against each sample and compare verdicts to expected outcomes."
else
  echo "Eval inventory has $FAIL issue(s). Fix before running agent evals."
  exit 1
fi
