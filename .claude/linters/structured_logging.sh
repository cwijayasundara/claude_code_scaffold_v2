#!/usr/bin/env bash
# structured_logging.sh — No raw print/console statements
# Exempts: test files, __main__.py
set -euo pipefail

TARGET_DIR="${1:-src/}"
ERRORS=0

while IFS= read -r -d '' f; do
    basename=$(basename "$f")
    [[ "$basename" == "__main__.py" ]] && continue
    [[ "$f" == */tests/* || "$f" == */test_* ]] && continue

    line_num=0
    while IFS= read -r line; do
        line_num=$((line_num + 1))
        stripped="${line#"${line%%[![:space:]]*}"}"
        [[ "$stripped" == \#* ]] && continue
        if [[ "$stripped" =~ print\( ]]; then
            echo "STRUCTURED_LOGGING: ${f}:${line_num} raw print() found."
            echo "  Remediation: Replace with logger.info(), logger.debug(), etc. Add: import logging; logger = logging.getLogger(__name__)"
            echo ""
            ERRORS=$((ERRORS + 1))
        fi
    done < "$f"
done < <(find "$TARGET_DIR" -name '*.py' -print0 2>/dev/null)

while IFS= read -r -d '' f; do
    [[ "$f" == */tests/* || "$f" == */test_* || "$f" == */__tests__/* ]] && continue

    line_num=0
    while IFS= read -r line; do
        line_num=$((line_num + 1))
        stripped="${line#"${line%%[![:space:]]*}"}"
        [[ "$stripped" == //* ]] && continue
        if [[ "$stripped" =~ console\.(log|error|warn|info)\( ]]; then
            echo "STRUCTURED_LOGGING: ${f}:${line_num} raw console.${BASH_REMATCH[1]}() found."
            echo "  Remediation: Use the project logger instead of console methods."
            echo ""
            ERRORS=$((ERRORS + 1))
        fi
    done < "$f"
done < <(find "$TARGET_DIR" \( -name '*.ts' -o -name '*.tsx' -o -name '*.js' -o -name '*.jsx' \) -print0 2>/dev/null)

if (( ERRORS > 0 )); then
    echo "structured_logging: ${ERRORS} violation(s) found."
    exit 1
fi
echo "structured_logging: OK"
