import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:erp_management/app.dart';
import 'core/utils/local_storage/storage_helper.dart';
import 'core/constants/app_colors.dart';
import 'core/services/api/endpoints.dart';
import 'core/utils/crypto/app_secrets.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Load saved base URL
  final savedBaseUrl = await StorageHelper.getBaseUrl();
  if (savedBaseUrl != null) {
    Endpoints.baseUrl = savedBaseUrl;
  }

  // Load saved language
  final langCode = await StorageHelper.getLanguage();
  Locale? initialLocale;
  if (langCode != null) {
    final parts = langCode.split('_');
    if (parts.length == 2) {
      initialLocale = Locale(parts[0], parts[1]);
    } else if (parts.length == 1) {
      initialLocale = Locale(parts[0]);
    }
  }

  // Load saved theme
  final themeStr = await StorageHelper.getThemeMode();
  ThemeMode initialThemeMode = ThemeMode.system;
  if (themeStr == 'light') initialThemeMode = ThemeMode.light;
  if (themeStr == 'dark') initialThemeMode = ThemeMode.dark;

  // Load saved primary color
  final primaryColorValue = await StorageHelper.getPrimaryColor();
  if (primaryColorValue != null) {
    AppColors.primary = Color(primaryColorValue);
  }

  // Load saved font size
  final fontSizeMultiplier = await StorageHelper.getFontSize();

  await AppSecrets.load();

  runApp(
    MyApp(
      initialLocale: initialLocale,
      initialThemeMode: initialThemeMode,
      initialFontSizeMultiplier: fontSizeMultiplier,
    ),
  );
}
