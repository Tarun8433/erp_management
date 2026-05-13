---
description: Security rules for the entire project. Non-negotiable — always apply. Never suggest code that violates these rules.
---

# Security Rules

## Secrets & Credentials — NEVER do this
- Never hardcode secrets, API keys, tokens, or credentials in any file
- Never commit `.env` files — they must be in `.gitignore`
- The Firebase service account JSON (`influnexa-5bb97-firebase-adminsdk-fbsvc-*.json`) must never be committed to git — it is a private key
- Never use a hardcoded fallback for production secrets:
  ```js
  // WRONG — 'secret' is predictable and gets committed
  secret: process.env.SESSION_SECRET || 'secret'
  
  // RIGHT — fail loudly if the env var is missing
  secret: process.env.SESSION_SECRET
  ```
- Never log `req.headers`, tokens, passwords, or any PII — remove `console.log('Auth Middleware Headers:', req.headers)` from auth middleware

## Authentication
- Every route that accesses or mutates user data must have the `protect` middleware
- Every admin route must have both `protect` AND `admin` middleware — never just one
- JWT secret must come from `process.env.JWT_SECRET` only — no `config` package fallback in production
- Always use `.select('-password')` when returning User documents — without exception
- Never store plain-text passwords — the `User` model pre-save hook handles hashing; never call `bcrypt` manually in controllers

## Authorization (Ownership Checks)
- Before modifying a resource, verify the authenticated user owns it:
  ```js
  if (resource.user.toString() !== req.user._id.toString()) {
    return res.status(403).json({ message: 'Not authorized' });
  }
  ```
- Never use `==` for ObjectId comparison — always `.toString()` on both sides
- Admin flag (`req.user.isAdmin`) is loaded from DB via `protect` middleware — never from the JWT payload directly

## Input Validation & Injection
- `express-mongo-sanitize` is currently disabled — Zod schemas are the only defense against MongoDB injection
- Every Zod schema must reject objects where strings are expected — use `z.string()` not `z.any()` for user-supplied fields
- Never pass `req.body`, `req.query`, or `req.params` directly into a Mongoose query without validation
- Never use `$where` or JavaScript evaluation in Mongoose queries
- Validate MongoDB ObjectIds before querying: `mongoose.Types.ObjectId.isValid(id)`

## CORS
- Current `cors()` config is open to all origins — acceptable in development only
- Before production: restrict to the specific origins of the Flutter apps and admin panel
- Never re-open CORS to `*` in production

## File Uploads
- File type is checked by MIME type in `middleware/upload.js` — do not bypass this check
- Never serve uploaded files that could be executed (`.html`, `.php`, `.js`) — restrict to images, video, and specific document types
- Uploaded file paths must never be constructed from user input (path traversal risk)
- Upload endpoints must be behind `protect` middleware — unauthenticated uploads waste storage

## Sensitive Data in Responses
Never include these fields in API responses unless explicitly required and the requester is the owner or admin:
- `password` (always excluded)
- `fcmToken` (device-specific, private)
- `paymentSettings.trustScore`, `paymentSettings.creditLimit` (admin-only fields)
- `walletBalance` (owner only)
- Internal Mongoose fields (`__v`)

## Error Handling
- Never return `error.message` or stack traces to the client in 500 responses:
  ```js
  // WRONG
  res.status(500).json({ message: error.message });
  
  // RIGHT
  console.error(error);
  res.status(500).json({ message: 'Server error' });
  ```
- Log errors server-side with `console.error(error)` — not `console.log`

## Flutter App Security
- Never hardcode backend URLs, API keys, or admin credentials in Dart files
- Token is stored in `shared_preferences` via `StorageManager` — never store it in a `print()` or log statement
- Always handle 401 responses globally — clear stored token and redirect to login
- Use `if (kDebugMode)` guard on any debug-only logging
- The admin app (`gold_admin/`) must never be published to the public App Store or Play Store

## Socket.io
- Socket connections must be authenticated — validate JWT on connection
- Users must only be able to join their own rooms/channels
- Chat message content must be sanitized before broadcast

## What to do when you find a violation
Flag it immediately with `[SECURITY]` prefix in your response, explain the risk, and provide the fix before continuing with any other work.
