#!/usr/bin/env bash

set -euo pipefail

###############################################################################
# Helper utilities for ConcourseGPT
# General purpose utilities used across the application
###############################################################################

# Get pipeline name from filename
# Args:
#   $1 - filename
get_pipeline_name() {
    local filename="$1"
    local basename
    
    # Get the filename without the path
    basename=$(basename "$filename")
    
    # Remove the extension (everything after the last dot)
    basename="${basename%.*}"
    
    echo "$basename"
}

# Sanitize filename for use in paths
# Args:
#   $1 - filename to sanitize
sanitize_filename() {
    echo "$1" | tr '[:upper:]' '[:lower:]' \
      | sed 's/[^a-z0-9]/-/g' \
      | sed 's/--*/-/g'
}

# Retry a command multiple times
# Args:
#   $@ - command and its arguments to retry
retry_command() {
    local max_retries=3
    local attempt=1
    local cmd=("$@")

    while [ $attempt -le $max_retries ]; do
        if "${cmd[@]}" 2>/dev/null; then
            return 0
        fi
        print_retry_message "$attempt" "$max_retries" >&2
        sleep 3
        attempt=$((attempt + 1))
    done

    echo "All attempts failed. Not retrying further." >&2
    return 1
}

# Ensure required commands are available
validate_requirements() {
    local missing_cmds=()
    
    # List of required commands
    local required_cmds=(
        curl
        jq
        yq
        python3
        pip
    )
    
    for cmd in "${required_cmds[@]}"; do
        if ! command -v "$cmd" >/dev/null 2>&1; then
            missing_cmds+=("$cmd")
        fi
    done
    
    if (( ${#missing_cmds[@]} > 0 )); then
        echo "ERROR: Required commands not found: ${missing_cmds[*]}" >&2
        return 1
    fi
}

# Create necessary directory structure for documentation
# Args:
#   $1 - pipeline name
setup_doc_directories() {
    local pipeline_name="$1"
    mkdir -p "docs/$pipeline_name"/{jobs,resources,groups}
}
