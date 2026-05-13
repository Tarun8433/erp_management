import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:erp_management/core/utils/drawer_main/src/flutter_zoom_drawer.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/api/dilog/logout_confermation.dart';
import '../controllers/profile_controller.dart';

class ProfileScreen extends GetView<ProfileController> {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      extendBodyBehindAppBar: true,

      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(context),
            const SizedBox(height: 20),
            _buildProfileContent(context),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Obx(() {
      bool isLoading = controller.userName.value == 'Loading...';
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(24, 60, 24, 40),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary,
              AppColors.primary.withValues(alpha: 0.8),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(40),
            bottomRight: Radius.circular(40),
          ),
        ),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  icon: const Icon(Icons.menu, color: Colors.white),
                  onPressed: () => ZoomDrawer.of(context)?.toggle(),
                ),
                Spacer(),
                Stack(
                  children: [
                    GestureDetector(
                      onTap: () => controller.pickImage(context),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.5),
                            width: 2,
                          ),
                        ),
                        child: Obx(
                          () => CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.white,
                            backgroundImage:
                                controller.profileImage.value != null
                                ? FileImage(controller.profileImage.value!)
                                : null,
                            child: controller.profileImage.value != null
                                ? null
                                : (isLoading
                                      ? CircularProgressIndicator(
                                          strokeWidth: 3,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                AppColors.primary,
                                              ),
                                        )
                                      : Text(
                                          controller.userName.value.isNotEmpty
                                              ? controller.userName.value[0]
                                                    .toUpperCase()
                                              : 'U',
                                          style: context.textTheme.displaySmall
                                              ?.copyWith(
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.primary,
                                              ),
                                        )),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 5,
                      right: 5,
                      child: GestureDetector(
                        onTap: () => controller.pickImage(context),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.edit,
                            size: 16,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Spacer(),
                IconButton(
                  icon: const Icon(Icons.menu, color: Colors.transparent),
                  onPressed: () {},
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (isLoading)
              Container(
                width: 120,
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
              )
            else
              Text(
                controller.userName.value,
                style: context.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
            const SizedBox(height: 8),
            if (isLoading)
              Container(
                width: 180,
                height: 14,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(7),
                ),
              )
            else if (controller.userEmail.value.isNotEmpty)
              Text(
                controller.userEmail.value,
                style: context.textTheme.bodyLarge?.copyWith(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontWeight: FontWeight.w400,
                ),
              ),
          ],
        ),
      );
    });
  }

  Widget _buildProfileContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          _buildSectionHeader(context, 'General'),
          const SizedBox(height: 10),
          _buildCard(context, [
            Obx(
              () => _buildProfileItem(
                context: context,
                icon: Icons.language,
                label: 'language'.tr,
                value: controller.language.value,
                onTap: () => _showLanguageDialog(context),
                color: Colors.purple,
              ),
            ),
            _buildDivider(context),
          ]),
          const SizedBox(height: 24),

          _buildSectionHeader(context, 'Account'),
          const SizedBox(height: 10),
          _buildCard(context, [
            _buildActionItem(
              context: context,
              icon: Icons.vpn_key,
              label: 'reset_password'.tr,
              onTap: () => _showChangePasswordDialog(context),
              color: context.theme.colorScheme.primary,
            ),
            _buildDivider(context),
            _buildActionItem(
              context: context,
              icon: Icons.lock_reset,
              label: 'Change MPIN',
              onTap: () => _showChangeMpinDialog(context),
              color: context.theme.colorScheme.primary,
            ),
            _buildDivider(context),
            _buildActionItem(
              context: context,
              icon: Icons.logout,
              label: 'logout'.tr,
              onTap: () => showLogoutConfirmationDialog(context),
              color: AppColors.accentOrange,
              isDestructive: true,
            ),
          ]),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(4, 0, 0, 8),
        child: Text(
          title.toUpperCase(),
          style: context.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: context.isDarkMode ? Colors.white70 : AppColors.grey500,
            letterSpacing: 1.2,
          ),
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

  Widget _buildProfileItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String value,
    VoidCallback? onTap,
    required Color color,
  }) {
    bool isLoading = value == 'Loading...';
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: context.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: context.isDarkMode
                            ? Colors.white60
                            : AppColors.grey500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    if (isLoading)
                      Container(
                        width: 100,
                        height: 16,
                        decoration: BoxDecoration(
                          color: context.isDarkMode
                              ? Colors.white10
                              : AppColors.grey100,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      )
                    else
                      Text(
                        value,
                        style: context.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: context.isDarkMode
                              ? Colors.white
                              : AppColors.grey900,
                        ),
                      ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: context.isDarkMode ? Colors.white30 : AppColors.grey400,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color color,
    bool isDestructive = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
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
                  style: context.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isDestructive
                        ? Colors.red
                        : (context.isDarkMode
                              ? Colors.white
                              : AppColors.grey900),
                  ),
                ),
              ),
              if (!isDestructive)
                Icon(
                  Icons.chevron_right,
                  color: context.isDarkMode
                      ? Colors.white30
                      : AppColors.grey400,
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    final hasLanguages = controller.availableLanguages.isNotEmpty;
    final options = hasLanguages
        ? controller.availableLanguages.map((l) => l.name ?? '').toList()
        : const ['English', 'हिंदी'];

    _showSelectionBottomSheet(
      context: context,
      title: 'language'.tr,
      options: options,
      currentValue: controller.language.value,
      onSelect: (val) {
        if (hasLanguages) {
          final lang = controller.availableLanguages.firstWhereOrNull(
            (l) => l.name == val,
          );
          if (lang != null && lang.code != null) {
            controller.changeLanguage(lang.code!);
          }
        } else {
          controller.changeLanguage(val == 'हिंदी' ? 'hi' : 'en');
        }
      },
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final oldCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();
    final obscureOld = true.obs;
    final obscureNew = true.obs;
    final obscureConfirm = true.obs;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: cs.onSurface.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: context.theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.vpn_key, color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Change Password',
                    style: context.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: cs.onSurface,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(Icons.close, color: cs.onSurfaceVariant),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Update your account password',
                style: context.textTheme.bodySmall?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),
              Obx(
                () => _buildPasswordField(
                  context: context,
                  controller: oldCtrl,
                  label: 'Current Password',
                  obscure: obscureOld.value,
                  onToggle: () => obscureOld.value = !obscureOld.value,
                ),
              ),
              const SizedBox(height: 16),
              Obx(
                () => _buildPasswordField(
                  context: context,
                  controller: newCtrl,
                  label: 'New Password',
                  obscure: obscureNew.value,
                  onToggle: () => obscureNew.value = !obscureNew.value,
                ),
              ),
              const SizedBox(height: 16),
              Obx(
                () => _buildPasswordField(
                  context: context,
                  controller: confirmCtrl,
                  label: 'Confirm New Password',
                  obscure: obscureConfirm.value,
                  onToggle: () => obscureConfirm.value = !obscureConfirm.value,
                ),
              ),
              const SizedBox(height: 28),
              Obx(
                () => SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: controller.isChangingPassword.value
                        ? null
                        : () {
                            if (oldCtrl.text.isEmpty ||
                                newCtrl.text.isEmpty ||
                                confirmCtrl.text.isEmpty) {
                              Get.snackbar(
                                'Error',
                                'All fields are required',
                                backgroundColor: cs.error,
                                colorText: cs.onError,
                              );
                              return;
                            }
                            if (newCtrl.text != confirmCtrl.text) {
                              Get.snackbar(
                                'Error',
                                'New passwords do not match',
                                backgroundColor: cs.error,
                                colorText: cs.onError,
                              );
                              return;
                            }
                            controller.changePassword(
                              oldPassword: oldCtrl.text,
                              newPassword: newCtrl.text,
                            );
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: cs.primary,
                      foregroundColor: cs.onPrimary,
                      disabledBackgroundColor: cs.primary.withValues(
                        alpha: 0.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    child: controller.isChangingPassword.value
                        ? SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: cs.onPrimary,
                            ),
                          )
                        : const Text(
                            'Update Password',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required BuildContext context,
    required TextEditingController controller,
    required String label,
    required bool obscure,
    required VoidCallback onToggle,
  }) {
    final cs = Theme.of(context).colorScheme;
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: context.textTheme.bodyLarge?.copyWith(color: cs.onSurface),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: cs.onSurfaceVariant),
        filled: true,
        fillColor: cs.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: cs.outlineVariant, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: cs.primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        suffixIcon: IconButton(
          icon: Icon(
            obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            color: cs.onSurfaceVariant,
            size: 20,
          ),
          onPressed: onToggle,
        ),
      ),
    );
  }

  void _showChangeMpinDialog(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final oldCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: cs.onSurface.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: context.theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.lock_reset,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Change MPIN',
                    style: context.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: cs.onSurface,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(Icons.close, color: cs.onSurfaceVariant),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Enter your 4-digit MPIN',
                style: context.textTheme.bodySmall?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),
              _buildMpinField(
                context: context,
                controller: oldCtrl,
                label: 'Current MPIN',
              ),
              const SizedBox(height: 16),
              _buildMpinField(
                context: context,
                controller: newCtrl,
                label: 'New MPIN',
              ),
              const SizedBox(height: 16),
              _buildMpinField(
                context: context,
                controller: confirmCtrl,
                label: 'Confirm New MPIN',
              ),
              const SizedBox(height: 28),
              Obx(
                () => SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: controller.isChangingMpin.value
                        ? null
                        : () {
                            if (oldCtrl.text.isEmpty ||
                                newCtrl.text.isEmpty ||
                                confirmCtrl.text.isEmpty) {
                              Get.snackbar(
                                'Error',
                                'All fields are required',
                                backgroundColor: cs.error,
                                colorText: cs.onError,
                              );
                              return;
                            }
                            if (newCtrl.text != confirmCtrl.text) {
                              Get.snackbar(
                                'Error',
                                'New MPINs do not match',
                                backgroundColor: cs.error,
                                colorText: cs.onError,
                              );
                              return;
                            }
                            if (newCtrl.text.length != 4) {
                              Get.snackbar(
                                'Error',
                                'MPIN must be 4 digits',
                                backgroundColor: cs.error,
                                colorText: cs.onError,
                              );
                              return;
                            }
                            controller.changeMpin(
                              oldMpin: oldCtrl.text,
                              newMpin: newCtrl.text,
                            );
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: cs.primary,
                      foregroundColor: cs.onPrimary,
                      disabledBackgroundColor: cs.primary.withValues(
                        alpha: 0.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    child: controller.isChangingMpin.value
                        ? SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: cs.onPrimary,
                            ),
                          )
                        : const Text(
                            'Update MPIN',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMpinField({
    required BuildContext context,
    required TextEditingController controller,
    required String label,
  }) {
    final cs = Theme.of(context).colorScheme;
    return TextField(
      controller: controller,
      obscureText: true,
      keyboardType: TextInputType.number,
      maxLength: 4,
      textAlign: TextAlign.center,
      style: context.textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
        letterSpacing: 12,
        color: cs.onSurface,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: cs.onSurfaceVariant),
        counterText: '',
        filled: true,
        fillColor: cs.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: cs.outlineVariant, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: cs.primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
    );
  }

  void _showSelectionBottomSheet({
    required BuildContext context,
    required String title,
    required List<String> options,
    required String currentValue,
    required Function(String) onSelect,
    bool showSearch = false,
  }) {
    String searchQuery = '';
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final filteredOptions = options
                .where(
                  (opt) =>
                      opt.toLowerCase().contains(searchQuery.toLowerCase()),
                )
                .toList();

            return Container(
              height:
                  MediaQuery.of(context).size.height * (showSearch ? 0.7 : 0.5),
              decoration: BoxDecoration(
                color: context.theme.scaffoldBackgroundColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(25),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 12),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: context.isDarkMode
                          ? Colors.white12
                          : Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          title,
                          style: context.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: context.isDarkMode
                                ? Colors.white
                                : AppColors.grey900,
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.close,
                            color: context.isDarkMode
                                ? Colors.white70
                                : AppColors.grey600,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),
                  if (showSearch || options.length > 6)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Search...',
                          prefixIcon: const Icon(Icons.search, size: 20),
                          filled: true,
                          fillColor: context.isDarkMode
                              ? Colors.white.withValues(alpha: 0.05)
                              : AppColors.grey100,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 0,
                          ),
                        ),
                        onChanged: (val) {
                          setModalState(() {
                            searchQuery = val;
                          });
                        },
                      ),
                    ),
                  Expanded(
                    child: filteredOptions.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.search_off,
                                  size: 48,
                                  color: context.isDarkMode
                                      ? Colors.white12
                                      : Colors.grey[300],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No options found',
                                  style: TextStyle(
                                    color: context.isDarkMode
                                        ? Colors.white38
                                        : Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                            itemCount: filteredOptions.length,
                            separatorBuilder: (context, index) => Divider(
                              height: 1,
                              color: context.isDarkMode
                                  ? Colors.white10
                                  : Colors.grey[200],
                            ),
                            itemBuilder: (context, index) {
                              final option = filteredOptions[index];
                              final isSelected = option == currentValue;
                              return ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 4,
                                ),
                                title: Text(
                                  option,
                                  style: Theme.of(context).textTheme.bodyLarge
                                      ?.copyWith(
                                        color: isSelected
                                            ? AppColors.primary
                                            : (context.isDarkMode
                                                  ? Colors.white70
                                                  : AppColors.grey800),
                                        fontWeight: isSelected
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                      ),
                                ),
                                trailing: isSelected
                                    ? Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: AppColors.primary,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.check,
                                          color: Colors.white,
                                          size: 14,
                                        ),
                                      )
                                    : null,
                                onTap: () {
                                  onSelect(option);
                                  Navigator.pop(context);
                                },
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
