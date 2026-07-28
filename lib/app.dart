import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'core/theme/app_theme.dart';
import 'routes/app_pages.dart';
import 'core/localization/app_translations.dart';
import 'core/bindings/initial_binding.dart';
import 'core/widgets/app_updater.dart';

class MyApp extends StatelessWidget {
  final Locale? initialLocale;
  final ThemeMode initialThemeMode;
  final double initialFontSizeMultiplier;

  const MyApp({
    super.key,
    this.initialLocale,
    this.initialThemeMode = ThemeMode.system,
    this.initialFontSizeMultiplier = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Logimind',
      theme: AppTheme.lightTheme(fontSizeMultiplier: initialFontSizeMultiplier),
      darkTheme: AppTheme.darkTheme(
        fontSizeMultiplier: initialFontSizeMultiplier,
      ),
      themeMode: initialThemeMode,
      initialBinding: InitialBinding(),
      initialRoute: AppPages.initial,
      getPages: AppPages.routes,
      debugShowCheckedModeBanner: false,
      translations: AppTranslations(),
      locale: initialLocale ?? const Locale('en'),
      fallbackLocale: const Locale('en'),
      builder: (context, child) {
        return SafeArea(
          top: false,
          bottom: true,
          right: false,
          left: false,
          child: AppUpdater(child: child ?? const SizedBox.shrink()),
        );
      },
    );
  }
}
