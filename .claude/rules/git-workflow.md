---
description: Git commit and branching rules for this project. Apply when committing, branching, or reviewing changes.
---

# Git Workflow

## Branches
- `main` — production-ready code only. Never push directly.
- `dev` — integration branch. Merge features here first.
- `feature/<short-description>` — new features: `feature/wallet-topup`
- `fix/<short-description>` — bug fixes: `fix/cart-total-calculation`
- `chore/<short-description>` — config, deps, tooling: `chore/update-flutter-deps`

## Commit Messages
Follow Conventional Commits format:
```
<type>(<scope>): <short description>

[optional body]
```

Types:
- `feat` — new feature
- `fix` — bug fix
- `refactor` — code change that neither fixes a bug nor adds a feature
- `chore` — dependency updates, config, tooling
- `docs` — documentation only
- `style` — formatting, no logic change
- `test` — adding or fixing tests

Scopes (use the sub-project): `backend`, `gold`, `gold_admin`

Examples:
```
feat(backend): add pagination to products list endpoint
fix(gold): prevent infinite loading when auth fails
chore(backend): update mongoose to 9.2.0
feat(gold_admin): add user ban/unban action in user detail screen
```

## What NOT to commit
These files must be in `.gitignore`:
- `.env` (all variants)
- `*.json` Firebase service account files — especially `influnexa-5bb97-firebase-adminsdk-fbsvc-*.json`
- `node_modules/`
- `build/` (Flutter)
- `.dart_tool/`
- `*.local.md`, `settings.local.json` (Claude personal overrides)
- `ios/Pods/`, `android/.gradle/`

## Separating backend and Flutter changes
- Do not mix backend and Flutter changes in a single commit
- If a feature requires both (e.g., new API endpoint + Flutter screen), make two commits: `feat(backend): ...` then `feat(gold): ...`

## Before pushing
1. `flutter analyze` — zero errors in Flutter files
2. `npm run dev` starts without errors in backend
3. No `console.log` debug artifacts
4. No `.env` or service account JSON accidentally staged (`git status` check)