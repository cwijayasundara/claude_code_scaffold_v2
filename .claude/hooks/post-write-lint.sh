#!/usr/bin/env bash
# post-write-lint.sh — Run targeted custom linters after writes
# PostToolUse hook for Write/Edit operations. Advisory only (exit 0).
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
LINTER_DIR="${PROJECT_ROOT}/.claude/linters"

# Read tool result from stdin
INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // .tool_input.path // ""' 2>/dev/null)

[[ -z "$FILE_PATH" ]] && exit 0

# Determine file extension
ext="${FILE_PATH##*.}"

run_linter() {
    local linter="$1"
    local target="$2"
    local script="${LINTER_DIR}/${linter}.sh"
    [[ ! -x "$script" ]] && return
    output=$(bash "$script" "$target" 2>&1)
    status=$?
    if (( status != 0 )); then
        echo "post-write-lint [${linter}]:"
        echo "$output" | head -5
    fi
}

# Get the directory containing the file for targeted linting
file_dir=$(dirname "$FILE_PATH")

case "$ext" in
    py)
        run_linter "layer_deps" "$file_dir"
        run_linter "file_size" "$file_dir"
        ;;
    ts|tsx|js|jsx)
        run_linter "file_size" "$file_dir"
        ;;
esac

# --- Test file existence check for service modules ---
if [[ "$FILE_PATH" == *"src/service/"* && "$ext" == "py" ]]; then
    base=$(basename "$FILE_PATH" .py)
    if [[ "$base" != "__init__" && "$base" != "conftest" ]]; then
        test_file="${PROJECT_ROOT}/tests/service/test_${base}.py"
        if [[ ! -f "$test_file" ]]; then
            echo "post-write-lint: No test file found at tests/service/test_${base}.py — consider adding tests."
        fi
    fi
fi

exit 0
