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
Generate comprehensive markdown documentation for this Concourse pipeline group as it's implemented in this specific pipeline.

FORMAT REQUIREMENTS:
- Start with H1 heading 'Concourse Group Documentation: [GroupName]'
- Follow with H2 'Purpose' section explaining what this specific group accomplishes in this pipeline
- Include H2 'Group Components' section that:
  * Lists all actual jobs and resources that belong to this group
  * Explains how these components work together to fulfill the group's purpose
  * Describes the workflow or sequence of operations within this group
- Include H2 'Pipeline Relationships' explaining:
  * How this group relates to other groups in this specific pipeline
  * Any dependencies this group has on other parts of the pipeline
  * Any other groups that depend on this group's outputs

WRITING STYLE:
- Describe the actual implementation, not theoretical usage
- Use statements like 'This group contains...' rather than 'This group can contain...'
- Reference specific pipeline details rather than general Concourse concepts
- Be thorough but avoid unnecessary repetition
- Do NOT refer to this document as AI-generated
- Do NOT use phrases like 'the provided group' or 'you asked me to'

GROUP DEFINITION:
${group_def}
"
    local response
    local response
    if ! response=$(call_llm_api_with_validation "$prompt" 2>/dev/null); then
        print_progress "$group" "error"
        return
    fi

    {
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
