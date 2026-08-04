// import 'dart:convert';
// import 'dart:developer';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:intl/intl.dart';
// import '../../../../../core/controllers/session_controller.dart';
// import '../../../../../core/models/category_model.dart';
// import '../../../../../core/services/api/api_service.dart';
// import '../../../../../core/services/api/endpoints.dart';
// import '../models/attendance_student_model.dart';
// import '../models/attendance_type.dart';
// import '../models/shift_model.dart';

// class AttendanceMarkingController extends GetxController {
//   final SessionController _session = Get.put(SessionController());
//   final ApiService _api = ApiService();

//   // ── Filters ────────────────────────────────────────────────────────────────
//   final sessionList = <String>[].obs;
//   final selectedSession = ''.obs;

//   final groupList = <CategoryModel>[].obs;
//   final selectedGroup = Rxn<CategoryModel>();
//   final isGroupLoading = false.obs;

//   final classList = <CategoryModel>[].obs;
//   final selectedClass = Rxn<CategoryModel>();
//   final isClassLoading = false.obs;

//   final shiftList = <ShiftModel>[].obs;
//   final selectedShift = Rxn<ShiftModel>();
//   final isShiftLoading = false.obs;

//   final selectedDate = Rxn<DateTime>();
//   String get formattedDate => selectedDate.value == null
//       ? ''
//       : DateFormat('dd/MM/yyyy').format(selectedDate.value!);

//   // ── Student list ───────────────────────────────────────────────────────────
//   final isLoading = false.obs;
//   final hasLoaded = false.obs;
//   final students = <AttendanceStudentModel>[].obs;
//   final searchQuery = ''.obs;

//   List<AttendanceStudentModel> get filteredStudents {
//     final q = searchQuery.value.toLowerCase();
//     if (q.isEmpty) return students;
//     return students
//         .where((s) =>
//             s.firstName.toLowerCase().contains(q) ||
//             s.fatherName.toLowerCase().contains(q) ||
//             s.sid.toLowerCase().contains(q))
//         .toList();
//   }

//   // ── Marking state: studentId -> typeId ─────────────────────────────────────
//   final markingMap = <int, int?>{}.obs;

//   // ── Bulk set ───────────────────────────────────────────────────────────────
//   final bulkType = Rxn<AttendanceTypeOption>();

//   // ── Summary (reactive from markingMap) ─────────────────────────────────────
//   int get presentCount =>
//       markingMap.values.where((v) => v == AttendanceTypeOption.present.id).length;
//   int get absentCount =>
//       markingMap.values.where((v) => v == AttendanceTypeOption.absent.id).length;
//   int get halfDayCount =>
//       markingMap.values.where((v) => v == AttendanceTypeOption.halfDay.id).length;
//   int get holidayCount =>
//       markingMap.values.where((v) => v == AttendanceTypeOption.holiday.id).length;
//   int get unmarkedCount => markingMap.values.where((v) => v == null).length;

//   // ── Save ───────────────────────────────────────────────────────────────────
//   final isSaving = false.obs;

//   // ── View mode ──────────────────────────────────────────────────────────────
//   final viewMode = 'card'.obs;

//   static const allColumns = ['serial', 'sid', 'name', 'father', 'P', 'A', 'H', 'Ho'];
//   static const columnLabels = <String, String>{
//     'serial': '#',
//     'sid': 'Student ID',
//     'name': 'Name',
//     'father': 'Father',
//     'P': 'Present',
//     'A': 'Absent',
//     'H': 'Half Day',
//     'Ho': 'Holiday',
//   };
//   final columnVisibility = <String, bool>{
//     'serial': true,
//     'sid': true,
//     'name': true,
//     'father': true,
//     'P': true,
//     'A': true,
//     'H': true,
//     'Ho': true,
//   }.obs;

//   void toggleView() =>
//       viewMode.value = viewMode.value == 'card' ? 'table' : 'card';

//   void toggleColumn(String key) {
//     final visibleCount = columnVisibility.values.where((v) => v).length;
//     if (visibleCount == 1 && columnVisibility[key] == true) return;
//     columnVisibility[key] = !(columnVisibility[key] ?? true);
//   }

//   @override
//   void onInit() {
//     super.onInit();
//     // Register reactive workers BEFORE loading sessions. Otherwise, when a
//     // session is already available synchronously, _loadSessions() would set
//     // selectedSession before the worker exists and the group fetch never fires.
//     ever(selectedSession, (_) => _fetchGroups());
//     ever(selectedGroup, (_) => _fetchClasses());
//     // Default the attendance date to today.
//     selectedDate.value = DateTime.now();
//     _loadSessions();
//     _fetchShifts();
//   }

//   // ── Session ────────────────────────────────────────────────────────────────

//   void _loadSessions() {
//     void apply(List sessions) {
//       final names = sessions
//           .map((e) => e.sessionName ?? '')
//           .where((n) => (n as String).isNotEmpty)
//           .cast<String>()
//           .toList();
//       sessionList.assignAll(names);
//       if (names.isNotEmpty && selectedSession.value.isEmpty) {
//         selectedSession.value = names.first;
//       }
//     }

//     ever(_session.sessionList, apply);
//     if (_session.sessionList.isNotEmpty) apply(_session.sessionList);
//   }

//   // ── Group ──────────────────────────────────────────────────────────────────

//   Future<void> _fetchGroups() async {
//     final session = _session.sessionList
//         .firstWhereOrNull((e) => e.sessionName == selectedSession.value);
//     if (session?.sessionId == null) return;
//     isGroupLoading.value = true;
//     selectedGroup.value = null;
//     classList.clear();
//     selectedClass.value = null;
//     try {
//       groupList.assignAll(
//           await _session.getGroupList(session!.sessionId as int));
//     } finally {
//       isGroupLoading.value = false;
//     }
//   }

//   // ── Class ──────────────────────────────────────────────────────────────────

//   Future<void> _fetchClasses() async {
//     final group = selectedGroup.value;
//     final session = _session.sessionList
//         .firstWhereOrNull((e) => e.sessionName == selectedSession.value);
//     if (group == null || session?.sessionId == null) return;
//     isClassLoading.value = true;
//     selectedClass.value = null;
//     classList.clear();
//     try {
//       classList.assignAll(await _session.getClassList(
//           group.id ?? 0, session!.sessionId as int));
//     } finally {
//       isClassLoading.value = false;
//     }
//   }

//   // ── Shift ──────────────────────────────────────────────────────────────────

//   Future<void> _fetchShifts() async {
//     isShiftLoading.value = true;
//     try {
//       final raw = await _api.postJsonWithoutBody(Endpoints.shiftList());
//       List<dynamic> list = raw is List
//           ? raw
//           : (raw is Map && raw['result'] is List ? raw['result'] as List : []);
//       final shifts = list
//           .whereType<Map<String, dynamic>>()
//           .map(ShiftModel.fromJson)
//           .toList();
//       shiftList.assignAll(shifts);
//       if (shifts.isNotEmpty) selectedShift.value = shifts.first;
//     } catch (e) {
//       log('[Marking] _fetchShifts: $e');
//     } finally {
//       isShiftLoading.value = false;
//     }
//   }

//   // ── Date ───────────────────────────────────────────────────────────────────

//   Future<void> pickDate(BuildContext context) async {
//     final picked = await showDatePicker(
//       context: context,
//       initialDate: selectedDate.value ?? DateTime.now(),
//       firstDate: DateTime(2020),
//       lastDate: DateTime.now(),
//     );
//     if (picked != null) selectedDate.value = picked;
//   }

//   // ── Load students ──────────────────────────────────────────────────────────

//   String? get validationError {
//     if (selectedGroup.value == null) return 'Please select a group';
//     if (selectedClass.value == null) return 'Please select a class';
//     if (selectedDate.value == null) return 'Please select a date';
//     if (selectedShift.value == null) return 'Please select a shift';
//     return null;
//   }

//   Future<void> loadStudents() async {
//     final err = validationError;
//     if (err != null) {
//       Get.snackbar('Required', err,
//           snackPosition: SnackPosition.BOTTOM,
//           margin: const EdgeInsets.all(16));
//       return;
//     }

//     final session = _session.sessionList
//         .firstWhereOrNull((e) => e.sessionName == selectedSession.value);

//     isLoading.value = true;
//     hasLoaded.value = false;
//     students.clear();
//     markingMap.clear();
//     bulkType.value = null;

//     try {
//       final raw = await _api.postJson(
//         Endpoints.getStudentsForAttendance(),
//         {
//           'groupId': selectedGroup.value!.id ?? 0,
//           'classId': selectedClass.value!.id ?? 0,
//           'sessionId': session?.sessionId ?? 0,
//           'attendanceDate':
//               DateFormat('yyyy-MM-dd').format(selectedDate.value!),
//           'shiftId': selectedShift.value!.id,
//         },
//       );

//       List<dynamic> list = raw is List
//           ? raw
//           : (raw is Map && raw['result'] is List ? raw['result'] as List : []);

//       final loaded = list
//           .whereType<Map<String, dynamic>>()
//           .map(AttendanceStudentModel.fromJson)
//           .toList();

//       students.assignAll(loaded);

//       // Pre-fill marking map — keep any existing attendance, otherwise default
//       // each student to Present so the sheet loads ready to save.
//       for (final s in loaded) {
//         markingMap[s.id] = s.attendenceTypeId ?? AttendanceTypeOption.present.id;
//       }
//       hasLoaded.value = true;
//     } catch (e) {
//       log('[Marking] loadStudents: $e');
//       _showError(_friendlyMessage(e));
//     } finally {
//       isLoading.value = false;
//     }
//   }

//   /// Turns a raw error into a short, plain-language message a non-technical
//   /// user can act on. The original error is still logged for developers.
//   String _friendlyMessage(Object e) {
//     final msg = e.toString().toLowerCase();
//     if (msg.contains('no internet') ||
//         msg.contains('socketexception') ||
//         msg.contains('network') ||
//         msg.contains('failed host lookup') ||
//         msg.contains('connection')) {
//       return 'No internet connection. Please check your network and try again.';
//     }
//     if (msg.contains('timeout') || msg.contains('timed out')) {
//       return 'The server is taking too long to respond. Please try again.';
//     }
//     if (msg.contains('session expired') || msg.contains('unauthor')) {
//       return 'Your session has expired. Please log in again.';
//     }
//     if (msg.contains('http 5') ||
//         msg.contains('500') ||
//         msg.contains('502') ||
//         msg.contains('503')) {
//       return 'The server is having a problem right now. '
//           'Please try again in a little while.';
//     }
//     if (msg.contains('http 4') ||
//         msg.contains('format') ||
//         msg.contains('json') ||
//         msg.contains('type ')) {
//       return 'We couldn\'t complete this request. Please try again.';
//     }
//     return 'Something went wrong. Please try again.';
//   }

//   void _showError(String message) {
//     Get.snackbar(
//       'Something went wrong',
//       message,
//       snackPosition: SnackPosition.BOTTOM,
//       backgroundColor: const Color(0xFFC62828),
//       colorText: const Color(0xFFFFFFFF),
//       margin: const EdgeInsets.all(16),
//     );
//   }

//   // ── Mark individual ────────────────────────────────────────────────────────

//   void setMark(int studentId, int typeId) {
//     markingMap[studentId] = typeId;
//     // Clear bulk selection when individual entries differ.
//     bulkType.value = null;
//   }

//   // ── Bulk mark all ──────────────────────────────────────────────────────────

//   void applyBulk(AttendanceTypeOption? option) {
//     if (option == null) return;
//     bulkType.value = option;
//     for (final s in students) {
//       markingMap[s.id] = option.id;
//     }
//   }

//   // ── Save ───────────────────────────────────────────────────────────────────

//   Future<void> saveBulk() async {
//     final session = _session.sessionList
//         .firstWhereOrNull((e) => e.sessionName == selectedSession.value);

//     // A holiday requires a note; ask for it before saving.
//     String holidayNote = '';
//     if (holidayCount > 0) {
//       final note = await _askHolidayNote();
//       if (note == null) return; // user cancelled
//       holidayNote = note;
//     }

//     final holidayId = AttendanceTypeOption.holiday.id;
//     final attendenceData = students.map((s) {
//       final type = markingMap[s.id] ?? AttendanceTypeOption.absent.id;
//       return {
//         'studentId': s.id,
//         'attendenceType': type,
//         'attendenceSource': AttendenceSource.mobile.id,
//         // Only holiday entries carry a note.
//         'note': type == holidayId ? holidayNote : '',
//       };
//     }).toList();

//     final payload = <String, dynamic>{
//       'groupId': selectedGroup.value?.id ?? 0,
//       'sessionId': session?.sessionId ?? 0,
//       'classId': selectedClass.value?.id ?? 0,
//       'date': DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'").format(selectedDate.value!),
//       'shiftId': selectedShift.value!.id,
//       'setAllAttendanceValue': 0,
//       'ipAddress': '',
//       'attendenceData': attendenceData,
//       'holidayRemarks': holidayNote,
//     };

//     log('[Marking] saveBulk payload:\n${const JsonEncoder.withIndent('  ').convert(payload)}');

//     isSaving.value = true;
//     try {
//       await _api.postJson(Endpoints.saveBulkAttendance(), payload);
//       Get.snackbar(
//         'Saved',
//         'Attendance saved successfully',
//         snackPosition: SnackPosition.BOTTOM,
//         backgroundColor: const Color(0xFF2E7D32),
//         colorText: const Color(0xFFFFFFFF),
//         margin: const EdgeInsets.all(16),
//       );
//     } catch (e) {
//       log('[Marking] saveBulk error: $e');
//       _showError(_friendlyMessage(e));
//     } finally {
//       isSaving.value = false;
//     }
//   }

//   /// Prompts for a holiday note. Returns the note, or null if cancelled.
//   Future<String?> _askHolidayNote() {
//     final ctrl = TextEditingController();
//     return Get.dialog<String>(
//       AlertDialog(
//         title: const Text('Holiday Note'),
//         content: TextField(
//           controller: ctrl,
//           autofocus: true,
//           maxLines: 2,
//           decoration: const InputDecoration(
//             hintText: 'Reason for holiday',
//             border: OutlineInputBorder(),
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Get.back<String>(),
//             child: const Text('Cancel'),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               final note = ctrl.text.trim();
//               if (note.isEmpty) return;
//               Get.back<String>(result: note);
//             },
//             child: const Text('Save'),
//           ),
//         ],
//       ),
//       barrierDismissible: false,
//     );
//   }
// }
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
import '../models/attendance_type.dart';
import '../models/shift_model.dart';

/// Single source of truth for the merged "Student Attendance" screen.
/// Handles BOTH viewing (search/filter/summary) AND marking (edit + save)
/// so the UI no longer needs two separate controllers/screens.
class AttendanceMarkingController extends GetxController {
  final SessionController _session = Get.put(SessionController());
  final ApiService _api = ApiService();
  final isAttendanceSubmitted = false.obs;
  // ── Filters ────────────────────────────────────────────────────────────────
  final sessionList = <String>[].obs;
  final selectedSession = ''.obs;

  final groupList = <CategoryModel>[].obs;
  final selectedGroup = Rxn<CategoryModel>();
  final isGroupLoading = false.obs;

  final classList = <CategoryModel>[].obs;
  final selectedClass = Rxn<CategoryModel>();
  final isClassLoading = false.obs;

  final shiftList = <ShiftModel>[].obs;
  final selectedShift = Rxn<ShiftModel>();
  final isShiftLoading = false.obs;

  final selectedDate = Rxn<DateTime>();
  String get formattedDate => selectedDate.value == null
      ? ''
      : DateFormat('dd/MM/yyyy').format(selectedDate.value!);

  // ── Student list ───────────────────────────────────────────────────────────
  final isLoading = false.obs;
  final hasLoaded = false.obs;
  final students = <AttendanceStudentModel>[].obs;
  final searchQuery = ''.obs;

  /// 'all' | 'marked' | 'unmarked' — drives the MARKED/UNMARKED toggle.
  final markedFilter = 'all'.obs;

  List<AttendanceStudentModel> get filteredStudents {
    final q = searchQuery.value.toLowerCase();
    var list = students.where((s) {
      if (q.isEmpty) return true;
      return s.firstName.toLowerCase().contains(q) ||
          s.fatherName.toLowerCase().contains(q) ||
          s.sid.toLowerCase().contains(q);
    });

    switch (markedFilter.value) {
      case 'marked':
        list = list.where((s) => markingMap[s.id] != null);
        break;
      case 'unmarked':
        list = list.where((s) => markingMap[s.id] == null);
        break;
      default:
        break;
    }
    return list.toList();
  }

  void setMarkedFilter(String value) => markedFilter.value = value;

  // ── Marking state: studentId -> typeId ─────────────────────────────────────
  final markingMap = <int, int?>{}.obs;

  // ── Bulk set ───────────────────────────────────────────────────────────────
  final bulkType = Rxn<AttendanceTypeOption>();

  // ── Summary (reactive from markingMap) ─────────────────────────────────────
  int get totalCount => students.length;
  int get presentCount => markingMap.values
      .where((v) => v == AttendanceTypeOption.present.id)
      .length;
  int get absentCount => markingMap.values
      .where((v) => v == AttendanceTypeOption.absent.id)
      .length;
  int get halfDayCount => markingMap.values
      .where((v) => v == AttendanceTypeOption.halfDay.id)
      .length;
  int get holidayCount => markingMap.values
      .where((v) => v == AttendanceTypeOption.holiday.id)
      .length;
  int get unmarkedCount => markingMap.values.where((v) => v == null).length;

  // ── Save ───────────────────────────────────────────────────────────────────
  final isSaving = false.obs;

  // ── View mode ──────────────────────────────────────────────────────────────
  // Table view matches the "everything on one screen" design, so it's the
  // default now instead of card view.
  final viewMode = 'table'.obs;

  static const allColumns = [
    'serial',
    'sid',
    'name',
    'father',
    'P',
    'A',
    'H',
    'Ho',
  ];
  static const columnLabels = <String, String>{
    'serial': '#',
    'sid': 'Student ID',
    'name': 'Name',
    'father': 'Father',
    'P': 'Present',
    'A': 'Absent',
    'H': 'Half Day',
    'Ho': 'Holiday',
  };
  final columnVisibility = <String, bool>{
    'serial': true,
    'sid': true,
    'name': true,
    'father': true,
    'P': true,
    'A': true,
    'H': true,
    'Ho': true,
  }.obs;

  void toggleView() =>
      viewMode.value = viewMode.value == 'card' ? 'table' : 'card';

  void toggleColumn(String key) {
    final visibleCount = columnVisibility.values.where((v) => v).length;
    if (visibleCount == 1 && columnVisibility[key] == true) return;
    columnVisibility[key] = !(columnVisibility[key] ?? true);
  }

  @override
  void onInit() {
    super.onInit();
    // Register reactive workers BEFORE loading sessions. Otherwise, when a
    // session is already available synchronously, _loadSessions() would set
    // selectedSession before the worker exists and the group fetch never fires.
    ever(selectedSession, (_) => _fetchGroups());
    ever(selectedGroup, (_) => _fetchClasses());
    // Default the attendance date to today.
    selectedDate.value = DateTime.now();
    _loadSessions();
    _fetchShifts();
  }

  // ── Session ────────────────────────────────────────────────────────────────

  void _loadSessions() {
    void apply(List sessions) {
      final names = sessions
          .map((e) => e.sessionName ?? '')
          .where((n) => (n as String).isNotEmpty)
          .cast<String>()
          .toList();
      sessionList.assignAll(names);
      if (names.isNotEmpty && selectedSession.value.isEmpty) {
        selectedSession.value = names.first;
      }
    }

    ever(_session.sessionList, apply);
    if (_session.sessionList.isNotEmpty) apply(_session.sessionList);
  }

  // ── Group ──────────────────────────────────────────────────────────────────

  Future<void> _fetchGroups() async {
    final session = _session.sessionList.firstWhereOrNull(
      (e) => e.sessionName == selectedSession.value,
    );
    if (session?.sessionId == null) return;
    isGroupLoading.value = true;
    selectedGroup.value = null;
    classList.clear();
    selectedClass.value = null;
    try {
      groupList.assignAll(
        await _session.getGroupList(session!.sessionId as int),
      );
    } finally {
      isGroupLoading.value = false;
    }
  }

  // ── Class ──────────────────────────────────────────────────────────────────

  Future<void> _fetchClasses() async {
    final group = selectedGroup.value;
    final session = _session.sessionList.firstWhereOrNull(
      (e) => e.sessionName == selectedSession.value,
    );
    if (group == null || session?.sessionId == null) return;
    isClassLoading.value = true;
    selectedClass.value = null;
    classList.clear();
    try {
      classList.assignAll(
        await _session.getClassList(group.id ?? 0, session!.sessionId as int),
      );
    } finally {
      isClassLoading.value = false;
    }
  }

  // ── Shift ──────────────────────────────────────────────────────────────────

  Future<void> _fetchShifts() async {
    isShiftLoading.value = true;
    try {
      final raw = await _api.postJsonWithoutBody(Endpoints.shiftList());
      List<dynamic> list = raw is List
          ? raw
          : (raw is Map && raw['result'] is List ? raw['result'] as List : []);
      final shifts = list
          .whereType<Map<String, dynamic>>()
          .map(ShiftModel.fromJson)
          .toList();
      shiftList.assignAll(shifts);
      if (shifts.isNotEmpty) selectedShift.value = shifts.first;
    } catch (e) {
      log('[Attendance] _fetchShifts: $e');
    } finally {
      isShiftLoading.value = false;
    }
  }

  // ── Date ───────────────────────────────────────────────────────────────────

  Future<void> pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate.value ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) selectedDate.value = picked;
  }

  // ── Load students ──────────────────────────────────────────────────────────

  String? get validationError {
    if (selectedGroup.value == null) return 'Please select a group';
    if (selectedClass.value == null) return 'Please select a class';
    if (selectedDate.value == null) return 'Please select a date';
    if (selectedShift.value == null) return 'Please select a shift';
    return null;
  }

  Future<void> loadStudents() async {
    final err = validationError;
    if (err != null) {
      Get.snackbar(
        'Required',
        err,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
      return;
    }

    final session = _session.sessionList.firstWhereOrNull(
      (e) => e.sessionName == selectedSession.value,
    );

    isLoading.value = true;
    hasLoaded.value = false;
    students.clear();
    markingMap.clear();
    bulkType.value = null;
    markedFilter.value = 'all';

    try {
      final raw = await _api.postJson(Endpoints.getStudentsForAttendance(), {
        'groupId': selectedGroup.value!.id ?? 0,
        'classId': selectedClass.value!.id ?? 0,
        'sessionId': session?.sessionId ?? 0,
        'attendanceDate': DateFormat('yyyy-MM-dd').format(selectedDate.value!),
        'shiftId': selectedShift.value!.id,
      });

      List<dynamic> list = raw is List
          ? raw
          : (raw is Map && raw['result'] is List ? raw['result'] as List : []);

      final loaded = list
          .whereType<Map<String, dynamic>>()
          .map(AttendanceStudentModel.fromJson)
          .toList();

      students.assignAll(loaded);

      // Pre-fill marking map — keep any existing attendance, otherwise default
      // each student to Present so the sheet loads ready to save.

      for (final s in loaded) {
        markingMap[s.id] =
            s.attendenceTypeId ?? AttendanceTypeOption.present.id;
      }
      // for (final s in loaded) {
      //   markingMap[s.id] =
      //       s.attendenceTypeId ?? AttendanceTypeOption.present.id;
      // }
      hasLoaded.value = true;
    } catch (e) {
      log('[Attendance] loadStudents: $e');
      _showError(_friendlyMessage(e));
    } finally {
      isLoading.value = false;
    }
  }

  /// Turns a raw error into a short, plain-language message a non-technical
  /// user can act on. The original error is still logged for developers.
  String _friendlyMessage(Object e) {
    final msg = e.toString().toLowerCase();
    if (msg.contains('no internet') ||
        msg.contains('socketexception') ||
        msg.contains('network') ||
        msg.contains('failed host lookup') ||
        msg.contains('connection')) {
      return 'No internet connection. Please check your network and try again.';
    }
    if (msg.contains('timeout') || msg.contains('timed out')) {
      return 'The server is taking too long to respond. Please try again.';
    }
    if (msg.contains('session expired') || msg.contains('unauthor')) {
      return 'Your session has expired. Please log in again.';
    }
    if (msg.contains('http 5') ||
        msg.contains('500') ||
        msg.contains('502') ||
        msg.contains('503')) {
      return 'The server is having a problem right now. '
          'Please try again in a little while.';
    }
    if (msg.contains('http 4') ||
        msg.contains('format') ||
        msg.contains('json') ||
        msg.contains('type ')) {
      return 'We couldn\'t complete this request. Please try again.';
    }
    return 'Something went wrong. Please try again.';
  }

  void _showError(String message) {
    Get.snackbar(
      'Something went wrong',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFFC62828),
      colorText: const Color(0xFFFFFFFF),
      margin: const EdgeInsets.all(16),
    );
  }

  // ── Mark individual ────────────────────────────────────────────────────────
  void setMark(int studentId, int typeId) {
    if (markingMap[studentId] == typeId) {
      markingMap[studentId] = null;
    } else {
      markingMap[studentId] = typeId;
    }
    bulkType.value = null;
  }

  // ── Bulk mark all ──────────────────────────────────────────────────────────

  void applyBulk(AttendanceTypeOption? option) {
    if (option == null) return;

    // If the same bulk option is clicked again, clear all attendance.
    if (bulkType.value?.id == option.id) {
      bulkType.value = null;

      for (final s in students) {
        markingMap[s.id] = null; // Unmarked
      }
      return;
    }

    // Otherwise, apply the selected attendance to all students.
    bulkType.value = option;

    for (final s in students) {
      markingMap[s.id] = option.id;
    }
  }

  // ── Save ───────────────────────────────────────────────────────────────────

  Future<void> saveBulk() async {
    final session = _session.sessionList.firstWhereOrNull(
      (e) => e.sessionName == selectedSession.value,
    );

    // A holiday requires a note; ask for it before saving.
    String holidayNote = '';
    if (holidayCount > 0) {
      final note = await _askHolidayNote();
      if (note == null) return; // user cancelled
      holidayNote = note;
    }

    final holidayId = AttendanceTypeOption.holiday.id;
    final attendenceData = students.map((s) {
      final type = markingMap[s.id] ?? AttendanceTypeOption.absent.id;
      return {
        'studentId': s.id,
        'attendenceType': type,
        'attendenceSource': AttendenceSource.mobile.id,
        // Only holiday entries carry a note.
        'note': type == holidayId ? holidayNote : '',
      };
    }).toList();

    final payload = <String, dynamic>{
      'groupId': selectedGroup.value?.id ?? 0,
      'sessionId': session?.sessionId ?? 0,
      'classId': selectedClass.value?.id ?? 0,
      'date': DateFormat(
        "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'",
      ).format(selectedDate.value!),
      'shiftId': selectedShift.value!.id,
      'setAllAttendanceValue': 0,
      'ipAddress': '',
      'attendenceData': attendenceData,
      'holidayRemarks': holidayNote,
    };

    log(
      '[Attendance] saveBulk payload:\n${const JsonEncoder.withIndent('  ').convert(payload)}',
    );

    isSaving.value = true;
    try {
      await _api.postJson(Endpoints.saveBulkAttendance(), payload);
      Get.snackbar(
        'Saved',
        'Attendance saved successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF2E7D32),
        colorText: const Color(0xFFFFFFFF),
        margin: const EdgeInsets.all(16),
      );
    } catch (e) {
      log('[Attendance] saveBulk error: $e');
      _showError(_friendlyMessage(e));
    } finally {
      isSaving.value = false;
    }
  }

  /// Prompts for a holiday note. Returns the note, or null if cancelled.
  Future<String?> _askHolidayNote() {
    final ctrl = TextEditingController();
    return Get.dialog<String>(
      AlertDialog(
        title: const Text('Holiday Note'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          maxLines: 2,
          decoration: const InputDecoration(
            hintText: 'Reason for holiday',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back<String>(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final note = ctrl.text.trim();
              if (note.isEmpty) return;
              Get.back<String>(result: note);
            },
            child: const Text('Save'),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }
}
