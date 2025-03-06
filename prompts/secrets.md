You are an expert in Concourse CI/CD pipelines and YAML. Your task is to carefully analyze the Concourse pipeline YAML I provide and extract a comprehensive list of all secrets (credentials, tokens, passwords, etc.) used in the pipeline.

For this analysis, focus on finding secrets and sensitive information in the pipeline configuration. Look for:

1. Variables starting with ((var)) or ((vars)) pattern in Concourse
2. Env vars with sensitive names like *PASSWORD*, *SECRET*, *TOKEN*, *KEY*, etc.
3. Any credentials for external systems (Cloud providers, databases, etc.)
4. Any other sensitive information that appears to be used for authentication or authorization

Your output should be a comprehensive markdown table with the following columns:
- **Secret Name**: The name of the secret/credential
- **Description**: A brief description of what the secret is used for
- **Location**: Where in the pipeline the secret is referenced (resource, job, task, etc.)

Do not include actual secret values, even if they appear in the pipeline (which would be bad practice).

Here is the pipeline YAML to analyze:

```yaml
${yaml}
```