---
description: API design rules for the Node.js backend. Always apply when creating or modifying routes, controllers, or response shapes.
---

# API Conventions

## URL Structure
- Base: `/api/<resource>` — plural nouns, kebab-case
- Examples: `/api/products`, `/api/orders`, `/api/deal-applications`, `/api/home-sections`
- Nested resources: `/api/orders/:id/items` — max one level of nesting
- Admin-specific routes: `/api/admin/<resource>`
- No verbs in URLs — use HTTP methods instead: `DELETE /api/cart/:id` not `/api/cart/remove/:id`

## HTTP Methods
| Action | Method | Path | Status |
|---|---|---|---|
| List all | GET | `/api/products` | 200 |
| Get one | GET | `/api/products/:id` | 200 |
| Create | POST | `/api/products` | 201 |
| Full update | PUT | `/api/products/:id` | 200 |
| Partial update | PATCH | `/api/products/:id` | 200 |
| Delete | DELETE | `/api/products/:id` | 200 |

## Response Shape

The codebase uses **flat responses** — not wrapped in `{success, data}`. Match the existing pattern:

**Success — single resource:**
```json
{ "_id": "...", "name": "...", "token": "..." }
```

**Success — list:**
```json
[{ "_id": "...", "name": "..." }, ...]
```
Or with pagination:
```json
{ "items": [...], "total": 100, "page": 1, "pages": 5 }
```

**Error:**
```json
{ "message": "Human-readable error description" }
```

**Rules:**
- Never include `password`, `fcmToken`, `paymentSettings`, or `walletBalance` in responses unless the requesting user owns the record or is admin
- Never expose Mongoose internal fields (`__v`) — use `.select('-__v')` on queries
- Never return `error.message` from a caught exception to the client — log it server-side, return `{ message: 'Server error' }`

## HTTP Status Codes
- `200` — success (GET, PUT, PATCH, DELETE)
- `201` — resource created (POST)
- `400` — bad input / validation error / business rule violation
- `401` — not authenticated (no token or invalid token)
- `403` — authenticated but not authorized (wrong role, not owner)
- `404` — resource not found
- `500` — unexpected server error

## Pagination
Every list endpoint that can return more than 20 records **must** support pagination:
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

## Authentication on Routes
```js
// Public — no middleware
router.get('/', getProducts);

// Authenticated users only
router.post('/', protect, createProduct);

// Admin only
router.delete('/:id', protect, admin, deleteProduct);
```

Always apply middleware in this order: `protect` → `admin` → `validate(schema)` → handler

## Validation
- Every POST/PUT/PATCH must validate `req.body` with a Zod schema via `validate` middleware
- Path params (`:id`) must be validated as MongoDB ObjectIds:
  ```js
  import mongoose from 'mongoose';
  if (!mongoose.Types.ObjectId.isValid(req.params.id)) {
    return res.status(404).json({ message: 'Invalid ID' });
  }
  ```
- Query params must be parsed and typed — never pass raw query string values to DB queries

## Querying Best Practices
- Always use `.lean()` on read-only queries
- Always use `.select('-password -__v')` when returning User documents
- Never `Model.find({})` without a `limit()` on public endpoints
- Use `Promise.all([...])` for parallel independent DB calls — never `await` sequentially when calls don't depend on each other

## Versioning
- No versioning prefix currently (`/api/v1/`) — do not add it without discussing first
- Maintain backwards compatibility when changing existing endpoints — the Flutter apps may not update simultaneously
