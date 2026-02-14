#!/usr/bin/env bash
# naming_conventions.sh — snake_case files/functions, PascalCase classes
# Exempt: __init__.py, __main__.py, conftest.py, test files
set -euo pipefail

TARGET_DIR="${1:-src/}"
ERRORS=0

# Check Python filenames are snake_case
while IFS= read -r -d '' f; do
    basename=$(basename "$f" .py)
    [[ "$basename" == "__init__" || "$basename" == "__main__" || "$basename" == "conftest" ]] && continue
    [[ "$f" == */tests/* || "$basename" == test_* ]] && continue

    if [[ "$basename" =~ [A-Z] || "$basename" =~ - ]]; then
        echo "NAMING: ${f} filename is not snake_case."
        echo "  Remediation: Rename to $(echo "$basename" | sed -E 's/([A-Z])/_\L\1/g; s/^_//; s/-/_/g').py"
        echo ""
        ERRORS=$((ERRORS + 1))
    fi
done < <(find "$TARGET_DIR" -name '*.py' -print0 2>/dev/null)

# Check Python functions are snake_case and classes are PascalCase
while IFS= read -r -d '' f; do
    [[ "$f" == */tests/* ]] && continue
    line_num=0
    while IFS= read -r line; do
        line_num=$((line_num + 1))
        # Check def declarations
        if [[ "$line" =~ ^[[:space:]]*def[[:space:]]+([a-zA-Z_][a-zA-Z0-9_]*)\( ]]; then
            func="${BASH_REMATCH[1]}"
            [[ "$func" == __* ]] && continue  # dunder methods
            if [[ "$func" =~ [A-Z] ]]; then
                echo "NAMING: ${f}:${line_num} function '${func}' is not snake_case."
                echo "  Remediation: Rename to $(echo "$func" | sed -E 's/([A-Z])/_\L\1/g; s/^_//')"
                echo ""
                ERRORS=$((ERRORS + 1))
            fi
        fi
        # Check class declarations
        if [[ "$line" =~ ^[[:space:]]*class[[:space:]]+([a-zA-Z_][a-zA-Z0-9_]*) ]]; then
            cls="${BASH_REMATCH[1]}"
            if [[ ! "$cls" =~ ^[A-Z] ]]; then
                echo "NAMING: ${f}:${line_num} class '${cls}' is not PascalCase."
                echo "  Remediation: Rename to start with uppercase, e.g., $(echo "${cls:0:1}" | tr '[:lower:]' '[:upper:]')${cls:1}"
                echo ""
                ERRORS=$((ERRORS + 1))
            fi
        fi
    done < "$f"
done < <(find "$TARGET_DIR" -name '*.py' -print0 2>/dev/null)

# Check TS/JS filenames (snake_case or kebab-case, no PascalCase)
while IFS= read -r -d '' f; do
    [[ "$f" == */tests/* || "$f" == */__tests__/* || "$f" == */node_modules/* ]] && continue
    basename=$(basename "$f")
    name="${basename%.*}"
    if [[ "$name" =~ ^[A-Z] ]]; then
        echo "NAMING: ${f} filename uses PascalCase."
        echo "  Remediation: Use snake_case or kebab-case, e.g., $(echo "$name" | sed -E 's/([A-Z])/-\L\1/g; s/^-//')"
        echo ""
        ERRORS=$((ERRORS + 1))
    fi
done < <(find "$TARGET_DIR" \( -name '*.ts' -o -name '*.tsx' -o -name '*.js' -o -name '*.jsx' \) -print0 2>/dev/null)

if (( ERRORS > 0 )); then
    echo "naming_conventions: ${ERRORS} violation(s) found."
    exit 1
fi
echo "naming_conventions: OK"
