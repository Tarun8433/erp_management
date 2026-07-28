import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../../core/controllers/session_controller.dart';
import '../../../../../core/models/category_model.dart';
import '../../../../../core/services/api/api_service.dart';
import '../../../../../core/services/api/endpoints.dart';
import '../models/attendance_student_model.dart';
import '../models/shift_model.dart';

class AttendanceController extends GetxController {
  final SessionController _session = Get.put(SessionController());
  final ApiService _api = ApiService();

  // ── Session ────────────────────────────────────────────────────────────────
  final sessionList = <String>[].obs;
  final selectedSession = ''.obs;

  // ── Group ──────────────────────────────────────────────────────────────────
  final groupList = <CategoryModel>[].obs;
  final selectedGroup = Rxn<CategoryModel>();
  final isGroupLoading = false.obs;

  // ── Class ──────────────────────────────────────────────────────────────────
  final classList = <CategoryModel>[].obs;
  final selectedClass = Rxn<CategoryModel>();
  final isClassLoading = false.obs;

  // ── Shift ──────────────────────────────────────────────────────────────────
  final shiftList = <ShiftModel>[].obs;
  final selectedShift = Rxn<ShiftModel>();
  final isShiftLoading = false.obs;

  // ── Date ───────────────────────────────────────────────────────────────────
  final selectedDate = Rxn<DateTime>();

  String get formattedDate => selectedDate.value == null
      ? ''
      : DateFormat('dd/MM/yyyy').format(selectedDate.value!);

  // ── Results ────────────────────────────────────────────────────────────────
  final isSearching = false.obs;
  final hasSearched = false.obs;
  final students = <AttendanceStudentModel>[].obs;
  final searchQuery = ''.obs;
  final viewMode = 'card'.obs; // 'card' | 'table'

  // ── Table column visibility ────────────────────────────────────────────────
  static const allColumns = [
    'serial',
    'sid',
    'firstName',
    'fatherName',
    'status',
  ];
  static const columnLabels = {
    'serial':     '#',
    'sid':        'Student ID',
    'firstName':  'Student Name',
    'fatherName': 'Father Name',
    'status':     'Status',
  };

  final columnVisibility = <String, bool>{
    'serial':     true,
    'sid':        true,
    'firstName':  true,
    'fatherName': true,
    'status':     true,
  }.obs;

  void toggleColumn(String key) {
    // Prevent hiding all columns — at least one must remain visible.
    final currentlyVisible = columnVisibility.values.where((v) => v).length;
    if (currentlyVisible == 1 && columnVisibility[key] == true) return;
    columnVisibility[key] = !(columnVisibility[key] ?? true);
  }

  List<AttendanceStudentModel> get filteredStudents {
    final q = searchQuery.value.toLowerCase();
    if (q.isEmpty) return students;
    return students.where((s) =>
        s.firstName.toLowerCase().contains(q) ||
        s.fatherName.toLowerCase().contains(q) ||
        s.sid.toLowerCase().contains(q)).toList();
  }

  int get totalCount => students.length;
  int get presentCount => students.where((s) => s.status == 'P').length;
  int get absentCount => students.where((s) => s.status == 'A').length;
  int get lateCount => students.where((s) => s.status == 'L').length;
  int get notMarkedCount => students.where((s) => !s.isMarked).length;

  void toggleView() =>
      viewMode.value = viewMode.value == 'card' ? 'table' : 'card';

  @override
  void onInit() {
    super.onInit();
    // Register reactions BEFORE loading sessions. When SessionController already
    // has sessions cached, _loadSessions() sets selectedSession synchronously —
    // if the reactions weren't registered yet, _fetchGroups() would never fire
    // and the Group/Class dropdowns would stay empty (unselectable).
    ever(selectedSession, (_) => _fetchGroups());
    ever(selectedGroup, (_) => _fetchClasses());
    _loadSessions();
    _fetchShifts();
  }

  // ── Session loading ────────────────────────────────────────────────────────

  void _loadSessions() {
    void applyList(List sessions) {
      final names = sessions
          .map((e) => e.sessionName ?? '')
          .where((n) => (n as String).isNotEmpty)
          .toList()
          .cast<String>();
      sessionList.assignAll(names);
      if (names.isNotEmpty && selectedSession.value.isEmpty) {
        selectedSession.value = names.first;
      }
    }

    ever(_session.sessionList, applyList);
    if (_session.sessionList.isNotEmpty) applyList(_session.sessionList);
  }

  // ── Group loading ──────────────────────────────────────────────────────────

  Future<void> _fetchGroups() async {
    final session = _session.sessionList.firstWhereOrNull(
      (e) => e.sessionName == selectedSession.value,
    );
    if (session == null || session.sessionId == null) return;

    isGroupLoading.value = true;
    selectedGroup.value = null;
    classList.clear();
    selectedClass.value = null;

    try {
      final list = await _session.getGroupList(session.sessionId as int);
      groupList.assignAll(list);
    } finally {
      isGroupLoading.value = false;
    }
  }

  // ── Class loading ──────────────────────────────────────────────────────────

  Future<void> _fetchClasses() async {
    final group = selectedGroup.value;
    final session = _session.sessionList.firstWhereOrNull(
      (e) => e.sessionName == selectedSession.value,
    );
    if (group == null || session == null || session.sessionId == null) return;

    isClassLoading.value = true;
    selectedClass.value = null;
    classList.clear();

    try {
      final list = await _session.getClassList(
        group.id ?? 0,
        session.sessionId as int,
      );
      classList.assignAll(list);
    } finally {
      isClassLoading.value = false;
    }
  }

  // ── Shift loading ──────────────────────────────────────────────────────────

  Future<void> _fetchShifts() async {
    isShiftLoading.value = true;
    try {
      final raw = await _api.postJsonWithoutBody(Endpoints.shiftList());
      List<dynamic> list = [];
      if (raw is List) {
        list = raw;
      } else if (raw is Map && raw['result'] is List) {
        list = raw['result'] as List;
      }
      final shifts = list
          .whereType<Map<String, dynamic>>()
          .map(ShiftModel.fromJson)
          .toList();
      shiftList.assignAll(shifts);
      if (shifts.isNotEmpty) selectedShift.value = shifts.first;
    } catch (e) {
      log('[Attendance] _fetchShifts error: $e');
    } finally {
      isShiftLoading.value = false;
    }
  }

  // ── Date picker ────────────────────────────────────────────────────────────

  Future<void> pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate.value ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      selectedDate.value = picked;
    }
  }

  // ── Search ─────────────────────────────────────────────────────────────────

  String? get validationError {
    if (selectedGroup.value == null) return 'Please select a group';
    if (selectedClass.value == null) return 'Please select a class';
    if (selectedDate.value == null) return 'Please select a date';
    if (selectedShift.value == null) return 'Please select a shift';
    return null;
  }

  Future<void> search() async {
    final err = validationError;
    if (err != null) {
      Get.snackbar('Required', err,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16));
      return;
    }

    final session = _session.sessionList.firstWhereOrNull(
      (e) => e.sessionName == selectedSession.value,
    );

    final payload = {
      'groupId': selectedGroup.value!.id ?? 0,
      'classId': selectedClass.value!.id ?? 0,
      'sessionId': session?.sessionId ?? 0,
      'attendanceDate':
          DateFormat('yyyy-MM-dd').format(selectedDate.value!),
      'shiftId': selectedShift.value!.id,
    };

    log('[Attendance] search payload: ${jsonEncode(payload)}');

    isSearching.value = true;
    hasSearched.value = false;
    students.clear();
    try {
      final raw = await _api.postJson(
          Endpoints.getStudentsForAttendance(), payload);
      log('[Attendance] response:\n${const JsonEncoder.withIndent('  ').convert(raw)}');
      List<dynamic> list = [];
      if (raw is List) {
        list = raw;
      } else if (raw is Map && raw['result'] is List) {
        list = raw['result'] as List;
      }
      students.assignAll(list
          .whereType<Map<String, dynamic>>()
          .map(AttendanceStudentModel.fromJson));
      hasSearched.value = true;
    } catch (e) {
      log('[Attendance] search error: $e');
      Get.snackbar('Error', e.toString().replaceFirst('Exception: ', ''),
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16));
    } finally {
      isSearching.value = false;
    }
  }

  // ── Monthly register (GetAttendenceRegister) ───────────────────────────────
  final isLoadingRegister = false.obs;
  final registerRows = <Map<String, dynamic>>[].obs;

  /// Fetches the monthly attendance summary for each student.
  /// [month] is the month id (e.g. April = 4).
  Future<void> fetchAttendanceRegister({required int month}) async {
    final session = _session.sessionList.firstWhereOrNull(
      (e) => e.sessionName == selectedSession.value,
    );

    final payload = {
      'groupId': selectedGroup.value?.id ?? 0,
      'classId': selectedClass.value?.id ?? 0,
      'sessionId': session?.sessionId ?? 0,
      'month': month,
    };

    log('[Attendance] register payload: ${jsonEncode(payload)}');
    isLoadingRegister.value = true;
    registerRows.clear();
    try {
      final raw = await _api.postJson(
        Endpoints.getAttendanceRegister(),
        payload,
      );
      log('[Attendance] register response:\n${const JsonEncoder.withIndent('  ').convert(raw)}');

      List<dynamic> list = [];
      if (raw is List) {
        list = raw;
      } else if (raw is Map && (raw['result'] ?? raw['data']) is List) {
        list = (raw['result'] ?? raw['data']) as List;
      }
      registerRows.assignAll(list.whereType<Map<String, dynamic>>());
    } catch (e) {
      log('[Attendance] register error: $e');
      Get.snackbar('Error', e.toString().replaceFirst('Exception: ', ''),
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16));
    } finally {
      isLoadingRegister.value = false;
    }
  }
}
