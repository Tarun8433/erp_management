Scaffold a new Flutter feature: $ARGUMENTS

Format: "feature-name in gold" OR "feature-name in gold_admin"
Example: /project:new-feature wallet-history in gold

Use the `flutter-feature-builder` agent from `.claude/agents/flutter-feature-builder.md`.

Before writing any code:
1. Check if a similar feature already exists in `gold/lib/features/` — if so, use it as a reference for code style
2. Check `backend/routes/` to find the API endpoints this feature will consume
3. Check `backend/models/` to understand the data shape

Then create all required files:
- `features/<name>/bindings/<name>_binding.dart`
- `features/<name>/controllers/<name>_controller.dart`
- `features/<name>/models/<name>_model.dart` (if needed)
- `features/<name>/views/<name>_page.dart`
- Any widgets in `features/<name>/widgets/`

After creating files, show:
1. The route constant to add to `app_routes.dart`
2. The `GetPage` entry to add to `app_pages.dart`
3. How to navigate to this screen: `Get.toNamed(Routes.x)`
