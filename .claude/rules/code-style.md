---
description: Code style rules for all files in this project (Node.js backend + Flutter apps). Always apply these when writing or editing code.
---

# Code Style Rules

## Backend (Node.js — `backend/`)

### Modules
- ES Modules only. Always `import`/`export`, never `require()` or `module.exports`
- Always include `.js` extension on local imports: `import User from '../models/User.js'`
- Group imports: external packages first, then internal files, separated by a blank line

### Naming
- Files: `camelCase.js` for controllers/routes/utils, `PascalCase.js` for models
- Functions: `camelCase` — descriptive verbs: `getProduct`, `createOrder`, `sendNotification`
- Constants: `SCREAMING_SNAKE_CASE` for true constants, `camelCase` for variables
- Route handlers: named exports (not default), named after their action: `export const getUser`

### Controller Structure
Every async controller function follows this exact shape — no exceptions:
```js
const doSomething = async (req, res) => {
  try {
    // logic here
    res.json({ ... });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server error' });
  }
};
```
- Never `res.send()` — always `res.json()`
- Never return `error.message` to the client in 500 responses — it leaks internals. Use `'Server error'`
- Always `return` before early `res.json()` calls to prevent "headers already sent" errors

### Comments
- Route handlers get a 3-line JSDoc header:
  ```js
  // @desc    What this does
  // @route   METHOD /api/path
  // @access  Public | Protected | Admin
  ```
- No inline comments for obvious code. Comment the *why*, not the *what*

### Formatting
- 2-space indentation
- Single quotes for strings
- Semicolons required
- Max line length: 100 characters

---

## Flutter / Dart (`gold/`, `gold_admin/`)

### Naming
- Files: `snake_case.dart`
- Classes: `PascalCase`
- Variables, functions, parameters: `camelCase`
- Private members: `_camelCase` prefix
- Constants: `kCamelCase` (with `k` prefix) or `SCREAMING_SNAKE_CASE` for true compile-time constants
- GetX controllers: suffix `Controller` — `AuthController`, `CartController`
- GetX bindings: suffix `Binding` — `AuthBinding`
- Pages/screens: suffix `Page` — `LoginPage`, `ProductDetailPage`
- Widgets: descriptive noun — `ProductCard`, `OrderStatusBadge`

### Dart Style
- Always use `const` constructors where possible — reduces rebuilds
- Prefer `final` for all variables that don't change after assignment
- Use `?` (nullable) intentionally — not as a default to silence null errors
- Never force-unwrap with `!` without a comment explaining why it's safe
- Use `if (!mounted) return;` after every `await` that uses `BuildContext`
- No `dynamic` types — use the actual type or generics

### Flutter Patterns
- `TextEditingController` and `FocusNode` must be disposed in `onClose()` (GetX) or `dispose()` (StatefulWidget)
- `ListView` inside `Column` always needs `shrinkWrap: true` + `physics: NeverScrollableScrollPhysics()` or be wrapped in `Expanded`
- Network images: always `CachedNetworkImage`, never `Image.network`
- Loading placeholders: `shimmer` skeleton, not `CircularProgressIndicator` in the center of a screen

### Debug Code
- `print()` is forbidden in committed code — use `log()` from `dart:developer` or remove entirely
- `debugPrint()` is acceptable for debug-only logs but must be wrapped: `if (kDebugMode) debugPrint(...)`
- Never log tokens, passwords, or user PII — even in debug builds

### Imports
- Order: dart, flutter, packages, then local imports — separated by blank lines
- Use relative imports for files within the same feature, package imports for cross-feature

### Formatting
- `flutter format` must pass with no changes
- 2-space indentation (enforced by `flutter format`)
- Trailing commas on multi-line widget parameters — enables better formatting
