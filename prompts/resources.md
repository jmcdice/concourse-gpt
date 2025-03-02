Generate comprehensive markdown documentation for this Concourse resource as it's used in this specific pipeline.

FORMAT REQUIREMENTS:
- Start with H1 heading 'Concourse Resource Documentation: [ResourceName]'
- Follow with H2 'Overview' section describing how this specific resource is used in this pipeline
- Include H2 'Configuration Analysis' that explains:
  * What this specific resource is connecting to (repository, registry, etc.)
  * The specific configuration parameters used and their actual values or variables
  * How this resource is configured for this particular pipeline's needs
- Include H2 'Pipeline Integration' explaining:
  * Which jobs in this pipeline use this resource and how
  * How this resource interacts with other resources in this pipeline
  * The data/artifacts this resource provides to or receives from the pipeline
- If applicable, add H2 'Maintenance Notes' with information about:
  * How to update credentials or configuration for this resource
  * Pipeline-specific troubleshooting for this resource

WRITING STYLE:
- Write as if documenting an existing implementation, not a theoretical usage
- Use statements like 'This resource is used to...' rather than 'This resource can be used to...'
- Reference actual pipeline-specific details wherever possible
- Be thorough but avoid unnecessary repetition
- Do NOT refer to this document as AI-generated
- Do NOT use phrases like 'the provided resource' or 'you asked me to'

RESOURCE DEFINITION:
${resource_def}