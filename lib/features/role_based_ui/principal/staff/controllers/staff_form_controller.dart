import 'dart:developer';
import 'dart:io';

import 'package:erp_management/core/controllers/session_controller.dart';
import 'package:erp_management/core/models/category_model.dart';
import 'package:erp_management/core/services/api/api_service.dart';
import 'package:erp_management/core/services/api/endpoints.dart';
import 'package:erp_management/core/services/category_service.dart';
import 'package:erp_management/core/utils/image/image_utils.dart';
import 'package:erp_management/features/role_based_ui/principal/staff/models/staff_details_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

/// Thrown when DocumentSettings/UploadDocuments returns statusCode == -1.
class StaffUploadException implements Exception {
  final String message;
  StaffUploadException(this.message);
  @override
  String toString() => message;
}

class StaffFormController extends GetxController {
  final ApiService _api = ApiService();

  // Identity (filled from GetStaffDetailsById).
  int staffId = 0; // AddStaff "Id"
  int userId = 0; // AddStaff "UserId"

  // Editable text fields.
  final nameCtrl = TextEditingController();
  final fatherNameCtrl = TextEditingController();
  // Shown instead of Father Name for a married female staff member. Both map
  // to the single `FatherName` API field.
  final husbandNameCtrl = TextEditingController();
  final mobileCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final dobCtrl = TextEditingController();
  final designationCtrl = TextEditingController();
  final qualificationCtrl = TextEditingController();
  final villageCtrl = TextEditingController();
  final tehsilCtrl = TextEditingController();
  final districtCtrl = TextEditingController();

  // Free-text fields added to match the full staff form.
  final subCasteCtrl = TextEditingController();
  final stateCtrl = TextEditingController();

  // Editable dropdown/selection fields.
  final RxString gender = ''.obs;
  final RxString maritalStatus = ''.obs;
  final RxString religion = ''.obs;
  final RxString caste = ''.obs;
  int designationId = 0;
  int roleId = 0;

  // ── Group & Class (same session-scoped API used by attendance) ─────────────
  final SessionController _session = Get.put(SessionController());

  // Group and Class are multi-select: a staff member can belong to several
  // groups/classes. The API carries them as comma-separated id strings.
  final RxList<CategoryModel> groupList = <CategoryModel>[].obs;
  final RxList<CategoryModel> selectedGroups = <CategoryModel>[].obs;
  final RxBool isGroupLoading = false.obs;

  final RxList<CategoryModel> classList = <CategoryModel>[].obs;
  final RxList<CategoryModel> selectedClasses = <CategoryModel>[].obs;
  final RxBool isClassLoading = false.obs;

  // The single class this staff member is class-teacher of, chosen from the
  // selected classes. Only shown/sent for teacher designations.
  final Rxn<CategoryModel> selectedClassTeacherOf = Rxn<CategoryModel>();

  /// True when the selected designation is a teacher (e.g. ASST. TEACHER,
  /// CLASS TEACHER) — the only case where "Class Teacher Of" applies.
  bool get showClassTeacherOf =>
      (selectedDesignation.value?.name ?? '').toLowerCase().contains('teacher');

  /// A married female staff member enters a husband's name; everyone else
  /// (male, or unmarried female) enters a father's name.
  bool get usesHusbandName =>
      gender.value == 'Female' && maritalStatus.value == 'Married';

  // Preselection ids captured while loading staff details.
  List<int> _loadedGroupIds = [];
  List<int> _loadedClassIds = [];
  int _loadedClassTeacherOf = 0;

  // ── Designation (POST /Staff/GetDesignation) ───────────────────────────────
  final RxList<CategoryModel> designationList = <CategoryModel>[].obs;
  final Rxn<CategoryModel> selectedDesignation = Rxn<CategoryModel>();
  final RxBool isDesignationLoading = false.obs;

  // ── Role (GET /RolePermission/GetRoleForStaff) ─────────────────────────────
  final RxList<CategoryModel> roleList = <CategoryModel>[].obs;
  final Rxn<CategoryModel> selectedRole = Rxn<CategoryModel>();
  final RxBool isRoleLoading = false.obs;

  /// The active session id, used to scope the group/class lookups.
  int get _activeSessionId {
    final s =
        _session.sessionList.firstWhereOrNull((e) => e.isActive == true) ??
        (_session.sessionList.isNotEmpty ? _session.sessionList.first : null);
    final id = s?.sessionId;
    return id is int ? id : int.tryParse('${id ?? 0}') ?? 0;
  }

  final List<String> genderList = ['Male', 'Female', 'Other'];
  final List<String> maritalStatusList = ['Single', 'Married'];
  final List<String> religionList = [
    'Hindu',
    'Muslim',
    'Sikh',
    'Christian',
    'Other',
  ];
  // Caste (category-level: General/OBC/SC/ST) comes from the API.
  final RxList<String> casteList = <String>[].obs;
  final CategoryService _categoryService = CategoryService();

  final RxBool isLoading = false.obs;
  final RxBool isSaving = false.obs;

  /// True when the form was opened to edit an existing staff (a userId was
  /// passed in Get.arguments); false when adding a new staff.
  final RxBool isEditMode = false.obs;

  // ── Required-field validation + scroll-to navigation ───────────────────────
  final ScrollController scrollController = ScrollController();
  final GlobalKey nameFieldKey = GlobalKey();
  final GlobalKey emailFieldKey = GlobalKey();
  final GlobalKey mobileFieldKey = GlobalKey();
  final GlobalKey designationFieldKey = GlobalKey();
  final GlobalKey roleFieldKey = GlobalKey();
  final GlobalKey genderFieldKey = GlobalKey();
  final GlobalKey maritalFieldKey = GlobalKey();

  // ── Documents ────────────────────────────────────────────────────────────
  static const List<String> documentKeys = [
    'photo',
    'aadhar_front',
    'aadhar_back',
    'pan_card',
    'higher_marksheet',
    'inter_marksheet',
    'graduation_marksheet',
    'postgraduation_marksheet',
    'experience_certificate',
    'driving_license',
  ];

  static const Map<String, String> documentNames = {
    'photo': 'Photo',
    'aadhar_front': 'Aadhaar Front',
    'aadhar_back': 'Aadhaar Back',
    'pan_card': 'PAN Card',
    'higher_marksheet': 'Higher Marksheet',
    'inter_marksheet': 'Inter Marksheet',
    'graduation_marksheet': 'Graduation Marksheet',
    'postgraduation_marksheet': 'Post Graduation Marksheet',
    'experience_certificate': 'Experience Certificate',
    'driving_license': 'Driving License',
  };

  static const Map<String, IconData> documentIcons = {
    'photo': Icons.person_outline,
    'aadhar_front': Icons.credit_card,
    'aadhar_back': Icons.credit_card,
    'pan_card': Icons.badge_outlined,
    'higher_marksheet': Icons.assessment_outlined,
    'inter_marksheet': Icons.assessment_outlined,
    'graduation_marksheet': Icons.school_outlined,
    'postgraduation_marksheet': Icons.school_outlined,
    'experience_certificate': Icons.work_outline,
    'driving_license': Icons.directions_car_outlined,
  };

  /// Maps each document key to its field name in the AddStaff payload.
  static const Map<String, String> _docPayloadField = {
    'photo': 'PhotoUrl',
    'aadhar_front': 'AadharCardUrl',
    'aadhar_back': 'AadharCardBackUrl',
    'pan_card': 'PanCardUrl',
    'higher_marksheet': 'HigherMarksheetUrl',
    'experience_certificate': 'ExperienceCertificateUrl',
    'driving_license': 'DrivingLicenseUrl',
    'inter_marksheet': 'interMarksheet',
    'graduation_marksheet': 'graduationMarksheet',
    'postgraduation_marksheet': 'postgraduationMarksheet',
  };

  /// Existing document URLs loaded from `GetStaffDetailsById`. These are seeded
  /// into the AddStaff payload so that unchanged documents are not erased.
  final Map<String, String?> _existingDocUrls = {};

  final RxMap<String, File?> uploadedFiles = <String, File?>{}.obs;

  void setUploadedFile(String key, File file) {
    uploadedFiles[key] = file;
    uploadedFiles.refresh();
  }

  void removeUploadedFile(String key) {
    uploadedFiles[key] = null;
    uploadedFiles.refresh();
  }

  // ── Gender / marital-status code mapping ─────────────────────────────────
  static const Map<String, String> _genderCodeToLabel = {
    'M': 'Male',
    'F': 'Female',
    'O': 'Other',
  };
  static const Map<String, String> _genderLabelToCode = {
    'Male': 'M',
    'Female': 'F',
    'Other': 'O',
  };
  static const Map<String, String> _maritalCodeToLabel = {
    'U': 'Single',
    'M': 'Married',
  };
  static const Map<String, String> _maritalLabelToCode = {
    'Single': 'U',
    'Married': 'M',
  };

  String _genderLabel(String code) {
    final normalized = code.trim().toUpperCase();
    if (_genderCodeToLabel.containsKey(normalized)) {
      return _genderCodeToLabel[normalized]!;
    }
    if (_genderLabelToCode.containsKey(code.trim())) return code.trim();
    return code;
  }

  String _genderCode(String label) => _genderLabelToCode[label.trim()] ?? label;

  String _maritalLabel(String code) {
    final normalized = code.trim().toUpperCase();
    if (_maritalCodeToLabel.containsKey(normalized)) {
      return _maritalCodeToLabel[normalized]!;
    }
    if (_maritalLabelToCode.containsKey(code.trim())) return code.trim();
    return code;
  }

  String _maritalCode(String label) =>
      _maritalLabelToCode[label.trim()] ?? label;

  @override
  void onInit() {
    super.onInit();
    _loadCastes();
    _fetchDesignations();
    _fetchRoles();

    // Load classes whenever a group is picked; load groups as soon as the
    // active session is available (mirrors the attendance screen).
    ever(selectedGroups, (_) => _fetchClasses());
    // Keep the "Class Teacher Of" pick valid whenever the class list changes.
    ever(selectedClasses, (_) => _reconcileClassTeacher());
    ever(_session.sessionList, (list) {
      if (list.isNotEmpty && groupList.isEmpty) _fetchGroups();
    });
    if (_session.sessionList.isNotEmpty) _fetchGroups();

    final args = Get.arguments;
    if (args is Map && args['userId'] != null) {
      final uid = args['userId'] is int
          ? args['userId'] as int
          : int.tryParse('${args['userId']}') ?? 0;
      if (uid > 0) {
        isEditMode.value = true;
        loadStaffDetails(uid);
      }
    }
    // When adding a new staff, prefill the father name with the "Mr. " prefix.
    if (!isEditMode.value) {
      fatherNameCtrl.text = 'Mr. ';
      husbandNameCtrl.text = 'Mr. ';
    }
  }

  Future<void> _loadCastes() async {
    final list = await _categoryService.getCategories();
    casteList.assignAll(list.map((e) => e.name));
  }

  /// POST /Staff/GetDesignation — designation dropdown. Response is a top-level
  /// list of { id, name, ... }.
  Future<void> _fetchDesignations() async {
    isDesignationLoading.value = true;
    try {
      final raw = await _api.postJsonWithoutBody(Endpoints.getDesignation());
      designationList.assignAll(_parseList(raw, nameKeys: const ['name']));
      _applyPreselections();
    } catch (e) {
      log('GetDesignation error: $e');
    } finally {
      isDesignationLoading.value = false;
    }
  }

  /// GET /RolePermission/GetRoleForStaff — role dropdown. Response is a
  /// top-level list of { id, normalizedName }.
  Future<void> _fetchRoles() async {
    isRoleLoading.value = true;
    try {
      final raw = await _api.getJson(Endpoints.getRoleForStaff());
      roleList.assignAll(
        _parseList(raw, nameKeys: const ['normalizedName', 'name']),
      );
      _applyPreselections();
    } catch (e) {
      log('GetRoleForStaff error: $e');
    } finally {
      isRoleLoading.value = false;
    }
  }

  /// Turns an API response (top-level List or {result/data: List}) into
  /// CategoryModels, reading the label from the first matching key.
  List<CategoryModel> _parseList(
    dynamic raw, {
    required List<String> nameKeys,
  }) {
    final list = raw is List
        ? raw
        : (raw is Map && raw['result'] is List
              ? raw['result'] as List
              : (raw is Map && raw['data'] is List ? raw['data'] as List : []));
    return list.whereType<Map<String, dynamic>>().map((m) {
      final id = m['id'] ?? m['Id'] ?? 0;
      String name = '';
      for (final k in nameKeys) {
        if (m[k] != null && '${m[k]}'.trim().isNotEmpty) {
          name = '${m[k]}'.trim();
          break;
        }
      }
      return CategoryModel(
        id: id is int ? id : int.tryParse('$id') ?? 0,
        name: name,
      );
    }).toList();
  }

  // ── Group & Class fetch (session-scoped, same API as attendance) ───────────

  Future<void> _fetchGroups() async {
    final sid = _activeSessionId;
    if (sid <= 0) return;
    isGroupLoading.value = true;
    try {
      groupList.assignAll(await _session.getGroupList(sid));
      _applyPreselections();
    } finally {
      isGroupLoading.value = false;
    }
  }

  Future<void> _fetchClasses() async {
    final groups = selectedGroups.toList();
    final sid = _activeSessionId;
    if (groups.isEmpty || sid <= 0) {
      classList.clear();
      selectedClasses.clear();
      return;
    }
    isClassLoading.value = true;
    try {
      // Union the classes of every selected group, de-duplicated by id.
      final union = <int, CategoryModel>{};
      for (final g in groups) {
        final classes = await _session.getClassList(g.id ?? 0, sid);
        for (final cl in classes) {
          if (cl.id != null) union[cl.id!] = cl;
        }
      }
      classList.assignAll(union.values);

      // Drop any previously selected class no longer offered, and remap the
      // survivors to the freshly fetched instances (CategoryModel has no value
      // equality, so identity would otherwise break after a re-fetch).
      final kept = selectedClasses
          .map((c) => c.id)
          .whereType<int>()
          .where(union.containsKey)
          .map((id) => union[id]!)
          .toList();
      selectedClasses.assignAll(kept);

      _applyPreselections();
    } finally {
      isClassLoading.value = false;
    }
  }

  /// Selects dropdown values for designation, role, group and class once both
  /// the option list and the loaded id are available.
  void _applyPreselections() {
    if (designationId > 0 && selectedDesignation.value == null) {
      selectedDesignation.value = designationList.firstWhereOrNull(
        (e) => e.id == designationId,
      );
    }
    if (roleId > 0 && selectedRole.value == null) {
      selectedRole.value = roleList.firstWhereOrNull((e) => e.id == roleId);
    }
    if (_loadedGroupIds.isNotEmpty && selectedGroups.isEmpty) {
      final picked =
          groupList.where((e) => _loadedGroupIds.contains(e.id)).toList();
      if (picked.isNotEmpty) selectedGroups.assignAll(picked);
    }
    if (_loadedClassIds.isNotEmpty && selectedClasses.isEmpty) {
      final picked =
          classList.where((e) => _loadedClassIds.contains(e.id)).toList();
      if (picked.isNotEmpty) selectedClasses.assignAll(picked);
    }
    // Class-teacher pick must be one of the selected classes.
    if (_loadedClassTeacherOf > 0 && selectedClassTeacherOf.value == null) {
      selectedClassTeacherOf.value = selectedClasses
          .firstWhereOrNull((e) => e.id == _loadedClassTeacherOf);
    }
  }

  /// Clears the "Class Teacher Of" pick if it is no longer among the selected
  /// classes; otherwise remaps it to the current instance.
  void _reconcileClassTeacher() {
    final current = selectedClassTeacherOf.value;
    if (current == null) return;
    selectedClassTeacherOf.value =
        selectedClasses.firstWhereOrNull((c) => c.id == current.id);
  }

  /// Parses all positive integers from a comma-separated id string.
  static List<int> _allIds(String ids) {
    if (ids.trim().isEmpty) return [];
    return ids
        .split(',')
        .map((p) => int.tryParse(p.trim()))
        .whereType<int>()
        .where((v) => v > 0)
        .toList();
  }

  /// Opens a date picker for the Date of Birth field.
  Future<void> pickDob(BuildContext context) async {
    final now = DateTime.now();
    DateTime initial = DateTime(now.year - 20);
    final current = dobCtrl.text.trim();
    if (current.isNotEmpty) {
      try {
        initial = DateFormat('dd-MM-yyyy').parseStrict(current);
      } catch (_) {}
    }
    final picked = await showDatePicker(
      context: context,
      initialDate: initial.isAfter(now) ? now : initial,
      firstDate: DateTime(1950),
      lastDate: now,
    );
    if (picked != null) {
      dobCtrl.text = DateFormat('dd-MM-yyyy').format(picked);
    }
  }

  /// GET /Staff/GetStaffDetailsById — prefills the form on edit.
  Future<void> loadStaffDetails(int id) async {
    isLoading.value = true;
    try {
      final response = await _api.getJson(Endpoints.getStaffDetailsById(id));
      log('GetStaffDetailsById response: $response');
      if (response is Map<String, dynamic>) {
        final d = StaffDetailsModel.fromJson(response);
        staffId = d.id;
        userId = d.userId;
        nameCtrl.text = d.name;
        mobileCtrl.text = d.mobileNo;
        emailCtrl.text = d.email;
        designationCtrl.text = d.designation;
        designationId = d.designationId;
        roleId = d.roleId;
        dobCtrl.text = d.dob;
        qualificationCtrl.text = d.qualification;
        gender.value = _genderLabel(d.gender);
        maritalStatus.value = _maritalLabel(d.maritalStatus);
        // Route the stored FatherName into the field the UI will show.
        if (usesHusbandName) {
          husbandNameCtrl.text = d.fatherName;
        } else {
          fatherNameCtrl.text = d.fatherName;
        }
        religion.value = d.religion;
        caste.value = d.caste;
        subCasteCtrl.text = d.subCaste;
        villageCtrl.text = d.villageMohalla;
        tehsilCtrl.text = d.tehsil;
        districtCtrl.text = d.district;

        _loadedGroupIds = _allIds(d.groupId);
        // Include every listed class, plus the class-teacher class if set.
        final classIds = _allIds(d.classId);
        if (d.classTeacherOf > 0 && !classIds.contains(d.classTeacherOf)) {
          classIds.add(d.classTeacherOf);
        }
        _loadedClassIds = classIds;
        _loadedClassTeacherOf = d.classTeacherOf;

        _existingDocUrls.addAll({
          'AadharCardUrl': _emptyToNull(d.aadharCardUrl),
          'AadharCardBackUrl': _emptyToNull(d.aadharCardBackUrl),
          'PanCardUrl': _emptyToNull(d.panCardUrl),
          'HigherMarksheetUrl': _emptyToNull(d.higherMarksheetUrl),
          'ExperienceCertificateUrl': _emptyToNull(d.experienceCertificateUrl),
          'DrivingLicenseUrl': _emptyToNull(d.drivingLicenseUrl),
          'PhotoUrl': _emptyToNull(d.photoUrl),
          'interMarksheet': _emptyToNull(d.interMarksheet),
          'graduationMarksheet': _emptyToNull(d.graduationMarksheet),
          'postgraduationMarksheet': _emptyToNull(d.postgraduationMarksheet),
        });

        // Apply preselections immediately in case the option lists are
        // already loaded; otherwise they are applied when each list arrives.
        _applyPreselections();
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load staff details: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  static String? _emptyToNull(String value) =>
      value.trim().isEmpty ? null : value.trim();

  /// Uploads one file and returns the server filename. Throws on statusCode -1.
  Future<String> _uploadDocument(File file) async {
    final bytes = await ImageUtils.compress(file);
    final multipartFile = http.MultipartFile.fromBytes(
      'file',
      bytes,
      filename: file.path.split('/').last,
      contentType: MediaType('image', 'jpeg'),
    );
    // documentFor=1 → Staff.
    final response = await _api.postMultipart(
      Endpoints.uploadDocuments(documentFor: 1),
      fields: {},
      headers: {},
      files: [multipartFile],
    );

    if (response is Map && response['statusCode'] == -1) {
      final msg =
          response['responseText']?.toString() ?? 'Document upload failed';
      log('staff _uploadDocument failed: $msg');
      throw StaffUploadException(msg);
    }

    // The server returns the uploaded photo's link/filename. Different
    // endpoints put it under different keys, so check the common ones.
    final name = (response is String)
        ? response
        : (response?['result'] ??
                  response?['fileName'] ??
                  response?['data'] ??
                  response?['url'] ??
                  response?['filePath'] ??
                  response?['link'] ??
                  response?['responseText'] ??
                  '')
              .toString();
    log('staff _uploadDocument: ${file.path.split('/').last} → $name');
    return name;
  }

  /// Validates required fields. On the first empty one, scrolls it into view
  /// and shows a message, then returns false.
  bool _validateRequired() {
    final checks = <(bool, GlobalKey, String)>[
      (nameCtrl.text.trim().isEmpty, nameFieldKey, 'Name is required'),
      (emailCtrl.text.trim().isEmpty, emailFieldKey, 'Email is required'),
      (mobileCtrl.text.trim().isEmpty, mobileFieldKey, 'Mobile No is required'),
      (
        selectedDesignation.value == null,
        designationFieldKey,
        'Designation is required',
      ),
      (selectedRole.value == null, roleFieldKey, 'Role is required'),
      (gender.value.trim().isEmpty, genderFieldKey, 'Gender is required'),
      (
        maritalStatus.value.trim().isEmpty,
        maritalFieldKey,
        'Marital Status is required',
      ),
    ];
    for (final (invalid, key, msg) in checks) {
      if (invalid) {
        _scrollToField(key);
        Get.snackbar(
          'Required',
          msg,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
        );
        return false;
      }
    }
    return true;
  }

  void _scrollToField(GlobalKey key) {
    final ctx = key.currentContext;
    if (ctx == null) return;
    Scrollable.ensureVisible(
      ctx,
      duration: const Duration(milliseconds: 300),
      alignment: 0.1,
      curve: Curves.easeInOut,
    );
  }

  /// Joins the ids of [items] into the comma-separated string the API expects
  /// for `GroupId` / `ClassId`.
  static String _idsFromList(List<CategoryModel> items) => items
      .map((e) => e.id)
      .whereType<int>()
      .where((id) => id > 0)
      .join(',');

  /// Joins the names of [items] into a comma-separated string.
  static String _namesFromList(List<CategoryModel> items) => items
      .map((e) => e.name ?? '')
      .where((n) => n.isNotEmpty)
      .join(',');

  /// Uploads any selected documents, then POSTs /Staff/AddStaff.
  Future<void> saveStaff() async {
    if (!_validateRequired()) return;
    isSaving.value = true;
    try {
      // 1. Upload documents and collect returned filenames.
      final docFields = <String, String>{};
      for (final key in documentKeys) {
        final file = uploadedFiles[key];
        if (file != null) {
          final name = await _uploadDocument(file);
          final field = _docPayloadField[key];
          if (field != null) docFields[field] = name;
        }
      }

      // 2. Build the AddStaff payload matching the server contract.
      final payload = <String, dynamic>{
        'Id': staffId,
        'UserId': userId,
        'Name': nameCtrl.text.trim(),
        'Email': emailCtrl.text.trim(),
        'FatherName': (usesHusbandName ? husbandNameCtrl : fatherNameCtrl)
            .text
            .trim(),
        'DOB': dobCtrl.text.trim(),
        'DesignationId': selectedDesignation.value?.id ?? designationId,
        'RoleId': selectedRole.value?.id ?? roleId,
        'Designation':
            selectedDesignation.value?.name ?? designationCtrl.text.trim(),
        'Qualification': qualificationCtrl.text.trim(),
        'Gender': _genderCode(gender.value),
        'MaritalStatus': _maritalCode(maritalStatus.value),
        'Religion': religion.value,
        'Caste': caste.value,
        'SubCaste': subCasteCtrl.text.trim(),
        'MobileNo': mobileCtrl.text.trim(),
        'VillageMohalla': villageCtrl.text.trim(),
        'Tehsil': tehsilCtrl.text.trim(),
        'District': districtCtrl.text.trim(),
        'State': stateCtrl.text.trim(),
        'UserName': null,
        'EntryAt': null,
        'AadharCardUrl': _existingDocUrls['AadharCardUrl'],
        'AadharCardBackUrl': _existingDocUrls['AadharCardBackUrl'],
        'PanCardUrl': _existingDocUrls['PanCardUrl'],
        'HigherMarksheetUrl': _existingDocUrls['HigherMarksheetUrl'],
        'ExperienceCertificateUrl':
            _existingDocUrls['ExperienceCertificateUrl'],
        'DrivingLicenseUrl': _existingDocUrls['DrivingLicenseUrl'],
        'PhotoUrl': _existingDocUrls['PhotoUrl'],
        'interMarksheet': _existingDocUrls['interMarksheet'],
        'graduationMarksheet': _existingDocUrls['graduationMarksheet'],
        'postgraduationMarksheet': _existingDocUrls['postgraduationMarksheet'],
        'SessionId': _activeSessionId,
        'GroupId': _idsFromList(selectedGroups),
        'ClassId': _idsFromList(selectedClasses),
        'GroupName': _namesFromList(selectedGroups),
        'ClassName': _namesFromList(selectedClasses),
        // Only teacher designations carry a class-teacher assignment.
        'ClassTeacherOf':
            showClassTeacherOf ? (selectedClassTeacherOf.value?.id ?? 0) : 0,
      };
      docFields.forEach((k, v) => payload[k] = v);

      log('AddStaff payload: $payload');
      final response = await _api.postJson(Endpoints.addStaff(), payload);
      log('AddStaff response: $response');

      final failed = response is Map && response['statusCode'] == -1;
      if (failed) {
        Get.snackbar(
          'Failed',
          response['responseText']?.toString() ?? 'Could not save staff',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      } else {
        Get.back();
        Get.snackbar(
          'Success',
          (response is Map ? response['responseText']?.toString() : null) ??
              'Staff saved successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } on StaffUploadException catch (e) {
      // A document upload failed (statusCode -1) — show it and abort; AddStaff
      // is never reached.
      Get.snackbar(
        'Upload Failed',
        e.message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to save staff: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isSaving.value = false;
    }
  }

  @override
  void onClose() {
    nameCtrl.dispose();
    fatherNameCtrl.dispose();
    husbandNameCtrl.dispose();
    mobileCtrl.dispose();
    emailCtrl.dispose();
    dobCtrl.dispose();
    designationCtrl.dispose();
    qualificationCtrl.dispose();
    villageCtrl.dispose();
    tehsilCtrl.dispose();
    districtCtrl.dispose();
    subCasteCtrl.dispose();
    stateCtrl.dispose();
    scrollController.dispose();
    super.onClose();
  }
}
