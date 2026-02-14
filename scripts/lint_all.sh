#!/usr/bin/env bash
# lint_all.sh — Master runner for all 5 custom linters
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LINTER_DIR="${SCRIPT_DIR}/linters"

LINTERS=(
    layer_deps
    structured_logging
    naming_conventions
    file_size
    spec_coverage
)

PASSED=0
FAILED=0
RESULTS=()

echo "=== Custom Linter Suite ==="
echo ""

for linter in "${LINTERS[@]}"; do
    script="${LINTER_DIR}/${linter}.sh"
    if [[ ! -x "$script" ]]; then
        echo "SKIP: ${linter} (not found or not executable)"
        RESULTS+=("SKIP  ${linter}")
        continue
    fi

    echo "--- Running: ${linter} ---"
    output=$(bash "$script" 2>&1)
    status=$?

    if (( status == 0 )); then
        echo "  ${linter}: PASS"
        PASSED=$((PASSED + 1))
        RESULTS+=("PASS  ${linter}")
    else
        echo "$output"
        echo "  ${linter}: FAIL"
        FAILED=$((FAILED + 1))
        RESULTS+=("FAIL  ${linter}")
    fi
    echo ""
done

echo "=== Summary ==="
echo ""
for r in "${RESULTS[@]}"; do
    echo "  $r"
done
echo ""
echo "  Passed: ${PASSED} / $((PASSED + FAILED))"

if (( FAILED > 0 )); then
    echo "  FAILED: ${FAILED} linter(s) reported issues."
    exit 1
fi
echo "  All linters passed."
