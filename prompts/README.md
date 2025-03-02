# ConcourseGPT Prompt Templates

This directory contains prompt templates used by ConcourseGPT to generate documentation for Concourse pipelines. 

## Prompt Files

- `groups.md` - Template for documenting pipeline groups
- `jobs.md` - Template for documenting pipeline jobs
- `pipeline-small.md` - Template for documenting small pipelines (single prompt)
- `pipeline-chunk.md` - Template for processing chunks of large pipelines
- `pipeline-unify.md` - Template for combining pipeline chunk summaries
- `resources.md` - Template for documenting pipeline resources
- `root-readme.md` - Template for generating root README for all pipelines

## Variable Placeholders

Prompts use placeholders like `${group_def}` or `${pipeline_data}` that get replaced with actual content at runtime.
