# Getting Started with ConcourseGPT

This guide will help you get up and running with ConcourseGPT quickly.

## Prerequisites

Before installing ConcourseGPT, ensure you have:

- Bash 4.0 or higher
- Python 3.7 or higher
- curl
- yq command line tool
- Access to an LLM API endpoint

### Installing Prerequisites

#### macOS
```bash
# Using Homebrew
brew install python3 yq
```

#### Ubuntu/Debian
```bash
# Update package list
sudo apt update

# Install dependencies
sudo apt install python3 curl
pip install yq
```

#### RHEL/CentOS
```bash
# Install EPEL repository
sudo yum install epel-release

# Install dependencies
sudo yum install python3 curl
pip install yq
```

## Installation

1. Clone the repository:
```bash
git clone https://github.com/jmcdice/concourse-gpt.git
cd concourse-gpt
```

2. Setup python virtual env
```bash
python3 -m venv .venv
source .venv/bin/activate
```

3. (Optional) Add to your PATH:
```bash
# Add to your ~/.bashrc or ~/.zshrc
export PATH="$PATH:/path/to/concourse-gpt/bin"
```

## Configuration

ConcourseGPT requires access to an LLM API. Configure your environment with:

```bash
export LLM_API_BASE="your-llm-api-endpoint"
export LLM_MODEL="your-model-name"
export LLM_TOKEN="your-api-token"
```

Add these to your shell's rc file (e.g., ~/.bashrc or ~/.zshrc) to make them permanent.

## First Steps

1. Generate documentation for a pipeline:
```bash
concourse-gpt generate path/to/pipeline.yml
```

2. Generate an overview README for all documented pipelines:
```bash
concourse-gpt gen-readme
```

3. Build and view the documentation site:
```bash
concourse-gpt build-site
concourse-gpt serve
```

Your documentation will be available at http://127.0.0.1:8000

## Next Steps

- Read the [Usage Guide](usage.md) for detailed instructions
- Check out the [Examples](examples.md) to see sample outputs
- Learn about [Configuration](configuration.md) options
