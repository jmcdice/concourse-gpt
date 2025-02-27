# Examples

This guide provides examples of using ConcourseGPT with different types of pipelines and shows sample output. All examples are available in the [examples/](../examples/) directory.

This project came about from understanding pipelines can be broken down into pieces, like this:

Get a list of jobs/resources/groups:
```bash
yq '.jobs[].name' examples/advanced/multi-env.yml
```

For each job in jobs:
```bash
yq '.jobs[] | select(.name == "deploy-dev")' examples/advanced/multi-env.yml
```



## Basic Examples

### Hello World Pipeline
A simple pipeline demonstrating basic Concourse concepts:
- [examples/basic/hello-world.yml](../examples/basic/hello-world.yml)

```yaml
# Snippet from hello-world.yml
jobs:
- name: hello-world
  plan:
  - task: say-hello
    config:
      platform: linux
      image_resource:
        type: registry-image
        source: {repository: ubuntu}
      run:
        path: echo
        args: ["Hello, world!"]
```

Try it:
```bash
concourse-gpt generate examples/basic/hello-world.yml
```

## Intermediate Examples

### Backup Pipeline
Demonstrates backup automation with S3 integration:
- [examples/intermediate/backup.yml](../examples/intermediate/backup.yml)

### Test and Deploy Pipeline
Shows a complete CI/CD workflow:
- [examples/intermediate/test-deploy.yml](../examples/intermediate/test-deploy.yml)

## Advanced Examples

### BBR Backup Pipeline
A production-grade backup pipeline based on BOSH Backup and Restore:
- [examples/advanced/bbr-backup.yml](../examples/advanced/bbr-backup.yml)

### Multi-Environment Pipeline
Shows environment promotion patterns:
- [examples/advanced/multi-env.yml](../examples/advanced/multi-env.yml)

## Running the Examples

1. Generate documentation for any example:
```bash
concourse-gpt generate examples/basic/hello-world.yml
```

2. Generate documentation for multiple examples:
```bash
# Document all basic examples
for f in examples/basic/*.yml; do
  concourse-gpt generate "$f"
done
```

3. Build the complete site:
```bash
concourse-gpt gen-readme
concourse-gpt build-site
concourse-gpt serve
```

## Example Output

The documentation for each pipeline will be generated in `docs/` following this structure:

```
docs/
└── pipeline-name/
    ├── index.md         # Pipeline overview
    ├── jobs/            # Job documentation
    ├── resources/       # Resource documentation
    └── groups/          # Group documentation
```

Each section includes:
- Architectural overview
- Component relationships
- Best practices
- Configuration details

## Contributing Examples

Have a useful pipeline pattern? Contributions are welcome! Please:
1. Add your pipeline to the appropriate examples/ subdirectory
2. Ensure it follows our naming conventions
3. Test it with ConcourseGPT
4. Submit a pull request
