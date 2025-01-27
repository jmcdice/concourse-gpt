# Usage Guide

This guide covers the detailed usage of ConcourseGPT's features and commands.

## Command Overview

ConcourseGPT provides four main commands:

```bash
concourse-gpt generate <pipeline.yml>    # Generate documentation for a pipeline
concourse-gpt gen-readme                 # Generate overview README
concourse-gpt build-site                 # Build documentation site
concourse-gpt serve                      # Serve documentation locally
```

## Generating Pipeline Documentation

The `generate` command analyzes a Concourse pipeline and creates comprehensive documentation:

```bash
concourse-gpt generate path/to/pipeline.yml
```

This will:
1. Create a directory structure under `docs/` named after your pipeline
2. Generate an overview of the pipeline's purpose and architecture
3. Document each job, resource, and group
4. Create navigation indices for each component type

### Output Structure

For a pipeline named "example-pipeline", the following structure is created:

```
docs/
└── example-pipeline/
    ├── index.md               # Pipeline overview
    ├── jobs/
    │   ├── index.md          # Jobs directory
    │   ├── job1.md           # Individual job documentation
    │   └── job2.md
    ├── resources/
    │   ├── index.md          # Resources directory
    │   ├── resource1.md      # Individual resource documentation
    │   └── resource2.md
    └── groups/
        ├── index.md          # Groups directory
        ├── group1.md         # Individual group documentation
        └── group2.md
```

### Large Pipeline Support

For pipelines exceeding 600 lines, ConcourseGPT automatically:
- Chunks the pipeline into manageable sections
- Analyzes each chunk separately
- Combines the analyses into a coherent overview

## Generating Overview Documentation

After documenting multiple pipelines, generate a root-level README:

```bash
concourse-gpt gen-readme
```

This creates `docs/README.md` containing:
- Overview of all documented pipelines
- Their relationships and purposes
- Navigation guidance

## Building the Documentation Site

Convert the markdown documentation into a searchable static site:

```bash
concourse-gpt build-site
```

This:
1. Installs MkDocs dependencies if needed
2. Generates mkdocs.yml configuration
3. Creates a Material theme-based site
4. Builds the static site in the `site/` directory

### Site Features
- Responsive design
- Dark/light mode toggle
- Full-text search
- Nested navigation
- Mobile-friendly

## Serving Documentation Locally

To view the documentation site:

```bash
concourse-gpt serve
```

This starts a local server at http://127.0.0.1:8000 with:
- Live reload for changes
- Search functionality
- Mobile-responsive design

## Best Practices

1. **Pipeline Organization**
   - Keep pipelines in a dedicated directory
   - Use consistent naming conventions
   - Maintain one pipeline per file

2. **Documentation Workflow**
   ```bash
   # Document each pipeline
   concourse-gpt generate pipeline1.yml
   concourse-gpt generate pipeline2.yml
   
   # Generate overview
   concourse-gpt gen-readme
   
   # Build and view
   concourse-gpt build-site
   concourse-gpt serve
   ```

3. **Version Control**
   - Commit generated documentation
   - Include `site/` in .gitignore
   - Version documentation with pipeline changes

## Troubleshooting

### Common Issues

1. **Missing Dependencies**
   ```bash
   # Check Python installation
   python3 --version
   
   # Install MkDocs dependencies
   pip install mkdocs mkdocs-material
   ```

2. **API Connection Issues**
   - Verify environment variables are set
   - Check API endpoint accessibility
   - Ensure token is valid

3. **Build Failures**
   - Ensure docs/ directory exists
   - Check file permissions
   - Verify mkdocs.yml syntax

For more details on configuration options, see the [Configuration Guide](configuration.md).
