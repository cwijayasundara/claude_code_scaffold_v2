#!/usr/bin/env bash
# layer_deps.sh — Forward-only layer dependency check
# Layer order: types=0, config=1, repo=2, service=3, runtime=4, ui=5
# A file in layer N can only import from layers 0..N.
set -eo pipefail

TARGET_DIR="${1:-src/}"
ERRORS=0

# Layer index lookup (bash 3.2 compatible — no associative arrays)
layer_index() {
    case "$1" in
        types)   echo 0 ;;
        config)  echo 1 ;;
        repo)    echo 2 ;;
        service) echo 3 ;;
        runtime) echo 4 ;;
        ui)      echo 5 ;;
        *)       echo -1 ;;
    esac
}

LAYER_NAMES="types config repo service runtime ui"

get_layer() {
    local filepath="$1"
    for layer in $LAYER_NAMES; do
        case "$filepath" in
            *"src/${layer}/"*) echo "$layer"; return ;;
        esac
    done
    echo ""
}

get_import_layer() {
    local target="$1"
    for layer in $LAYER_NAMES; do
        if echo "$target" | grep -qE "(^|\.)(src\.)?${layer}(\.|$)"; then
            echo "$layer"
            return
        fi
    done
    echo ""
}

while IFS= read -r -d '' pyfile; do
    file_layer=$(get_layer "$pyfile")
    [ -z "$file_layer" ] && continue
    file_index=$(layer_index "$file_layer")

    line_num=0
    while IFS= read -r line; do
        line_num=$((line_num + 1))
        # Skip empty lines and comments
        case "$line" in
            *[!\ ]*) ;;  # has non-space content
            *) continue ;;
        esac
        stripped=$(echo "$line" | sed 's/^[[:space:]]*//')
        case "$stripped" in
            \#*) continue ;;
            "") continue ;;
        esac

        import_target=""
        if echo "$stripped" | grep -qE '^from[[:space:]]+'; then
            import_target=$(echo "$stripped" | sed -E 's/^from[[:space:]]+([a-zA-Z0-9_.]+)[[:space:]]+import.*/\1/')
        elif echo "$stripped" | grep -qE '^import[[:space:]]+'; then
            import_target=$(echo "$stripped" | sed -E 's/^import[[:space:]]+([a-zA-Z0-9_.]+).*/\1/')
        fi
        [ -z "$import_target" ] && continue

        import_layer=$(get_import_layer "$import_target")
        [ -z "$import_layer" ] && continue

        import_index=$(layer_index "$import_layer")
        if [ "$import_index" -gt "$file_index" ]; then
            echo "LAYER_DEPS: ${pyfile}:${line_num} layer '${file_layer}' (${file_index}) imports '${import_layer}' (${import_index})."
            echo "  Remediation: Layer '${file_layer}' cannot import from '${import_layer}'. Move the dependency or refactor."
            echo "  Order: types(0) -> config(1) -> repo(2) -> service(3) -> runtime(4) -> ui(5)"
            echo ""
            ERRORS=$((ERRORS + 1))
        fi
    done < "$pyfile"
done < <(find "$TARGET_DIR" -name '*.py' -print0 2>/dev/null)

if [ "$ERRORS" -gt 0 ]; then
    echo "layer_deps: ${ERRORS} violation(s) found."
    exit 1
fi
echo "layer_deps: OK"
