import 'dart:developer';

import 'package:erp_management/core/controllers/session_controller.dart';
import 'package:erp_management/core/models/category_model.dart';
import 'package:erp_management/core/services/api/api_service.dart';
import 'package:erp_management/core/services/api/endpoints.dart';
import 'package:erp_management/features/role_based_ui/principal/admission/controllers/admission_controller.dart';
import 'package:erp_management/features/role_based_ui/principal/new_student_list/models/student_list_response.dart';
import 'package:erp_management/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AdmissionReportItem {
  final int id;
  final int sNo;
  final String sid;
  final String group;
  final String className;
  final String aadhaarNo;
  final String name;
  final String status;
  final String fatherName;
  final String motherName;
  final String mobileNo;
  final String district;
  final String tehsil;
  final String village;
  final String dob;
  final String studentImage;
  final String finishedImage;
  final String srNo;
  final String religion;
  final String category;
  final String subCategory;
  final String gender;
  final String entryAt;

  AdmissionReportItem({
    required this.id,
    required this.sNo,
    required this.sid,
    required this.group,
    required this.className,
    required this.aadhaarNo,
    required this.name,
    required this.status,
    required this.fatherName,
    required this.motherName,
    required this.mobileNo,
    required this.district,
    required this.tehsil,
    required this.village,
    required this.dob,
    required this.studentImage,
    required this.finishedImage,
    required this.srNo,
    required this.religion,
    required this.category,
    required this.subCategory,
    required this.gender,
    required this.entryAt,
  });

  factory AdmissionReportItem.fromResponse(StudentListResponse s, int index) {
    return AdmissionReportItem(
      id: s.id ?? 0,
      sNo: index + 1,
      sid: s.sid ?? '',
      group: s.groupName ?? '',
      className: s.className ?? '',
      aadhaarNo: s.aadharNo ?? '',
      name: '${s.firstName ?? ''} ${s.lastName ?? ''}'.trim(),
      status: (s.isActive == true) ? 'Active' : 'Inactive',
      fatherName: s.fatherName ?? '',
      motherName: s.motherName ?? '',
      mobileNo: s.fatherMobile ?? '',
      district: s.district ?? '',
      tehsil: s.tehsil ?? '',
      village: s.villageMohalla ?? '',
      dob: s.dob ?? '',
      studentImage: (s.photo != null && s.photo!.isNotEmpty) ? s.photo! : '',
      finishedImage: s.finishedPhoto ?? '',
      srNo: s.srno ?? '',
      religion: s.religion ?? '',
      category: s.category ?? '',
      subCategory: s.subCategory ?? '',
      gender: s.gender ?? '',
      entryAt: s.entryOn ?? '',
    );
  }
}

class AdmissionReportController extends GetxController {
  final RxString viewMode = 'table'.obs;
  final RxDouble baseFontSize = 12.0.obs;

  // Default "All" options shown at the top of the Group / Class dropdowns.
  static const String allGroup = 'ALL GROUP';
  static const String allClass = 'ALL CLASS';

  // Filters — names displayed in dropdowns
  final RxString selectedSession = ''.obs;
  final RxString selectedGroup = allGroup.obs;
  final RxString selectedClass = allClass.obs;
  final RxString selectedStatus = 'All'.obs;
  final RxString searchText = ''.obs;

  // Admission date range. Defaults to 01-April of the current session year
  // through today.
  final Rx<DateTime> fromDate = _defaultFromDate().obs;
  final Rx<DateTime> toDate = DateTime.now().obs;

  static DateTime _defaultFromDate() {
    final now = DateTime.now();
    // Academic session starts in April; before April use the previous year.
    final year = now.month >= 4 ? now.year : now.year - 1;
    return DateTime(year, 4, 1);
  }

  String get fromDateText => _formatDisplay(fromDate.value);
  String get toDateText => _formatDisplay(toDate.value);

  String _formatDisplay(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}-${d.month.toString().padLeft(2, '0')}-${d.year}';

  String _formatApi(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Future<void> pickFromDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: fromDate.value,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) fromDate.value = picked;
  }

  Future<void> pickToDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: toDate.value,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) toDate.value = picked;
  }

  // Dynamic dropdown lists from API
  final RxList<String> sessions = <String>[].obs;
  final RxList<String> groups = <String>[allGroup].obs;
  final RxList<String> classes = <String>[allClass].obs;
  final List<String> statuses = ['Active', 'Inactive', 'All'];

  final RxList<AdmissionReportItem> reportItems = <AdmissionReportItem>[].obs;
  final RxBool isLoading = false.obs;

  final SessionController _sessionCtrl = Get.put(SessionController());
  List<CategoryModel> _loadedGroups = [];
  List<CategoryModel> _loadedClasses = [];

  @override
  void onInit() {
    super.onInit();
    _loadSessions();
    ever(selectedSession, (_) => _fetchGroups());
    ever(selectedGroup, (_) => _fetchClasses());
  }

  void _loadSessions() {
    ever(_sessionCtrl.sessionList, (list) {
      final names = list
          .map((e) => e.sessionName ?? '')
          .where((n) => n.isNotEmpty)
          .toList();
      sessions.assignAll(names);
      if (selectedSession.value.isNotEmpty && !names.contains(selectedSession.value)) {
        selectedSession.value = '';
      }
    });
    if (_sessionCtrl.sessionList.isNotEmpty) {
      final names = _sessionCtrl.sessionList
          .map((e) => e.sessionName ?? '')
          .where((n) => n.isNotEmpty)
          .toList();
      sessions.assignAll(names);
      if (selectedSession.value.isNotEmpty && !names.contains(selectedSession.value)) {
        selectedSession.value = '';
      }
    }
  }

  Future<void> _fetchGroups() async {
    final session = _sessionCtrl.sessionList.firstWhereOrNull(
      (e) => e.sessionName == selectedSession.value,
    );
    if (session == null || session.sessionId == null) return;

    _loadedGroups = await _sessionCtrl.getGroupList(session.sessionId);
    final names = _loadedGroups
        .map((g) => g.name ?? '')
        .where((n) => n.isNotEmpty)
        .toList();
    groups.assignAll([allGroup, ...names]);

    if (!groups.contains(selectedGroup.value)) {
      selectedGroup.value = allGroup;
    }
  }

  Future<void> _fetchClasses() async {
    // "ALL GROUP" spans every class, so there's no specific class list to load.
    if (selectedGroup.value == allGroup) {
      _loadedClasses = [];
      classes.assignAll([allClass]);
      selectedClass.value = allClass;
      return;
    }

    final session = _sessionCtrl.sessionList.firstWhereOrNull(
      (e) => e.sessionName == selectedSession.value,
    );
    final group = _loadedGroups.firstWhereOrNull(
      (g) => g.name == selectedGroup.value,
    );
    if (session == null || session.sessionId == null ||
        group == null || group.id == null) {
      return;
    }

    _loadedClasses = await _sessionCtrl.getClassList(group.id!, session.sessionId!);
    final names = _loadedClasses
        .map((c) => c.name ?? '')
        .where((n) => n.isNotEmpty)
        .toList();
    classes.assignAll([allClass, ...names]);

    if (!classes.contains(selectedClass.value)) {
      selectedClass.value = allClass;
    }
  }

  void toggleViewMode() {
    viewMode.value = viewMode.value == 'table' ? 'card' : 'table';
  }

  void updateFontSize(double delta) {
    baseFontSize.value = (baseFontSize.value + delta).clamp(10.0, 20.0);
  }

  Future<void> fetchReport() async {
    isLoading.value = true;
    try {
      final session = _sessionCtrl.sessionList.firstWhereOrNull(
        (e) => e.sessionName == selectedSession.value,
      );
      // "ALL GROUP" / "ALL CLASS" map to 0 (no filter).
      final group = selectedGroup.value == allGroup
          ? null
          : _loadedGroups.firstWhereOrNull((g) => g.name == selectedGroup.value);
      final cls = selectedClass.value == allClass
          ? null
          : _loadedClasses.firstWhereOrNull((c) => c.name == selectedClass.value);

      int isActiveStatus = -1;
      if (selectedStatus.value == 'Active') isActiveStatus = 1;
      if (selectedStatus.value == 'Inactive') isActiveStatus = 0;

      final payload = {
        'isActive': isActiveStatus,
        'branchId': 0,
        'sessionId': session?.sessionId ?? 0,
        'groupId': group?.id ?? 0,
        'classId': cls?.id ?? 0,
        'top': 0,
        'searchText': searchText.value,
        'fromDate': _formatApi(fromDate.value),
        'toDate': _formatApi(toDate.value),
      };

      final response = await ApiService().postJson(
        Endpoints.getNewStudentList(),
        payload,
      );

      List<dynamic> listData = [];
      if (response is Map<String, dynamic>) {
        listData = response['result'] ?? response['data'] ?? [];
      } else if (response is List) {
        listData = response;
      }

      final items = listData
          .asMap()
          .entries
          .map((e) => AdmissionReportItem.fromResponse(
                StudentListResponse.fromJson(e.value),
                e.key,
              ))
          .toList();

      reportItems.assignAll(items);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to fetch report: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> openForEdit(int studentId) async {
    if (studentId == 0) return;
    isLoading.value = true;
    try {
      final response = await ApiService().getJson(
        Endpoints.studentAdmissionDetails(studentId),
      );

      // A failure still comes back as a Map — {statusCode: -1, result: null} —
      // so the envelope must be checked before navigating. Otherwise the edit
      // form opens with every field blank and no explanation.
      final isOk = response is Map<String, dynamic> &&
          response['statusCode'] == 1 &&
          response['result'] is Map<String, dynamic>;

      if (!isOk) {
        final message = (response is Map
                ? response['responseText']?.toString()
                : null) ??
            'Could not load student details';
        log('[AdmissionReport] openForEdit failed studentId=$studentId: '
            '$message');
        Get.snackbar(
          'Cannot Open Student',
          message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 5),
        );
        return;
      }

      Get.delete<AdmissionController>(force: true);
      Get.toNamed(
        AppRoutes.newAdmission,
        arguments: {'editData': response, 'studentType': 2},
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to open student: $e',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }
}
