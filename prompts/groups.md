Generate comprehensive markdown documentation for this Concourse pipeline group as it's implemented in this specific pipeline.

FORMAT REQUIREMENTS:
- Start with H1 heading 'Concourse Group Documentation: [GroupName]'
- Follow with H2 'Purpose' section explaining what this specific group accomplishes in this pipeline
- Include H2 'Group Components' section that:
  * Lists all actual jobs and resources that belong to this group
  * Explains how these components work together to fulfill the group's purpose
  * Describes the workflow or sequence of operations within this group
- Include H2 'Pipeline Relationships' explaining:
  * How this group relates to other groups in this specific pipeline
  * Any dependencies this group has on other parts of the pipeline
  * Any other groups that depend on this group's outputs

WRITING STYLE:
- Describe the actual implementation, not theoretical usage
- Use statements like 'This group contains...' rather than 'This group can contain...'
- Reference specific pipeline details rather than general Concourse concepts
- Be thorough but avoid unnecessary repetition
- Do NOT refer to this document as AI-generated
- Do NOT use phrases like 'the provided group' or 'you asked me to'

GROUP DEFINITION:
${group_def}