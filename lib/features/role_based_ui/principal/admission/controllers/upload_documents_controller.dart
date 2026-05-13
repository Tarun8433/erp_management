// upload_documents_controller.dart
import 'dart:io';
import 'package:erp_management/core/services/api/api_service.dart';
import 'package:erp_management/core/services/api/endpoints.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UploadDocumentsController extends GetxController {
  final ApiService _api = ApiService();

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
  ];

  static const List<String> optionalDocuments = [
    'transfer_certificate',
    'marksheet',
  ];

  // Document display names
  static const Map<String, String> documentNames = {
    'student_photo': 'Student Photo',
    'student_aadhar_front': 'Student Front Aadhar Card',
    'student_aadhar_back': 'Student Back Aadhar Card',
    'father_aadhar_front': 'Father Front Aadhar Card',
    'father_aadhar_back': 'Father Back Aadhar Card',
    'mother_aadhar_front': 'Mother Front Aadhar Card',
    'mother_aadhar_back': 'Mother Back Aadhar Card',
    'transfer_certificate': 'Transfer Certificate',
    'marksheet': 'MarkSheet',
  };

  // Document icons
  static const Map<String, IconData> documentIcons = {
    'student_photo': Icons.person,
    'student_aadhar_front': Icons.credit_card,
    'student_aadhar_back': Icons.credit_card,
    'father_aadhar_front': Icons.credit_card,
    'father_aadhar_back': Icons.credit_card,
    'mother_aadhar_front': Icons.credit_card,
    'mother_aadhar_back': Icons.credit_card,
    'transfer_certificate': Icons.description,
    'marksheet': Icons.grade,
  };

  // Student ID from previous screen (passed via GetX arguments)
  String get studentId => Get.arguments?['student_id'] ?? '';

  @override
  void onInit() {
    super.onInit();
    _initializeUploadStates();
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

  bool isRequiredDocumentUploaded(String docKey) {
    return uploadedFiles[docKey] != null;
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

 Future<void> submitDocuments() async {
  if (!areAllRequiredUploaded) {
    Get.snackbar(
      'Error',
      'Please upload all required documents',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
    return;
  }

  isSubmitting.value = true;

  try {
    final formData = <String, dynamic>{};
    formData['student_id'] = studentId;

    // Add all uploaded files
    for (final entry in uploadedFiles.entries) {
      if (entry.value != null) {
        formData[entry.key] = entry.value; // Pass the File object directly
      }
    }

    // Call your existing postMultipart method
    final response = await _api.postMultipartnew(
      Endpoints.uploadDocuments(), // Your endpoint
      formData,
    );

    if (response is Map && response['status'] == 'success') {
      Get.dialog(
        AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Icon(Icons.check_circle, color: Colors.green, size: 48),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Documents Uploaded Successfully!',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                response['message'] ?? 'Your documents have been submitted.',
                textAlign: TextAlign.center,
              ),
            ],
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
      throw Exception(response['message'] ?? 'Upload failed');
    }
  } catch (e) {
    Get.snackbar(
      'Upload Failed',
      'Error: $e',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  } finally {
    isSubmitting.value = false;
  }
}
}