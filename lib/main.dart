import 'package:erp_management/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:erp_management/app.dart';
import 'core/utils/local_storage/storage_helper.dart';
import 'core/constants/app_colors.dart';
import 'core/services/api/endpoints.dart';
import 'core/services/notifications/firebase_notification_service.dart';
import 'core/utils/crypto/app_secrets.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Register background FCM handler before any other Firebase Messaging call.
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // Notification setup must never block app startup. On iOS a hung/failed FCM
  // call (e.g. no APNs on the Simulator) would otherwise stop runApp() from
  // ever being reached, leaving a blank screen.
  try {
    await FirebaseNotificationService.instance.initialize(
      onMessageTap: (msg) {
        // TODO: navigate to the relevant screen based on msg.data.
        // Example: Get.toNamed('/notification-detail', arguments: msg);
      },
    );
  } catch (e) {
    debugPrint('[FCM] initialize failed (continuing without it): $e');
  }
  
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Load saved base URL only when the environment selector is enabled;
  // otherwise the app always uses the Prod default defined in Endpoints.
  final savedBaseUrl = await StorageHelper.getBaseUrl();
  if (Endpoints.showEnvironmentSelector && savedBaseUrl != null) {
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
