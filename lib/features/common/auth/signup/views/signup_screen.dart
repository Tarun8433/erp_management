import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:intl/intl.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/widgets/custom_button.dart';
import '../../../../../core/widgets/custom_text_field.dart';
import '../../../../../core/widgets/custom_dropdown.dart';
import '../../../../../core/widgets/custom_multi_dropdown.dart';
import '../../../../../core/widgets/common_dialog.dart';
import '../controllers/signup_controller.dart';

class SignUpScreen extends GetView<SignUpController> {
  const SignUpScreen({super.key});

  String _initialsFromName(String rawName) {
    final cleaned = rawName.trim();
    if (cleaned.isEmpty || cleaned == 'N/A') return '?';

    final parts = cleaned
        .split(RegExp(r'\s+'))
        .where((p) => p.trim().isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';

    if (parts.length == 1) {
      final p = parts[0];
      return p.substring(0, min(2, p.length)).toUpperCase();
    }

    final first = parts[0];
    final second = parts[1];
    final a = first.isNotEmpty ? first[0] : '';
    final b = second.isNotEmpty ? second[0] : '';
    final combined = (a + b).trim();
    if (combined.isNotEmpty) return (a + b).toUpperCase();

    return first.substring(0, min(2, first.length)).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Obx(() {
      if (!controller.isFormVisible.value) {
        return _buildUserList(context);
      }

      return Scaffold(
        backgroundColor: colorScheme.surfaceContainerLow,
        appBar: AppBar(
          backgroundColor: colorScheme.primary.withValues(alpha: 0.3),
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
            onPressed: controller.hideForm,
          ),
          title: Text(
            'Create Account',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          centerTitle: true,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1.0),
            child: Container(color: colorScheme.outlineVariant, height: 1.0),
          ),
        ),
        body: Column(
          children: [
            _buildStepIndicator(context),
            Expanded(
              child: IndexedStack(
                index: controller.currentStep.value,
                children: [
                  _buildStep1(context),
                  _buildStep2(context),
                  _buildStep3(context),
                ],
              ),
            ),
            _buildBottomNavigation(context),
          ],
        ),
      );
    });
  }

  Widget _buildUserList(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLow,
      appBar: AppBar(
        backgroundColor: colorScheme.primary.withValues(alpha: 0.3),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
          onPressed: Get.back,
        ),
        title: Text(
          'User Management',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: colorScheme.primary),
            onPressed: controller.fetchUsers,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: colorScheme.outlineVariant, height: 1.0),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: controller.showForm,
        label: const Text('New User'),
        icon: const Icon(Icons.person_add_rounded),
        elevation: 4,
      ),
      body: Obx(() {
        if (controller.isLoadingUsers.value) {
          return _buildShimmerLoading(context);
        }

        if (controller.userList.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHigh,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.people_outline_rounded,
                    size: 64,
                    color: colorScheme.primary.withValues(alpha: 0.5),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'No users found',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tap the + button to create a new user',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: controller.userList.length,
          separatorBuilder: (_, _) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            return _buildUserCard(context, controller.userList[index]);
          },
        );
      }),
    );
  }

  Widget _buildUserCard(BuildContext context, Map<String, dynamic> user) {
    final theme = Theme.of(context);

    // Safely extract values
    String getValue(String key, {String? subKey}) {
      if (subKey != null && user[key] is Map) {
        return user[key][subKey]?.toString() ?? 'N/A';
      }
      return user[key]?.toString() ?? 'N/A';
    }

    final name = getValue('name');
    final email = getValue('email');
    final mobile = getValue('mobile');
    final department = user['department'] is Map
        ? user['department']['nameCode']?.toString() ?? 'N/A'
        : 'N/A';

    String company = 'N/A';
    String branch = 'N/A';
    String role = 'N/A';

    if (user['userCompany'] is List &&
        (user['userCompany'] as List).isNotEmpty) {
      final firstCompanyData = (user['userCompany'] as List).first;

      // Company
      if (firstCompanyData['company'] is Map) {
        company = firstCompanyData['company']['nameCode']?.toString() ?? 'N/A';
      }

      // Branch
      if (firstCompanyData['userBranch'] is List &&
          (firstCompanyData['userBranch'] as List).isNotEmpty) {
        final firstBranch = (firstCompanyData['userBranch'] as List).first;
        if (firstBranch['branch'] is Map) {
          branch = firstBranch['branch']['nameCode']?.toString() ?? 'N/A';
        }
      }

      // Role
      if (firstCompanyData['userRole'] is List &&
          (firstCompanyData['userRole'] as List).isNotEmpty) {
        final firstRole = (firstCompanyData['userRole'] as List).first;
        if (firstRole['role'] is Map) {
          role = firstRole['role']['nameCode']?.toString() ?? 'N/A';
        }
      }
    }

    final isActive = user['active'] == true;
    final createdDate = _getTimeAgo(user['createdAt']?.toString() ?? '');

    final initials = _initialsFromName(name);

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowSoft,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.1)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showUserDetails(context, user),
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: theme.primaryColor.withValues(
                        alpha: 0.1,
                      ),
                      child: Text(
                        initials,
                        style: context.textTheme.titleMedium?.copyWith(
                          color: theme.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  name,
                                  style: context.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Joined $createdDate',
                                style: context.textTheme.labelSmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                             
                               if (role != 'N/A') ...[
                                
                                Text(
                                  role,
                                  style: context.textTheme.labelSmall?.copyWith(
                                    color: theme
                                        .colorScheme
                                        .onSecondaryContainer,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: isActive
                            ? AppColors.success.withValues(alpha: 0.1)
                            : AppColors.error.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        isActive ? 'Active' : 'Inactive',
                        style: context.textTheme.labelSmall?.copyWith(
                          color: isActive ? AppColors.success : AppColors.error,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Content: Email & Mobile
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (email != 'N/A')
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          children: [
                            Icon(
                              Icons.email_outlined,
                              size: 14,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                email,
                                style: context.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (mobile != 'N/A')
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          children: [
                            Icon(
                              Icons.phone_outlined,
                              size: 14,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              mobile,
                              style: context.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Tags Row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (department != 'N/A')
                      _buildChip(
                        context,
                        department,
                        Icons.business,
                        color: AppColors.primaryBlueLight,
                        textColor: AppColors.primary,
                      ),
                    if (company != 'N/A')
                      _buildChip(
                        context,
                        company,
                        Icons.apartment,
                        color: AppColors.grey100,
                        textColor: AppColors.grey800,
                      ),
                    if (branch != 'N/A')
                      _buildChip(
                        context,
                        branch,
                        Icons.store,
                        color: AppColors.grey100,
                        textColor: AppColors.grey800,
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChip(
    BuildContext context,
    String label,
    IconData icon, {
    Color? color,
    Color? textColor,
  }) {
    final bgColor = color ?? AppColors.grey.withValues(alpha: 0.1);
    final txtColor = textColor ?? AppColors.grey800;
    final iconColor = textColor ?? AppColors.grey700;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: txtColor.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: iconColor),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              style: context.textTheme.labelSmall?.copyWith(
                color: txtColor,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              softWrap: false,
            ),
          ),
        ],
      ),
    );
  }

  String _getTimeAgo(String dateStr) {
    if (dateStr.isEmpty) return 'N/A';
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays > 365) {
        return DateFormat('MMM d, yyyy').format(date);
      } else if (difference.inDays > 30) {
        return DateFormat('MMM d').format(date);
      } else if (difference.inDays > 0) {
        return '${difference.inDays}d ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours}h ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes}m ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return dateStr;
    }
  }

  Widget _buildShimmerLoading(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 8),
      itemCount: 6,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: context.isDarkMode ? AppColors.grey800 : AppColors.grey300,
          highlightColor: context.isDarkMode
              ? AppColors.grey700
              : AppColors.grey100,
          child: Container(
            height: 160,
            decoration: BoxDecoration(
              color: context.isDarkMode
                  ? AppColors.darkSurface
                  : AppColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: context.isDarkMode
                    ? AppColors.grey800
                    : AppColors.grey200,
              ),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 120,
                            height: 14,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            width: 80,
                            height: 10,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 60,
                      height: 20,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  width: 200,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  width: 150,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const Spacer(),
                Row(
                  children: [
                    Container(
                      width: 80,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 80,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStepIndicator(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      color: colorScheme.surface,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      child: Obx(() {
        final current = controller.currentStep.value;
        return Row(
          children: [
            _buildStepItem(
              context,
              0,
              "Basic Info",
              Icons.person_outline,
              current >= 0,
            ),
            _buildStepDivider(context, current >= 1),
            _buildStepItem(
              context,
              1,
              "Work",
              Icons.work_outline,
              current >= 1,
            ),
            _buildStepDivider(context, current >= 2),
            _buildStepItem(
              context,
              2,
              "Company",
              Icons.business_outlined,
              current >= 2,
            ),
          ],
        );
      }),
    );
  }

  Widget _buildStepItem(
    BuildContext context,
    int step,
    String label,
    IconData icon,
    bool isActive,
  ) {
    final theme = Theme.of(context);
    final isSelected = controller.currentStep.value == step;
    final color = isSelected
        ? theme.colorScheme.primary
        : (isActive ? theme.colorScheme.primary : theme.colorScheme.outline);

    return GestureDetector(
      onTap: () => controller.goToStep(step),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected ? color : Colors.transparent,
              border: Border.all(color: color, width: 2),
            ),
            child: Icon(
              icon,
              size: 20,
              color: isSelected ? theme.colorScheme.onPrimary : color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepDivider(BuildContext context, bool isActive) {
    final theme = Theme.of(context);
    return Expanded(
      child: Container(
        height: 2,
        color: isActive
            ? theme.colorScheme.primary
            : theme.colorScheme.outlineVariant,
        margin: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 10,
        ), // vertical align with circle center roughly
      ),
    );
  }

  Widget _buildStep1(BuildContext context) {
    return SingleChildScrollView(
      child: Card(
        elevation: 4,
        shadowColor: Colors.black.withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User Type & Name
              Obx(
                () => CustomDropdown<String>(
                  label: 'User Type',
                  value: controller.selectedUserType.value,
                  items: controller.userTypes
                      .map(
                        (e) => DropdownMenuItem(
                          value: e['id'],
                          child: Text(e['name']!),
                        ),
                      )
                      .toList(),
                  onChanged: (val) => controller.selectedUserType.value = val,
                  isRequired: true,
                  hint: 'Select Type',
                ),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: controller.nameController,
                label: 'Name',
                hintText: 'Full Name',
                isRequired: true,
              ),
              const SizedBox(height: 16),
              // Mobile & Email
              CustomTextField(
                controller: controller.mobileController,
                label: 'Mobile',
                hintText: '9876543210',
                keyboardType: TextInputType.phone,
                isRequired: true,
                inputFormatters: [
                  LengthLimitingTextInputFormatter(10),
                  FilteringTextInputFormatter.digitsOnly,
                ],
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: controller.emailController,
                label: 'Email',
                hintText: 'user@example.com',
                keyboardType: TextInputType.emailAddress,
                isRequired: true,
              ),
              const SizedBox(height: 16),
              // DOB & Password
              GestureDetector(
                onTap: () => controller.selectDate(context),
                child: AbsorbPointer(
                  child: CustomTextField(
                    controller: controller.dobController,
                    label: 'Date of Birth',
                    hintText: 'DD-MM-YYYY',
                    suffixIcon: const Icon(
                      Icons.calendar_today_outlined,
                      size: 20,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Obx(
                () => CustomTextField(
                  controller: controller.passwordController,
                  label: 'Password',
                  hintText: '********',
                  obscureText: !controller.isPasswordVisible.value,
                  isRequired: true,
                  suffixIcon: IconButton(
                    icon: Icon(
                      controller.isPasswordVisible.value
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      size: 20,
                    ),
                    onPressed: controller.togglePasswordVisibility,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep2(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(0),
      child: Card(
        elevation: 4,
        shadowColor: Colors.black.withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Department & State
              Obx(
                () => CustomDropdown<String>(
                  label: 'Department',
                  value: controller.selectedDepartment.value,
                  items: controller.departments
                      .map(
                        (e) => DropdownMenuItem(
                          value: e['id'],
                          child: Text(e['name']!),
                        ),
                      )
                      .toList(),
                  onChanged: (val) => controller.selectedDepartment.value = val,
                  isRequired: true,
                  hint: 'Select Dept',
                ),
              ),
              const SizedBox(height: 16),
              Obx(
                () => CustomDropdown<String>(
                  label: 'State',
                  value: controller.selectedState.value,
                  items: controller.states
                      .map(
                        (e) => DropdownMenuItem(
                          value: e['id'],
                          child: Text(e['name']!),
                        ),
                      )
                      .toList(),
                  onChanged: (val) => controller.selectedState.value = val,
                  isRequired: true,
                  hint: 'Select State',
                ),
              ),
              const SizedBox(height: 16),
              // City & Postal Code
              Obx(
                () => CustomDropdown<String>(
                  label: 'City',
                  value: controller.selectedCity.value,
                  items: controller.cities
                      .map(
                        (e) => DropdownMenuItem(
                          value: e['id'],
                          child: Text(e['name']!),
                        ),
                      )
                      .toList(),
                  onChanged: (val) => controller.selectedCity.value = val,
                  isRequired: true,
                  hint: 'Select City',
                ),
              ),
              const SizedBox(height: 16),
              Obx(
                () => CustomDropdown<String>(
                  label: 'Postal Code',
                  value: controller.selectedPostalCode.value,
                  items: controller.postalCodes
                      .map(
                        (e) => DropdownMenuItem(
                          value: e['id'],
                          child: Text(e['name']!),
                        ),
                      )
                      .toList(),
                  onChanged: (val) => controller.selectedPostalCode.value = val,
                  isRequired: true,
                  hint: 'Select Code',
                ),
              ),
              const SizedBox(height: 16),
              // Vendor & Customer
              Obx(
                () => CustomMultiDropdown<String>(
                  label: 'Vendor',
                  selectedValues: controller.selectedVendors.toList(),
                  items: controller.vendors
                      .map(
                        (e) => DropdownMenuItem(
                          value: e['id'],
                          child: Text(e['name']!),
                        ),
                      )
                      .toList(),
                  onChanged: (val) => controller.selectedVendors.assignAll(val),
                  hint: 'Select Vendor',
                ),
              ),

              const SizedBox(height: 16),
              Obx(
                () => CustomMultiDropdown<String>(
                  label: 'Customer',
                  selectedValues: controller.selectedCustomers.toList(),
                  items: controller.customers
                      .map(
                        (e) => DropdownMenuItem(
                          value: e['id'],
                          child: Text(e['name']!),
                        ),
                      )
                      .toList(),
                  onChanged: (val) =>
                      controller.selectedCustomers.assignAll(val),
                  hint: 'Select Customer',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep3(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(0),
      child: Card(
        elevation: 4,
        shadowColor: Colors.black.withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Company & Branch
              Obx(
                () => CustomDropdown<String>(
                  label: 'Company',
                  value: controller.selectedCompany.value,
                  items: controller.companies
                      .map(
                        (e) => DropdownMenuItem(
                          value: e['id'],
                          child: Text(e['name']!),
                        ),
                      )
                      .toList(),
                  onChanged: (val) => controller.selectedCompany.value = val,
                  isRequired: true,
                  hint: 'Select Company',
                ),
              ),
              const SizedBox(height: 16),
              Obx(
                () => CustomMultiDropdown<String>(
                  label: 'Branch',
                  selectedValues: controller.selectedBranches.toList(),
                  items: controller.branches
                      .map(
                        (e) => DropdownMenuItem(
                          value: e['id'],
                          child: Text(e['name']!),
                        ),
                      )
                      .toList(),
                  onChanged: (val) =>
                      controller.selectedBranches.assignAll(val),
                  hint: 'Select Branch',
                ),
              ),
              const SizedBox(height: 16),
              // Roles & Add Button
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Obx(
                      () => CustomMultiDropdown<String>(
                        label: 'Role',
                        selectedValues: controller.selectedRoles.toList(),
                        items: controller.roles
                            .map(
                              (e) => DropdownMenuItem(
                                value: e['id'],
                                child: Text(e['name']!),
                              ),
                            )
                            .toList(),
                        onChanged: (val) =>
                            controller.selectedRoles.assignAll(val),
                        hint: 'Select Role',
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  SizedBox(
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        if (controller.selectedCompany.value == null ||
                            controller.selectedBranches.isEmpty ||
                            controller.selectedRoles.isEmpty) {
                          showCommonDialog(
                            title: 'Missing Fields',
                            message: 'Please select Company, Branch and Role',
                            isError: true,
                          );
                          return;
                        }
                        controller.addRole();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.add, size: 20),
                      label: const Text(
                        'ADD',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Added Roles List
              Obx(() {
                if (controller.addedRoles.isEmpty) {
                  return const SizedBox.shrink();
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Added Roles',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(color: colorScheme.outlineVariant),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            headingRowColor: WidgetStateProperty.all(
                              colorScheme.primary.withValues(alpha: 0.1),
                            ),
                            headingTextStyle: TextStyle(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                            dataRowMinHeight: 60,
                            dataRowMaxHeight: 80,
                            columns: const [
                              DataColumn(label: Text('#')),
                              DataColumn(label: Text('Company')),
                              DataColumn(label: Text('Branches')),
                              DataColumn(label: Text('Roles')),
                              DataColumn(label: Text('Action')),
                            ],
                            rows: controller.addedRoles.asMap().entries.map((
                              entry,
                            ) {
                              final index = entry.key;
                              final item = entry.value;
                              final branches = (item['branches'] as List)
                                  .map((e) => e['name'])
                                  .join(', ');
                              final roles = (item['roles'] as List)
                                  .map((e) => e['name'])
                                  .join(', ');

                              return DataRow(
                                cells: [
                                  DataCell(Text('${index + 1}')),
                                  DataCell(
                                    SizedBox(
                                      width: 150,
                                      child: Text(
                                        item['companyName']?.toString() ?? '',
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 2,
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    SizedBox(
                                      width: 200,
                                      child: Text(
                                        branches,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 3,
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    SizedBox(
                                      width: 200,
                                      child: Text(
                                        roles,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 3,
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    IconButton(
                                      icon: Icon(
                                        Icons.delete_outline,
                                        color: colorScheme.error,
                                      ),
                                      onPressed: () =>
                                          controller.removeRole(index),
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavigation(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Obx(() {
        final current = controller.currentStep.value;
        final isLast = current == 2;

        return Row(
          children: [
            if (current > 0)
              Expanded(
                child: OutlinedButton(
                  onPressed: controller.previousStep,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Back'),
                ),
              )
            else
              Expanded(
                child: OutlinedButton(
                  onPressed: controller.clearForm,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    side: BorderSide(
                      color: Theme.of(
                        context,
                      ).colorScheme.error.withValues(alpha: 0.5),
                    ),
                    foregroundColor: Theme.of(context).colorScheme.error,
                  ),
                  child: const Text('Clear'),
                ),
              ),
            const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: CustomButton(
                text: isLast ? 'Create Account' : 'Next',
                onPressed: isLast ? controller.onSignUp : controller.nextStep,
                height: 52,
                isLoading: isLast && controller.isSubmitting.value,
              ),
            ),
          ],
        );
      }),
    );
  }

  void _showUserDetails(BuildContext context, Map<String, dynamic> user) {
    final theme = Theme.of(context);

    // Safely extract values
    String getValue(String key, {String? subKey}) {
      if (subKey != null && user[key] is Map) {
        return user[key][subKey]?.toString() ?? 'N/A';
      }
      return user[key]?.toString() ?? 'N/A';
    }

    final name = getValue('name');
    final email = getValue('email');
    final mobile = getValue('mobile');

    // Address
    final state = user['state'] is Map
        ? user['state']['nameCode']?.toString() ?? 'N/A'
        : 'N/A';
    final city = user['city'] is Map
        ? user['city']['name']?.toString() ?? 'N/A'
        : 'N/A';
    final postalCode = user['postalCode'] is Map
        ? user['postalCode']['code']?.toString() ?? 'N/A'
        : 'N/A';
    final address = [
      city,
      state,
      postalCode,
    ].where((e) => e != 'N/A').join(', ');

    // Department
    final department = user['department'] is Map
        ? user['department']['nameCode']?.toString() ?? 'N/A'
        : 'N/A';

    // Company/Branch/Role Extraction
    String company = 'N/A';
    String branch = 'N/A';
    String role = 'N/A';

    if (user['userCompany'] is List &&
        (user['userCompany'] as List).isNotEmpty) {
      final firstCompanyData = (user['userCompany'] as List).first;
      if (firstCompanyData['company'] is Map) {
        company = firstCompanyData['company']['nameCode']?.toString() ?? 'N/A';
      }
      if (firstCompanyData['userBranch'] is List &&
          (firstCompanyData['userBranch'] as List).isNotEmpty) {
        final firstBranch = (firstCompanyData['userBranch'] as List).first;
        if (firstBranch['branch'] is Map) {
          branch = firstBranch['branch']['nameCode']?.toString() ?? 'N/A';
        }
      }
      if (firstCompanyData['userRole'] is List &&
          (firstCompanyData['userRole'] as List).isNotEmpty) {
        final firstRole = (firstCompanyData['userRole'] as List).first;
        if (firstRole['role'] is Map) {
          role = firstRole['role']['nameCode']?.toString() ?? 'N/A';
        }
      }
    }

    final isActive = user['active'] == true;
    final createdDate = _getTimeAgo(user['createdAt']?.toString() ?? '');

    final initials = _initialsFromName(name);

    Get.bottomSheet(
      Container(
        height: Get.height * 0.85,
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Handle bar
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.grey300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "User Details",
                    style: context.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.close),
                    style: IconButton.styleFrom(
                      backgroundColor: theme.colorScheme.surfaceContainerHighest
                          .withValues(alpha: 0.3),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile Header
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: theme.primaryColor.withValues(
                            alpha: 0.1,
                          ),
                          child: Text(
                            initials,
                            style: context.textTheme.titleLarge?.copyWith(
                              color: theme.primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: context.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              if (role != 'N/A')
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.secondaryContainer,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    role,
                                    style: context.textTheme.labelSmall?.copyWith(
                                      color: theme
                                          .colorScheme
                                          .onSecondaryContainer,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              
                              Text(
                                'Joined $createdDate',
                                style: context.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: isActive
                                ? AppColors.success.withValues(alpha: 0.1)
                                : AppColors.error.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            isActive ? 'Active' : 'Inactive',
                            style: context.textTheme.labelSmall?.copyWith(
                              color: isActive
                                  ? AppColors.success
                                  : AppColors.error,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Contact Info
                    Text(
                      "Contact Information",
                      style: context.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest
                            .withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: theme.dividerColor.withValues(alpha: 0.1),
                        ),
                      ),
                      child: Column(
                        children: [
                          _buildDetailRow(
                            context,
                            Icons.email_outlined,
                            "Email",
                            email,
                          ),
                          const Divider(height: 24),
                          _buildDetailRow(
                            context,
                            Icons.phone_outlined,
                            "Mobile",
                            mobile,
                          ),
                          if (address.isNotEmpty) ...[
                            const Divider(height: 24),
                            _buildDetailRow(
                              context,
                              Icons.location_on_outlined,
                              "Address",
                              address,
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Organization Info
                    Text(
                      "Organization",
                      style: context.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest
                            .withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: theme.dividerColor.withValues(alpha: 0.1),
                        ),
                      ),
                      child: Column(
                        children: [
                          _buildDetailRow(
                            context,
                            Icons.business,
                            "Department",
                            department,
                          ),
                          const Divider(height: 24),
                          _buildDetailRow(
                            context,
                            Icons.apartment,
                            "Company",
                            company,
                          ),
                          const Divider(height: 24),
                          _buildDetailRow(
                            context,
                            Icons.store,
                            "Branch",
                            branch,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: context.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
