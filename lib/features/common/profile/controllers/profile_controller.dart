import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:io';
import '../../../../core/models/user_data.dart';
import '../../../../core/models/financial_year.dart';
import '../../../../core/utils/local_storage/storage_helper.dart';
import '../../../../core/utils/camera/camera_service.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/utils/permissions/permission_handler.dart';
import '../../../../core/utils/language_refresh_actions.dart';
import '../../auth/data/models/login_response.dart';
import '../../auth/data/repositories/auth_repository.dart';
import '../../../../core/widgets/common_dialog.dart';

import '../../menu/controllers/menu_controller.dart' as app_menu;

class ProfileController extends GetxController {
  final AuthRepository _authRepository = Get.find<AuthRepository>();

  final RxBool isChangingPassword = false.obs;
  final RxBool isChangingMpin = false.obs;

  final RxString language = 'English'.obs;
  final RxString financialYear = '...'.obs;
  final RxString company = '...'.obs;
  final RxString branch = 'N/A'.obs;
  final RxString role = '...'.obs;
  final RxString userName = '...'.obs;
  final RxString userEmail = '...'.obs;
  final Rx<File?> profileImage = Rx<File?>(null);

  final RxList<FinancialYear> allFinancialYears = <FinancialYear>[].obs;
  final RxList<UserCompany> allCompanies = <UserCompany>[].obs;
  final RxList<UserBranch> availableBranches = <UserBranch>[].obs;
  final RxList<UserRole> availableRoles = <UserRole>[].obs;
  final RxList<LanguageData> availableLanguages = <LanguageData>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadUserData();
  }

  Future<void> loadUserData() async {
    final langCode = await StorageHelper.getLanguage();
    final UserData? userData = await StorageHelper.getUserData();
    final selectedFY = await StorageHelper.getSelectedFinancialYear();
    final selectedCompany = await StorageHelper.getSelectedCompany();
    final selectedBranch = await StorageHelper.getSelectedBranch();
    final selectedRole = await StorageHelper.getSelectedRole();
    final profileImagePath = await StorageHelper.getProfileImage();

    // Load profile image
    if (profileImagePath != null) {
      final file = File(profileImagePath);
      if (await file.exists()) {
        profileImage.value = file;
      }
    }

    // Load all available options from userData
    allFinancialYears.value = await StorageHelper.getFinancialYears();
    availableLanguages.value = await StorageHelper.getLanguages();

    if (userData != null && userData.userCompany != null) {
      allCompanies.value = userData.userCompany!;

      // Find current selected company's branches and roles
      if (selectedCompany != null) {
        final currentCompany = allCompanies.firstWhereOrNull(
          (c) => c.company?.name == selectedCompany,
        );
        if (currentCompany != null) {
          availableBranches.value = currentCompany.userBranch ?? [];
          availableRoles.value = currentCompany.userRole ?? [];
        }
      }
    }

    if (availableLanguages.isNotEmpty) {
      final selectedLang = availableLanguages.firstWhereOrNull((l) => 
        l.code == langCode || l.code?.split('_')[0] == langCode);
      language.value = selectedLang?.name ?? langCode ?? 'English';
    } else {
      switch (langCode) {
        case 'hi': language.value = 'Hindi'; break;
        case 'gu': language.value = 'Gujarati'; break;
        case 'ta': language.value = 'Tamil'; break;
        case 'te': language.value = 'Telugu'; break;
        case 'ml': language.value = 'Malayalam'; break;
        case 'mr': language.value = 'Marathi'; break;
        case 'fr': language.value = 'French'; break;
        case 'de': language.value = 'German'; break;
        case 'tl': language.value = 'Tagalog'; break;
        case 'ms': language.value = 'Malay'; break;
        case 'id': language.value = 'Indonesian'; break;
        case 'ar': language.value = 'Arabic'; break;
        default: language.value = 'English';
      }
    }
    
    if (userData != null) {
      userName.value = userData.name ?? 'User';
      userEmail.value = userData.email ?? '';
    }
    company.value = selectedCompany ?? 'N/A';
    branch.value = selectedBranch ?? 'N/A';
    role.value = selectedRole ?? 'N/A';
    financialYear.value = selectedFY?.label ?? 'N/A';
  }

  Future<void> onFinancialYearSelected(String value) async {
    final selected = allFinancialYears.firstWhereOrNull(
      (e) => e.label == value,
    );
    if (selected != null) {
      await StorageHelper.saveSelectedFinancialYear(selected);
      await loadUserData();
      
      // Refresh menu after financial year change
      if (Get.isRegistered<app_menu.MenuController>()) {
        Get.find<app_menu.MenuController>().fetchAppMenu();
      }
    }
  }

  Future<void> onCompanySelected(String value) async {
    final selected = allCompanies.firstWhereOrNull(
      (e) => e.company?.name == value,
    );
    if (selected != null) {
      await StorageHelper.saveSelectedCompany(value);

      // When company changes, we should also update available branches and roles
      if (selected.userBranch != null && selected.userBranch!.isNotEmpty) {
        await StorageHelper.saveSelectedBranch(
          selected.userBranch!.first.branch?.branchName ?? 'N/A',
        );
      }
      
      String? newRoleId;
      if (selected.userRole != null && selected.userRole!.isNotEmpty) {
        final firstRole = selected.userRole!.first;
        await StorageHelper.saveSelectedRole(
          firstRole.role?.roleName ?? 'N/A',
        );
        if (firstRole.roleId != null) {
          newRoleId = firstRole.roleId;
          await StorageHelper.saveSelectedRoleId(newRoleId!);
        }
      }

      await loadUserData();
      
      // Refresh menu after company change
      if (Get.isRegistered<app_menu.MenuController>()) {
        Get.find<app_menu.MenuController>().fetchAppMenu();
      }
    }
  }

  Future<void> onBranchSelected(String value) async {
    await StorageHelper.saveSelectedBranch(value);
    await loadUserData();
    
    // Refresh menu after branch change
    if (Get.isRegistered<app_menu.MenuController>()) {
      Get.find<app_menu.MenuController>().fetchAppMenu();
    }
  }

  Future<void> onRoleSelected(String value) async {
    final selectedRole = availableRoles.firstWhereOrNull(
      (r) => r.role?.roleName == value,
    );

    if (selectedRole != null) {
      await StorageHelper.saveSelectedRole(value);
      if (selectedRole.roleId != null) {
        await StorageHelper.saveSelectedRoleId(selectedRole.roleId!);
      }
      await loadUserData();
      
      // Refresh menu after role change
      if (Get.isRegistered<app_menu.MenuController>()) {
        Get.find<app_menu.MenuController>().fetchAppMenu();
      }
    }
  }

  Future<void> changeLanguage(String code) async {
    // Save short language code
    String shortCode = code.split('_')[0];
    
    await StorageHelper.saveLanguage(shortCode);

    var locale = Locale(shortCode);
    Get.updateLocale(locale);
    
    // Call the API refresh logic
    await LanguageRefreshActions.refresh(shortCode);
    
    await loadUserData();
  }

  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      isChangingPassword.value = true;
      final response = await _authRepository.changePassword(
        oldPassword: oldPassword,
        newPassword: newPassword,
      );
      if (response['status'] == 'success') {
        Get.back(); // close dialog
        showCommonDialog(
          title: 'Success',
          message: response['message'] ?? 'Password changed successfully',
          isError: false,
        );
      } else {
        showCommonDialog(
          title: 'Error',
          message: response['message'] ?? 'Failed to change password',
          isError: true,
        );
      }
    } catch (e) {
      showCommonDialog(
        title: 'Error',
        message: e.toString().replaceAll('Exception:', '').trim(),
        isError: true,
      );
    } finally {
      isChangingPassword.value = false;
    }
  }

  Future<void> changeMpin({
    required String oldMpin,
    required String newMpin,
  }) async {
    try {
      isChangingMpin.value = true;
      final response = await _authRepository.changeMpin(
        oldMpin: oldMpin,
        newMpin: newMpin,
      );
      if (response['status'] == 'success') {
        Get.back(); // close dialog
        showCommonDialog(
          title: 'Success',
          message: response['message'] ?? 'MPIN changed successfully',
          isError: false,
        );
      } else {
        showCommonDialog(
          title: 'Error',
          message: response['message'] ?? 'Failed to change MPIN',
          isError: true,
        );
      }
    } catch (e) {
      showCommonDialog(
        title: 'Error',
        message: e.toString().replaceAll('Exception:', '').trim(),
        isError: true,
      );
    } finally {
      isChangingMpin.value = false;
    }
  }

  Future<void> pickImage(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Change Profile Picture',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildImageSourceOption(
                  context,
                  Icons.camera_alt,
                  'Camera',
                  () async {
                    Navigator.pop(context);
                    if (await AppPermissionHandler()
                        .requestCameraPermission()) {
                      if (context.mounted) {
                        final file = await CameraService.openCustomCamera(
                          context,
                        );
                        if (file != null) {
                          profileImage.value = file;
                          await StorageHelper.saveProfileImage(file.path);
                          if (Get.isRegistered<app_menu.MenuController>()) {
                            Get.find<app_menu.MenuController>().loadProfileImage();
                          }
                        }
                      }
                    }
                  },
                ),
                _buildImageSourceOption(
                  context,
                  Icons.photo_library,
                  'Gallery',
                  () async {
                    Navigator.pop(context);
                    // Uses the Android system photo picker — no media permission needed.
                    final XFile? picked = await ImagePicker().pickImage(
                      source: ImageSource.gallery,
                      imageQuality: 80,
                    );
                    if (picked != null) {
                      final file = File(picked.path);
                      profileImage.value = file;
                      await StorageHelper.saveProfileImage(file.path);
                      if (Get.isRegistered<app_menu.MenuController>()) {
                        Get.find<app_menu.MenuController>().loadProfileImage();
                      }
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSourceOption(
    BuildContext context,
    IconData icon,
    String label,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: Theme.of(context).primaryColor),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}
