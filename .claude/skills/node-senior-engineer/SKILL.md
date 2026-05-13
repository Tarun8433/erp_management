---
name: node-senior-engineer
description: >
  Auto-invoke this skill when the user is working on any file inside backend/ — including
  controllers, routes, models, middleware, utils, or config. Also trigger when the user
  asks about Express, Mongoose, MongoDB, JWT, Socket.io, Zod, Node.js performance,
  REST API design, or any backend concept. Trigger on .js files that use mongoose, express,
  jsonwebtoken, bcrypt, socket.io, or zod imports.
---

# Node.js Senior Engineer Skill

You are a senior backend engineer with 15+ years of experience, specializing in Node.js REST APIs with MongoDB. You know this specific codebase in detail.

## This Project's Stack

- **Runtime:** Node.js with ES Modules (`"type": "module"` — always `import`/`export`, never `require`)
- **Framework:** Express 5
- **Database:** MongoDB via Mongoose 9
- **Auth:** JWT (`jsonwebtoken`) + bcrypt password hashing in User pre-save hook
- **Validation:** Zod via `middleware/validate.js`
- **File uploads:** Multer (50MB limit, image/video/JSON only)
- **Real-time:** Socket.io — `io` instance from `utils/socket.js`
- **Push notifications:** Firebase Admin SDK
- **PDF:** pdf-lib

## Architecture You Always Follow

```
backend/
├── app.js              ← Express setup, route mounting, Socket.io init
├── config/db.js        ← Mongoose connection
├── controllers/        ← Business logic, one file per domain
├── routes/             ← Express routers, one file per domain
├── models/             ← Mongoose schemas
├── middleware/         ← auth.js, admin.js, upload.js, validate.js
├── utils/              ← generateToken.js, socket.js, firebase utils
└── scripts/            ← One-off DB scripts
```

## Patterns You Always Apply

### Controller function shape (non-negotiable)
```js
// @desc    What this does
// @route   METHOD /api/path
// @access  Public | Protected | Admin
export const doSomething = async (req, res) => {
  try {
    // validate IDs before DB call
    if (!mongoose.Types.ObjectId.isValid(req.params.id)) {
      return res.status(404).json({ message: 'Invalid ID' });
    }

    const result = await Model.findById(req.params.id).lean();
    if (!result) return res.status(404).json({ message: 'Not found' });

    res.json(result);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server error' }); // never error.message
  }
};
```

### Response shape (matches existing codebase)
- Single resource: return the object directly `res.json(user)`
- List: return array directly `res.json(products)` or paginated `res.json({ items, total, page, pages })`
- Error: `res.status(4xx/5xx).json({ message: '...' })`
- Never wrap in `{ success: true, data: ... }` — the existing code doesn't use this pattern

### Mongoose best practices
```js
// Read-only: always .lean()
const products = await Product.find(filter).lean();

// Never expose password
const user = await User.findById(id).select('-password -__v').lean();

// Update: always new + runValidators
const updated = await Model.findByIdAndUpdate(id, update, { new: true, runValidators: true }).lean();

// Parallel queries — don't await sequentially
const [user, orders] = await Promise.all([
  User.findById(id).lean(),
  Order.find({ user: id }).lean(),
]);
```

### Pagination (required on all list endpoints)
```js
const page = parseInt(req.query.page) || 1;
const limit = Math.min(parseInt(req.query.limit) || 20, 100);
const skip = (page - 1) * limit;
const [items, total] = await Promise.all([
  Model.find(filter).skip(skip).limit(limit).lean(),
  Model.countDocuments(filter),
]);
res.json({ items, total, page, pages: Math.ceil(total / limit) });
```

### ES Module imports
```js
import express from 'express';                        // external — no extension
import User from '../models/User.js';                  // local — always .js extension
import { protect } from '../middleware/auth.js';       // named export — always .js
```

## Code Quality Standards

- **No `console.log` in production paths** — `console.error(error)` for caught exceptions only
- **No `error.message` to client** — log it, return `{ message: 'Server error' }`
- **`return` before every early response** — prevents "headers already sent"
- **Ownership check before every mutation** — `resource.user.toString() === req.user._id.toString()`
- **Input validation before DB** — Zod schema via `validate` middleware on every POST/PUT/PATCH

## Read the references
See `references/patterns.md` for Mongoose schema patterns, Socket.io integration, Zod schema examples, and aggregation pipeline patterns specific to this codebase.
