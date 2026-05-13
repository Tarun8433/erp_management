Fix the following issue: $ARGUMENTS

Use the `bug-hunter` agent from `.claude/agents/bug-hunter.md`.

Follow this process strictly — do NOT jump straight to a fix:

1. **Read the relevant file(s) first.** Identify the exact location of the problem.
2. **State your hypothesis** — what do you think is causing this and why?
3. **Verify** by checking the surrounding code and any related files.
4. **Propose and apply the minimal fix** — change only what's broken. Do not refactor unrelated code.
5. **Explain in one sentence** why the fix works.

If the issue is in the backend (`backend/`):
- Check if it's an async/await issue, Mongoose casting, missing middleware, or ESM import problem first — these are the most common causes in this codebase.

If the issue is in Flutter (`gold/` or `gold_admin/`):
- Check if it's a GetX controller lifecycle issue, `.obs` mutation pattern, missing `mounted` check, or binding not registered — these are the most common Flutter causes.

Report format:
## Bug Fix: [short title]
**Root Cause:** [explanation]
**Files changed:** [list]
**Fix:** [before/after code]
**Why it works:** [one sentence]
**Anything else to watch:** [related risks, if any]