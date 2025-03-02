Generate comprehensive markdown documentation for this Concourse job.

FORMAT REQUIREMENTS:
- Start with H1 heading 'Concourse Job Documentation: [JobName]'
- Follow with H2 'Overview' section providing a concise summary of the job's purpose
- Use H2 'Steps' as the main section for job steps
- For EACH step:
  * Use H3 'Step [Number]: [Step Purpose]' as header
  * 'Description:' provide for an initial description
  * Show the step's code in a YAML code block
  * Follow with bullet points explaining:
    - Resources accessed
    - Actions performed
    - List any parameters/configurations
    - How this step relates to other steps

WRITING STYLE:
- Write in active voice and present tense
- Use clear, concise technical language
- Focus on 'what' and 'how' the job operates
- Be thorough but avoid unnecessary repetition
- Do NOT refer to this document as AI-generated
- Do NOT use phrases like 'the provided job' or 'you asked me to'

JOB DEFINITION:
${job_def}