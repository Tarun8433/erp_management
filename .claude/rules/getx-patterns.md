---
description: GetX-specific rules for Flutter apps (gold/ and gold_admin/). Apply to all .dart files using GetX.
---

# GetX Patterns

## Controllers

### Lifecycle
```dart
class ExampleController extends GetxController {
  // Dispose EVERYTHING here — no exceptions
  @override
  void onClose() {
    textController.dispose();
    focusNode.dispose();
    _debounceWorker?.dispose();
    super.onClose();
  }
}
```
- `onInit()` for setup logic and initial data fetch
- `onClose()` for ALL disposals — `TextEditingController`, `FocusNode`, workers (`ever`, `debounce`, `once`, `interval`)
- Never use `StatefulWidget` just to call `dispose()` — use `GetxController.onClose()` instead

### State — always three branches
Every async operation needs all three states handled:
```dart
final isLoading = false.obs;
final errorMessage = ''.obs;
final data = <Model>[].obs;

Future<void> fetch() async {
  isLoading.value = true;
  errorMessage.value = '';        // reset error before new request
  try {
    final result = await _repository.getData();
    data.assignAll(result);
  } catch (e) {
    errorMessage.value = e.toString();
  } finally {
    isLoading.value = false;      // MUST be in finally — not just in try
  }
}
```
Never set `isLoading.value = false` only in the success branch — the error branch never resets it.

### Observable mutation — common mistakes
```dart
// WRONG — UI does not rebuild
list = newList;

// RIGHT
list.value = newList;        // for Rx<List<T>>
list.assignAll(newList);     // for RxList<T> — preferred

// WRONG
map['key'] = value;          // doesn't trigger reactive update

// RIGHT
map.value = {...map, 'key': value};  // replace entire map
```

### Accessing controllers
```dart
// In a GetView<T> page — use controller property directly
class ProductPage extends GetView<ProductController> { ... }

// In a non-GetView widget — use Get.find
final ctrl = Get.find<ProductController>();

// NEVER instantiate in a widget
final ctrl = ProductController(); // WRONG — bypasses DI, creates duplicate
```

## Bindings

Every controller must be registered in a Binding, not in `main.dart` or a widget:
```dart
class ProductBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProductController>(() => ProductController());
  }
}
```
- Use `Get.lazyPut` (lazy initialization) for feature controllers
- Use `Get.put(X, permanent: true)` only for app-wide singletons (AuthController, ChatController)

## Navigation

```dart
// Named routes only — no Navigator.push
Get.toNamed(RoutesName.productDetail, arguments: product);

// Pass arguments as a typed object or map
final product = Get.arguments as ProductModel;

// Go back
Get.back();

// Replace current screen
Get.offNamed(RoutesName.home);

// Clear stack and go to screen
Get.offAllNamed(RoutesName.login);
```
- Route names are constants in `lib/routes/routes_name.dart` — never hardcode `/strings` in navigation calls
- Every `GetPage` has a `binding:` parameter — never register dependencies manually before navigation

## Reactive UI

```dart
// Obx — rebuilds whenever any .obs accessed inside changes
Obx(() => Text(controller.name.value))

// GetX — same as Obx but gives you the controller reference
GetX<ProductController>(
  builder: (ctrl) => Text(ctrl.name.value),
)

// GetBuilder — manual rebuild, use only for fine-grained control
GetBuilder<ProductController>(
  builder: (ctrl) => Text(ctrl.name),
  id: 'product-name',   // update only this widget with update(['product-name'])
)
```
- Prefer `Obx` for reactive state
- Keep `Obx` scope small — wrap only the widget that actually changes, not the whole screen
- Never put an `Obx` inside another `Obx` unless intentional

## Storage

Token and user data are stored via `StorageManager` (`core/storage/storage_manager.dart`):
```dart
// Read token
final token = StorageManager.instance.getToken();

// Check login
StorageManager.instance.isLoggedIn();

// Clear on logout
StorageManager.instance.clearAll();
```
Never access `shared_preferences` directly in a controller — go through `StorageManager`.
