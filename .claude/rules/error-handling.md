---
description: Error handling rules for backend and Flutter. Apply whenever writing try/catch, API responses, or user-facing error messages.
---

# Error Handling Rules

## Backend

### Every async controller must have try/catch
```js
// CORRECT
const getUser = async (req, res) => {
  try {
    const user = await User.findById(req.params.id).lean();
    if (!user) return res.status(404).json({ message: 'User not found' });
    res.json(user);
  } catch (error) {
    console.error(error);                            // log full error server-side
    res.status(500).json({ message: 'Server error' }); // generic message to client
  }
};
```

### Never leak internal details to client
```js
// WRONG — exposes internal error message, DB query details, or stack trace
res.status(500).json({ message: error.message });

// RIGHT
console.error(error);
res.status(500).json({ message: 'Server error' });
```

### Return before sending, never fall through
```js
// WRONG — sends two responses
if (!user) res.status(404).json({ message: 'Not found' });
res.json(user);  // also runs — crashes

// RIGHT
if (!user) return res.status(404).json({ message: 'Not found' });
res.json(user);
```

### Validation errors have a different shape
```json
{ "message": "Validation error", "errors": [{ "path": ["body", "email"], "message": "Invalid email" }] }
```
This comes from `middleware/validate.js` automatically — don't replicate it manually.

### Log levels
- `console.error(error)` — for caught exceptions (5xx situations)
- `console.warn(...)` — for non-critical issues (deprecated usage, fallback triggered)
- Never `console.log` in production code paths — remove or guard with `if (process.env.NODE_ENV !== 'production')`

---

## Flutter

### Controller error handling
```dart
Future<void> fetchData() async {
  isLoading.value = true;
  errorMessage.value = '';
  try {
    data.assignAll(await _repository.getData());
  } catch (e) {
    errorMessage.value = _friendlyError(e);   // convert to user-friendly message
  } finally {
    isLoading.value = false;                  // always in finally
  }
}

String _friendlyError(dynamic e) {
  if (e.toString().contains('SocketException')) return 'No internet connection';
  if (e.toString().contains('401')) return 'Session expired. Please log in again.';
  return 'Something went wrong. Please try again.';
}
```

### Every screen shows errors
No silent failures. If `errorMessage.isNotEmpty`, show it:
```dart
Obx(() {
  if (controller.isLoading.value) return const LoadingWidget();
  if (controller.errorMessage.isNotEmpty) return ErrorView(
    message: controller.errorMessage.value,
    onRetry: controller.fetchData,     // always provide a retry action
  );
  if (controller.items.isEmpty) return const EmptyView();
  return _buildContent();
})
```

### User-facing error messages
- Short, plain English — no technical terms, no raw exception text
- Always offer a next action (retry, go back, contact support)
- Show via `Get.snackbar()` for transient errors (network timeout, validation failure)
- Show inline (in the screen) for persistent errors (load failed, unauthorized)

### 401 handling
When the API returns 401, clear stored credentials and redirect to login immediately:
```dart
if (response.statusCode == 401) {
  StorageManager.instance.clearAll();
  Get.offAllNamed(RoutesName.login);
  return;
}
```
This must happen in the repository layer — not scattered across individual controllers.

### Context after async
```dart
// WRONG — BuildContext may be invalid after await
await someAsyncCall();
Navigator.of(context).pop();

// RIGHT
await someAsyncCall();
if (!mounted) return;
Navigator.of(context).pop();
```
