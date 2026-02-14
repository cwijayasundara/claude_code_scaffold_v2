#!/usr/bin/env bash
# init-from-app-spec.sh — Parse XML app_spec → feature_list.json + feature stubs
# Usage: ./scripts/init-from-app-spec.sh specs/app_spec.xml
set -euo pipefail

SPEC_FILE="${1:-}"
if [[ -z "$SPEC_FILE" || ! -f "$SPEC_FILE" ]]; then
    echo "Usage: $0 <app_spec.xml>"
    echo "  Example: $0 specs/app_spec.xml"
    exit 1
fi

mkdir -p specs/features

# Extract app name
APP_NAME=$(grep -oP '<name>\K[^<]+' "$SPEC_FILE" 2>/dev/null | head -1 || echo "unnamed-app")

echo "Parsing app spec: ${SPEC_FILE}"
echo "App name: ${APP_NAME}"
echo ""

# Extract features using sed/grep (no xmllint dependency)
FEATURE_IDS=()
FEATURE_NAMES=()
FEATURE_PRIORITIES=()
FEATURE_DESCS=()

# Parse features block
in_feature=false
current_id=""
current_name=""
current_priority=""
current_desc=""

while IFS= read -r line; do
    stripped=$(echo "$line" | sed 's/^[[:space:]]*//')

    if echo "$stripped" | grep -qE '<feature[[:space:]]'; then
        in_feature=true
        current_id=$(echo "$stripped" | grep -oP 'id="[^"]*"' | sed 's/id="//;s/"//')
        current_priority=$(echo "$stripped" | grep -oP 'priority="[^"]*"' | sed 's/priority="//;s/"//')
        [[ -z "$current_priority" ]] && current_priority="medium"
        current_name=""
        current_desc=""
    fi

    if $in_feature; then
        if echo "$stripped" | grep -qE '<name>'; then
            current_name=$(echo "$stripped" | grep -oP '<name>\K[^<]+')
        fi
        if echo "$stripped" | grep -qE '<description>'; then
            current_desc=$(echo "$stripped" | grep -oP '<description>\K[^<]+')
        fi
    fi

    if echo "$stripped" | grep -qE '</feature>'; then
        if [[ -n "$current_id" ]]; then
            FEATURE_IDS+=("$current_id")
            FEATURE_NAMES+=("${current_name:-$current_id}")
            FEATURE_PRIORITIES+=("$current_priority")
            FEATURE_DESCS+=("${current_desc:-No description}")
        fi
        in_feature=false
    fi
done < "$SPEC_FILE"

# Generate feature_list.json
JSON_FILE="specs/feature_list.json"
echo "{" > "$JSON_FILE"
echo "  \"app_name\": \"${APP_NAME}\"," >> "$JSON_FILE"
echo "  \"source\": \"${SPEC_FILE}\"," >> "$JSON_FILE"
echo "  \"generated_at\": \"$(date -u +%Y-%m-%dT%H:%M:%SZ)\"," >> "$JSON_FILE"
echo "  \"features\": [" >> "$JSON_FILE"

count=${#FEATURE_IDS[@]}
for ((i=0; i<count; i++)); do
    comma=","
    (( i == count - 1 )) && comma=""
    echo "    {" >> "$JSON_FILE"
    echo "      \"id\": \"${FEATURE_IDS[$i]}\"," >> "$JSON_FILE"
    echo "      \"name\": \"${FEATURE_NAMES[$i]}\"," >> "$JSON_FILE"
    echo "      \"priority\": \"${FEATURE_PRIORITIES[$i]}\"," >> "$JSON_FILE"
    echo "      \"description\": \"${FEATURE_DESCS[$i]}\"," >> "$JSON_FILE"
    echo "      \"status\": \"pending\"," >> "$JSON_FILE"
    echo "      \"spec_file\": \"specs/features/${FEATURE_IDS[$i]}.md\"" >> "$JSON_FILE"
    echo "    }${comma}" >> "$JSON_FILE"
done

echo "  ]" >> "$JSON_FILE"
echo "}" >> "$JSON_FILE"

echo "Generated: ${JSON_FILE} (${count} features)"

# Generate feature spec stubs
for ((i=0; i<count; i++)); do
    stub="specs/features/${FEATURE_IDS[$i]}.md"
    if [[ -f "$stub" ]]; then
        echo "  SKIP: ${stub} (already exists)"
        continue
    fi
    cat > "$stub" << SPECEOF
# Feature: ${FEATURE_NAMES[$i]}

**ID**: ${FEATURE_IDS[$i]}
**Priority**: ${FEATURE_PRIORITIES[$i]}
**Status**: draft

## Description

${FEATURE_DESCS[$i]}

## Acceptance Criteria

<!-- Fill in testable criteria in Given/When/Then format -->

1. Given [precondition], When [action], Then [expected result]

## Affected Layers

- [ ] Types
- [ ] Config
- [ ] Repo
- [ ] Service
- [ ] Runtime
- [ ] UI

## Dependencies

- None identified yet

## Test Strategy

- **Unit**: TBD
- **Integration**: TBD
- **E2E**: TBD

## Open Questions

- TBD
SPECEOF
    echo "  Created: ${stub}"
done

echo ""
echo "Done. Next steps:"
echo "  1. Review specs/feature_list.json"
echo "  2. Flesh out each spec stub in specs/features/"
echo "  3. Use the spec-writer agent to complete specs: /init-from-spec"
