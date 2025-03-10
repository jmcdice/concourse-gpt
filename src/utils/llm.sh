#!/usr/bin/env bash

# Ensures script fails on any error
set -euo pipefail

###############################################################################
# LLM API interaction utilities for ConcourseGPT
# Handles all interactions with the LLM API including retries and validation
###############################################################################

# Source formatting utilities if available
if [[ -f "${BASH_SOURCE%/*}/formatting.sh" ]]; then
    source "${BASH_SOURCE%/*}/formatting.sh"
fi

# Environment validation
validate_llm_environment() {
    local missing_vars=()
    
    [[ -z "${LLM_API_BASE:-}" ]] && missing_vars+=("LLM_API_BASE")
    [[ -z "${LLM_MODEL:-}" ]] && missing_vars+=("LLM_MODEL")
    [[ -z "${LLM_TOKEN:-}" ]] && missing_vars+=("LLM_TOKEN")
    
    if (( ${#missing_vars[@]} > 0 )); then
        echo "ERROR: Required environment variables not set: ${missing_vars[*]}" >&2
        return 1
    fi
}

# Basic LLM API call
# Args:
#   $1 - prompt text
call_llm_api() {
    local prompt="$1"
    local max_attempts=3
    local sleep_between=2

    local curl_opts=(
        -S
        -X POST
        --connect-timeout 30
        --max-time 600
    )

    # Add silent mode unless debug is enabled
    if [ "${DEBUG_CURL:-}" != "1" ]; then
        curl_opts=(-s "${curl_opts[@]}")
    else
        curl_opts=(-v "${curl_opts[@]}")
    fi

    local json_payload
    json_payload=$(jq -n \
        --arg model "$LLM_MODEL" \
        --arg user_prompt "$prompt" \
        '{
            "model": $model,
            "messages": [
                {
                    "role": "user",
                    "content": $user_prompt
                }
            ],
            "temperature": 0.7,
            "max_tokens": 2000
        }'
    )

    local raw_response=""
    local attempt
    for attempt in $(seq 1 "$max_attempts"); do
        if [ "$attempt" -gt 1 ]; then
            print_retry_message "$attempt" "$max_attempts"
        fi

        # Create a debug log file to capture the raw response
        local debug_log="llm-response-debug-$(date +%s).log"
        if [ "${DEBUG_CURL:-}" = "1" ]; then
            echo "Attempting API call (attempt $attempt/$max_attempts)" > "$debug_log"
            echo "Payload: $json_payload" >> "$debug_log"
        fi

        if raw_response=$(curl "${curl_opts[@]}" \
            "${LLM_API_BASE}/chat/completions" \
            -H "Authorization: Bearer ${LLM_TOKEN}" \
            -H "Content-Type: application/json" \
            -d "$json_payload" 2>&1); then
            
            # Log response if debug is enabled
            if [ "${DEBUG_CURL:-}" = "1" ]; then
                echo "Raw response: $raw_response" >> "$debug_log"
            fi
            break
        else
            # If curl failed, show error
            printf "\r%${COLUMNS}s\r" ""
            printf "        ${RED:-}↳ API call failed: %s${RESET:-}\n" "$raw_response"
            
            if [ "${DEBUG_CURL:-}" = "1" ]; then
                echo "API call failed: $raw_response" >> "$debug_log"
            fi
            
            if [ "$attempt" -lt "$max_attempts" ]; then
                sleep "$sleep_between"
            fi
        fi
    done

    # Debug the raw response
    if [ "${DEBUG_CURL:-}" = "1" ]; then
        echo "Attempting to extract content from: $raw_response" >> "$debug_log"
    fi

    local assistant_text
    assistant_text=$(echo "$raw_response" | jq -r '.choices[0].message.content' 2>/dev/null || echo "")
    
    if [ "${DEBUG_CURL:-}" = "1" ]; then
        echo "Extracted content: $assistant_text" >> "$debug_log"
    fi
    
    echo "$assistant_text"
}

# Validated LLM API call with retry on null/empty responses
# Args:
#   $1 - prompt text
call_llm_api_with_validation() {
    local prompt="$1"
    local max_validation_attempts=3
    local validation_sleep=2
    
    local attempt=1
    while [ $attempt -le $max_validation_attempts ]; do
        local response
        response=$(call_llm_api "$prompt")
        
        if [ "$response" = "null" ] || [ -z "$response" ]; then
            if [ $attempt -lt $max_validation_attempts ]; then
                print_retry_message "$attempt" "$max_validation_attempts"
                sleep $validation_sleep
                attempt=$((attempt + 1))
                continue
            else
                return 1
            fi
        fi
        
        echo "$response"
        return 0
    done
}

# If this script is run directly, validate the environment
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    validate_llm_environment
fi

