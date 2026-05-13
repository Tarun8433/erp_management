---
name: code-review-auto
description: >
  Auto-invoke this skill when the user shares code for feedback, pastes a diff, asks "is this right?",
  "does this look good?", "can you check this?", "what do you think of this?", or when the user
  just wrote a significant block of code and seems to be finishing up. Also trigger when the user
  asks about a specific implementation they just wrote — even if they don't explicitly ask for review.
---

# Automatic Code Review Skill

When triggered, silently check the code against the project rules. Only speak up if something is wrong or could be improved. Do not give a lengthy review if the code is correct — just say what's wrong and move on.

## Priority Order

Check in this order — stop and flag immediately at Critical, continue through the rest silently:

### 1. Critical — Flag immediately, block everything else
- Security violation (see `security.md` rules)
- Data loss risk (missing `await`, wrong destructive operation)
- Authentication bypass (missing `protect` or `admin` middleware)
- Sensitive field exposed in response (password, fcmToken, walletBalance without ownership check)

### 2. High — Flag after critical
- `isLoading.value = false` missing in error/finally branch (Flutter infinite spinner)
- `error.message` returned to client in 500 response (backend)
- Missing `.lean()` on a read-only Mongoose query
- `print()` or `console.log` that could expose tokens/PII
- Missing ownership check before mutation

### 3. Medium — Mention if the code is otherwise clean
- Missing `return` before early `res.json()` (could cause "headers already sent")
- `Image.network` instead of `CachedNetworkImage`
- `TextEditingController` not disposed in `onClose()`
- Missing `if (!mounted) return` after `await` with `BuildContext`
- Hard-coded hex colors or raw `TextStyle` values in Flutter

### 4. Low / Suggestion — Only if asked, or if nothing else to flag
- `const` constructor missing
- Opportunity to use `Promise.all` for parallel queries
- Naming inconsistency with project conventions

## Response Format

**If nothing is wrong:** One sentence — "Looks good." or "This follows the project conventions."

**If something is wrong:**
```
[CRITICAL/HIGH/MEDIUM] Short title
→ What: specific description
→ Fix: exact code change
```

Do not add a preamble. Do not summarize what the code does before reviewing it. Do not list things that are correct. Lead with the problem.
