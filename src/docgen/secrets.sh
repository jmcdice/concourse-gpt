#!/usr/bin/env bash
set -euo pipefail

# Purpose: Generate documentation for pipeline secrets
# This script extracts secrets information from a Concourse pipeline YAML file
# and generates markdown documentation using LLM.

# Source required utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
source "${SCRIPT_DIR}/utils/helpers.sh"
source "${SCRIPT_DIR}/utils/formatting.sh"
source "${SCRIPT_DIR}/utils/llm.sh"

document_secrets() {
  local pipeline_file=$1
  local pipeline_name=$2
  local docs_dir="docs/$pipeline_name"
  
  # Create documentation directory
  local secrets_dir="$docs_dir/secrets"
  [[ -d "$secrets_dir" ]] || mkdir -p "$secrets_dir"
  
  # Initialize index file
  local index_file="$secrets_dir/index.md"
  echo "# Secrets in $pipeline_name pipeline" > "$index_file"
  echo "" >> "$index_file"
  echo "This document lists all secrets and sensitive information used in the pipeline." >> "$index_file"
  echo "" >> "$index_file"
  
  # Progress header
  printf "      Processing pipeline secrets\n"
  
  # Process pipeline secrets
  local yaml_content
  yaml_content=$(cat "$pipeline_file")
  
  # Load prompt template
  local prompt_template
  prompt_template=$(<"${ROOT_DIR}/prompts/secrets.md")
  
  # Replace variables in the prompt
  local prompt="${prompt_template/\$\{yaml\}/$yaml_content}"
  
  # Call LLM API
  print_progress "pipeline-secrets" "..."
  local response
  response=$(call_llm_api_with_validation "$prompt")
  
  if [[ -n "$response" ]]; then
    local output_file="$secrets_dir/pipeline-secrets.md"
    local title="Secrets in $pipeline_name pipeline"
    
    echo "# $title" > "$output_file"
    echo "" >> "$output_file"
    echo "$response" >> "$output_file"
    
    echo "- [Pipeline Secrets](pipeline-secrets.md)" >> "$index_file"
    print_progress "pipeline-secrets" "success"
  else
    print_progress "pipeline-secrets" "error"
  fi
}

# Prevent direct execution
[[ "${BASH_SOURCE[0]}" != "${0}" ]] || {
  echo "❌ This script should be sourced, not executed directly"
  exit 1
}