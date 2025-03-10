#!/usr/bin/env bash

set -euo pipefail

###############################################################################
# Pipeline overview documentation generator for ConcourseGPT
# Handles generating the main pipeline documentation, including chunking for
# large pipelines
###############################################################################

# Source required utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
source "${SCRIPT_DIR}/utils/formatting.sh"
source "${SCRIPT_DIR}/utils/llm.sh"
source "${SCRIPT_DIR}/utils/helpers.sh"

# Document pipeline overview
# Args:
#   $1 - pipeline file path
#   $2 - pipeline name
document_pipeline() {
    local pipeline_file="$1"
    local pipeline_name="$2"
    local doc_file="docs/$pipeline_name/index.md"

    if [ -s "$doc_file" ]; then
        print_progress "Pipeline Overview" "skip"
        return 0
    fi
    print_progress "Pipeline Overview" "..."

    local line_threshold=600  # each chunk will have 600 lines
    local total_lines
    total_lines="$(wc -l < "$pipeline_file")"

    local tmp_doc
    tmp_doc=$(mktemp)
    echo "# Pipeline Documentation" > "$tmp_doc"
    echo >> "$tmp_doc"

    if [ "$total_lines" -le "$line_threshold" ]; then
        _process_small_pipeline "$pipeline_file" "$tmp_doc"
    else
        _process_large_pipeline "$pipeline_file" "$pipeline_name" "$tmp_doc" "$line_threshold"
    fi

    # Add documentation section references
    echo >> "$tmp_doc"
    echo "## Documentation Sections" >> "$tmp_doc"
    echo "* [Groups](groups/index.md)" >> "$tmp_doc"
    echo "* [Jobs](jobs/index.md)" >> "$tmp_doc"
    echo "* [Resources](resources/index.md)" >> "$tmp_doc"
    echo "* [Secrets](secrets/index.md)" >> "$tmp_doc"

    mv "$tmp_doc" "$doc_file"
    print_progress "Pipeline Overview" "success"
}

# Process a small pipeline (under threshold)
# Args:
#   $1 - pipeline file
#   $2 - temp doc file
_process_small_pipeline() {
    local pipeline_file="$1"
    local tmp_doc="$2"
    
    local pipeline_data
    pipeline_data="$(cat "$pipeline_file")"

    # Read prompt template from file
    local prompt_template
    prompt_template=$(<"${ROOT_DIR}/prompts/pipeline-small.md")
    
    # Replace placeholder with actual pipeline data
    local prompt="${prompt_template/\$\{pipeline_data\}/$pipeline_data}"
    local response
    if ! response=$(call_llm_api_with_validation "$prompt"); then
        rm -f "$tmp_doc"
        print_progress "Pipeline Overview" "error"
        return 1
    fi
    echo "$response" >> "$tmp_doc"
}

# Process a large pipeline (over threshold) using chunking
# Args:
#   $1 - pipeline file
#   $2 - pipeline name
#   $3 - temp doc file
#   $4 - line threshold
_process_large_pipeline() {
    local pipeline_file="$1"
    local pipeline_name="$2"
    local tmp_doc="$3"
    local line_threshold="$4"

    echo >> "$tmp_doc"

    # Create chunk files
    local chunk_prefix="/tmp/${pipeline_name}-chunk-$$-"
    rm -f "${chunk_prefix}"* 2>/dev/null || true
    split -l "$line_threshold" "$pipeline_file" "$chunk_prefix"

    # Process chunks
    local chunk_files
    chunk_files=( ${chunk_prefix}* )

    local partial_summaries=""
    local i=1
    local total_chunks="${#chunk_files[@]}"

    printf "\n"

    for chunk_file in "${chunk_files[@]}"; do
        local chunk_size
        chunk_size="$(wc -c < "$chunk_file")"

        printf "      Summarizing chunk %d/%d (size: %d bytes)\n" \
               "$i" "$total_chunks" "$chunk_size"

        local chunk_data
        chunk_data="$(cat "$chunk_file")"

        # Read chunk prompt template from file
        local chunk_prompt_template
        chunk_prompt_template=$(<"${ROOT_DIR}/prompts/pipeline-chunk.md")
        
        # Replace placeholder with actual chunk data
        local chunk_prompt="${chunk_prompt_template/\$\{chunk_data\}/$chunk_data}"
        local chunk_response
        if ! chunk_response=$(call_llm_api_with_validation "$chunk_prompt"); then
            print_progress "Pipeline Overview" "error"
            continue
        fi

        partial_summaries+="${chunk_response}\n\n"
        ((i++))
    done

    # Remove temp chunk files
    rm -f "${chunk_prefix}"*

    # Unify the summaries
    printf "      Combining partial summaries...\n"
    # Read unify prompt template from file
    local unify_prompt_template
    unify_prompt_template=$(<"${ROOT_DIR}/prompts/pipeline-unify.md")
    
    # Replace placeholder with actual partial summaries
    local unify_prompt="${unify_prompt_template/\$\{partial_summaries\}/$partial_summaries}"
    local unify_response
    if ! unify_response=$(call_llm_api_with_validation "$unify_prompt"); then
        print_progress "Pipeline Overview" "error"
        rm -f "$tmp_doc"
        return 1
    fi
    echo "$unify_response" >> "$tmp_doc"
}

# If this script is run directly, show usage
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    echo "This script is meant to be sourced and used as part of ConcourseGPT"
    exit 1
fi
