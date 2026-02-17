#!/usr/bin/env bash
# pre-write-check.sh — Advisory pre-write hook (quality reminders, never blocks)
# PreToolUse hook for Write/Edit operations.
set -uo pipefail

# Read tool input from stdin
INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // .tool_input.path // ""' 2>/dev/null)

[[ -z "$FILE_PATH" ]] && exit 0

# Only advise on src/ and tests/ writes
IS_SRC=false
if [[ "$FILE_PATH" == */src/* ]]; then IS_SRC=true; fi

if ! $IS_SRC && [[ "$FILE_PATH" != */tests/* ]]; then
  exit 0
fi

# --- Layer reminder for src/ writes ---
if $IS_SRC; then
  for layer in types config repo service runtime ui; do
    if [[ "$FILE_PATH" == *"src/${layer}/"* ]]; then
      echo "pre-write-check: Writing to '${layer}' layer. Imports only from lower layers."
      break
    fi
  done

  # Soft spec suggestion for new service modules
  BASENAME=$(basename "$FILE_PATH" .py)
  if [[ "$FILE_PATH" == *"src/service/"* && "$BASENAME" != "__init__" && "$BASENAME" != "conftest" ]]; then
    FEATURE_ID=$(echo "$BASENAME" | sed 's/_/-/g')
    if [[ ! -f "specs/features/${FEATURE_ID}.md" ]]; then
      echo "pre-write-check: No spec found for '${FEATURE_ID}'. Consider creating one with the spec-writer agent."
    fi
  fi
fi

# --- Test reminder ---
echo "pre-write-check: Remember to add/update tests for this change."

exit 0
