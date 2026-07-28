import 'dart:developer';
import 'dart:io';
import 'package:erp_management/core/controllers/session_controller.dart';
import 'package:erp_management/core/models/category_model.dart';
import 'package:erp_management/core/models/session_model.dart';
import 'package:erp_management/core/services/api/api_service.dart';
import 'package:erp_management/core/services/api/endpoints.dart';
import 'package:erp_management/core/utils/image/image_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:intl/intl.dart';

class AddStudentController extends GetxController {
  final ApiService _api = ApiService();
  final SessionController _sessionController = Get.put(SessionController());

  // Step management
  final RxInt currentStep = 0.obs;
  final int totalSteps = 2;
  int _savedStudentId = 0;

  // Session / group / class
  final RxString selectedAcademicYear = ''.obs;
  final RxString selectedGroup = ''.obs;
  final RxString selectedClass = ''.obs;
  final RxList<String> academicYearList = <String>[].obs;
  final RxList<String> groupList = <String>[].obs;
  final RxList<String> classList = <String>[].obs;
  List<SessionModel> _loadedSessions = [];
  List<CategoryModel> _loadedGroups = [];
  List<CategoryModel> _loadedClasses = [];

  int get _sessionId =>
      _loadedSessions
          .firstWhereOrNull((s) => s.sessionName == selectedAcademicYear.value)
          ?.sessionId as int? ??
      0;
  int get _groupId =>
      _loadedGroups.firstWhereOrNull((g) => g.name == selectedGroup.value)?.id ?? 0;
  int get _classId =>
      _loadedClasses.firstWhereOrNull((c) => c.name == selectedClass.value)?.id ?? 0;

  // Step 1 text controllers
  final TextEditingController fullNameCtrl = TextEditingController();
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController dobCtrl = TextEditingController();
  final TextEditingController aadhaarCtrl = TextEditingController();
  final TextEditingController penNoCtrl = TextEditingController();
  final TextEditingController apaarIdCtrl = TextEditingController();
  final TextEditingController districtCtrl = TextEditingController();
  final TextEditingController tehsilCtrl = TextEditingController();
  final TextEditingController villageCtrl = TextEditingController();
  final TextEditingController fatherNameCtrl = TextEditingController();
  final TextEditingController motherNameCtrl = TextEditingController();
  final TextEditingController mobileNoCtrl = TextEditingController();

  // Step 1 focus nodes
  final FocusNode fullNameFocus = FocusNode();
  final FocusNode emailFocus = FocusNode();
  final FocusNode aadhaarFocus = FocusNode();
  final FocusNode penNoFocus = FocusNode();
  final FocusNode apaarIdFocus = FocusNode();
  final FocusNode districtFocus = FocusNode();
  final FocusNode tehsilFocus = FocusNode();
  final FocusNode villageFocus = FocusNode();
  final FocusNode fatherNameFocus = FocusNode();
  final FocusNode motherNameFocus = FocusNode();
  final FocusNode mobileNoFocus = FocusNode();

  // Step 2 — SR No
  final TextEditingController srNoCtrl = TextEditingController();
  final RxBool autoGenerateSrNo = true.obs;
  final FocusNode srNoFocus = FocusNode();

  // Step 2 — Photo
  final Rxn<File> studentPhoto = Rxn<File>();

  final RxBool isSubmitting = false.obs;

  // Dropdown options
  final RxString selectedGender = ''.obs;
  final RxString selectedReligion = ''.obs;
  final RxString selectedCategory = ''.obs;
  final RxString selectedSubCategory = ''.obs;
  final List<String> genderList = ['Male', 'Female', 'Other'];
  final List<String> religionList = ['Hindu', 'Muslim', 'Sikh', 'Christian', 'Other'];
  final List<String> categoryList = ['General', 'OBC', 'SC', 'ST'];
  final List<String> subCategoryList = ['None', 'PWD', 'Ex-Serviceman'];

  @override
  void onInit() {
    super.onInit();
    _loadSessions();
    ever(selectedAcademicYear, (_) => _onSessionChanged());
    ever(selectedGroup, (_) => _onGroupChanged());
  }

  // ── Session / Group / Class cascade ────────────────────────────────────────

  void _loadSessions() {
    ever(_sessionController.sessionList, (sessions) => _applySessionList(sessions));
    if (_sessionController.sessionList.isNotEmpty) {
      _applySessionList(_sessionController.sessionList);
    }
  }

  void _applySessionList(List<SessionModel> sessions) {
    _loadedSessions = sessions;
    final names = sessions
        .map((s) => s.sessionName ?? '')
        .where((n) => n.isNotEmpty)
        .toList();
    academicYearList.assignAll(names);
    if (names.isNotEmpty && selectedAcademicYear.value.isEmpty) {
      selectedAcademicYear.value = names.last;
    }
  }

  Future<void> _onSessionChanged() async {
    selectedGroup.value = '';
    groupList.clear();
    _loadedGroups = [];
    _onGroupChanged();
    if (_sessionId == 0) return;
    _loadedGroups = await _sessionController.getGroupList(_sessionId);
    groupList.assignAll(
      _loadedGroups.map((g) => g.name ?? '').where((n) => n.isNotEmpty),
    );
    if (groupList.isNotEmpty) selectedGroup.value = groupList.first;
  }

  void _onGroupChanged() {
    selectedClass.value = '';
    classList.clear();
    _loadedClasses = [];
    if (_groupId == 0) return;
    _fetchClasses();
  }

  Future<void> _fetchClasses() async {
    _loadedClasses = await _sessionController.getClassList(_groupId, _sessionId);
    classList.assignAll(
      _loadedClasses.map((c) => c.name ?? '').where((n) => n.isNotEmpty),
    );
    if (classList.isNotEmpty) selectedClass.value = classList.first;
  }

  // ── Step navigation ─────────────────────────────────────────────────────────

  Future<void> nextStep() async {
    if (currentStep.value == 0) await _saveBasicInfo();
  }

  void previousStep() {
    if (currentStep.value > 0) currentStep.value--;
  }

  // ── Step 1 API ──────────────────────────────────────────────────────────────

  Future<void> _saveBasicInfo() async {
    if (fullNameCtrl.text.trim().isEmpty) {
      _showError('Student Full Name is required');
      return;
    }
    if (motherNameCtrl.text.trim().isEmpty) {
      _showError('Mother Name is required');
      return;
    }

    isSubmitting.value = true;
    try {
      final payload = <String, dynamic>{
        'studentId': 0,
        'loginId': 0,
        'studentType': 1,
        'sessionId': _sessionId,
        'groupId': _groupId,
        'classId': _classId,
        'studentName': fullNameCtrl.text.trim(),
        'aadharNo': aadhaarCtrl.text.replaceAll(' ', ''),
        'penNo': penNoCtrl.text.trim(),
        'apaarId': apaarIdCtrl.text.trim(),
        'dob': dobCtrl.text.trim(),
        'fatherName': fatherNameCtrl.text.trim(),
        'fatherOccupation': '',
        'fatherMobile': mobileNoCtrl.text.trim(),
        'motherName': motherNameCtrl.text.trim(),
        'motherOccupation': '',
        'motherMobile': '',
        'gender': _mapGender(selectedGender.value),
        'religion': selectedReligion.value,
        'caste': selectedCategory.value,
        'subCaste': selectedSubCategory.value,
        'villageMohalla': villageCtrl.text.trim(),
        'tehsil': tehsilCtrl.text.trim(),
        'district': districtCtrl.text.trim(),
        'state': '',
        'pinCode': 0,
        'parentUserId': 0,
        'applicationNo': '',
      };

      log('saveBasicInfo payload: $payload');
      final response = await _api.postJson(Endpoints.saveBasicInformation(), payload);
      log('saveBasicInfo response: $response');

      if (response is Map &&
          (response['statusCode'] == 1 || response['status'] == 'success')) {
        _savedStudentId = (response['result'] as int?) ?? 0;
        log('saveBasicInfo: studentId=$_savedStudentId');
        currentStep.value++;
      } else {
        _showError(
          response?['responseText']?.toString() ??
              response?['message']?.toString() ??
              'Failed to save student info',
        );
      }
    } catch (e) {
      log('saveBasicInfo error: $e');
      _showError('Failed to save: $e');
    } finally {
      isSubmitting.value = false;
    }
  }

  // ── Step 2 API ──────────────────────────────────────────────────────────────

  Future<void> completeAdmission() async {
    isSubmitting.value = true;
    try {
      // Upload photo and register filename
      if (studentPhoto.value != null) {
        final fileName = await _uploadPhoto(studentPhoto.value!);
        if (fileName.isNotEmpty && _savedStudentId > 0) {
          await _api.postJsonWithoutBody(
            Endpoints.updateStudentImageName(_savedStudentId, fileName),
          );
        }
      }

      // Save SR No
      final srPayload = <String, dynamic>{
        'studentId': _savedStudentId,
        'loginId': 0,
        'srNo': autoGenerateSrNo.value ? '' : srNoCtrl.text.trim(),
        'isAutoGenerateSrNo': autoGenerateSrNo.value,
        'isAvailTransport': false,
        'vehicleId': 0,
        'routeId': 0,
        'pickupPointId': 0,
      };

      log('saveTransportDetail payload: $srPayload');
      final response = await _api.postJson(Endpoints.saveTransportDetail(), srPayload);
      log('saveTransportDetail response: $response');

      if (response is Map &&
          (response['statusCode'] == 1 || response['status'] == 'success')) {
        Get.dialog(
          AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Icon(Icons.check_circle, color: Colors.green, size: 48),
            content: Text(
              response['responseText']?.toString() ?? 'Student added successfully!',
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
        _showError(
          response?['responseText']?.toString() ??
              response?['message']?.toString() ??
              'Failed to complete',
        );
      }
    } catch (e) {
      log('completeAdmission error: $e');
      _showError('Failed: $e');
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<String> _uploadPhoto(File file) async {
    try {
      final bytes = await ImageUtils.compress(file);
      final multipartFile = http.MultipartFile.fromBytes(
        'file',
        bytes,
        filename: file.path.split('/').last,
        contentType: MediaType('image', 'jpeg'),
      );
      final response = await _api.postMultipart(
        Endpoints.uploadDocuments(),
        fields: {},
        headers: {},
        files: [multipartFile],
      );
      final name = (response is String)
          ? response
          : (response?['result'] ?? response?['fileName'] ?? response?['data'] ?? '')
              .toString();
      log('_uploadPhoto: ${file.path.split('/').last} → $name');
      return name;
    } catch (e) {
      log('_uploadPhoto error: $e');
      return '';
    }
  }

  // ── Helpers ─────────────────────────────────────────────────────────────────

  Future<void> pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 5)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) dobCtrl.text = DateFormat('dd-MM-yyyy').format(picked);
  }

  void setStudentPhoto(File file) => studentPhoto.value = file;
  void removeStudentPhoto() => studentPhoto.value = null;

  String _mapGender(String value) {
    switch (value.toLowerCase()) {
      case 'male':
        return 'M';
      case 'female':
        return 'F';
      default:
        return 'O';
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

  @override
  void onClose() {
    fullNameCtrl.dispose();
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
    srNoCtrl.dispose();
    fullNameFocus.dispose();
    emailFocus.dispose();
    aadhaarFocus.dispose();
    penNoFocus.dispose();
    apaarIdFocus.dispose();
    districtFocus.dispose();
    tehsilFocus.dispose();
    villageFocus.dispose();
    fatherNameFocus.dispose();
    motherNameFocus.dispose();
    mobileNoFocus.dispose();
    srNoFocus.dispose();
    super.onClose();
  }
}
