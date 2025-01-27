#!/usr/bin/env bash

set -euo pipefail

###############################################################################
# Resources documentation generator for ConcourseGPT
# Handles generating documentation for all pipeline resources
###############################################################################

# Source required utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "${SCRIPT_DIR}/utils/formatting.sh"
source "${SCRIPT_DIR}/utils/llm.sh"
source "${SCRIPT_DIR}/utils/helpers.sh"

# Document pipeline resources
# Args:
#   $1 - pipeline file path
#   $2 - pipeline name
document_resources() {
    local pipeline_file="$1"
    local pipeline_name="$2"

    mkdir -p "docs/$pipeline_name/resources"
    local res_index="docs/$pipeline_name/resources/index.md"

    # Initialize index file
    cat <<EOF > "$res_index"
# Pipeline Resources

This document provides links to detailed documentation for each resource in the pipeline.

EOF

    # Get list of resources
    local resources=()
    while IFS= read -r resource; do
        resources+=("$resource")
    done < <(yq eval '.resources[].name' "$pipeline_file" 2>/dev/null)

    local count="${#resources[@]}"
    printf "      Found %d resources to process\n" "$count"
    
    if [ "$count" -eq 0 ]; then
        return
    fi

    # Process each resource
    for resource in "${resources[@]}"; do
        _process_single_resource "$pipeline_file" "$pipeline_name" "$resource" "$res_index"
    done
}

# Process a single resource
# Args:
#   $1 - pipeline file path
#   $2 - pipeline name
#   $3 - resource name
#   $4 - index file path
_process_single_resource() {
    local pipeline_file="$1"
    local pipeline_name="$2"
    local resource="$3"
    local res_index="$4"

    local filename
    filename=$(sanitize_filename "$resource")
    local doc_file="docs/$pipeline_name/resources/${filename}.md"

    if [ -s "$doc_file" ]; then
        print_progress "$resource" "skip"
        echo "* [$resource](${filename}.md)" >> "$res_index"
        return
    fi

    print_progress "$resource" "..."

    local resource_def
    resource_def=$(yq eval '.resources[] | select(.name == "'"$resource"'")' "$pipeline_file")

    local prompt="
Provide a markdown-formatted explanation of this Concourse resource configuration.
Use an official reference tone, active voice, and do NOT mention AI generation.
Do not repeat the definition verbatim.

Important Style Note:

- Write in a direct doc style.
- Avoid phrases like \"the provided pipeline\" or \"you asked me...\"
- Do NOT mention that this was AI-generated.
- Use active voice, official reference tone.

Here is the pipeline definition (for context only; do not repeat verbatim):

Resource definition (context only):
${resource_def}
"
    local response
    local response
    if ! response=$(call_llm_api_with_validation "$prompt" 2>/dev/null); then
        print_progress "$resource" "error"
        return
    fi

    {
        echo "# $resource"
        echo
        echo "$response"
        echo
        echo "## Raw Resource Definition"
        echo '```yaml'
        echo "$resource_def"
        echo '```'
    } > "$doc_file"

    echo "* [$resource](${filename}.md)" >> "$res_index"
    print_progress "$resource" "success"
}

# If this script is run directly, show usage
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    echo "This script is meant to be sourced and used as part of ConcourseGPT"
    exit 1
fi
