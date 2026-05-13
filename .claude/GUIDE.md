# Claude Code — .claude Folder Guide

This guide explains everything set up in this project's `.claude/` folder, what each piece does,
and exactly how to use it day-to-day while working on the Influe backend + Flutter apps.

---

## The Big Picture — How Everything Fits Together

```
.claude/
├── CLAUDE.md          → Always loaded. Project overview Claude reads first.
├── CLAUDE.local.md    → Your personal notes (gitignored, never committed)
├── GUIDE.md           → This file
├── settings.json      → What Claude can do without asking (shared with team)
├── settings.local.json → Your personal permission overrides (gitignored)
├── rules/             → Always-on constraints. Claude follows these silently.
├── skills/            → Auto-trigger deep expertise. No invocation needed.
├── agents/            → Specialist workers you spin up for a task.
└── commands/          → /project:x slash commands — reusable prompt shortcuts.
```

Think of it this way:

| Layer | Analogy | When active |
|---|---|---|
| **Rules** | Standing orders | Every single response, always |
| **Skills** | Expert mode | Auto-triggers based on context |
| **Agents** | Specialist you hire | You ask for them explicitly |
| **Commands** | Saved macros | You type `/project:x` |
| **Settings** | Security guard | Before Claude runs any tool |

---

## Part 1 — Rules (Always On)

Rules live in `.claude/rules/`. Claude reads them at the start of every session and applies them
without you asking. You never invoke them — they just work.

### What rules are set up

| File | What it enforces |
|---|---|
| `code-style.md` | ESM imports, controller shape, Dart naming, no `print()`, trailing commas |
| `api-conventions.md` | URL patterns, HTTP status codes, response shape, mandatory pagination, `.lean()` |
| `security.md` | Secrets, ownership checks, what fields to never expose, error message rules |
| `error-handling.md` | try/catch shape, `finally` for `isLoading`, `mounted` check after `await` |
| `getx-patterns.md` | `.obs` mutation, `onClose()` disposal, `Binding` registration, `Obx` scope |
| `testing.md` | No DB mocking, test file locations, what to and not to test |
| `git-workflow.md` | Branch naming, commit message format, what never to commit |

### How to use rules in practice

**You don't do anything.** Just write code normally and Claude follows them.

Example — you write a controller without `.lean()`:
```js
const products = await Product.find({});  // you wrote this
```
Claude will silently add `.lean()` because `api-conventions.md` requires it — without you asking.

**When to update a rule:**
- You decide on a new convention (e.g., always use `dio` instead of `http`)
- You want to enforce something Claude keeps getting wrong
- A rule becomes outdated after refactoring

**How to update:** Open the rule file, edit it directly. It takes effect in the next session.

---

## Part 2 — Skills (Auto-Trigger Expertise)

Skills live in `.claude/skills/`. Each skill has a `SKILL.md` with a `description:` frontmatter
that tells Claude when to activate. When the context matches, the skill fires automatically.

### Skills set up in this project

| Skill | Auto-fires when... |
|---|---|
| `flutter-senior-engineer` | You work on any `.dart` file, mention GetX, pubspec, Flutter screens |
| `node-senior-engineer` | You work on any file in `backend/` — routes, controllers, models, middleware |
| `security-review` | You touch auth, payment, uploads, JWT, admin routes, user data |
| `deploy` | You mention "deploy", "release", "build APK", "push to prod", "going live" |
| `code-review-auto` | You paste code and ask "does this look good?" or "is this right?" |
| `firebase-expert` | You mention FCM, push notifications, `firebase_messaging`, Firebase tokens |
| `socket-expert` | You work on chat, Socket.io, real-time events, `socket_io_client` |

### How skills actually work

Skills are invisible. You don't type anything special. Example:

> You: "Add pagination to the orders controller"

Claude sees you're working on `backend/controllers/ordersController.js` →
`node-senior-engineer` skill fires → Claude writes code with the correct
Mongoose patterns, `.lean()`, `Promise.all`, pagination shape — without you asking for any of that.

> You: "Why are my push notifications not showing in foreground?"

`firebase-expert` skill fires → Claude gives you the exact answer
(you need `flutter_local_notifications` for foreground) with the code pattern for this project.

### When skills have reference files

Some skills have a `references/` subfolder with detailed patterns:
- `flutter-senior-engineer/references/patterns.md` — 13 production code patterns
- `node-senior-engineer/references/patterns.md` — Mongoose, Zod, Socket.io, JWT patterns
- `security-review/DETAILED_GUIDE.md` — OWASP Top 10 checklist for this stack

Claude reads these automatically when the skill is active. You never need to reference them yourself.

---

## Part 3 — Agents (Specialist Workers)

Agents live in `.claude/agents/`. Unlike skills, you explicitly ask for them.
Each agent is a specialist persona that Claude adopts for a specific task.

### Agents available

| Agent | Best for |
|---|---|
| `code-reviewer` | "Review this file before I commit" |
| `security-auditor` | "Audit this auth flow / payment endpoint" |
| `flutter-feature-builder` | "Build me a new screen in gold/" |
| `api-builder` | "Add a new backend endpoint for X" |
| `bug-hunter` | "This is broken, find out why" |
| `db-schema-designer` | "Design a schema for X / add this field" |
| `performance-optimizer` | "This query is slow / the app is janky" |

### How to invoke an agent

Just describe what you want in plain English — Claude will use the right agent:

```
"Review backend/controllers/paymentController.js before I push"
→ Uses code-reviewer agent

"Something is wrong with the cart total calculation"
→ Uses bug-hunter agent

"Build a loyalty points screen in gold/"
→ Uses flutter-feature-builder agent

"The product list endpoint is slow with 10k products"
→ Uses performance-optimizer agent
```

Or be explicit:
```
"Use the security-auditor agent to check the upload route"
```

### What makes agents different from just asking

Agents have deep project context baked in. The `bug-hunter` agent already knows:
- The most common failure patterns in your exact stack (missing `await`, ObjectId casting, GetX controller lifecycle)
- It forces a hypothesis-first approach — won't jump to a fix without understanding the root cause

The `code-reviewer` agent already knows:
- Your 4 known open security issues (disabled mongo-sanitize, open CORS, etc.)
- The exact response shape your codebase uses
- Flutter GetX anti-patterns specific to your setup

---

## Part 4 — Commands (Slash Shortcuts)

Commands live in `.claude/commands/`. They are reusable prompt templates invoked with `/project:name`.
`$ARGUMENTS` in the template gets replaced with whatever you type after the command name.

### Commands available

| Command | Usage | What it does |
|---|---|---|
| `/project:review` | `/project:review backend/routes/auth.js` | Full code review using the code-reviewer agent |
| `/project:fix-issue` | `/project:fix-issue "cart total wrong"` | Bug fix using bug-hunter, hypothesis-first |
| `/project:deploy` | `/project:deploy backend` | Pre-deploy checklist for backend, gold, gold_admin, or all |
| `/project:new-feature` | `/project:new-feature wallet-history in gold` | Scaffold a full Flutter feature |
| `/project:new-api` | `/project:new-api reviews protected` | Scaffold backend route + controller + model |
| `/project:security-check` | `/project:security-check backend/routes/payment.js` | Targeted security audit |
| `/project:explain` | `/project:explain gold/lib/features/chat` | Plain-English explanation of any code |
| `/project:add-field` | `/project:add-field "loyaltyPoints: Number to User"` | Add a field across model + controllers + Flutter model |

### How to type them

In the Claude Code chat input, type `/project:` and autocomplete will show all available commands.

```
/project:review backend/controllers/authController.js

/project:new-feature transaction-history in gold

/project:fix-issue "login screen freezes after wrong password"

/project:deploy all

/project:add-field "isVerified: Boolean to Product, admin-only"
```

### Commands vs just asking

Commands are faster for repeated tasks. Instead of:
> "Review this file, use the code-reviewer agent, check for Mongoose issues,
> format it with Critical/Warning/Suggestion sections, and tell me if it's safe to commit"

You just type:
> `/project:review backend/controllers/ordersController.js`

---

## Part 5 — Settings (Permission Control)

### settings.json (shared with team)

Defines what Claude can do automatically without a popup. Already configured for:

**Auto-approved (no prompt):**
- All `npm run *` commands, `flutter pub get`, `flutter analyze`, `flutter test`, `flutter build`
- Safe git commands: `status`, `diff`, `log`, `add`, `commit`, `fetch`, `checkout`
- File operations: `ls`, `find`, `grep`, `mkdir`, `cp`, `mv`

**Blocked (Claude cannot do these even if you ask):**
- `rm -rf *`, `sudo *` — destructive
- `git push --force`, `git push origin main` — irreversible
- `curl`, `wget` — arbitrary HTTP calls
- Read `.env`, `*firebase-adminsdk*`, `*.pem`, `~/.ssh` — secrets
- `npm publish`, `flutter pub publish` — accidental releases
- DB drop commands

### settings.local.json (your machine only, gitignored)

Your personal overrides. Currently adds:
- `git push` — allowed on your machine but not auto-approved for the team
- `flutter pub upgrade` — dependency upgrades
- `open`, `code` — macOS/VS Code shortcuts

**To add your own overrides**, edit `settings.local.json`:
```json
{
  "permissions": {
    "allow": [
      "Bash(your-custom-command *)"
    ]
  }
}
```

---

## Part 6 — CLAUDE.md Files (Project Context)

There are 4 CLAUDE.md files. Claude reads ALL of them that are in the current directory tree.

| File | Loaded when | Purpose |
|---|---|---|
| `.claude/CLAUDE.md` | Always | Monorepo overview, shared security rules |
| `backend/CLAUDE.md` | Working in backend/ | Node.js conventions, stack details, env vars |
| `gold/CLAUDE.md` | Working in gold/ | Flutter conventions, GetX patterns, dependencies |
| `gold_admin/CLAUDE.md` | Working in gold_admin/ | Admin-specific rules, role guards |

**CLAUDE.local.md** is your personal override file — gitignored. Use it for:
```markdown
## My Dev Setup
- Android emulator: Pixel_6_API_33
- Local backend: http://192.168.1.x:5000
- MongoDB Compass connected to: mongodb://localhost:27017/influe

## Currently working on
- Wallet top-up flow (backend + gold/)
```

---

## Daily Workflow — Practical Examples

### Starting a new feature

```
1. Tell Claude what you want to build:
   "Build a transaction history screen in gold/ that shows wallet credits and debits"

   → flutter-feature-builder agent activates
   → node-senior-engineer checks if backend endpoint exists
   → Creates: binding, controller, model, page, widgets
   → Shows route constants to add

2. Or use the command:
   /project:new-feature transaction-history in gold
```

### Adding a backend endpoint

```
/project:new-api transactions protected

→ Creates: models/Transaction.js (if missing), controllers/transactionsController.js,
   routes/transactions.js with protect middleware, Zod schema
→ Shows the line to add to app.js
```

### Before committing

```
/project:review backend/controllers/paymentController.js

→ Runs the full code-reviewer checklist
→ Flags Critical/Warning/Suggestion findings
→ Ends with: "Safe to commit? YES / NO / YES (after fixing X)"
```

### Something is broken

```
/project:fix-issue "cart total shows NaN when a product has no price"

→ bug-hunter reads the relevant files
→ States hypothesis before touching anything
→ Proposes minimal fix with before/after code
```

### Before going to production

```
/project:deploy backend
/project:deploy gold
/project:deploy gold_admin

→ Works through the full checklist
→ Lists ✅ safe items, ❌ blockers, ⚠️ warnings
```

### Security audit on sensitive code

```
/project:security-check backend/routes/payment.js

→ security-auditor agent + security-review skill
→ Checks OWASP Top 10 for your stack
→ Flags known open issues (disabled mongo-sanitize, open CORS, etc.)
→ Ends with: SAFE TO SHIP / NEEDS FIXES / CRITICAL — DO NOT SHIP
```

### Understanding unfamiliar code

```
/project:explain gold/lib/features/chat

→ Reads the feature
→ Gives: what it does, how it works step-by-step, key decisions, where to look next
```

---

## Keeping the .claude Folder Updated

The `.claude` folder is only useful if it reflects how the project actually works.

### Update rules when:
- You change a major convention (e.g., switch from `http` to `dio`)
- A pattern Claude keeps getting wrong
- A new package is added that has specific usage patterns

### Update agents when:
- The project structure changes significantly
- New features are added that agents should know about
- An agent gives wrong suggestions repeatedly (its context is stale)

### Update CLAUDE.md files when:
- Build commands change
- New environment variables are required
- Architecture decisions are made

### Update settings when:
- A new tool/command needs to be auto-approved
- A command should be blocked that isn't currently

### Add new commands when:
- You find yourself typing the same instruction more than 3 times

---

## Quick Reference Card

```
┌─────────────────────────────────────────────────────────────┐
│  DAILY USE                                                  │
├─────────────────────────────────────────────────────────────┤
│  New Flutter screen    /project:new-feature <name> in gold  │
│  New API endpoint      /project:new-api <name> protected    │
│  Review before commit  /project:review <file>               │
│  Fix a bug             /project:fix-issue "<description>"   │
│  Pre-deploy check      /project:deploy backend|gold|all     │
│  Security audit        /project:security-check <file>       │
│  Understand code       /project:explain <file or folder>    │
│  Add a model field     /project:add-field "<field to Model>"│
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│  AUTO-ACTIVE (no typing needed)                             │
├─────────────────────────────────────────────────────────────┤
│  Flutter file    → flutter-senior-engineer skill            │
│  backend/ file   → node-senior-engineer skill               │
│  Auth/payment    → security-review skill                    │
│  Firebase/FCM    → firebase-expert skill                    │
│  Chat/Socket.io  → socket-expert skill                      │
│  "Deploy/release"→ deploy skill                             │
│  "Is this right?"→ code-review-auto skill                   │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│  BLOCKED (Claude cannot do these)                           │
├─────────────────────────────────────────────────────────────┤
│  rm -rf  •  git push --force  •  push to main              │
│  curl/wget  •  sudo  •  npm publish                         │
│  Read .env / firebase-adminsdk / *.pem / ~/.ssh             │
│  dropDatabase / dropCollection                              │
└─────────────────────────────────────────────────────────────┘
```
