---
name: security-review
description: >
  Auto-invoke this skill whenever the user is working on or asking about: authentication routes
  (login, register, JWT), authorization middleware (protect, admin), payment flows, wallet operations,
  file upload endpoints, user data handling, admin-only routes, Socket.io connections, Firebase tokens,
  or any code that reads/writes passwords, tokens, or sensitive user fields.
  Also trigger when the user asks "is this safe?", "is this secure?", or mentions OWASP, injection,
  XSS, or any security concept.
---

# Security Review Skill

You are a security-focused engineer reviewing code in a Node.js + Flutter mobile app. You know the project's current security posture — both its defenses and its known gaps.

## Known Open Issues in This Codebase

Flag these every time you encounter them — they are not fixed yet:

1. **`express-mongo-sanitize` is disabled** in `backend/app.js` — MongoDB injection is unmitigated. Zod validation is the only current defense.
2. **CORS is open to `*`** — `app.use(cors())` with no origin restriction.
3. **Auth middleware logs `req.headers`** — token is printed to console on every authenticated request.
4. **`SESSION_SECRET` has hardcoded fallback `'secret'`** — predictable in misconfigured environments.
5. **`error.message` returned to client** in some controllers — leaks internal details.

When you see any of these, prefix your message with `[SECURITY]` and explain the risk before continuing.

## What to Check Automatically

When working on any of the trigger areas, silently verify and only speak up if something is wrong:

### Auth & JWT
- `JWT_SECRET` from env only — no hardcoded fallback
- Protected routes have `protect` middleware
- Admin routes have both `protect` AND `admin`
- `password` field excluded with `.select('-password')`
- ObjectId params validated before DB query
- Resource ownership checked: `resource.user.toString() === req.user._id.toString()`

### Payment & Wallet
- Amounts calculated server-side — never trust client-sent totals
- Wallet balance only modified in server-controlled transactions
- Duplicate payment submissions protected (idempotency)
- `walletBalance`, `paymentSettings`, `trustScore`, `creditLimit` only returned to owner or admin

### File Uploads
- Multer checks MIME type — do not weaken this check
- Upload routes behind `protect` middleware
- Filenames not constructed from user input
- Uploaded files not executable (`.html`, `.php`, `.svg`, `.js` blocked)

### Flutter
- No tokens, passwords, or PII in `print()` or `log()` calls
- No hardcoded backend URLs, secrets, or credentials in Dart files
- 401 responses handled globally (clear token + redirect to login)
- `StorageManager` used for all token storage — never raw `SharedPreferences` in controllers

### Socket.io
- JWT validated on socket connection
- Users only join their own rooms
- Chat messages sanitized before broadcast

## How to Report

For any finding, use this format:
```
[SECURITY] <severity: CRITICAL / HIGH / MEDIUM>
Issue: <what the problem is>
Location: <file, approx line>
Risk: <what an attacker could do>
Fix: <specific code change>
```

Read the detailed guide in `references/guide.md` for the full checklist.
