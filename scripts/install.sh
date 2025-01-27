#!/usr/bin/env bash

set -euo pipefail

###############################################################################
# ConcourseGPT Installation Script
###############################################################################

# Determine script location
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

# Text formatting
CYAN=$'\e[36m'
GREEN=$'\e[32m'
RED=$'\e[31m'
YELLOW=$'\e[33m'
BOLD=$'\e[1m'
RESET=$'\e[0m'

print_step() {
    printf "\n${BOLD}$1${RESET}\n"
}

print_success() {
    printf "${GREEN}✓ %s${RESET}\n" "$1"
}

print_error() {
    printf "${RED}✗ %s${RESET}\n" "$1" >&2
}

print_warning() {
    printf "${YELLOW}! %s${RESET}\n" "$1"
}

# Check for required commands
check_requirements() {
    print_step "Checking requirements..."
    
    local missing_cmds=()
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
        print_error "Missing required commands: ${missing_cmds[*]}"
        cat <<EOF

Please install the missing requirements:

On macOS:
    brew install jq yq python3

On Ubuntu/Debian:
    sudo apt update
    sudo apt install curl jq python3 python3-pip
    pip install yq

On RHEL/CentOS:
    sudo yum install epel-release
    sudo yum install curl jq python3 python3-pip
    pip install yq
EOF
        exit 1
    fi
    
    print_success "All required commands are available"
}

# Install Python dependencies
install_python_deps() {
    print_step "Installing Python dependencies..."
    
    if pip install --upgrade mkdocs mkdocs-material >/dev/null 2>&1; then
        print_success "Installed MkDocs and Material theme"
    else
        print_error "Failed to install Python dependencies"
        exit 1
    fi
}

# Create env.sh template if it doesn't exist
create_env_template() {
    print_step "Creating environment template..."
    
    if [ ! -f "${PROJECT_ROOT}/env.sh" ]; then
        cat <<EOF > "${PROJECT_ROOT}/env.sh"
# ConcourseGPT Environment Configuration
# Copy this file to env.sh and update with your values

# LLM API Configuration
export LLM_API_BASE="your-llm-api-endpoint"
export LLM_MODEL="your-model-name"
export VLLM_TOKEN="your-api-token"

# Optional Settings
#export DEBUG_CURL=1  # Enable for verbose API output
EOF
        print_success "Created env.sh template"
        print_warning "Remember to update env.sh with your API credentials"
    else
        print_warning "env.sh already exists, skipping"
    fi
}

# Add executable permissions
set_permissions() {
    print_step "Setting executable permissions..."
    
    chmod +x "${PROJECT_ROOT}/bin/concourse-gpt"
    print_success "Made concourse-gpt executable"
}

# Main installation
main() {
    echo "${BOLD}Installing ConcourseGPT...${RESET}"
    
    check_requirements
    install_python_deps
    create_env_template
    set_permissions
    
    echo
    print_success "Installation complete!"
    echo
    cat <<EOF
${BOLD}Next Steps:${RESET}
1. Update ${CYAN}env.sh${RESET} with your API credentials
2. Source your environment: ${CYAN}source env.sh${RESET}
3. Run your first documentation: ${CYAN}bin/concourse-gpt generate pipeline.yml${RESET}

For more information, see: ${CYAN}project-docs/getting-started.md${RESET}
EOF
}

main "$@"
