#!/usr/bin/env bash

set -euo pipefail

###############################################################################
# Jobs documentation generator for ConcourseGPT
# Handles generating documentation for all pipeline jobs
###############################################################################

# Source required utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
source "${SCRIPT_DIR}/utils/formatting.sh"
source "${SCRIPT_DIR}/utils/llm.sh"
source "${SCRIPT_DIR}/utils/helpers.sh"

# Document pipeline jobs
# Args:
#   $1 - pipeline file path
#   $2 - pipeline name
document_jobs() {
    local pipeline_file="$1"
    local pipeline_name="$2"

    mkdir -p "docs/$pipeline_name/jobs"
    local jobs_index="docs/$pipeline_name/jobs/index.md"

    # Initialize index file
    cat <<EOF > "$jobs_index"
# Pipeline Jobs

This document provides links to detailed documentation for each job in the pipeline.

EOF

    # Get list of jobs
    local jobs=()
    while IFS= read -r job; do
        jobs+=("$job")
    done < <(yq eval '.jobs[].name' "$pipeline_file" 2>/dev/null)

    local count="${#jobs[@]}"
    printf "      Found %d jobs to process\n" "$count"
    
    if [ "$count" -eq 0 ]; then
        return
    fi

    # Process each job
    for job in "${jobs[@]}"; do
        _process_single_job "$pipeline_file" "$pipeline_name" "$job" "$jobs_index"
    done
}

# Process a single job
# Args:
#   $1 - pipeline file path
#   $2 - pipeline name
#   $3 - job name
#   $4 - index file path
_process_single_job() {
    local pipeline_file="$1"
    local pipeline_name="$2"
    local job="$3"
    local jobs_index="$4"

    local filename
    filename=$(sanitize_filename "$job")
    local doc_file="docs/$pipeline_name/jobs/${filename}.md"

    if [ -s "$doc_file" ]; then
        print_progress "$job" "skip"
        echo "* [$job](${filename}.md)" >> "$jobs_index"
        return
    fi

    print_progress "$job" "..."

    local job_def
    job_def=$(yq eval '.jobs[] | select(.name == "'"$job"'")' "$pipeline_file")

    # Read prompt template from file
    local prompt_template
    prompt_template=$(<"${ROOT_DIR}/prompts/jobs.md")
    
    # Replace placeholder with actual job definition
    local prompt="${prompt_template/\$\{job_def\}/$job_def}"
    local response
    local response
    if ! response=$(call_llm_api_with_validation "$prompt" 2>/dev/null); then
        print_progress "$job" "error"
        return
    fi

    {
        echo
        echo "$response"
        echo
        echo "## Raw Job Definition"
        echo '```yaml'
        echo "$job_def"
        echo '```'
    } > "$doc_file"

    echo "* [$job](${filename}.md)" >> "$jobs_index"
    print_progress "$job" "success"
}

# If this script is run directly, show usage
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    echo "This script is meant to be sourced and used as part of ConcourseGPT"
    exit 1
fi
