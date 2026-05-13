Review the file or code passed as argument, or the currently open/edited file if no argument is given: $ARGUMENTS

Use the `code-reviewer` agent from `.claude/agents/code-reviewer.md` to perform this review.

Follow the full checklist in that agent for whichever layer is relevant:
- If it's a `.dart` file → apply the Flutter/GetX checklist
- If it's a `.js` file in `backend/` → apply the Node.js/Mongoose/Express checklist
- If both are touched → review both

Structure the output exactly as the agent specifies:
## Review: [filename]

### Critical
### Warning  
### Suggestion
### Approved ✓

Be specific — cite line numbers. Do not invent issues. If the code is clean, say so clearly.

After the review, answer: "Is this safe to commit?" with a one-line YES / NO / YES (after fixing X).
