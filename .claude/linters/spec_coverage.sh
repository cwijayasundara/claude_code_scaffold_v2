#!/usr/bin/env bash
# spec_coverage.sh — Service modules must trace to specs
# Every .py in src/service/ (except __init__.py) needs a spec in specs/features/
set -euo pipefail

TARGET_DIR="${1:-src/}"
ERRORS=0

SERVICE_DIR="${TARGET_DIR%/}/service"
[[ ! -d "$SERVICE_DIR" ]] && { echo "spec_coverage: OK (no service directory)"; exit 0; }

while IFS= read -r -d '' f; do
    basename=$(basename "$f" .py)
    [[ "$basename" == "__init__" ]] && continue

    # Look for a matching spec
    spec_found=false
    if [[ -d "specs/features" ]]; then
        for spec in specs/features/*.md; do
            [[ ! -f "$spec" ]] && continue
            spec_name=$(basename "$spec" .md)
            # Match by name (with underscores/hyphens normalized)
            normalized_mod=$(echo "$basename" | tr '_' '-')
            normalized_spec=$(echo "$spec_name" | tr '_' '-')
            if [[ "$normalized_mod" == "$normalized_spec" ]]; then
                spec_found=true
                break
            fi
        done
    fi

    if ! $spec_found; then
        echo "SPEC_COVERAGE: ${f} has no corresponding spec in specs/features/."
        echo "  Remediation: Create specs/features/${basename}.md (or ${basename//_/-}.md) using the feature spec template."
        echo ""
        ERRORS=$((ERRORS + 1))
    fi
done < <(find "$SERVICE_DIR" -name '*.py' -print0 2>/dev/null)

if (( ERRORS > 0 )); then
    echo "spec_coverage: ${ERRORS} module(s) missing specs."
    exit 1
fi
echo "spec_coverage: OK"
