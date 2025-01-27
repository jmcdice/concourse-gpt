# ConcourseGPT

AI-powered documentation generator for Concourse pipelines.

## Overview

ConcourseGPT automatically generates comprehensive documentation for Concourse CI pipelines using AI. It analyzes your pipeline YAML files and produces detailed markdown documentation explaining:

- Pipeline architecture and purpose
- Individual jobs and their functions
- Resource configurations
- Pipeline groups and their relationships

The generated documentation is organized into a searchable static site using MkDocs with the Material theme.

## Features

- **Intelligent Pipeline Analysis**: Automatically understands and documents pipeline architecture and patterns
- **Comprehensive Coverage**: Documents all pipeline components including jobs, resources, and groups
- **Large Pipeline Support**: Handles large pipelines through intelligent chunking
- **Beautiful Documentation**: Generates a modern, searchable static site with dark/light mode
- **Progress Tracking**: Real-time progress display with error handling and retries
- **Markdown-Based**: All documentation in Markdown format for easy version control and editing

## Documentation

- [Getting Started](project-docs/getting-started.md) - Quick start guide and installation
- [Usage Guide](project-docs/usage.md) - Detailed usage instructions and examples
- [Configuration](project-docs/configuration.md) - Environment setup and customization
- [Examples](project-docs/examples.md) - Example pipelines and generated documentation

## Quick Start

1. Set up environment variables:
```bash
export LLM_API_BASE="your-llm-api-endpoint"
export LLM_MODEL="your-model-name"
export VLLM_TOKEN="your-api-token"
```

2. Run documentation generation:
```bash
concourse-gpt generate path/to/pipeline.yml
```

3. Build the documentation site:
```bash
concourse-gpt build-site
```

4. View your documentation:
```bash
concourse-gpt serve
```

## Command Reference

```bash
# Generate docs for a pipeline
concourse-gpt generate pipeline.yml

# Generate overview README of all documented pipelines
concourse-gpt gen-readme

# Build static documentation site
concourse-gpt build-site

# Serve documentation locally
concourse-gpt serve
```

## Requirements

- Bash 4.0+
- Python 3.7+ (for MkDocs)
- Access to an LLM API endpoint
- yq command line tool
- curl

## Installation

```bash
git clone https://github.com/jmcdice/concourse-gpt.git
cd concourse-gpt
./scripts/install.sh
```

## Implementation Note

ConcourseGPT is intentionally written in Bash. Since Concourse pipeline authors regularly work with shell scripts and Bash-based tasks, this makes the codebase immediately accessible to the Concourse community. While other languages might offer different advantages, Bash keeps the barrier to entry low and aligns with the daily tools and skills of Concourse users.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

[MIT License](LICENSE)
