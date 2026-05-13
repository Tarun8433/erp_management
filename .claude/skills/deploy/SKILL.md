---
name: deploy
description: >
  Auto-invoke this skill when the user mentions: deploying, releasing, going to production,
  building a release APK/IPA, publishing the app, pushing to server, or asks about
  production readiness. Also trigger on phrases like "ready to ship", "push to prod",
  "build for release", "submit to App Store / Play Store".
---

# Deploy Skill

You are a deployment engineer for this project. When triggered, your job is to ensure nothing broken, insecure, or misconfigured ships to production.

## Projects in This Repo

| Target | Type | Command |
|---|---|---|
| `backend/` | Node.js API server | `npm start` (NOT `npm run dev`) |
| `gold/` | Flutter user app | `flutter build apk --release` / `flutter build ios` |
| `gold_admin/` | Flutter admin app | `flutter build apk --release` (internal only) |

## Before Any Deploy — Run This Mental Checklist

### Backend
1. Is `NODE_ENV=production` set on the server?
2. Is `SESSION_SECRET` a real secret (not the default `'secret'` fallback)?
3. Is CORS restricted to known origins (not open `*`)?
4. Is `express-mongo-sanitize` re-enabled or a Zod-based mitigation in place?
5. Is `console.log('Auth Middleware Headers:', req.headers)` removed from auth middleware?
6. Are there any `console.log` statements left that could expose tokens or PII?
7. Is the Firebase service account JSON NOT committed to git?
8. Is the `.env` file NOT in git?
9. Is the server using `npm start` (node), not `npm run dev` (nodemon)?
10. Does `npm run dev` start clean with no errors locally?

### Flutter (`gold/`)
1. Does `flutter analyze` pass with zero errors?
2. Is the API base URL pointing to production (not `localhost` or a dev IP)?
3. Are all `print()` calls removed or guarded with `if (kDebugMode)`?
4. Does `flutter build apk --release` complete without errors?
5. Is the Firebase project the production one (check `firebase_options.dart`)?
6. Is the app signing config set up for release?

### Flutter Admin (`gold_admin/`)
Same as `gold/` PLUS:
- Is distribution set to internal only (Firebase App Distribution / TestFlight internal)?
- Is the app NOT submitted to the public App Store or Play Store?

## Release Notes

When preparing a release, use the template at `templates/release-notes.md`.

Fill in:
- Version number (update `pubspec.yaml` version for Flutter, package.json version for backend)
- List of changes since the last release
- Any breaking changes or migration steps
- Known issues

## Common Deploy Mistakes in This Project

- Forgetting to change the API base URL from `http://localhost:5000` to the production URL
- Pushing with `npm run dev` still running — use `npm start` in production
- Leaving the `console.log` header leak in auth middleware
- Building the admin APK and accidentally uploading it to a public channel
- Missing `NODE_ENV=production` causes `cookie.secure` to be false, breaking secure cookies
