#!/usr/bin/env bash

set -euo pipefail

###############################################################################
# Formatting utilities for ConcourseGPT
# Handles all terminal output formatting, progress indicators, and status messages
###############################################################################

# Check if variables are already set to avoid readonly errors
if [[ -z "${CYAN:-}" ]]; then readonly CYAN=$'\e[36m'; fi
if [[ -z "${GREEN:-}" ]]; then readonly GREEN=$'\e[32m'; fi
if [[ -z "${YELLOW:-}" ]]; then readonly YELLOW=$'\e[33m'; fi
if [[ -z "${RED:-}" ]]; then readonly RED=$'\e[31m'; fi
if [[ -z "${BOLD:-}" ]]; then readonly BOLD=$'\e[1m'; fi
if [[ -z "${RESET:-}" ]]; then readonly RESET=$'\e[0m'; fi

# Status indicators
if [[ -z "${CHECK_MARK:-}" ]]; then readonly CHECK_MARK="✓"; fi
if [[ -z "${CROSS_MARK:-}" ]]; then readonly CROSS_MARK="✗"; fi
if [[ -z "${INFO_MARK:-}" ]]; then readonly INFO_MARK="ℹ"; fi
if [[ -z "${GEAR:-}" ]]; then readonly GEAR="⚙"; fi

# Track start time for elapsed time calculations
START_TIME=${START_TIME:-$(date +%s)}

# Format progress message with dots
# Args:
#   $1 - text to display
format_progress() {
    local text="$1"
    local max_length=50
    local padding_length=$((max_length - ${#text} - 1))
    printf "%s%s " "$text" "$(printf '%*s' "$padding_length" | tr ' ' '.')"
}

# Calculate and format elapsed time
get_elapsed_time() {
    local end_time
    end_time=$(date +%s)
    local elapsed=$((end_time - START_TIME))
    printf "%02d:%02d" $((elapsed / 60)) $((elapsed % 60))
}

# Print section header
# Args:
#   $1 - section number
#   $2 - total sections
#   $3 - description
print_section_header() {
    local section_num="$1"
    local total_sections="$2"
    local description="$3"
    printf "\n${BOLD}[%s/%s] %s${RESET}\n" "$section_num" "$total_sections" "$description"
}

# Print progress status
# Args:
#   $1 - name
#   $2 - status (success|skip|error|...)
print_progress() {
    local name="$1"
    local status="$2"
    
    printf "\r"
    printf "      ${CYAN}${GEAR}${RESET} %s" "$(format_progress "$name")"
    case "$status" in
        "success") printf "${GREEN}Done ${CHECK_MARK}${RESET}" ;;
        "skip")    printf "${YELLOW}Skipped${RESET}" ;;
        "error")   printf "${RED}Failed ${CROSS_MARK}${RESET}" ;;
        *)         printf "%s" "$status" ;;
    esac
    
    case "$status" in
        "success"|"skip"|"error") printf "\n" ;;
    esac
}

# Print retry message
# Args:
#   $1 - current attempt number
#   $2 - maximum attempts
print_retry_message() {
    local attempt="$1"
    local max_attempts="$2"
    printf "\r%${COLUMNS}s\r" ""
    printf "        ${YELLOW}↳ Attempt %d/%d: Retrying...${RESET}\n" "$attempt" "$max_attempts"
}

# Print header with pipeline info
# Args:
#   $1 - pipeline name
print_header() {
    local pipeline_name="$1"
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    printf "\n%s\n" "${BOLD}Pipeline Documentation Generator${RESET}"
    printf "Started: %s\n" "$timestamp"
    printf "Pipeline: %s\n\n" "$pipeline_name"
}

# Print completion message
# Args:
#   $1 - pipeline name
print_completion() {
    local pipeline_name="$1"
    
    printf "\n%s\n" "${BOLD}Generation Complete${RESET}"
    printf "Time Elapsed: %s\n\n" "$(get_elapsed_time)"
    printf "Documentation available at: docs/%s/\n" "$pipeline_name"
    printf "  └── index.md\n"
    printf "      ├── jobs/\n"
    printf "      ├── resources/\n"
    printf "      └── groups/\n\n"
}
