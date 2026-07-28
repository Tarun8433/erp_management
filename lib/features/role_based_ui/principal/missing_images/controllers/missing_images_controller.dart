import 'dart:io';
import 'package:erp_management/core/controllers/session_controller.dart';
import 'package:erp_management/core/models/category_model.dart';
import 'package:erp_management/core/services/api/api_service.dart';
import 'package:erp_management/core/services/api/endpoints.dart';
import 'package:erp_management/core/utils/local_storage/storage_helper.dart';
import 'package:erp_management/features/role_based_ui/principal/new_student_list/models/student_list_response.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class MissingImagesController extends GetxController {
  final ApiService _api = ApiService();
  final SessionController sessionController = Get.put(SessionController());

  final RxString selectedSession = ''.obs;
  final RxString selectedGroup = ''.obs;
  final RxString selectedClass = ''.obs;
  final RxString searchText = ''.obs;
  final RxBool isLoading = false.obs;
  final RxString viewMode = 'card'.obs;
  final RxDouble baseFontSize = 12.0.obs;

  void toggleViewMode() {
    viewMode.value = viewMode.value == 'table' ? 'card' : 'table';
  }

  final RxList<String> sessionYearList = <String>[].obs;
  final RxList<String> groupList = <String>[].obs;
  final RxList<String> classList = <String>[].obs;

  List<CategoryModel> _loadedGroups = [];
  List<CategoryModel> _loadedClasses = [];

  final RxList<StudentListResponse> allStudents = <StudentListResponse>[].obs;
  final RxList<StudentListResponse> filteredStudents =
      <StudentListResponse>[].obs;
  final RxInt totalFetched = 0.obs;

  final searchCtrl = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    _loadSessions();
    ever(selectedSession, (_) => _fetchGroups());
    ever(selectedGroup, (_) => _fetchClasses());
  }

  void _loadSessions() {
    ever(sessionController.sessionList, (sessions) {
      final names = sessions
          .map((e) => e.sessionName ?? '')
          .where((n) => n.isNotEmpty)
          .toList();
      sessionYearList.assignAll(names);
      if (selectedSession.value.isNotEmpty && !names.contains(selectedSession.value)) {
        selectedSession.value = '';
      }
    });
    if (sessionController.sessionList.isNotEmpty) {
      final names = sessionController.sessionList
          .map((e) => e.sessionName ?? '')
          .where((n) => n.isNotEmpty)
          .toList();
      sessionYearList.assignAll(names);
      if (selectedSession.value.isNotEmpty && !names.contains(selectedSession.value)) {
        selectedSession.value = '';
      }
    }
  }

  Future<void> _fetchGroups() async {
    final session = sessionController.sessionList.firstWhereOrNull(
      (e) => e.sessionName == selectedSession.value,
    );
    if (session == null || session.sessionId == null) return;

    _loadedGroups = await sessionController.getGroupList(session.sessionId);
    groupList.assignAll(
      _loadedGroups
          .map((g) => g.name ?? '')
          .where((n) => n.isNotEmpty)
          .toList(),
    );
    if (selectedGroup.value.isNotEmpty && !groupList.contains(selectedGroup.value)) {
      selectedGroup.value = '';
    } else if (groupList.isEmpty) {
      selectedGroup.value = '';
    }
  }

  Future<void> _fetchClasses() async {
    final session = sessionController.sessionList.firstWhereOrNull(
      (e) => e.sessionName == selectedSession.value,
    );
    final group = _loadedGroups.firstWhereOrNull(
      (g) => g.name == selectedGroup.value,
    );
    if (session?.sessionId == null || group?.id == null) return;

    _loadedClasses = await sessionController.getClassList(
      group!.id!,
      session!.sessionId!,
    );
    classList.assignAll(
      _loadedClasses
          .map((c) => c.name ?? '')
          .where((n) => n.isNotEmpty)
          .toList(),
    );
    if (selectedClass.value.isNotEmpty && !classList.contains(selectedClass.value)) {
      selectedClass.value = '';
    } else if (classList.isEmpty) {
      selectedClass.value = '';
    }
  }

  Future<void> fetchMissingImages() async {
    isLoading.value = true;
    allStudents.clear();
    filteredStudents.clear();
    totalFetched.value = 0;

    try {
      final session = sessionController.sessionList.firstWhereOrNull(
        (e) => e.sessionName == selectedSession.value,
      );
      final group = _loadedGroups.firstWhereOrNull(
        (g) => g.name == selectedGroup.value,
      );
      final cls = _loadedClasses.firstWhereOrNull(
        (c) => c.name == selectedClass.value,
      );

      final payload = {
        "isActive": -1,
        "branchId": 0,
        "sessionId": session?.sessionId ?? 0,
        "groupId": group?.id ?? 0,
        "classId": cls?.id ?? 0,
        "top": 0,
        "searchText": "",
      };

      final response =
          await _api.postJson(Endpoints.getStudentList(), payload);

      List<dynamic> listData = [];
      if (response is Map<String, dynamic>) {
        listData = response['result'] ?? response['data'] ?? [];
      } else if (response is List) {
        listData = response;
      }

      final all =
          listData.map((e) => StudentListResponse.fromJson(e)).toList();

      // Keep only students whose photo is null/empty.
      final missing =
          all.where((s) => (s.photo ?? '').trim().isEmpty).toList();

      totalFetched.value = missing.length;
      allStudents.assignAll(missing);
      _applySearch(searchText.value);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to fetch students: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void onSearch(String query) {
    searchText.value = query;
    _applySearch(query);
  }

  void _applySearch(String query) {
    if (query.isEmpty) {
      filteredStudents.assignAll(allStudents);
    } else {
      filteredStudents.assignAll(
        allStudents.where((s) {
          final q = query.toLowerCase();
          return (s.firstName ?? '').toLowerCase().contains(q) ||
              (s.className ?? '').toLowerCase().contains(q) ||
              (s.groupName ?? '').toLowerCase().contains(q) ||
              (s.fatherMobile ?? '').toLowerCase().contains(q) ||
              (s.rollNumber ?? '').toLowerCase().contains(q) ||
              (s.srno ?? '').toLowerCase().contains(q) ||
              (s.aadharNo ?? '').toLowerCase().contains(q) ||
              (s.penno ?? '').toLowerCase().contains(q) ||
              (s.apaarId ?? '').toLowerCase().contains(q);
        }).toList(),
      );
    }
  }

  Future<void> pickFromGallery(StudentListResponse student) async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
    );
    if (picked == null) return;
    await _cropAndUpload(picked.path, student);
  }

  Future<void> pickFromCamera(StudentListResponse student) async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.camera,
      imageQuality: 50,
    );
    if (picked == null) return;
    await _cropAndUpload(picked.path, student);
  }

  Future<void> _cropAndUpload(
      String imagePath, StudentListResponse student) async {
    final cropped = await ImageCropper().cropImage(
      sourcePath: imagePath,
      compressQuality: 70,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Photo',
          toolbarColor: Colors.blue,
          toolbarWidgetColor: Colors.white,
        ),
        IOSUiSettings(title: 'Crop Photo'),
      ],
    );
    if (cropped == null) return;

    Get.back(); // close bottom sheet
    await _uploadAndSave(File(cropped.path), student);
  }

  // Step 1: upload the file, get back the server filename
  // Step 2: call UpdateStudentImageName with that filename
  Future<void> _uploadAndSave(
      File file, StudentListResponse student) async {
    _showLoader('Uploading photo...');
    try {
      final branchId = await StorageHelper.getSelectedBranchId() ?? '0';

      final uploadResponse = await _api.postMultipartnew(
        Endpoints.uploadStudentDocument(),
        {'file': file, 'branchId': branchId},
      );

      if (uploadResponse == null ||
          uploadResponse['statusCode'] != 1 ||
          uploadResponse['result'] == null) {
        // Loader still open — dismiss it then show error
        Get.back();
        Get.snackbar(
          'Upload Failed',
          uploadResponse?['responseText']?.toString() ?? 'Image upload failed',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
        );
        return;
      }

      final fileName = uploadResponse['result'] as String;
      _updateLoader('Saving record...');
      // _updateStudentImageName always calls Get.back() itself
      await _updateStudentImageName(student.id ?? 0, fileName);
    } catch (e) {
      // Only reached if an unexpected exception is thrown before
      // _updateStudentImageName (which handles its own dialog dismiss)
      if (Get.isDialogOpen ?? false) Get.back();
      Get.snackbar(
        'Upload Failed',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    }
  }

  Future<void> _updateStudentImageName(
      int studentId, String fileName) async {
    final response = await _api.postJson(
      Endpoints.updateStudentImageName(studentId, fileName),
      {},
    );

    Get.back(); // dismiss loader

    if (response is Map && response['statusCode'] == 1) {
      Get.snackbar(
        'Congratulations',
        response['responseText']?.toString() ?? 'Photo updated successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
      // Re-fetch from server so the list always reflects real server state.
      // This removes the uploaded student (they now have a photo) and keeps
      // any other changes that may have happened concurrently.
      await fetchMissingImages();
    } else {
      Get.snackbar(
        'Error',
        response?['responseText']?.toString() ?? 'Failed to update image record',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    }
  }

  void _showLoader(String message) {
    Get.dialog(
      PopScope(
        canPop: false,
        child: Dialog(
          backgroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 28),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(width: 20),
                Expanded(
                  child: Obx(() => Text(
                        _loaderMessage.value,
                        style: const TextStyle(fontSize: 15),
                      )),
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
    _loaderMessage.value = message;
  }

  void _updateLoader(String message) {
    _loaderMessage.value = message;
  }

  final RxString _loaderMessage = ''.obs;

  @override
  void onClose() {
    searchCtrl.dispose();
    super.onClose();
  }
}
