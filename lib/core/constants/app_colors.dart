import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Brand Colors
  static Color primary = const Color.fromARGB(255, 12, 62, 154);
  static const Color primaryVariant = Color.fromARGB(255, 0, 57, 179);
  static const Color secondary = Color(0xFF03DAC6);
  static const Color secondaryVariant = Color(0xFF018786);
  static const Color tertiary = Color(0xFFFFB74D);
  static const Color primaryBlue3 = Color.fromARGB(255, 227, 237, 255);
  // Neutral Colors
  static const Color background = Color.fromARGB(255, 255, 255, 255);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFEEEEEE);
  static const Color white20 = Color(0x33FFFFFF);
  static const Color white70 = Color(0xB3FFFFFF);

  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onSecondary = Color(0xFF000000);
  static const Color onBackground = Color(0xFF121212);
  static const Color onSurface = Color(0xFF121212);
  static const Color onSurfaceVariant = Color(0xFF49454F);

  // Semantic Colors
  static const Color error = Color(0xFFB00020);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color success = Color(0xFF4CAF50);
  static const Color onSuccess = Color(0xFFFFFFFF);
  static const Color warning = Color(0xFFFFC107);
  static const Color onWarning = Color(0xFF000000);
  static const Color info = Color(0xFF2196F3);
  static const Color onInfo = Color(0xFFFFFFFF);

  // Grey Scale
  static const Color grey50 = Color(0xFFFAFAFA);
  static const Color grey100 = Color(0xFFF5F5F5);
  static const Color grey200 = Color(0xFFEEEEEE);
  static const Color grey300 = Color(0xFFE0E0E0);
  static const Color grey400 = Color(0xFFBDBDBD);
  static const Color grey500 = Color(0xFF9E9E9E);
  static const Color grey600 = Color(0xFF757575);
  static const Color grey700 = Color(0xFF616161);
  static const Color grey800 = Color(0xFF424242);
  static const Color grey900 = Color(0xFF212121);

  // Dark Theme Colors
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkOnBackground = Color(0xFFFFFFFF);
  static const Color darkOnSurface = Color(0xFFFFFFFF);

  // Overlay
  static const Color overlay = Color(0x80000000);
  static const Color transparent = Colors.transparent;

  // Added for NavBar
  static List<Color> get primaryBlueGradient => [primary, primaryVariant];
  static const Color shadowSoft = Color(0x1F000000);
  static const Color shadowStrong = Color(0x42000000);
  static const Color primaryBlueLight = Color(0xFFE3F2FD); // Light blue
  static Color get primaryBlue2 => primary;
  static const Color black26 = Colors.black26;
  static const Color white = Colors.white;
  static const Color black = Colors.black;
  static const Color grey = Colors.grey;
  static const Color accentOrange = Color(0xFFFF7043);
  static const Color white24 = Colors.white24;

  static final LinearGradient gradientColors = LinearGradient(
    colors: [
      AppColors.primary,
      AppColors.primaryVariant, // Blue
      // Cyan (Water)
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
