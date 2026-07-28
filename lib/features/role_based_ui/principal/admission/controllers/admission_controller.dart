import 'dart:developer';
import 'dart:io';
import 'package:erp_management/core/controllers/session_controller.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:erp_management/core/models/category_model.dart';
import 'package:erp_management/core/models/session_model.dart';
import 'package:erp_management/core/models/transport_model.dart';
import 'package:erp_management/routes/app_routes.dart';
import 'package:erp_management/core/services/api/api_service.dart';
import 'package:erp_management/core/services/api/endpoints.dart';
import 'package:erp_management/core/utils/image/image_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

/// Thrown when DocumentSettings/UploadDocuments returns statusCode == -1.
/// Carries the server's responseText so the caller can show it and skip the
/// subsequent saveAdmissionDocument call.
class DocumentUploadException implements Exception {
  final String message;
  DocumentUploadException(this.message);

  @override
  String toString() => message;
}

/// Text input formatter that converts all input to uppercase
class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}

class AdmissionController extends GetxController {
  final ApiService _api = ApiService();
  final SessionController _sessionController = Get.put(SessionController());

  // Student type: 1 = AddStudent, 2 = NewAdmission (enum StudentType)
  final RxInt studentType = 2.obs;

  // Tab management (legacy)
  final tabController = Rxn<TabController>();

  // Step management
  final RxInt currentStep = 0.obs;
  final int totalSteps = 5;

  // Form fields
  final RxString selectedAcademicYear = ''.obs;
  final RxString selectedGroup = ''.obs;
  final RxString selectedClass = ''.obs;
  final RxString selectedGender = ''.obs;
  final RxString selectedReligion = ''.obs;
  final RxString selectedCategory = ''.obs;
  final RxString selectedCaste = ''.obs;
  final RxString selectedSubCategory = ''.obs;

  // Loaded lists (names for display, models for IDs)
  final RxList<String> academicYearList = <String>[].obs;
  final RxList<String> groupList = <String>[].obs;
  final RxList<String> classList = <String>[].obs;

  List<SessionModel> _loadedSessions = [];
  List<CategoryModel> _loadedGroups = [];
  List<CategoryModel> _loadedClasses = [];

  // Derived IDs from loaded lists
  int get _sessionId =>
      _loadedSessions
          .firstWhereOrNull((s) => s.sessionName == selectedAcademicYear.value)
          ?.sessionId as int? ??
      0;

  int get _groupId =>
      _loadedGroups
          .firstWhereOrNull((g) => g.name == selectedGroup.value)
          ?.id ??
      0;

  int get _classId =>
      _loadedClasses
          .firstWhereOrNull((c) => c.name == selectedClass.value)
          ?.id ??
      0;

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
 // final TextEditingController remarkCtrl = TextEditingController();

  // Step 0 focus nodes
  final FocusNode fullNameFocus = FocusNode();
  final FocusNode aadhaarFocus = FocusNode();
  final FocusNode penNoFocus = FocusNode();
  final FocusNode apaarIdFocus = FocusNode();
  final FocusNode fatherNameFocus = FocusNode();
  final FocusNode fatherMobileFocus = FocusNode();
  final FocusNode fatherOccupationFocus = FocusNode();
  final FocusNode motherNameFocus = FocusNode();
  final FocusNode motherMobileFocus = FocusNode();
  final FocusNode motherOccupationFocus = FocusNode();
  final FocusNode villageFocus = FocusNode();
  final FocusNode tehsilFocus = FocusNode();
  final FocusNode districtFocus = FocusNode();
  final FocusNode stateFocus = FocusNode();
  final FocusNode pinCodeFocus = FocusNode();
//  final FocusNode remarkFocus = FocusNode();

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

  // Step 1 focus nodes
  final FocusNode guardianNameFocus = FocusNode();
  final FocusNode guardianMobileFocus = FocusNode();
  final FocusNode guardianOccupationFocus = FocusNode();
  final FocusNode guardianVillageFocus = FocusNode();
  final FocusNode guardianTehsilFocus = FocusNode();
  final FocusNode guardianDistrictFocus = FocusNode();
  final FocusNode guardianStateFocus = FocusNode();
  final FocusNode guardianPinCodeFocus = FocusNode();

  // Previous School Details
  final TextEditingController prevSchoolNameCtrl = TextEditingController();
  final TextEditingController prevClassCtrl = TextEditingController();
  final RxString selectedPrevResult = ''.obs;
  final RxString selectedPrevSessionYear = ''.obs;

  // Step 3 focus nodes
  final FocusNode prevSchoolNameFocus = FocusNode();
  final FocusNode prevClassFocus = FocusNode();

  // SR No & Transport
  final RxBool generateSrNo = false.obs;
  final RxBool availTransport = false.obs;
  final TextEditingController srNoCtrl = TextEditingController();

  // Step 4 focus nodes
  final FocusNode srNoFocus = FocusNode();

  // Transport dropdowns
  final RxString selectedVehicle = ''.obs;
  final RxString selectedRoute = ''.obs;
  final RxString selectedPickupPoint = ''.obs;
  final RxList<String> vehicleList = <String>[].obs;
  final RxList<String> routeList = <String>[].obs;
  final RxList<String> pickupPointList = <String>[].obs;

  List<VehicleModel> _loadedVehicles = [];
  List<RouteModel> _loadedRoutes = [];
  List<PickupPointModel> _loadedPickupPoints = [];

  int get _vehicleId =>
      _loadedVehicles
          .firstWhereOrNull((v) => v.displayLabel == selectedVehicle.value)
          ?.id ??
      0;

  int get _routeId =>
      _loadedRoutes
          .firstWhereOrNull((r) => r.fullName == selectedRoute.value)
          ?.id ??
      0;

  int get _pickupPointId =>
      _loadedPickupPoints
          .firstWhereOrNull((p) => p.name == selectedPickupPoint.value)
          ?.id ??
      0;

  // Static option lists (not from API)
  final List<String> genderList = ['Male', 'Female', 'Other'];
  final List<String> religionList = ['Hindu', 'Muslim', 'Sikh', 'Christian', 'Other'];
  // Category (General/OBC/SC/ST) and Caste (sub-category) come from the API.
  final RxList<String> categoryList = <String>[].obs;
  final RxList<String> casteList = <String>[].obs;
  final Map<String, int> _categoryIds = {}; // categoryName -> categoryId
  final Map<String, int> _casteIds = {}; // subCategoryName -> id
  final List<String> subCategoryList = ['None', 'PWD', 'Ex-Serviceman'];
  final List<String> resultList = ['Passed', 'Failed', 'Promoted', 'Awaited'];
  final RxList<String> sessionYearList = <String>[].obs;

  // ── Dropdown API loading flags (drive the suffix spinner) ─────────────────
  final RxBool isGroupLoading = false.obs;
  final RxBool isClassLoading = false.obs;
  final RxBool isCategoryLoading = false.obs;
  final RxBool isCasteLoading = false.obs;
  final RxBool isVehicleLoading = false.obs;
  final RxBool isRouteLoading = false.obs;
  final RxBool isPickupLoading = false.obs;

  // Saved student ID from save-basic-information response
  int _savedStudentId = 0;
  final RxBool isBasicInfoSaved = false.obs;

  // Pending cascade values when opening in edit mode
  int _pendingEditSessionId = 0;
  int _pendingEditGroupId = 0;
  int _pendingEditClassId = 0;
  Map<String, dynamic>? _pendingEditData;

  // Document upload state
  final RxMap<String, File?> uploadedFiles = <String, File?>{}.obs;
  final RxMap<String, bool> uploadProgress = <String, bool>{}.obs;
  final RxMap<String, double> uploadPercent = <String, double>{}.obs;
  final RxBool isSubmitting = false.obs;

  // Document keys. Every document is optional — none of these block submission.
  static const List<String> documents = [
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
    studentType.value = (Get.arguments?['studentType'] as int?) ?? 2;
    _initializeUploadStates();

    // Register cascade listeners BEFORE loading sessions. If the shared
    // SessionController already has data (common — it's a singleton loaded
    // elsewhere), _loadSessions() sets selectedAcademicYear synchronously;
    // the listener must already exist to catch that and auto-load groups.
    ever(selectedAcademicYear, (_) => _onSessionChanged());
    ever(selectedGroup, (_) => _onGroupChanged());
    ever(selectedCategory, (_) => _loadSubCategories());
    ever(availTransport, (bool on) { if (on) _loadVehicles(); });
    ever(selectedVehicle, (_) => _onVehicleChanged());
    ever(selectedRoute, (_) => _onRouteChanged());

    _loadSessions();
    _loadCategories();

    // Set default prefixes for father and mother names
    fatherNameCtrl.text = 'MR. ';
    motherNameCtrl.text = 'MRS. ';

    // Default state for a new admission (overridden by _loadForEdit on edit).
    stateCtrl.text = 'Uttar Pradesh';
    
    // Add listeners to maintain prefix
    fatherNameCtrl.addListener(() {
      if (!fatherNameCtrl.text.startsWith('MR. ')) {
        final text = fatherNameCtrl.text.replaceFirst(RegExp(r'^(MR\.?\s*)?', caseSensitive: false), '');
        fatherNameCtrl.value = TextEditingValue(
          text: 'MR. $text',
          selection: TextSelection.collapsed(offset: fatherNameCtrl.text.length),
        );
      }
    });
    
    motherNameCtrl.addListener(() {
      if (!motherNameCtrl.text.startsWith('MRS. ')) {
        final text = motherNameCtrl.text.replaceFirst(RegExp(r'^(MRS\.?\s*)?', caseSensitive: false), '');
        motherNameCtrl.value = TextEditingValue(
          text: 'MRS. $text',
          selection: TextSelection.collapsed(offset: motherNameCtrl.text.length),
        );
      }
    });
    
    final editData = Get.arguments?['editData'];
    if (editData is Map<String, dynamic>) {
      if (_loadedSessions.isNotEmpty) {
        _loadForEdit(editData);
      } else {
        _pendingEditData = editData;
      }
    }
  }

  // ── Category / Caste (sub-category) cascade ───────────────────────────────
  Future<void> _loadCategories() async {
    isCategoryLoading.value = true;
    try {
      final res = await _api.postJson(Endpoints.getCategories(), {'userId': 0});
      final list = _extractList(res);
      _categoryIds.clear();
      final names = <String>[];
      for (final e in list) {
        if (e is Map) {
          final name = (e['categoryName'] ?? '').toString();
          if (name.isEmpty) continue;
          names.add(name);
          _categoryIds[name] = _toInt(e['categoryId']);
        }
      }
      categoryList.assignAll(names);
    } catch (e) {
      log('GetCategories error: $e');
    } finally {
      isCategoryLoading.value = false;
    }
  }

  Future<void> _loadSubCategories() async {
    final categoryId = _categoryIds[selectedCategory.value];
    if (categoryId == null) {
      casteList.clear();
      _casteIds.clear();
      selectedCaste.value = '';
      return;
    }
    isCasteLoading.value = true;
    try {
      final res =
          await _api.postJsonWithoutBody(Endpoints.getSubCategories(categoryId));
      final list = _extractList(res);
      _casteIds.clear();
      final names = <String>[];
      for (final e in list) {
        if (e is Map) {
          final name = (e['subCategoryName'] ?? '').toString();
          if (name.isEmpty) continue;
          names.add(name);
          _casteIds[name] = _toInt(e['id']);
        }
      }
      casteList.assignAll(names);
      // Keep the current caste if it's still valid (e.g. in edit mode).
      if (!names.contains(selectedCaste.value)) {
        selectedCaste.value = '';
      }
    } catch (e) {
      log('GetSubCategories error: $e');
    } finally {
      isCasteLoading.value = false;
    }
  }

  List<dynamic> _extractList(dynamic res) {
    if (res is List) return res;
    if (res is Map<String, dynamic>) {
      final r = res['result'] ?? res['data'];
      if (r is List) return r;
    }
    return const [];
  }

  int _toInt(dynamic v) {
    if (v is int) return v;
    return int.tryParse(v?.toString() ?? '') ?? 0;
  }

  // ── Session / Group / Class cascade ───────────────────────────────────────

  void _loadSessions() {
    ever(_sessionController.sessionList, (sessions) {
      _applySessionList(sessions);
    });
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
    sessionYearList.assignAll(names);
    if (selectedAcademicYear.value.isNotEmpty && !names.contains(selectedAcademicYear.value)) {
      selectedAcademicYear.value = '';
    }
    // Default to the current (active) session for a new admission.
    if (selectedAcademicYear.value.isEmpty && _pendingEditData == null) {
      final active = sessions.firstWhereOrNull((s) => s.isActive == true);
      if (active?.sessionName != null && active!.sessionName!.isNotEmpty) {
        selectedAcademicYear.value = active.sessionName!;
      }
    }
    if (_pendingEditData != null && _loadedSessions.isNotEmpty) {
      final data = _pendingEditData!;
      _pendingEditData = null;
      _loadForEdit(data);
    }
  }

  Future<void> _onSessionChanged() async {
    selectedGroup.value = '';
    groupList.clear();
    _loadedGroups = [];
    _onGroupChanged();
    log('[Admission] _onSessionChanged: selectedAcademicYear="${selectedAcademicYear.value}" sessionId=$_sessionId');
    if (_sessionId == 0) return;
    isGroupLoading.value = true;
    try {
      _loadedGroups = await _sessionController.getGroupList(_sessionId);
      groupList.assignAll(
        _loadedGroups.map((g) => g.name ?? '').where((n) => n.isNotEmpty),
      );
      log('[Admission] groupList = ${groupList.toList()} (loaded ${_loadedGroups.length})');
      if (selectedGroup.value.isNotEmpty && !groupList.contains(selectedGroup.value)) {
        selectedGroup.value = '';
      }
      if (_pendingEditGroupId != 0) {
        final match = _loadedGroups.firstWhereOrNull((g) => g.id == _pendingEditGroupId);
        if (match?.name != null) {
          _pendingEditGroupId = 0;
          selectedGroup.value = match!.name!;
        }
      }
      // Group list is populated only — the user picks it manually, no auto-select.
    } finally {
      isGroupLoading.value = false;
    }
  }

  void _onGroupChanged() {
    selectedClass.value = '';
    classList.clear();
    _loadedClasses = [];
    if (_groupId == 0) return;
    _fetchClasses();
  }

  Future<void> _fetchClasses() async {
    log('[Admission] _fetchClasses: selectedGroup="${selectedGroup.value}" groupId=$_groupId sessionId=$_sessionId');
    isClassLoading.value = true;
    try {
      _loadedClasses = await _sessionController.getClassList(_groupId, _sessionId);
      classList.assignAll(
        _loadedClasses.map((c) => c.name ?? '').where((n) => n.isNotEmpty),
      );
      log('[Admission] classList = ${classList.toList()} (loaded ${_loadedClasses.length})');
      if (selectedClass.value.isNotEmpty && !classList.contains(selectedClass.value)) {
        selectedClass.value = '';
      }
      if (_pendingEditClassId != 0) {
        final match = _loadedClasses.firstWhereOrNull((c) => c.id == _pendingEditClassId);
        if (match?.name != null) {
          _pendingEditClassId = 0;
          selectedClass.value = match!.name!;
        }
      }
    } finally {
      isClassLoading.value = false;
    }
  }

  // ── Transport cascade ─────────────────────────────────────────────────────

  Future<void> _loadVehicles() async {
    vehicleList.clear();
    _loadedVehicles = [];
    isVehicleLoading.value = true;
    try {
      final response = await _api.postJsonWithoutBody(Endpoints.getVehicle());
      if (response is List) {
        _loadedVehicles = response
            .whereType<Map<String, dynamic>>()
            .map(VehicleModel.fromJson)
            .toList();
        vehicleList.assignAll(_loadedVehicles.map((v) => v.displayLabel));
      }
    } catch (e) {
      log('_loadVehicles error: $e');
    } finally {
      isVehicleLoading.value = false;
    }
  }

  Future<void> _onVehicleChanged() async {
    selectedRoute.value = '';
    selectedPickupPoint.value = '';
    routeList.clear();
    pickupPointList.clear();
    _loadedRoutes = [];
    _loadedPickupPoints = [];
    if (_vehicleId == 0) return;
    isRouteLoading.value = true;
    try {
      final response = await _api.getJson(Endpoints.getRoutesByVehicleId(_vehicleId));
      if (response is List) {
        _loadedRoutes = response
            .whereType<Map<String, dynamic>>()
            .map(RouteModel.fromJson)
            .toList();
        routeList.assignAll(_loadedRoutes.map((r) => r.fullName));
      }
    } catch (e) {
      log('_onVehicleChanged error: $e');
    } finally {
      isRouteLoading.value = false;
    }
  }

  Future<void> _onRouteChanged() async {
    selectedPickupPoint.value = '';
    pickupPointList.clear();
    _loadedPickupPoints = [];
    if (_routeId == 0 || _vehicleId == 0) return;
    isPickupLoading.value = true;
    try {
      final response = await _api.getJson(
        Endpoints.getPickupPointByRouteAndVehicle(
          _routeId,
          _vehicleId,
          _sessionId,
        ),
      );
      if (response is List) {
        _loadedPickupPoints = response
            .whereType<Map<String, dynamic>>()
            .map(PickupPointModel.fromJson)
            .toList();
        pickupPointList.assignAll(_loadedPickupPoints.map((p) => p.name));
      }
    } catch (e) {
      log('_onRouteChanged error: $e');
    } finally {
      isPickupLoading.value = false;
    }
  }

  void _initializeUploadStates() {
    for (final doc in documents) {
      uploadedFiles[doc] = null;
      uploadProgress[doc] = false;
      uploadPercent[doc] = 0.0;
    }
  }

  // Step management
  Future<void> nextStep() async {
    final step = currentStep.value;
    if (step >= totalSteps - 1) return;
    if (!validateStep(step)) return;

    if (step == 0) {
      await _saveBasicInformation();
    } else if (step == 1) {
      await _saveGuardianDetail();
    } else if (step == 2) {
      await _savePreviousSchool();
    } else if (step == 3) {
      await _saveTransportDetail();
    } else {
      currentStep.value++;
    }
  }

  Future<void> _saveBasicInformation() async {
    isSubmitting.value = true;
    try {
      final payload = <String, dynamic>{
        'studentId': 0,
        'loginId': 0,
        'studentType': studentType.value,
        'sessionId': _sessionId,
        'groupId': _groupId,
        'classId': _classId,
        'studentName': fullNameCtrl.text.trim(),
        'aadharNo': aadhaarCtrl.text.replaceAll(' ', ''),
        'penNo': penNoCtrl.text.trim(),
        'apaarId': apaarIdCtrl.text.trim(),
        'dob': dobCtrl.text.trim(),
        'fatherName': fatherNameCtrl.text.trim(),
        'fatherOccupation': fatherOccupationCtrl.text.trim(),
        'fatherMobile': fatherMobileCtrl.text.trim(),
        'motherName': motherNameCtrl.text.trim(),
        'motherOccupation': motherOccupationCtrl.text.trim(),
        'motherMobile': motherMobileCtrl.text.trim(),
        'gender': _mapGender(selectedGender.value),
        'religion': selectedReligion.value,
        'category': selectedCategory.value,
        'categoryId': _categoryIds[selectedCategory.value] ?? 0,
        'caste': selectedCaste.value,
        'subCategoryId': _casteIds[selectedCaste.value] ?? 0,
        'subCaste': selectedSubCategory.value,
        'villageMohalla': villageCtrl.text.trim(),
        'tehsil': tehsilCtrl.text.trim(),
        'district': districtCtrl.text.trim(),
        'state': stateCtrl.text.trim(),
        'pinCode': int.tryParse(pinCodeCtrl.text.trim()) ?? 0,
        'parentUserId': 0,
        'applicationNo': '',
      };

      log('saveBasicInformation payload: $payload');
      final response = await _api.postJson(Endpoints.saveBasicInformation(), payload);
      log('saveBasicInformation response: $response');

      if (response is Map &&
          (response['statusCode'] == 1 || response['status'] == 'success')) {
        _savedStudentId = (response['result'] as int?) ?? 0;
        isBasicInfoSaved.value = true;
        log('saveBasicInformation: studentId=$_savedStudentId');
        currentStep.value++;
      } else {
        _showError(
          response?['responseText']?.toString() ??
              response?['message']?.toString() ??
              'Failed to save basic information',
        );
      }
    } catch (e) {
      log('saveBasicInformation error: $e');
      _showError('Failed to save: $e');
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> _saveGuardianDetail() async {
    isSubmitting.value = true;
    try {
      final payload = <String, dynamic>{
        'studentId': _savedStudentId,
        'loginId': 0,
        'isGuardianSameAsFather': isGuardianSameAsFather.value,
        'guardianName': guardianNameCtrl.text.trim(),
        'guardianOccupation': guardianOccupationCtrl.text.trim(),
        'guardianMobile': guardianMobileCtrl.text.trim(),
        'guardianVillageMohalla': guardianVillageCtrl.text.trim(),
        'guardianTehsil': guardianTehsilCtrl.text.trim(),
        'guardianDistrict': guardianDistrictCtrl.text.trim(),
        'guardianState': guardianStateCtrl.text.trim(),
        'guardianPinCode': guardianPinCodeCtrl.text.trim(),
      };

      log('saveGuardianDetail payload: $payload');
      final response = await _api.postJson(Endpoints.saveGuardianDetail(), payload);
      log('saveGuardianDetail response: $response');

      if (response is Map &&
          (response['statusCode'] == 1 || response['status'] == 'success')) {
        currentStep.value++;
      } else {
        _showError(
          response?['responseText']?.toString() ??
              response?['message']?.toString() ??
              'Failed to save guardian details',
        );
      }
    } catch (e) {
      log('saveGuardianDetail error: $e');
      _showError('Failed to save: $e');
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> _savePreviousSchool() async {
    isSubmitting.value = true;
    try {
      final payload = <String, dynamic>{
        'studentId': _savedStudentId,
        'loginId': 0,
        'previousSchoolName': prevSchoolNameCtrl.text.trim(),
        'previousClass': prevClassCtrl.text.trim(),
        'previousSessionResult': selectedPrevResult.value,
        'previousSession': selectedPrevSessionYear.value,
      };
      log('savePreviousSchool payload: $payload');
      final response = await _api.postJson(Endpoints.savePreviousSchool(), payload);
      log('savePreviousSchool response: $response');
      if (response is Map && (response['statusCode'] == 1 || response['status'] == 'success')) {
        currentStep.value++;
      } else {
        _showError(response?['responseText']?.toString() ?? response?['message']?.toString() ?? 'Failed to save previous school');
      }
    } catch (e) {
      log('savePreviousSchool error: $e');
      _showError('Failed to save: $e');
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> _saveTransportDetail() async {
    isSubmitting.value = true;
    try {
      final payload = <String, dynamic>{
        'studentId': _savedStudentId,
        'loginId': 0,
        'srNo': generateSrNo.value ? '' : srNoCtrl.text.trim(),
        'isAutoGenerateSrNo': generateSrNo.value,
        'isAvailTransport': availTransport.value,
        'vehicleId': _vehicleId,
        'routeId': _routeId,
        'pickupPointId': _pickupPointId,
      };
      log('saveTransportDetail payload: $payload');
      final response = await _api.postJson(Endpoints.saveTransportDetail(), payload);
      log('saveTransportDetail response: $response');
      if (response is Map && (response['statusCode'] == 1 || response['status'] == 'success')) {
        currentStep.value++;
      } else {
        _showError(response?['responseText']?.toString() ?? response?['message']?.toString() ?? 'Failed to save transport details');
      }
    } catch (e) {
      log('saveTransportDetail error: $e');
      _showError('Failed to save: $e');
    } finally {
      isSubmitting.value = false;
    }
  }

  /// Compresses [file] and uploads it to DocumentSettings/UploadDocuments.
  /// [documentFor]: 1=Staff, 2=Administrator, 3=Parent, 4=Student.
  /// Returns the server-assigned filename, or '' on failure.
  Future<String> _uploadDocument(File file, {int documentFor = 4}) async {
    final bytes = await ImageUtils.compress(file);
    final multipartFile = http.MultipartFile.fromBytes(
      'file',
      bytes,
      filename: file.path.split('/').last,
      contentType: MediaType('image', 'jpeg'),
    );
    final response = await _api.postMultipart(
      Endpoints.uploadDocuments(documentFor: documentFor),
      fields: {},
      headers: {},
      files: [multipartFile],
    );

    // Backend reports a failure with statusCode == -1 (e.g. "Invalid branch
    // id!"). Throw so the caller surfaces the message and the
    // saveAdmissionDocument API is never called after a failed upload.
    if (response is Map && response['statusCode'] == -1) {
      final msg = response['responseText']?.toString() ?? 'Document upload failed';
      log('_uploadDocument failed (documentFor=$documentFor): $msg');
      throw DocumentUploadException(msg);
    }

    final name = (response is String)
        ? response
        : (response?['result'] ?? response?['fileName'] ?? response?['data'] ?? '')
            .toString();
    log('_uploadDocument(documentFor=$documentFor): ${file.path.split('/').last} → $name');
    return name;
  }

  Future<String> _uploadDoc(String docKey) async {
    final file = uploadedFiles[docKey];
    if (file == null) return '';
    return _uploadDocument(file);
  }

  Future<void> _saveAdmissionDocument() async {
    isSubmitting.value = true;
    try {
      final fileCount = uploadedFiles.values.where((f) => f != null).length;
      log('saveAdmissionDocument: uploading $fileCount files…');

      final studentPhoto        = await _uploadDoc('student_photo');
      final studentAadharFront  = await _uploadDoc('student_aadhar_front');
      final studentAadharBack   = await _uploadDoc('student_aadhar_back');
      final fatherAadharFront   = await _uploadDoc('father_aadhar_front');
      final fatherAadharBack    = await _uploadDoc('father_aadhar_back');
      final motherAadharFront   = await _uploadDoc('mother_aadhar_front');
      final motherAadharBack    = await _uploadDoc('mother_aadhar_back');
      final transferCertificate = await _uploadDoc('transfer_certificate');
      final markSheet           = await _uploadDoc('marksheet');
      final characterCertificate= await _uploadDoc('character_certificate');

      final payload = <String, dynamic>{
        'studentId': _savedStudentId,
        'loginId': 0,
        'studentPhoto': studentPhoto,
        'studentAadharFront': studentAadharFront,
        'studentAadharBack': studentAadharBack,
        'fatherAadharFront': fatherAadharFront,
        'fatherAadharBack': fatherAadharBack,
        'motherAadharFront': motherAadharFront,
        'motherAadharBack': motherAadharBack,
        'transferCertificate': transferCertificate,
        'markSheet': markSheet,
        'characterCertificate': characterCertificate,
      };
      log('saveAdmissionDocument payload: $payload');
      final response = await _api.postJson(Endpoints.saveAdmissionDocument(), payload);
      log('saveAdmissionDocument response: $response');
      if (response is Map && (response['statusCode'] == 1 || response['status'] == 'success')) {
        Get.dialog(
          AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Icon(Icons.check_circle, color: Colors.green, size: 48),
            content: Text(
              response['responseText']?.toString() ?? 'Admission completed successfully!',
              textAlign: TextAlign.center,
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Get.back();
                  Get.offAllNamed(AppRoutes.principalDashboard);
                },
                child: const Text('Go to Dashboard'),
              ),
            ],
          ),
          barrierDismissible: false,
        );
      } else {
        _showError(response?['responseText']?.toString() ?? response?['message']?.toString() ?? 'Failed to save documents');
      }
    } on DocumentUploadException catch (e) {
      // A document upload failed (statusCode -1) — show it and abort; the
      // saveAdmissionDocument call above is never reached.
      log('saveAdmissionDocument upload failed: ${e.message}');
      _showError(e.message);
    } catch (e) {
      log('saveAdmissionDocument error: $e');
      _showError('Failed to save: $e');
    } finally {
      isSubmitting.value = false;
    }
  }

  void previousStep() {
    if (currentStep.value > 0) {
      currentStep.value--;
    }
  }

  void goToStep(int step) {
    if (step < 0 || step >= totalSteps) return;
    if (step > 0 && !isBasicInfoSaved.value) {
      _showError('Please complete Basic Info first');
      return;
    }
    currentStep.value = step;
  }

  bool validateStep(int step) {
    switch (step) {
      case 0:
        if (selectedGroup.value.isEmpty) {
          _showError('Group is required');
          return false;
        }
        if (selectedClass.value.isEmpty) {
          _showError('Class is required');
          return false;
        }
        if (fullNameCtrl.text.trim().isEmpty) {
          _showError('Student Name is required');
          return false;
        }
        if (selectedGender.value.isEmpty) {
          _showError('Gender is required');
          return false;
        }
        if (fatherNameCtrl.text.trim().isEmpty) {
          _showError('Father Name is required');
          return false;
        }
        if (fatherMobileCtrl.text.trim().isEmpty) {
          _showError('Father Mobile is required');
          return false;
        }
        if (motherNameCtrl.text.trim().isEmpty) {
          _showError('Mother Name is required');
          return false;
        }
        if (villageCtrl.text.trim().isEmpty) {
          _showError('Village / Mohalla is required');
          return false;
        }
        if (tehsilCtrl.text.trim().isEmpty) {
          _showError('Tehsil is required');
          return false;
        }
        if (districtCtrl.text.trim().isEmpty) {
          _showError('District is required');
          return false;
        }
        break;
    }
    return true;
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

  String _mapGender(String value) {
    switch (value.toLowerCase()) {
      case 'male': return 'M';
      case 'female': return 'F';
      default: return 'O';
    }
  }

  void _loadForEdit(Map<String, dynamic> raw) {
    // Response: { statusCode, result: { basicInformation, guardianDetail,
    //   previousSchoolDetail, srNoAndTransportDetail, documents } }
    final result = (raw['result'] is Map<String, dynamic>)
        ? raw['result'] as Map<String, dynamic>
        : raw;

    final basic = result['basicInformation'] is Map<String, dynamic>
        ? result['basicInformation'] as Map<String, dynamic>
        : result;
    final guardian =
        result['guardianDetail'] as Map<String, dynamic>? ?? {};
    final prev =
        result['previousSchoolDetail'] as Map<String, dynamic>? ?? {};
    final sr =
        result['srNoAndTransportDetail'] as Map<String, dynamic>? ?? {};

    _savedStudentId = (basic['studentId'] as num?)?.toInt() ?? 0;
    isBasicInfoSaved.value = true;

    _pendingEditSessionId = (basic['sessionId'] as num?)?.toInt() ?? 0;
    _pendingEditGroupId = (basic['groupId'] as num?)?.toInt() ?? 0;
    _pendingEditClassId = (basic['classId'] as num?)?.toInt() ?? 0;

    fullNameCtrl.text = basic['studentName']?.toString() ?? '';
    aadhaarCtrl.text = basic['aadharNo']?.toString() ?? '';
    penNoCtrl.text = basic['penNo']?.toString() ?? '';
    apaarIdCtrl.text = basic['apaarId']?.toString() ?? '';
    dobCtrl.text = basic['dob']?.toString() ?? '';
    
    // Add prefixes if not already present
    final fatherName = basic['fatherName']?.toString() ?? '';
    fatherNameCtrl.text = fatherName.isEmpty 
        ? 'MR. ' 
        : (fatherName.toUpperCase().startsWith('MR') ? fatherName : 'MR. $fatherName');
    
    fatherOccupationCtrl.text = basic['fatherOccupation']?.toString() ?? '';
    fatherMobileCtrl.text = basic['fatherMobile']?.toString() ?? '';
    
    final motherName = basic['motherName']?.toString() ?? '';
    motherNameCtrl.text = motherName.isEmpty 
        ? 'MRS. ' 
        : (motherName.toUpperCase().startsWith('MRS') ? motherName : 'MRS. $motherName');
    
    motherOccupationCtrl.text = basic['motherOccupation']?.toString() ?? '';
    motherMobileCtrl.text = basic['motherMobile']?.toString() ?? '';
    villageCtrl.text = basic['villageMohalla']?.toString() ?? '';
    tehsilCtrl.text = basic['tehsil']?.toString() ?? '';
    districtCtrl.text = basic['district']?.toString() ?? '';
    final state = basic['state']?.toString() ?? '';
    stateCtrl.text = state.isEmpty ? 'Uttar Pradesh' : state;
    final pin = (basic['pinCode'] as num?)?.toInt() ?? 0;
    pinCodeCtrl.text = pin > 0 ? pin.toString() : '';

    selectedGender.value = _reverseMapGender(basic['gender']?.toString() ?? '');
    selectedReligion.value = basic['religion']?.toString() ?? '';
    selectedCategory.value = basic['category']?.toString() ?? '';
    selectedCaste.value = basic['caste']?.toString() ?? '';
    selectedSubCategory.value = basic['subCaste']?.toString() ?? '';

    // Guardian
    isGuardianSameAsFather.value =
        guardian['isGuardianSameAsFather'] as bool? ?? true;
    guardianNameCtrl.text = guardian['guardianName']?.toString() ?? '';
    guardianMobileCtrl.text = guardian['guardianMobile']?.toString() ?? '';
    guardianOccupationCtrl.text =
        guardian['guardianOccupation']?.toString() ?? '';
    guardianVillageCtrl.text =
        guardian['guardianVillageMohalla']?.toString() ?? '';
    guardianTehsilCtrl.text = guardian['guardianTehsil']?.toString() ?? '';
    guardianDistrictCtrl.text = guardian['guardianDistrict']?.toString() ?? '';
    guardianStateCtrl.text = guardian['guardianState']?.toString() ?? '';
    guardianPinCodeCtrl.text = guardian['guardianPinCode']?.toString() ?? '';

    // Previous school
    prevSchoolNameCtrl.text = prev['previousSchoolName']?.toString() ?? '';
    prevClassCtrl.text = prev['previousClass']?.toString() ?? '';
    selectedPrevResult.value =
        prev['previousSessionResult']?.toString() ?? '';
    selectedPrevSessionYear.value = prev['previousSession']?.toString() ?? '';

    // SR & Transport
    srNoCtrl.text = sr['srNo']?.toString() ?? '';
    generateSrNo.value = sr['isAutoGenerateSrNo'] as bool? ?? false;
    availTransport.value = sr['isAvailTransport'] as bool? ?? false;

    // Trigger session cascade
    if (_pendingEditSessionId != 0) {
      final match = _loadedSessions
          .firstWhereOrNull((s) => s.sessionId == _pendingEditSessionId);
      if (match?.sessionName != null) {
        _pendingEditSessionId = 0;
        selectedAcademicYear.value = match!.sessionName!;
      }
    }
  }

  String _reverseMapGender(String code) {
    switch (code.toUpperCase()) {
      case 'M': return 'Male';
      case 'F': return 'Female';
      case 'O': return 'Other';
      default: return code;
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

  // True when launched from Add Student (2-step: basic info → SR & photo)
  bool get isAddStudentMode => studentType.value == 1;

  Future<void> submitAdmission() async {
    if (isAddStudentMode) {
      await _saveStudentSrAndPhoto();
    } else {
      await _saveAdmissionDocument();
    }
  }

  Future<void> _saveStudentSrAndPhoto() async {
    isSubmitting.value = true;
    try {
      // 1. Upload student photo — documentFor=4 (Student)
      String studentPhotoName = '';
      final photoFile = uploadedFiles['student_photo'];
      if (photoFile != null) {
        studentPhotoName = await _uploadDocument(photoFile, documentFor: 4);
        log('student photo uploaded: $studentPhotoName');
      }

      // 2. Save document record — matches API payload exactly
      final docPayload = <String, dynamic>{
        'studentId': _savedStudentId,
        'loginId': 0,
        'studentPhoto': studentPhotoName,
        'studentAadharFront': '',
        'studentAadharBack': '',
        'fatherAadharFront': '',
        'fatherAadharBack': '',
        'motherAadharFront': '',
        'motherAadharBack': '',
        'transferCertificate': '',
        'markSheet': '',
        'characterCertificate': '',
      };
      log('saveAdmissionDocument payload: $docPayload');
      final docResponse =
          await _api.postJson(Endpoints.saveAdmissionDocument(), docPayload);
      log('saveAdmissionDocument response: $docResponse');

      if (docResponse is Map &&
          docResponse['statusCode'] != 1 &&
          docResponse['status'] != 'success') {
        _showError(
          docResponse['responseText']?.toString() ??
              docResponse['message']?.toString() ??
              'Failed to save document',
        );
        return;
      }

      // 3. Save SR No via save-transport-detail
      final srPayload = <String, dynamic>{
        'studentId': _savedStudentId,
        'loginId': 0,
        'srNo': generateSrNo.value ? '' : srNoCtrl.text.trim(),
        'isAutoGenerateSrNo': generateSrNo.value,
        'isAvailTransport': false,
        'vehicleId': 0,
        'routeId': 0,
        'pickupPointId': 0,
      };
      log('saveTransportDetail payload: $srPayload');
      final srResponse =
          await _api.postJson(Endpoints.saveTransportDetail(), srPayload);
      log('saveTransportDetail response: $srResponse');

      if (srResponse is Map &&
          (srResponse['statusCode'] == 1 ||
              srResponse['status'] == 'success')) {
        Get.dialog(
          AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
            title:
                const Icon(Icons.check_circle, color: Colors.green, size: 48),
            content: Text(
              srResponse['responseText']?.toString() ??
                  'Student added successfully!',
              textAlign: TextAlign.center,
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Get.back();
                  Get.offAllNamed(AppRoutes.principalDashboard);
                },
                child: const Text('Go to Dashboard'),
              ),
            ],
          ),
          barrierDismissible: false,
        );
      } else {
        _showError(
          srResponse?['responseText']?.toString() ??
              srResponse?['message']?.toString() ??
              'Failed to save SR number',
        );
      }
    } on DocumentUploadException catch (e) {
      // Photo upload failed (statusCode -1) — show it and abort before the
      // saveAdmissionDocument / SR-number calls run.
      log('saveStudentSrAndPhoto upload failed: ${e.message}');
      _showError(e.message);
    } catch (e) {
      log('saveStudentSrAndPhoto error: $e');
      _showError('Failed: $e');
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
   // remarkCtrl.dispose();
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
    srNoCtrl.dispose();
    // Focus nodes
    fullNameFocus.dispose();
    aadhaarFocus.dispose();
    penNoFocus.dispose();
    apaarIdFocus.dispose();
    fatherNameFocus.dispose();
    fatherMobileFocus.dispose();
    fatherOccupationFocus.dispose();
    motherNameFocus.dispose();
    motherMobileFocus.dispose();
    motherOccupationFocus.dispose();
    villageFocus.dispose();
    tehsilFocus.dispose();
    districtFocus.dispose();
    stateFocus.dispose();
    pinCodeFocus.dispose();
   // remarkFocus.dispose();
    guardianNameFocus.dispose();
    guardianMobileFocus.dispose();
    guardianOccupationFocus.dispose();
    guardianVillageFocus.dispose();
    guardianTehsilFocus.dispose();
    guardianDistrictFocus.dispose();
    guardianStateFocus.dispose();
    guardianPinCodeFocus.dispose();
    prevSchoolNameFocus.dispose();
    prevClassFocus.dispose();
    srNoFocus.dispose();
    super.onClose();
  }
}
