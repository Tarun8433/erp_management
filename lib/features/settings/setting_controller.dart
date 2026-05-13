import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:local_auth/local_auth.dart';
import 'package:erp_management/core/utils/drawer_main/src/enum/drawer_style.dart';
import '../../../core/utils/local_storage/storage_helper.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_theme.dart';

class SettingController extends GetxController {
  final RxString themeMode = 'system'.obs;
  final RxBool notificationsEnabled = true.obs;
  final RxDouble fontSizeMultiplier = 1.0.obs;
  final RxBool biometricEnabled = false.obs;
  final Rx<DrawerStyle> drawerStyle = DrawerStyle.style3.obs;

  @override
  void onInit() {
    super.onInit();
    loadSettings();
  }

  Future<void> loadSettings() async {
    final mode = await StorageHelper.getThemeMode();
    themeMode.value = mode ?? 'system';
    fontSizeMultiplier.value = await StorageHelper.getFontSize();
    biometricEnabled.value = await StorageHelper.getBiometricEnabled();
    final styleName = await StorageHelper.getDrawerStyle();
    drawerStyle.value = _styleFromName(styleName);
  }

  Future<void> updateFontSize(double multiplier) async {
    await StorageHelper.saveFontSize(multiplier);
    fontSizeMultiplier.value = multiplier;

    // Refresh the theme with new font size
    Get.changeTheme(AppTheme.lightTheme(fontSizeMultiplier: multiplier));
    if (Get.isDarkMode) {
      Get.changeTheme(AppTheme.darkTheme(fontSizeMultiplier: multiplier));
    }

    // Force update to apply changes
    Get.forceAppUpdate();
  }

  Future<void> updateTheme(String mode) async {
    await StorageHelper.saveThemeMode(mode);
    themeMode.value = mode;

    ThemeMode getThemeMode() {
      switch (mode) {
        case 'light':
          return ThemeMode.light;
        case 'dark':
          return ThemeMode.dark;
        default:
          return ThemeMode.system;
      }
    }

    Get.changeThemeMode(getThemeMode());
  }

  Future<void> updateDrawerStyle(DrawerStyle style) async {
    await StorageHelper.saveDrawerStyle(style.name);
    drawerStyle.value = style;
  }

  DrawerStyle _styleFromName(String? name) {
    if (name == null || name.trim().isEmpty) return DrawerStyle.style3;
    return DrawerStyle.values.firstWhere(
      (e) => e.name == name,
      orElse: () => DrawerStyle.style3,
    );
  }

  void toggleNotifications(bool value) {
    notificationsEnabled.value = value;
    // Add logic to save notification preference if needed
  }

  Future<bool> setBiometricEnabled(bool v) async {
    if (!v) {
      await StorageHelper.saveBiometricEnabled(false);
      biometricEnabled.value = false;
      return true;
    }
    try {
      final auth = LocalAuthentication();
      final canCheck = await auth.canCheckBiometrics;
      final supported = canCheck || await auth.isDeviceSupported();
      if (!supported) return false;
      final didAuthenticate = await auth.authenticate(
        localizedReason: 'Authenticate to enable biometric unlock',
        biometricOnly: true,
      );
      await StorageHelper.saveBiometricEnabled(didAuthenticate);
      biometricEnabled.value = didAuthenticate;
      return didAuthenticate;
    } catch (_) {
      await StorageHelper.saveBiometricEnabled(false);
      biometricEnabled.value = false;
      return false;
    }
  }

  Future<void> updatePrimaryColor(Color color) async {
    await StorageHelper.savePrimaryColor(color.value);
    AppColors.primary = color;

    // Refresh the theme
    final multiplier = fontSizeMultiplier.value;
    if (Get.isDarkMode) {
      Get.changeTheme(AppTheme.darkTheme(fontSizeMultiplier: multiplier));
    } else {
      Get.changeTheme(AppTheme.lightTheme(fontSizeMultiplier: multiplier));
    }
    // Ensure the theme mode stays correct
    Get.forceAppUpdate();
  }
}
