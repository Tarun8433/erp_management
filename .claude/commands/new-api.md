Scaffold a new backend API resource: $ARGUMENTS

Format: "resource-name [public|protected|admin]"
Example: /project:new-api reviews protected
Example: /project:new-api app-settings admin

Use the `api-builder` agent from `.claude/agents/api-builder.md`.

Before writing any code:
1. Check `backend/models/` — does a model already exist for this resource?
2. Check `backend/routes/` — does a route file already exist?
3. Check `backend/controllers/` — is there existing logic to extend?

Then create:
- `backend/models/<Model>.js` — Mongoose schema with timestamps and indexes
- `backend/controllers/<resource>Controller.js` — async functions with try/catch
- `backend/routes/<resource>.js` — Express router with correct middleware applied
- Zod schema inline or in `backend/schemas/<resource>.js`

After creating files, show the exact line to add to `backend/app.js`:
```js
import <resource>Routes from './routes/<resource>.js';
app.use('/api/<resource>', <resource>Routes);
```

List all endpoints created with their method, path, auth level, and what they return.
