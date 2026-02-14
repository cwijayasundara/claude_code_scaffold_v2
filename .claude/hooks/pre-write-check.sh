#!/usr/bin/env bash
# pre-write-check.sh — Validate write location + spec reminders
# PreToolUse hook for Write/Edit operations. Advisory only (exit 0).
set -uo pipefail

# Read tool input from stdin
INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // .tool_input.path // ""' 2>/dev/null)

[[ -z "$FILE_PATH" ]] && exit 0

# Check: writing to allowed locations
ALLOWED=false
for prefix in src/ tests/ docs/ specs/ scripts/ .claude/; do
    if [[ "$FILE_PATH" == *"$prefix"* ]]; then
        ALLOWED=true
        break
    fi
done

if ! $ALLOWED; then
    echo "pre-write-check: Writing to '${FILE_PATH}' — not in standard project directories (src/, tests/, docs/, specs/, scripts/)."
fi

# Check: writing to src/ — remind about spec requirement
if [[ "$FILE_PATH" == */src/* ]]; then
    # Extract module name
    basename=$(basename "$FILE_PATH" .py)
    if [[ "$basename" != "__init__" ]]; then
        # Check for layer info
        for layer in types config repo service runtime ui; do
            if [[ "$FILE_PATH" == *"src/${layer}/"* ]]; then
                echo "pre-write-check: Writing to layer '${layer}'. Remember: imports only from lower layers."
                break
            fi
        done

        # Check for spec coverage (service layer)
        if [[ "$FILE_PATH" == *"src/service/"* ]]; then
            spec_name="${basename//_/-}"
            if [[ ! -f "specs/features/${basename}.md" && ! -f "specs/features/${spec_name}.md" ]]; then
                echo "pre-write-check: No spec found for service module '${basename}'. Consider creating specs/features/${basename}.md first."
            fi
        fi
    fi
fi

exit 0
