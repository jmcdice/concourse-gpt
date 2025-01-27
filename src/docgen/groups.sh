#!/usr/bin/env bash

set -euo pipefail

###############################################################################
# Groups documentation generator for ConcourseGPT
# Handles generating documentation for all pipeline groups
###############################################################################

# Source required utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "${SCRIPT_DIR}/utils/formatting.sh"
source "${SCRIPT_DIR}/utils/llm.sh"
source "${SCRIPT_DIR}/utils/helpers.sh"

# Document pipeline groups
# Args:
#   $1 - pipeline file path
#   $2 - pipeline name
document_groups() {
    local pipeline_file="$1"
    local pipeline_name="$2"

    mkdir -p "docs/$pipeline_name/groups"
    local groups_index="docs/$pipeline_name/groups/index.md"

    # Initialize index file
    cat <<EOF > "$groups_index"
# Pipeline Groups

This document provides links to detailed documentation for each group in the pipeline.

EOF

    # Get list of groups
    local groups=()
    while IFS= read -r group; do
        groups+=("$group")
    done < <(yq eval '.groups[].name' "$pipeline_file" 2>/dev/null)

    local count="${#groups[@]}"
    printf "      Found %d groups to process\n" "$count"
    
    if [ "$count" -eq 0 ]; then
        return
    fi

    # Process each group
    for group in "${groups[@]}"; do
        _process_single_group "$pipeline_file" "$pipeline_name" "$group" "$groups_index"
    done
}

# Process a single group
# Args:
#   $1 - pipeline file path
#   $2 - pipeline name
#   $3 - group name
#   $4 - index file path
_process_single_group() {
    local pipeline_file="$1"
    local pipeline_name="$2"
    local group="$3"
    local groups_index="$4"

    local filename
    filename=$(sanitize_filename "$group")
    local doc_file="docs/$pipeline_name/groups/${filename}.md"

    if [ -s "$doc_file" ]; then
        print_progress "$group" "skip"
        echo "* [$group](${filename}.md)" >> "$groups_index"
        return
    fi

    print_progress "$group" "..."

    local group_def
    group_def=$(yq eval '.groups[] | select(.name == "'"$group"'")' "$pipeline_file")

    local prompt="
Provide a markdown-formatted explanation of this Concourse pipeline group.
Use an official reference tone, active voice, and do NOT mention AI generation.
Do not repeat the definition verbatim.

Important Style Note:

- Write in a direct doc style.
- Avoid phrases like \"the provided pipeline\" or \"you asked me...\"
- Do NOT mention that this was AI-generated.
- Use active voice, official reference tone.

Here is the pipeline definition (for context only; do not repeat verbatim):

${group_def}
"
    local response
    local response
    if ! response=$(call_llm_api_with_validation "$prompt" 2>/dev/null); then
        print_progress "$group" "error"
        return
    fi

    {
        echo "# $group"
        echo
        echo "$response"
        echo
        echo "## Raw Group Definition"
        echo '```yaml'
        echo "$group_def"
        echo '```'
    } > "$doc_file"

    echo "* [$group](${filename}.md)" >> "$groups_index"
    print_progress "$group" "success"
}

# If this script is run directly, show usage
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    echo "This script is meant to be sourced and used as part of ConcourseGPT"
    exit 1
fi
