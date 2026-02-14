#!/usr/bin/env bash
# post-commit-spec-check.sh — Session-end spec coverage summary
# Stop hook. Informational only (always exit 0).
set -uo pipefail

PROJECT_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || echo ".")

# Get files changed in current session
UNCOMMITTED=$(git diff --name-only HEAD 2>/dev/null || true)
STAGED=$(git diff --cached --name-only 2>/dev/null || true)
ALL_CHANGED=$(printf "%s\n%s" "$UNCOMMITTED" "$STAGED" | sort -u | grep -v '^$' || true)

[[ -z "$ALL_CHANGED" ]] && exit 0

TOTAL=0
SRC_FILES=0
SPECS_FOUND=0
SPECS_MISSING=0

while IFS= read -r file; do
    [[ -z "$file" ]] && continue
    TOTAL=$((TOTAL + 1))

    if [[ "$file" == src/* ]]; then
        SRC_FILES=$((SRC_FILES + 1))
        basename=$(basename "$file" | sed 's/\.[^.]*$//')
        [[ "$basename" == "__init__" ]] && continue

        if [[ -d "${PROJECT_ROOT}/specs/features" ]]; then
            normalized=$(echo "$basename" | tr '_' '-')
            if ls "${PROJECT_ROOT}/specs/features/"*.md 2>/dev/null | xargs -I{} basename {} .md | tr '_' '-' | grep -qx "$normalized"; then
                SPECS_FOUND=$((SPECS_FOUND + 1))
            else
                SPECS_MISSING=$((SPECS_MISSING + 1))
            fi
        else
            SPECS_MISSING=$((SPECS_MISSING + 1))
        fi
    fi
done <<< "$ALL_CHANGED"

echo "========================================="
echo "  Session Changes Summary"
echo "========================================="
echo "  Files modified:   ${TOTAL}"
echo "  Source files:      ${SRC_FILES}"
echo "  Specs found:      ${SPECS_FOUND}"
echo "  Specs missing:    ${SPECS_MISSING}"
echo "========================================="

exit 0
