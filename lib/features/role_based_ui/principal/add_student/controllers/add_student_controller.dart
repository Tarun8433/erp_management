import 'dart:io';
import 'package:erp_management/core/services/api/api_service.dart';
import 'package:erp_management/core/services/api/endpoints.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class AddStudentController extends GetxController {
  final ApiService _api = ApiService();

  // Student Form Fields
  final RxString selectedAcademicYear = ''.obs;
  final RxString selectedGroup = ''.obs;
  final RxString selectedClass = ''.obs;
  final RxString selectedGender = ''.obs;
  final RxString selectedReligion = ''.obs;
  final RxString selectedCategory = ''.obs;
  final RxString selectedSubCategory = ''.obs;

  final TextEditingController fullNameCtrl = TextEditingController();
  final TextEditingController srNoCtrl = TextEditingController();
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController dobCtrl = TextEditingController();
  final TextEditingController aadhaarCtrl = TextEditingController();
  final TextEditingController penNoCtrl = TextEditingController();
  final TextEditingController apaarIdCtrl = TextEditingController();
  final TextEditingController districtCtrl = TextEditingController();
  final TextEditingController tehsilCtrl = TextEditingController();
  final TextEditingController villageCtrl = TextEditingController();

  // Parent Form Fields
  final TextEditingController fatherNameCtrl = TextEditingController();
  final TextEditingController motherNameCtrl = TextEditingController();
  final TextEditingController mobileNoCtrl = TextEditingController();

  // Student Photo
  final Rxn<File> studentPhoto = Rxn<File>();
  final RxBool isSubmitting = false.obs;

  // Dropdown lists
  final List<String> academicYearList = ['2024-2025', '2025-2026', '2026-2027'];
  final List<String> groupList = ['Science', 'Commerce', 'Arts'];
  final List<String> classList = ['11th', '12th', '9th', '10th'];
  final List<String> genderList = ['Male', 'Female', 'Other'];
  final List<String> religionList = ['Hindu', 'Muslim', 'Sikh', 'Christian', 'Other'];
  final List<String> categoryList = ['General', 'OBC', 'SC', 'ST'];
  final List<String> subCategoryList = ['None', 'PWD', 'Ex-Serviceman'];

  @override
  void onInit() {
    super.onInit();
    if (academicYearList.isNotEmpty) {
      selectedAcademicYear.value = academicYearList.last;
    }
  }

  Future<void> pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 5)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      dobCtrl.text = DateFormat('dd-MM-yyyy').format(picked);
    }
  }

  void setStudentPhoto(File file) {
    studentPhoto.value = file;
  }

  void removeStudentPhoto() {
    studentPhoto.value = null;
  }

  bool validateForm() {
    if (fullNameCtrl.text.trim().isEmpty) {
      _showError('Student Full Name is required');
      return false;
    }
    if (selectedGroup.value.isEmpty) {
      _showError('Group selection is required');
      return false;
    }
    if (selectedClass.value.isEmpty) {
      _showError('Class selection is required');
      return false;
    }
    if (motherNameCtrl.text.trim().isEmpty) {
      _showError('Mother Name is required');
      return false;
    }
    return true;
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

  Future<void> saveStudent() async {
    if (!validateForm()) return;

    isSubmitting.value = true;
    try {
      final formData = <String, dynamic>{
        'academic_year': selectedAcademicYear.value,
        'group': selectedGroup.value,
        'class': selectedClass.value,
        'full_name': fullNameCtrl.text,
        'sr_no': srNoCtrl.text,
        'email': emailCtrl.text,
        'dob': dobCtrl.text,
        'gender': selectedGender.value,
        'aadhar': aadhaarCtrl.text,
        'pen_no': penNoCtrl.text,
        'apaar_id': apaarIdCtrl.text,
        'religion': selectedReligion.value,
        'category': selectedCategory.value,
        'sub_category': selectedSubCategory.value,
        'district': districtCtrl.text,
        'tehsil': tehsilCtrl.text,
        'village': villageCtrl.text,
        'father_name': fatherNameCtrl.text,
        'mother_name': motherNameCtrl.text,
        'mobile_no': mobileNoCtrl.text,
      };

      if (studentPhoto.value != null) {
        formData['student_photo'] = studentPhoto.value;
      }

      // Note: Assuming a standard endpoint for adding student. 
      // Adjust if Endpoints class has a specific one.
      final response = await _api.postMultipartnew(
        Endpoints.uploadDocuments(), // Placeholder, adjust as needed
        formData,
      );

      if (response is Map && response['status'] == 'success') {
        Get.dialog(
          AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Icon(Icons.check_circle, color: Colors.green, size: 48),
            content: const Text(
              'Student added successfully!',
              textAlign: TextAlign.center,
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Get.back(); // Close dialog
                  Get.back(); // Go back to previous screen
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      } else {
        throw Exception(response['message'] ?? 'Failed to save student');
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to save student: $e',
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
    srNoCtrl.dispose();
    emailCtrl.dispose();
    dobCtrl.dispose();
    aadhaarCtrl.dispose();
    penNoCtrl.dispose();
    apaarIdCtrl.dispose();
    districtCtrl.dispose();
    tehsilCtrl.dispose();
    villageCtrl.dispose();
    fatherNameCtrl.dispose();
    motherNameCtrl.dispose();
    mobileNoCtrl.dispose();
    super.onClose();
  }
}
