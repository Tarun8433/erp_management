Run the pre-deploy checklist for: $ARGUMENTS
(valid values: "backend", "gold", "gold_admin", "all")

Work through each section below for the specified target. Check each item. Flag anything that is NOT confirmed safe as a blocker before deploying.

---

## Backend Deploy Checklist (`backend/`)

### Environment & Config
- [ ] `.env` file exists on the server with all required variables: `PORT`, `MONGO_URI`, `JWT_SECRET`, `JWT_EXPIRES_IN`, `SESSION_SECRET`, Firebase config vars
- [ ] `SESSION_SECRET` is NOT the default hardcoded `'secret'` fallback in `app.js`
- [ ] `NODE_ENV=production` is set
- [ ] Firebase service account JSON is NOT committed to git

### Security
- [ ] `cors()` in `app.js` is restricted to allowed origins (not open to `*`)
- [ ] `express-mongo-sanitize` is re-enabled OR Zod schemas are rejecting object-type inputs on all routes
- [ ] Auth middleware `console.log('Auth Middleware Headers:', req.headers)` line is removed
- [ ] No other `console.log` statements that could expose tokens, passwords, or user data

### Code Quality
- [ ] All `console.log` debug statements removed or guarded by `process.env.NODE_ENV !== 'production'`
- [ ] No hardcoded MongoDB URIs, secrets, or IPs in any file
- [ ] `npm run dev` (nodemon) is NOT used in production — use `npm start`

### Database
- [ ] Required indexes exist on commonly queried fields
- [ ] No pending schema migrations that would break existing documents
- [ ] DB connection string points to production MongoDB, not local/dev

### Final
- [ ] Test the `/` root endpoint returns `API Running`
- [ ] Test one authenticated route with a valid JWT
- [ ] Test one admin route to confirm the `admin` middleware is working

---

## Flutter User App Deploy Checklist (`gold/`)

### Environment
- [ ] API base URL in `core/network/` points to production backend, not `localhost`
- [ ] No `http://` URLs (only `https://` in production)
- [ ] `firebase_options.dart` is using production Firebase project

### Build
```bash
flutter clean
flutter pub get
flutter build apk --release           # Android
flutter build ios --release           # iOS (requires Mac + Xcode)
```
- [ ] Build completes without errors
- [ ] No `flutter analyze` errors (run before build)

### Code Quality
- [ ] No `print()` or `debugPrint()` calls that expose tokens, user data, or PII
- [ ] No hardcoded test credentials or admin tokens in Dart files

### Testing
- [ ] Login flow works end-to-end with production backend
- [ ] Push notifications received (FCM token registered)
- [ ] Payment flow tested in staging before production

---

## Flutter Admin App Deploy Checklist (`gold_admin/`)

Same as `gold/` checklist PLUS:
- [ ] Admin app has a separate signing config from the user app
- [ ] Admin app is distributed via internal channel only (TestFlight internal / Firebase App Distribution) — NOT published to public app stores
- [ ] Role guard verified: non-admin JWT is rejected and redirected to login

---

After completing the checklist, summarize:
- ✅ Items confirmed safe
- ❌ Blockers that must be fixed before deploying
- ⚠️ Warnings that are acceptable for now but should be tracked
