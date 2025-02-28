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
Generate comprehensive markdown documentation for this Concourse resource as it's used in this specific pipeline.

FORMAT REQUIREMENTS:
- Start with H1 heading 'Concourse Resource Documentation: [ResourceName]'
- Follow with H2 'Overview' section describing how this specific resource is used in this pipeline
- Include H2 'Configuration Analysis' that explains:
  * What this specific resource is connecting to (repository, registry, etc.)
  * The specific configuration parameters used and their actual values or variables
  * How this resource is configured for this particular pipeline's needs
- Include H2 'Pipeline Integration' explaining:
  * Which jobs in this pipeline use this resource and how
  * How this resource interacts with other resources in this pipeline
  * The data/artifacts this resource provides to or receives from the pipeline
- If applicable, add H2 'Maintenance Notes' with information about:
  * How to update credentials or configuration for this resource
  * Pipeline-specific troubleshooting for this resource

WRITING STYLE:
- Write as if documenting an existing implementation, not a theoretical usage
- Use statements like 'This resource is used to...' rather than 'This resource can be used to...'
- Reference actual pipeline-specific details wherever possible
- Be thorough but avoid unnecessary repetition
- Do NOT refer to this document as AI-generated
- Do NOT use phrases like 'the provided resource' or 'you asked me to'

RESOURCE DEFINITION:
${resource_def}
"
    local response
    local response
    if ! response=$(call_llm_api_with_validation "$prompt" 2>/dev/null); then
        print_progress "$resource" "error"
        return
    fi

    {
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
