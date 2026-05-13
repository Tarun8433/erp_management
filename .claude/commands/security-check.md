Run a security audit on: $ARGUMENTS

Use the `security-auditor` agent from `.claude/agents/security-auditor.md`.

Read the specified file(s) carefully, then work through the relevant section of the security checklist:
- Backend file → check auth, authorization, injection, data exposure, input validation
- Flutter file → check hardcoded secrets, token storage, API error handling, debug logs
- Route file → check every endpoint for missing `protect`/`admin` middleware, ownership checks
- Model file → check for sensitive fields that could be accidentally exposed

Always check these regardless of file type:
- Are there any `console.log` lines that could expose tokens, passwords, or headers?
- Are there any hardcoded secrets, credentials, or private URLs?
- Is user input used in a DB query without validation?

Report format:
## Security Audit: [filename]
### CRITICAL / HIGH / MEDIUM / LOW findings
### Mitigations Already Present ✓

End with a one-line verdict: SAFE TO SHIP / NEEDS FIXES BEFORE SHIP / CRITICAL — DO NOT SHIP
