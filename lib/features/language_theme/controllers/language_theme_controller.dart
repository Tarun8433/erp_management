import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/utils/local_storage/storage_helper.dart';
import '../../../routes/app_routes.dart';
import '../../../core/utils/language_refresh_actions.dart';
import '../../auth/data/models/login_response.dart';

class LanguageThemeController extends GetxController {
  var selectedLanguage = 'en'.obs;
  var selectedThemeMode = ThemeMode.system.obs;

  var languages = <LanguageData>[].obs;

  final themes = [
    {
      'key': 'light',
      'mode': ThemeMode.light,
      'icon': Icons.light_mode_outlined,
    },
    {'key': 'dark', 'mode': ThemeMode.dark, 'icon': Icons.dark_mode_outlined},
    {
      'key': 'system_default',
      'mode': ThemeMode.system,
      'icon': Icons.smartphone_outlined,
    },
  ];

  @override
  void onInit() {
    super.onInit();
    _loadPreferences();
  }

  void _loadPreferences() async {
    final storedLanguages = await StorageHelper.getLanguages();
    if (storedLanguages.isNotEmpty) {
      languages.assignAll(storedLanguages);
    } else {
      languages.assignAll([
        LanguageData(
            code: 'en', name: 'English', nativeName: 'English', isActive: true),
        LanguageData(
            code: 'hi', name: 'Hindi', nativeName: 'हिन्दी', isActive: true),
      ]);
    }

    final lang = await StorageHelper.getLanguage();
    if (lang != null) {
      selectedLanguage.value = lang;
    } else if (languages.isNotEmpty) {
      // Default to first language if no preference
      selectedLanguage.value = languages.first.code ?? 'en';
    }

    final themeStr = await StorageHelper.getThemeMode();
    if (themeStr != null) {
      if (themeStr == 'light') {
        selectedThemeMode.value = ThemeMode.light;
      } else if (themeStr == 'dark') {
        selectedThemeMode.value = ThemeMode.dark;
      } else {
        selectedThemeMode.value = ThemeMode.system;
      }
    }
  }

  void setLanguage(String code) async {
    selectedLanguage.value = code;
    Get.updateLocale(Locale(code));
    await StorageHelper.saveLanguage(code);
    await LanguageRefreshActions.refresh(code);
  }

  void setThemeMode(ThemeMode mode) {
    selectedThemeMode.value = mode;
    Get.changeThemeMode(mode);
    String modeStr = 'system';
    if (mode == ThemeMode.light) modeStr = 'light';
    if (mode == ThemeMode.dark) modeStr = 'dark';
    StorageHelper.saveThemeMode(modeStr);
  }

  void onContinue() async {
    await StorageHelper.saveIntroSeen();
    await StorageHelper.saveLanguage(selectedLanguage.value);
    String modeStr = 'system';
    if (selectedThemeMode.value == ThemeMode.light) modeStr = 'light';
    if (selectedThemeMode.value == ThemeMode.dark) modeStr = 'dark';
    await StorageHelper.saveThemeMode(modeStr);
    final isLoggedIn = await StorageHelper.getLoginStatus();
    if (isLoggedIn == true) {
      Get.offAllNamed(AppRoutes.dashboard);
    } else {
      Get.offNamed(AppRoutes.onboarding);
    }
  }
}
