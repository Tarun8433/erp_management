# Security Review — Detailed Guide

Full checklist for deep security audits. Use this alongside the main SKILL.md.

## OWASP Top 10 — Applied to This Stack

### A01 Broken Access Control
- [ ] Every mutation endpoint checks: is the user authenticated (`protect`) AND do they own this resource?
- [ ] Admin endpoints have both `protect` + `admin` middleware — not just one
- [ ] `req.user` is never trusted from the JWT payload for role checks — it comes from a fresh DB lookup in `protect`
- [ ] Can user A read user B's orders, cart, addresses, or chat messages?
- [ ] Are there any endpoints returning all documents without a user filter?

### A02 Cryptographic Failures
- [ ] Passwords hashed with bcrypt (salt rounds: 10) — handled in `User` pre-save hook
- [ ] JWT signed with `process.env.JWT_SECRET` — no hardcoded fallback
- [ ] `SESSION_SECRET` not the default `'secret'` string
- [ ] No sensitive data (passwords, tokens) in logs or error responses
- [ ] HTTPS enforced in production (`cookie.secure: true` requires `NODE_ENV=production`)

### A03 Injection
- [ ] `express-mongo-sanitize` is disabled — Zod schemas must reject objects where strings are expected
- [ ] No raw user input passed to `find()`, `findOne()`, `$match` without Zod validation
- [ ] Aggregation pipelines using user-supplied values have input sanitization
- [ ] No `$where` or `eval` in any Mongoose query

### A04 Insecure Design
- [ ] Rate limiting on login, register, OTP, and password reset endpoints?
- [ ] Brute force protection on login (lockout after N failures)?
- [ ] Email/phone enumeration possible? ("Email already registered" vs generic "Invalid credentials")
- [ ] Duplicate payment prevention (idempotency key or order status check)?

### A05 Security Misconfiguration
- [ ] `NODE_ENV=production` set in production
- [ ] Error responses not leaking stack traces
- [ ] CORS restricted to known origins (not `*`)
- [ ] Firebase service account JSON not in git
- [ ] `.env` in `.gitignore`
- [ ] `console.log('Auth Middleware Headers:', req.headers)` removed

### A06 Vulnerable and Outdated Components
- [ ] `npm audit` run — no high/critical vulnerabilities
- [ ] `flutter pub audit` run

### A07 Identification and Authentication Failures
- [ ] JWT expiry is set (not forever)
- [ ] Logout invalidates the FCM token (unregisters from push notifications)
- [ ] Password change invalidates existing JWT sessions

### A08 Software and Data Integrity
- [ ] Uploaded files validated both client-side and server-side
- [ ] Payment amounts re-calculated server-side, never from client payload

### A09 Security Logging and Monitoring
- [ ] Auth failures logged server-side (not just returned to client)
- [ ] Admin actions logged (ban, delete, refund)
- [ ] No sensitive data (passwords, tokens) in logs

### A10 Server-Side Request Forgery
- [ ] Any URL-fetching from user input? Validate against allowlist.

---

## Flutter-Specific Checks

### Token Storage
- Token stored via `StorageManager` in `shared_preferences` — acceptable for mobile
- Token never in `print()`, `log()`, or Crashlytics logs
- Token cleared on logout AND on 401 response

### Build Security
- `kDebugMode` guard on all debug logging
- No secrets in `pubspec.yaml`, `AndroidManifest.xml`, `Info.plist`
- `firebase_options.dart` contains Firebase config (public, acceptable) — but NOT the Admin SDK key
- Admin app (`gold_admin/`) distributed via internal channel only

### Network
- All API calls over HTTPS in production
- 401 handled globally — `StorageManager.clearAll()` + `Get.offAllNamed(RoutesName.login)`
- Certificate pinning recommended for payment flows (not currently implemented — flag if adding payment screens)

---

## Quick Reference — Sensitive Fields Never to Expose

| Field | Model | Rule |
|---|---|---|
| `password` | User | Always `.select('-password')` |
| `fcmToken` | User | Owner only |
| `walletBalance` | User | Owner or admin only |
| `paymentSettings` | User | Admin only |
| `trustScore` | User.paymentSettings | Admin only |
| `creditLimit` | User.paymentSettings | Admin only |
| `__v` | All | Always `.select('-__v')` |
