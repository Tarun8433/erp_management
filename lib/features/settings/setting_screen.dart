import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:erp_management/core/utils/drawer_main/src/flutter_zoom_drawer.dart';
import 'package:erp_management/core/utils/drawer_main/src/enum/drawer_style.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import '../../core/constants/app_colors.dart';
import 'setting_controller.dart';
import '../language_theme/controllers/language_theme_controller.dart';

class SettingScreen extends GetView<SettingController> {
  final ScrollController? scrollController;
  const SettingScreen({super.key, this.scrollController});

  @override
  Widget build(BuildContext context) {
    // Ensure controller is initialized if not using bindings
    if (!Get.isRegistered<SettingController>()) {
      Get.put(SettingController());
    }

    // Ensure LanguageThemeController is initialized
    if (!Get.isRegistered<LanguageThemeController>()) {
      Get.put(LanguageThemeController());
    }

    final languageController = Get.find<LanguageThemeController>();

    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'setting'.tr,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: context.theme.appBarTheme.backgroundColor,
        elevation: 0,
        centerTitle: false,
        leading: ModalRoute.of(context)?.canPop == true
            ? IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Get.back(),
              )
            : IconButton(
                icon: Icon(Icons.menu, color: Colors.white),
                onPressed: () => ZoomDrawer.of(context)?.toggle(),
              ),
      ),
      body: ListView(
        controller: scrollController,
        padding: const EdgeInsets.all(20),
        children: [
          _buildSectionHeader(context, 'app_settings'.tr),
          const SizedBox(height: 10),
          _buildCard(context, [
            Obx(
              () => _buildSettingItem(
                context: context,
                icon: Icons.fingerprint,
                label: 'Biometric Lock',
                trailing: Switch(
                  value: controller.biometricEnabled.value,
                  onChanged: (value) async {
                    final ok = await controller.setBiometricEnabled(value);
                    if (!ok && value) {
                      Get.snackbar(
                        'Biometric',
                        'Biometric not available or authentication failed',
                        colorText: Colors.white,
                        backgroundColor: Colors.red,
                      );
                    }
                  },
                  activeColor: AppColors.primary,
                ),
                color: Colors.deepPurple,
              ),
            ),
            _buildDivider(context),
            _buildSettingItem(
              context: context,
              icon: Icons.color_lens_outlined,
              label: 'theme_color'.tr,
              value: 'change'.tr,
              onTap: () => _showColorPickerDialog(context),
              color: Colors.deepPurple,
            ),
            _buildDivider(context),
            Obx(
              () => _buildSettingItem(
                context: context,
                icon: Icons.palette_outlined,
                label: 'appearance'.tr,
                value: controller.themeMode.value.tr,
                onTap: () => _showThemeDialog(context),
                color: Colors.blue,
              ),
            ),
            _buildDivider(context),
            Obx(
              () => _buildSettingItem(
                context: context,
                icon: Icons.view_sidebar_outlined,
                label: 'drawer_style'.tr,
                value: _drawerStyleLabel(controller.drawerStyle.value).tr,
                onTap: () => _showDrawerStyleDialog(context),
                color: Colors.cyan,
              ),
            ),
            _buildDivider(context),
            Obx(
              () => _buildSettingItem(
                context: context,
                icon: Icons.language,
                label: 'language'.tr,
                value: _getLanguageName(
                  languageController.selectedLanguage.value,
                ),
                onTap: () => _showLanguageDialog(context, languageController),
                color: Colors.pink,
              ),
            ),
            _buildDivider(context),
            Obx(
              () => _buildSettingItem(
                context: context,
                icon: Icons.text_fields,
                label: 'font_size'.tr,
                value:
                    '${(controller.fontSizeMultiplier.value * 100).round()}%',
                onTap: () => _showFontSizeDialog(context),
                color: Colors.green,
              ),
            ),
            _buildDivider(context),
            Obx(
              () => _buildSettingItem(
                context: context,
                icon: Icons.notifications_outlined,
                label: 'push_notifications'.tr,
                trailing: Switch(
                  value: controller.notificationsEnabled.value,
                  onChanged: controller.toggleNotifications,
                  activeColor: AppColors.primary,
                ),
                color: Colors.orange,
              ),
            ),
            _buildDivider(context),

            // _buildSettingItem(
            //   context: context,
            //   icon: Icons.face,
            //   label: 'face_liveness_check'.tr,
            //   onTap: () => Get.toNamed(AppRoutes.liveness),
            //   color: Colors.teal,
            // ),
            // _buildDivider(context),
          ]),
          const SizedBox(height: 24),
          _buildSectionHeader(context, 'support'.tr),
          const SizedBox(height: 10),
          _buildCard(context, [
            _buildSettingItem(
              context: context,
              icon: Icons.help_outline,
              label: 'help_center'.tr,
              onTap: () {},
              color: Colors.teal,
            ),
            _buildDivider(context),
            _buildSettingItem(
              context: context,
              icon: Icons.privacy_tip_outlined,
              label: 'privacy_policy'.tr,
              onTap: () {},
              color: Colors.indigo,
            ),
            _buildDivider(context),
            _buildSettingItem(
              context: context,
              icon: Icons.description_outlined,
              label: 'terms_service'.tr,
              onTap: () {},
              color: Colors.purple,
            ),
          ]),
          const SizedBox(height: 40),
          Center(
            child: Text(
              '${'version'.tr} 1.0.0',
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.isDarkMode ? Colors.white38 : Colors.grey,
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  void _showFontSizeDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        title: Text('font_size'.tr),
        content: Obx(
          () => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Text('A', style: TextStyle(fontSize: 14)),
                  Expanded(
                    child: Slider(
                      value: controller.fontSizeMultiplier.value,
                      min: 0.8,
                      max: 1.1,
                      divisions: 6,
                      label:
                          '${(controller.fontSizeMultiplier.value * 100).round()}%',
                      onChanged: (value) => controller.updateFontSize(value),
                    ),
                  ),
                  const Text('A', style: TextStyle(fontSize: 24)),
                ],
              ),
              Text(
                '${(controller.fontSizeMultiplier.value * 100).round()}%',
                style: context.textTheme.titleMedium,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('ok'.tr)),
        ],
      ),
    );
  }

  void _showDrawerStyleDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          decoration: BoxDecoration(
            color: context.theme.scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
          ),
          child: Obx(
            () => Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'drawer_style'.tr,
                  style: context.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: context.isDarkMode
                        ? Colors.white
                        : AppColors.grey900,
                  ),
                ),
                const SizedBox(height: 12),
                for (final style in DrawerStyle.values)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      Icons.dashboard_customize_outlined,
                      color: controller.drawerStyle.value == style
                          ? AppColors.primary
                          : (context.isDarkMode
                                ? Colors.white70
                                : AppColors.grey600),
                    ),
                    title: Text(
                      _drawerStyleLabel(style).tr,
                      style: context.textTheme.bodyLarge?.copyWith(
                        fontWeight: controller.drawerStyle.value == style
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: controller.drawerStyle.value == style
                            ? AppColors.primary
                            : (context.isDarkMode
                                  ? Colors.white
                                  : AppColors.grey900),
                      ),
                    ),
                    trailing: controller.drawerStyle.value == style
                        ? Icon(Icons.check_circle, color: AppColors.primary)
                        : null,
                    onTap: () {
                      controller.updateDrawerStyle(style);
                      Navigator.of(context).pop();
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _drawerStyleLabel(DrawerStyle style) {
    switch (style) {
      case DrawerStyle.defaultStyle:
        return 'drawer_style_default';
      case DrawerStyle.style1:
        return 'drawer_style_1';
      case DrawerStyle.style2:
        return 'drawer_style_2';
      case DrawerStyle.style3:
        return 'drawer_style_3';
      case DrawerStyle.style4:
        return 'drawer_style_4';
    }
  }

  void _showThemeDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
          decoration: BoxDecoration(
            color: context.theme.scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'appearance'.tr,
                style: context.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.isDarkMode ? Colors.white : AppColors.grey900,
                ),
              ),
              const SizedBox(height: 20),
              Obx(
                () => Column(
                  children: [
                    _buildThemeOption(
                      context: context,
                      icon: Icons.brightness_auto_outlined,
                      label: 'system_default'.tr,
                      value: 'system',
                    ),
                    _buildThemeOption(
                      context: context,
                      icon: Icons.light_mode_outlined,
                      label: 'light'.tr,
                      value: 'light',
                    ),
                    _buildThemeOption(
                      context: context,
                      icon: Icons.dark_mode_outlined,
                      label: 'dark'.tr,
                      value: 'dark',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showColorPickerDialog(BuildContext context) async {
    Color tempColor = AppColors.primary;
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('pick_a_color'.tr),
          content: SingleChildScrollView(
            child: ColorPicker(
              color: tempColor,
              onColorChanged: (Color color) => tempColor = color,
              width: 44,
              height: 44,
              borderRadius: 22,
              heading: Text(
                'select_color'.tr,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              subheading: Text(
                'select_color_shade'.tr,
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('cancel'.tr),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('ok'.tr),
              onPressed: () {
                controller.updatePrimaryColor(tempColor);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildThemeOption({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String value,
  }) {
    final isSelected = controller.themeMode.value == value;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.1)
              : (context.isDarkMode ? Colors.white10 : AppColors.grey100),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: isSelected
              ? AppColors.primary
              : (context.isDarkMode ? Colors.white70 : AppColors.grey600),
          size: 20,
        ),
      ),
      title: Text(
        label,
        style: context.textTheme.bodyLarge?.copyWith(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          color: isSelected
              ? AppColors.primary
              : (context.isDarkMode ? Colors.white : AppColors.grey900),
        ),
      ),
      trailing: isSelected
          ? Icon(Icons.check_circle, color: AppColors.primary)
          : null,
      onTap: () {
        controller.updateTheme(value);
        Navigator.pop(context);
      },
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 0, 8),
      child: Text(
        title.toUpperCase(),
        style: context.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w700,
          color: context.isDarkMode ? Colors.white70 : AppColors.grey500,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: context.theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(children: children),
      ),
    );
  }

  Widget _buildDivider(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 0.5,
      color: context.isDarkMode ? Colors.white10 : AppColors.grey100,
      indent: 56,
    );
  }

  Widget _buildSettingItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    String? value,
    VoidCallback? onTap,
    Widget? trailing,
    required Color color,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  label,
                  style: context.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: context.isDarkMode
                        ? Colors.white
                        : AppColors.grey900,
                  ),
                ),
              ),
              if (value != null)
                Text(
                  value,
                  style: context.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: context.isDarkMode
                        ? Colors.white38
                        : AppColors.grey500,
                  ),
                ),
              if (trailing != null)
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: trailing,
                )
              else if (onTap != null)
                Icon(
                  Icons.chevron_right,
                  size: 20,
                  color: context.isDarkMode
                      ? Colors.white30
                      : AppColors.grey400,
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _getLanguageName(String code) {
    final languageController = Get.find<LanguageThemeController>();
    final language = languageController.languages.firstWhereOrNull(
      (l) => l.code == code,
    );
    return language?.name ?? code;
  }

  void _showLanguageDialog(
    BuildContext context,
    LanguageThemeController languageController,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        decoration: BoxDecoration(
          color: context.theme.scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'language'.tr,
              style: context.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: context.isDarkMode ? Colors.white : AppColors.grey900,
              ),
            ),
            const SizedBox(height: 12),
            Flexible(
              child: Obx(
                () => ListView.builder(
                  shrinkWrap: true,
                  itemCount: languageController.languages.length,
                  itemBuilder: (context, index) {
                    final language = languageController.languages[index];
                    final selected =
                        languageController.selectedLanguage.value ==
                        language.code;
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(language.name ?? ''),
                      subtitle: Text(language.nativeName ?? ''),
                      trailing: selected
                          ? Icon(Icons.check_circle, color: AppColors.primary)
                          : null,
                      onTap: () {
                        languageController.setLanguage(language.code!);
                        Navigator.of(ctx).pop();
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
