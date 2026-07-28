import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../core/services/api/api_service.dart';
import '../../../../../core/services/api/endpoints.dart';
import '../../../../../core/utils/local_storage/storage_helper.dart';
import '../models/principal_profile_model.dart';

class PrincipalProfileController extends GetxController {
  final ApiService _api = ApiService();

  final Rx<PrincipalProfileModel?> profile = Rx(null);
  final RxBool isLoading = false.obs;
  final RxBool isSaving = false.obs;
  final RxString errorMessage = ''.obs;
  final RxBool isEditMode = false.obs;

  // Display observables (view mode)
  final RxString displayName = ''.obs;
  final RxString displayRole = ''.obs;
  final RxString displayEmail = ''.obs;
  final RxString displayPhone = ''.obs;
  final RxString displayBranch = ''.obs;
  final RxString displayBranchLogo = ''.obs;

  // Contact
  final mobile = TextEditingController();
  final email = TextEditingController();
  final altContact = TextEditingController();
  final contactPerson = TextEditingController();
  final address = TextEditingController();

  // Personal
  final gender = TextEditingController();
  final dob = TextEditingController();
  final designation = TextEditingController();
  final category = TextEditingController();
  final religion = TextEditingController();
  final caste = TextEditingController();
  final district = TextEditingController();
  final tehsil = TextEditingController();
  final village = TextEditingController();

  // Branch
  final branchName = TextEditingController();
  final branchCode = TextEditingController();
  final group = TextEditingController();
  final className = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    _loadFromStorage();
    fetchProfile();
  }

  @override
  void onClose() {
    mobile.dispose();
    email.dispose();
    altContact.dispose();
    contactPerson.dispose();
    address.dispose();
    gender.dispose();
    dob.dispose();
    designation.dispose();
    category.dispose();
    religion.dispose();
    caste.dispose();
    district.dispose();
    tehsil.dispose();
    village.dispose();
    branchName.dispose();
    branchCode.dispose();
    group.dispose();
    className.dispose();
    super.onClose();
  }

  Future<void> _loadFromStorage() async {
    final details = await StorageHelper.getUserDetails();
    final role = await StorageHelper.getSelectedRole();
    displayName.value = _tc(details?.displayName ?? '').isNotEmpty
        ? _tc(details!.displayName)
        : 'User';
    displayRole.value = (role != null && role.isNotEmpty) ? _tc(role) : '';
    displayEmail.value = details?.email ?? '';
    displayPhone.value = details?.phoneNumber ?? '';
    displayBranch.value = details?.name ?? '';
    displayBranchLogo.value = details?.branchLogo ?? '';
  }

  Future<void> fetchProfile() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final details = await StorageHelper.getUserDetails();
      final userId = details?.userId;
      if (userId == null || userId == 0) {
        errorMessage.value = 'User ID not found. Please log in again.';
        return;
      }
      final raw = await _api.getJson(Endpoints.userProfile(userId));
      if (raw is Map<String, dynamic>) {
        final p = PrincipalProfileModel.fromJson(raw);
        profile.value = p;
        if (p.name != null && p.name!.isNotEmpty) {
          displayName.value = _tc(p.name!);
        }
        if (p.email != null && p.email!.isNotEmpty) {
          displayEmail.value = p.email!;
        }
        if (p.mobileNo != null && p.mobileNo!.isNotEmpty) {
          displayPhone.value = p.mobileNo!;
        }
        if (p.branchName != null && p.branchName!.isNotEmpty) {
          displayBranch.value = p.branchName!;
        }
      }
    } catch (e) {
      log('[PrincipalProfile] fetchProfile error: $e');
      errorMessage.value = 'Could not load profile details.';
    } finally {
      isLoading.value = false;
    }
  }

  void enterEditMode() {
    final p = profile.value;
    mobile.text = p?.mobileNo ?? displayPhone.value;
    email.text = p?.email ?? displayEmail.value;
    altContact.text = p?.contactNo ?? '';
    contactPerson.text = p?.contactPerson ?? '';
    address.text = p?.address ?? '';
    gender.text = p?.gender ?? '';
    dob.text = _fmtDate(p?.dob) ?? '';
    designation.text = p?.designationName ?? '';
    category.text = p?.category ?? '';
    religion.text = p?.religion ?? '';
    caste.text = p?.caste ?? '';
    district.text = p?.district ?? '';
    tehsil.text = p?.tehsil ?? '';
    village.text = p?.villageMohalla ?? '';
    branchName.text = p?.branchName ?? displayBranch.value;
    branchCode.text = p?.branchCode ?? '';
    group.text = p?.groupName ?? '';
    className.text = p?.className ?? '';
    isEditMode.value = true;
  }

  void cancelEdit() {
    isEditMode.value = false;
    errorMessage.value = '';
  }

  Future<void> saveProfile() async {
    isSaving.value = true;
    try {
      // TODO: wire to PUT /api/User/{userId}/profile when endpoint is ready
      // For now update local display values from the text controllers
      await Future.delayed(const Duration(milliseconds: 400));
      displayPhone.value = mobile.text.trim();
      displayEmail.value = email.text.trim();
      displayBranch.value = branchName.text.trim();
      Get.snackbar(
        'Saved',
        'Profile updated successfully',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
      isEditMode.value = false;
    } catch (e) {
      log('[PrincipalProfile] saveProfile error: $e');
      Get.snackbar(
        'Error',
        'Could not save profile. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isSaving.value = false;
    }
  }

  static String? _fmtDate(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    try {
      final dt = DateTime.parse(raw);
      return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
    } catch (_) {
      return raw;
    }
  }

  static String _tc(String s) => s
      .split(RegExp(r'[\s_]+'))
      .map((w) =>
          w.isEmpty ? '' : '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}')
      .join(' ');
}
