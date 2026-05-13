---
description: Testing rules and patterns for the backend and Flutter apps. Apply when writing, running, or discussing tests.
---

# Testing Rules

## Backend Testing (`backend/`)

### What to test
- **Controllers** — every public endpoint: happy path, auth failure (401), ownership failure (403), not found (404), and invalid input (400)
- **Auth flow** — register, login, JWT verification, admin access
- **Mongoose models** — custom validators, pre-save hooks (especially password hashing), methods like `matchPassword`
- **Zod schemas** — valid inputs pass, invalid inputs return 400 with correct error shape

### What not to test
- Third-party library internals (don't test that `bcrypt.hash` works)
- The Express framework itself
- Mongoose built-in validation (min, max, required) — only test custom validators

### Test setup
```js
// Use a real MongoDB test database — no mocks
// Set NODE_ENV=test to use test DB from .env
// Reset DB between tests with beforeEach/afterEach
import { MongoMemoryServer } from 'mongodb-memory-server'; // preferred for CI
```

**No mocking the database.** The DB is core to correctness — mocked tests have historically hidden real bugs in this project. Use an in-memory MongoDB instance instead.

### File naming
```
backend/
└── __tests__/
    ├── auth.test.js
    ├── products.test.js
    └── orders.test.js
```

### Test pattern
```js
describe('POST /api/auth/login', () => {
  it('returns token on valid credentials', async () => { ... });
  it('returns 401 on wrong password', async () => { ... });
  it('returns 401 on non-existent email', async () => { ... });
  it('returns 400 if neither email nor phone provided', async () => { ... });
});
```

### Assertions for API responses
Always assert:
1. The HTTP status code
2. The response body shape (key fields exist)
3. For auth endpoints: that `password` is NOT in the response
4. For list endpoints: that pagination fields are present (`total`, `page`)

---

## Flutter Testing (`gold/`, `gold_admin/`)

### Test types — what to write
| Type | When to write | Location |
|---|---|---|
| Unit test | Pure Dart logic — validators, model `fromJson`/`toJson`, utility functions | `test/unit/` |
| Widget test | Individual widgets that have complex rendering logic | `test/widget/` |
| Integration test | Critical user flows (login → home, add to cart → checkout) | `integration_test/` |

### What to unit test
- `fromJson`/`toJson` on every model — test with real API response shapes
- Validators in `core/utils/validators.dart`
- Any pure Dart utility function in `utils/`

### What to widget test
- Custom widgets that have conditional rendering (loading/error/empty states)
- Form widgets with validation display

### What NOT to test
- GetX controllers in isolation with mocked repositories — too brittle
- Screens end-to-end in widget tests (use integration tests instead)
- Third-party package behavior

### Flutter test patterns
```dart
// Unit test — model serialization
test('UserModel.fromJson parses correctly', () {
  final json = {
    '_id': '123',
    'name': 'Test User',
    'email': 'test@test.com',
    'token': 'abc',
  };
  final user = UserModel.fromJson(json);
  expect(user.id, '123');
  expect(user.name, 'Test User');
});

// Widget test — loading/error/empty states
testWidgets('shows shimmer when loading', (tester) async {
  await tester.pumpWidget(const MaterialApp(home: ProductListPage()));
  expect(find.byType(Shimmer), findsWidgets);
});
```

### Running tests
```bash
# Backend
cd backend && npm test

# Flutter
cd gold && flutter test                    # unit + widget tests
cd gold && flutter test integration_test/  # integration tests (device required)
flutter analyze                            # always run before flutter test
```

## General Rules
- Tests must pass before any PR or deployment
- Run `flutter analyze` and fix all errors before committing Flutter code
- Never commit commented-out tests
- Never use `skip` on tests without a TODO comment explaining when they will be fixed
- Tests are code — apply the same code style rules to test files
