#!/usr/bin/env bash
# file_size.sh — Max 300 lines/file (warn 250), max 50 lines/function
set -euo pipefail

TARGET_DIR="${1:-src/}"
ERRORS=0

# Check file sizes
while IFS= read -r -d '' f; do
    lines=$(wc -l < "$f" | tr -d ' ')
    if (( lines > 300 )); then
        echo "FILE_SIZE: ${f} has ${lines} lines (max 300). Split into smaller modules."
        echo "  Remediation: Extract cohesive groups of functions into separate files."
        echo ""
        ERRORS=$((ERRORS + 1))
    elif (( lines > 250 )); then
        echo "FILE_SIZE_WARN: ${f} has ${lines} lines (approaching 300 limit). Consider splitting."
    fi
done < <(find "$TARGET_DIR" \( -name '*.py' -o -name '*.ts' -o -name '*.tsx' -o -name '*.js' -o -name '*.jsx' \) -print0 2>/dev/null)

# Check Python function sizes
while IFS= read -r -d '' f; do
    func_name=""
    func_start=0
    line_num=0

    while IFS= read -r line; do
        line_num=$((line_num + 1))

        if [[ "$line" =~ ^[[:space:]]*def[[:space:]]+([a-zA-Z_][a-zA-Z0-9_]*)\( ]]; then
            # Close previous function
            if [[ -n "$func_name" ]]; then
                func_len=$((line_num - func_start))
                if (( func_len > 50 )); then
                    echo "FUNC_SIZE: ${f}:${func_start} function '${func_name}' has ${func_len} lines (max 50). Extract helpers."
                    echo "  Remediation: Break into smaller functions with clear, descriptive names."
                    echo ""
                    ERRORS=$((ERRORS + 1))
                fi
            fi
            func_name="${BASH_REMATCH[1]}"
            func_start=$line_num
        fi
    done < "$f"

    # Check last function
    if [[ -n "$func_name" ]]; then
        func_len=$((line_num - func_start + 1))
        if (( func_len > 50 )); then
            echo "FUNC_SIZE: ${f}:${func_start} function '${func_name}' has ${func_len} lines (max 50). Extract helpers."
            echo "  Remediation: Break into smaller functions with clear, descriptive names."
            echo ""
            ERRORS=$((ERRORS + 1))
        fi
    fi
done < <(find "$TARGET_DIR" -name '*.py' -print0 2>/dev/null)

if (( ERRORS > 0 )); then
    echo "file_size: ${ERRORS} violation(s) found."
    exit 1
fi
echo "file_size: OK"
