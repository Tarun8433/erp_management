import 'dart:developer';

/// This file contains the logic to refresh specific data when the language changes.
/// Language is now managed locally — no API call is needed.
/// The user can mention/add refresh actions here if needed in the future.
class LanguageRefreshActions {
  static Future<void> refresh(String langCode) async {
    log('LanguageRefreshActions: Language changed locally to: $langCode');
    // Language change is now managed locally.
    // Add any additional local refresh logic here if needed.
  }
}
