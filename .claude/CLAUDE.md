# Influe — Monorepo Overview

This repo contains three sub-projects:
- `backend/` — Node.js + Express + MongoDB REST API
- `gold/` — Flutter user-facing app (GetX)
- `gold_admin/` — Flutter admin app (GetX)

Each sub-project has its own `CLAUDE.md` with specific instructions.
Read the relevant one before working on that project.

---

## Repo Structure

```
influe/
├── backend/          # Node.js API (ES Modules)
├── gold/             # Flutter user app
├── gold_admin/       # Flutter admin app
└── .claude/          # Claude config (this folder)
```

## General Rules

- Never commit `.env` files or Firebase service account JSON files
- `influnexa-5bb97-firebase-adminsdk-fbsvc-*.json` is a secret — never touch or expose it
- Keep backend and Flutter changes in separate commits
- ESM (`import`/`export`) is used in backend — never use `require()`
