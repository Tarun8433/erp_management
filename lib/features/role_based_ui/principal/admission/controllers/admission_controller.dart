import 'dart:io';
import 'package:erp_management/core/services/api/api_service.dart';
import 'package:erp_management/core/services/api/endpoints.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class AdmissionController extends GetxController {
  final ApiService _api = ApiService();

  // Tab management (legacy)
  final tabController = Rxn<TabController>();

  // Step management
  final RxInt currentStep = 0.obs;
  final int totalSteps = 6;

  // Form fields
  final RxString selectedAcademicYear = ''.obs;
  final RxString selectedGroup = ''.obs;
  final RxString selectedClass = ''.obs;
  final RxString selectedGender = ''.obs;
  final RxString selectedReligion = ''.obs;
  final RxString selectedCategory = ''.obs;
  final RxString selectedSubCategory = ''.obs;

  final TextEditingController fullNameCtrl = TextEditingController();
  final TextEditingController fatherNameCtrl = TextEditingController();
  final TextEditingController motherNameCtrl = TextEditingController();
  final TextEditingController fatherMobileCtrl = TextEditingController();
  final TextEditingController motherMobileCtrl = TextEditingController();
  final TextEditingController fatherOccupationCtrl = TextEditingController();
  final TextEditingController motherOccupationCtrl = TextEditingController();
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController phoneCtrl = TextEditingController();
  final TextEditingController aadhaarCtrl = TextEditingController();
  final TextEditingController penNoCtrl = TextEditingController();
  final TextEditingController apaarIdCtrl = TextEditingController();
  final TextEditingController dobCtrl = TextEditingController();
  final TextEditingController districtCtrl = TextEditingController();
  final TextEditingController tehsilCtrl = TextEditingController();
  final TextEditingController villageCtrl = TextEditingController();
  final TextEditingController stateCtrl = TextEditingController();
  final TextEditingController pinCodeCtrl = TextEditingController();
  final TextEditingController remarkCtrl = TextEditingController();

  // Guardian Details
  final RxBool isGuardianSameAsFather = true.obs;
  final TextEditingController guardianNameCtrl = TextEditingController();
  final TextEditingController guardianMobileCtrl = TextEditingController();
  final TextEditingController guardianOccupationCtrl = TextEditingController();
  final TextEditingController guardianVillageCtrl = TextEditingController();
  final TextEditingController guardianTehsilCtrl = TextEditingController();
  final TextEditingController guardianDistrictCtrl = TextEditingController();
  final TextEditingController guardianStateCtrl = TextEditingController();
  final TextEditingController guardianPinCodeCtrl = TextEditingController();

  // Previous School Details
  final TextEditingController prevSchoolNameCtrl = TextEditingController();
  final TextEditingController prevClassCtrl = TextEditingController();
  final RxString selectedPrevResult = ''.obs;
  final RxString selectedPrevSessionYear = ''.obs;

  // SR No & Transport
  final RxBool generateSrNo = true.obs;
  final RxBool availTransport = false.obs;

  // Dropdown lists
  final List<String> academicYearList = ['2024-2025', '2025-2026', '2026-2027'];
  final List<String> groupList = ['Science', 'Commerce', 'Arts'];
  final List<String> classList = ['11th', '12th', '9th', '10th'];
  final List<String> genderList = ['Male', 'Female', 'Other'];
  final List<String> religionList = ['Hindu', 'Muslim', 'Sikh', 'Christian', 'Other'];
  final List<String> categoryList = ['General', 'OBC', 'SC', 'ST'];
  final List<String> subCategoryList = ['None', 'PWD', 'Ex-Serviceman'];
  final List<String> resultList = ['Passed', 'Failed', 'Promoted', 'Awaited'];
  final List<String> sessionYearList = ['2023-2024', '2024-2025', '2025-2026'];

  // Document upload state
  final RxMap<String, File?> uploadedFiles = <String, File?>{}.obs;
  final RxMap<String, bool> uploadProgress = <String, bool>{}.obs;
  final RxMap<String, double> uploadPercent = <String, double>{}.obs;
  final RxBool isSubmitting = false.obs;

  // Document keys
  static const List<String> requiredDocuments = [
    'student_photo',
    'student_aadhar_front',
    'student_aadhar_back',
    'father_aadhar_front',
    'father_aadhar_back',
    'mother_aadhar_front',
    'mother_aadhar_back',
    'transfer_certificate',
    'marksheet',
    'character_certificate',
  ];

  static const List<String> optionalDocuments = [];

  static const Map<String, String> documentNames = {
    'student_photo': 'Student Photo',
    'student_aadhar_front': 'Student Aadhaar Front',
    'student_aadhar_back': 'Student Aadhaar Back',
    'father_aadhar_front': 'Father Aadhaar Front',
    'father_aadhar_back': 'Father Aadhaar Back',
    'mother_aadhar_front': 'Mother Aadhaar Front',
    'mother_aadhar_back': 'Mother Aadhaar Back',
    'transfer_certificate': 'Transfer Certificate',
    'marksheet': 'Marksheet',
    'character_certificate': 'Character Certificate',
  };

  static const Map<String, IconData> documentIcons = {
    'student_photo': Icons.camera_alt_outlined,
    'student_aadhar_front': Icons.badge_outlined,
    'student_aadhar_back': Icons.badge_outlined,
    'father_aadhar_front': Icons.badge_outlined,
    'father_aadhar_back': Icons.badge_outlined,
    'mother_aadhar_front': Icons.badge_outlined,
    'mother_aadhar_back': Icons.badge_outlined,
    'transfer_certificate': Icons.description_outlined,
    'marksheet': Icons.assessment_outlined,
    'character_certificate': Icons.verified_user_outlined,
  };

  @override
  void onInit() {
    super.onInit();
    _initializeUploadStates();
    if (academicYearList.isNotEmpty) {
      selectedAcademicYear.value = academicYearList.last;
    }
  }

  void _initializeUploadStates() {
    for (final doc in requiredDocuments) {
      uploadedFiles[doc] = null;
      uploadProgress[doc] = false;
      uploadPercent[doc] = 0.0;
    }
    for (final doc in optionalDocuments) {
      uploadedFiles[doc] = null;
      uploadProgress[doc] = false;
      uploadPercent[doc] = 0.0;
    }
  }

  // Step management
  void nextStep() {
    if (currentStep.value < totalSteps - 1) {
      if (validateStep(currentStep.value)) {
        currentStep.value++;
      }
    }
  }

  void previousStep() {
    if (currentStep.value > 0) {
      currentStep.value--;
    }
  }

  void goToStep(int step) {
    if (step >= 0 && step < totalSteps) {
      if (step < currentStep.value) {
        currentStep.value = step;
      } else {
        for (int i = currentStep.value; i < step; i++) {
          if (!validateStep(i)) return;
        }
        currentStep.value = step;
      }
    }
  }

  bool validateStep(int step) {
    switch (step) {
      case 0:
        if (fullNameCtrl.text.trim().isEmpty) {
          _showError('Full Name is required');
          return false;
        }
        if (fatherMobileCtrl.text.trim().isEmpty) {
          _showError('Father Mobile is required');
          return false;
        }
        break;
      case 2:
        if (selectedGroup.value.isEmpty || selectedClass.value.isEmpty) {
          _showError('Group and Class are required');
          return false;
        }
        break;
      case 5:
        if (!areAllRequiredUploaded) {
          _showError('Please upload all required documents');
          return false;
        }
        break;
    }
    return true;
  }

  bool get areAllRequiredUploaded {
    return requiredDocuments.every((doc) => uploadedFiles[doc] != null);
  }

  void setUploadedFile(String docKey, File file) {
    uploadedFiles[docKey] = file;
    uploadProgress[docKey] = false;
    uploadPercent[docKey] = 100.0;
    uploadedFiles.refresh();
  }

  void removeUploadedFile(String docKey) {
    uploadedFiles[docKey] = null;
    uploadProgress[docKey] = false;
    uploadPercent[docKey] = 0.0;
    uploadedFiles.refresh();
  }

  Future<void> pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 5)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      dobCtrl.text = DateFormat('dd/MM/yyyy').format(picked);
    }
  }

  void _showError(String message) {
    Get.snackbar(
      'Required Field',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.orange,
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
    );
  }

  Future<void> submitAdmission() async {
    for (int i = 0; i < totalSteps; i++) {
      if (!validateStep(i)) {
        currentStep.value = i;
        return;
      }
    }

    isSubmitting.value = true;
    try {
      final formData = <String, dynamic>{
        'academic_year': selectedAcademicYear.value,
        'full_name': fullNameCtrl.text,
        'father_name': fatherNameCtrl.text,
        'mother_name': motherNameCtrl.text,
        'father_mobile': fatherMobileCtrl.text,
        'mother_mobile': motherMobileCtrl.text,
        'father_occupation': fatherOccupationCtrl.text,
        'mother_occupation': motherOccupationCtrl.text,
        'email': emailCtrl.text,
        'phone': phoneCtrl.text,
        'aadhar': aadhaarCtrl.text.replaceAll(' ', ''),
        'pen_no': penNoCtrl.text,
        'apaar_id': apaarIdCtrl.text,
        'dob': dobCtrl.text,
        'group': selectedGroup.value,
        'class': selectedClass.value,
        'gender': selectedGender.value,
        'religion': selectedReligion.value,
        'category': selectedCategory.value,
        'sub_category': selectedSubCategory.value,
        'district': districtCtrl.text,
        'tehsil': tehsilCtrl.text,
        'village': villageCtrl.text,
        'state': stateCtrl.text,
        'pincode': pinCodeCtrl.text,
        'remark': remarkCtrl.text,
        // Guardian
        'guardian_same_as_father': isGuardianSameAsFather.value,
        'guardian_name': guardianNameCtrl.text,
        'guardian_mobile': guardianMobileCtrl.text,
        'guardian_occupation': guardianOccupationCtrl.text,
        'guardian_village': guardianVillageCtrl.text,
        'guardian_tehsil': guardianTehsilCtrl.text,
        'guardian_district': guardianDistrictCtrl.text,
        'guardian_state': guardianStateCtrl.text,
        'guardian_pincode': guardianPinCodeCtrl.text,
        // Previous School
        'prev_school_name': prevSchoolNameCtrl.text,
        'prev_class': prevClassCtrl.text,
        'prev_result': selectedPrevResult.value,
        'prev_session_year': selectedPrevSessionYear.value,
        // SR No & Transport
        'generate_sr_no': generateSrNo.value,
        'avail_transport': availTransport.value,
      };

      for (final entry in uploadedFiles.entries) {
        if (entry.value != null) {
          formData[entry.key] = entry.value;
        }
      }

      final response = await _api.postMultipartnew(
        Endpoints.uploadDocuments(),
        formData,
      );

      if (response is Map && response['status'] == 'success') {
        Get.dialog(
          AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Icon(Icons.check_circle, color: Colors.green, size: 48),
            content: const Text(
              'Admission Successful!\n\nThe student registration has been completed.',
              textAlign: TextAlign.center,
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Get.back();
                  Get.offAllNamed('/dashboard');
                },
                child: const Text('Go to Dashboard'),
              ),
            ],
          ),
          barrierDismissible: false,
        );
      } else {
        throw Exception(response['message'] ?? 'Admission failed');
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Submission failed: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  @override
  void onClose() {
    fullNameCtrl.dispose();
    fatherNameCtrl.dispose();
    motherNameCtrl.dispose();
    fatherMobileCtrl.dispose();
    motherMobileCtrl.dispose();
    fatherOccupationCtrl.dispose();
    motherOccupationCtrl.dispose();
    emailCtrl.dispose();
    phoneCtrl.dispose();
    aadhaarCtrl.dispose();
    penNoCtrl.dispose();
    apaarIdCtrl.dispose();
    dobCtrl.dispose();
    districtCtrl.dispose();
    tehsilCtrl.dispose();
    villageCtrl.dispose();
    stateCtrl.dispose();
    pinCodeCtrl.dispose();
    remarkCtrl.dispose();
    guardianNameCtrl.dispose();
    guardianMobileCtrl.dispose();
    guardianOccupationCtrl.dispose();
    guardianVillageCtrl.dispose();
    guardianTehsilCtrl.dispose();
    guardianDistrictCtrl.dispose();
    guardianStateCtrl.dispose();
    guardianPinCodeCtrl.dispose();
    prevSchoolNameCtrl.dispose();
    prevClassCtrl.dispose();
    super.onClose();
  }
}

