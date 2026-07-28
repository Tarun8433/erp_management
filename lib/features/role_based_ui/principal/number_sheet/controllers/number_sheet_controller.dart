import 'package:erp_management/core/controllers/session_controller.dart';
import 'package:erp_management/core/models/category_model.dart';
import 'package:erp_management/core/services/api/api_service.dart';
import 'package:erp_management/core/services/api/endpoints.dart';
import 'package:erp_management/features/role_based_ui/principal/new_student_list/models/student_list_response.dart';
import 'package:erp_management/features/role_based_ui/principal/number_sheet/models/number_sheet_models.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NumberSheetController extends GetxController {
  final ApiService _api = ApiService();
  final SessionController sessionController = Get.put(SessionController());

  // ── Filter selections ──────────────────────────────────────────────────
  final RxString selectedSession = ''.obs;
  final RxString selectedGroup = ''.obs;
  final RxString selectedClass = ''.obs;
  final RxString selectedExamType = ''.obs;
  final RxString selectedSubject = ''.obs;

  final RxList<String> sessionYearList = <String>[].obs;
  final RxList<String> groupList = <String>[].obs;
  final RxList<String> classList = <String>[].obs;
  final RxList<String> examTypeList = <String>[].obs;
  final RxList<String> subjectList = <String>[].obs;

  List<CategoryModel> _loadedGroups = [];
  List<CategoryModel> _loadedClasses = [];
  List<ExamTypeModel> _loadedExamTypes = [];
  List<SubjectModel> _loadedSubjects = [];

  // ── UI state ───────────────────────────────────────────────────────────
  final RxBool isLoading = false.obs;
  final RxBool isSaving = false.obs;
  final RxBool isShowFilter = true.obs;
  final RxBool isExamLocked = false.obs;
  final RxBool isFetchingMM = false.obs;

  // ── MM ─────────────────────────────────────────────────────────────────
  final RxInt mmValue = 0.obs;
  final mmCtrl = TextEditingController();

  // ── Student data ───────────────────────────────────────────────────────
  final RxList<NumberSheetStudent> students = <NumberSheetStudent>[].obs;

  // studentId → marks (pending local save)
  final Map<int, int> _pendingMarks = {};

  // pre-fetched exam numbers (existing marks from server)
  List<StudentExamNumber> _examNumbers = [];

  // assigned subjects per student
  List<AssignedSubject> _assignedSubjects = [];

  // Text controllers for filters
  final sessionCtrl = TextEditingController();
  final groupCtrl = TextEditingController();
  final classCtrl = TextEditingController();
  final examTypeCtrl = TextEditingController();
  final subjectCtrl = TextEditingController();

  // ── Derived IDs ────────────────────────────────────────────────────────
  int get _sessionId =>
      sessionController.sessionList
          .firstWhereOrNull((e) => e.sessionName == selectedSession.value)
          ?.sessionId ??
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

  int get _examTypeId =>
      _loadedExamTypes
          .firstWhereOrNull((e) => e.name == selectedExamType.value)
          ?.id ??
      0;

  int get _subjectId =>
      _loadedSubjects
          .firstWhereOrNull((s) => s.name == selectedSubject.value)
          ?.id ??
      0;

  bool get hasPendingMarks => _pendingMarks.isNotEmpty;

  // ── Lifecycle ──────────────────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    _loadSessions();
    ever(selectedSession, (_) => _onSessionChanged());
    ever(selectedGroup, (_) => _onGroupChanged());
    ever(selectedClass, (_) => _onClassChanged());
    ever(selectedExamType, (_) => _onExamTypeChanged());
  }

  @override
  void onClose() {
    mmCtrl.dispose();
    sessionCtrl.dispose();
    groupCtrl.dispose();
    classCtrl.dispose();
    examTypeCtrl.dispose();
    subjectCtrl.dispose();
    super.onClose();
  }

  // ── Session loading ────────────────────────────────────────────────────
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

  Future<void> _onSessionChanged() async {
    _reset();
    await _fetchGroups();
  }

  Future<void> _fetchGroups() async {
    if (_sessionId == 0) return;
    _loadedGroups = await sessionController.getGroupList(_sessionId);
    groupList.assignAll(
      _loadedGroups.map((g) => g.name ?? '').where((n) => n.isNotEmpty),
    );
    if (selectedGroup.value.isNotEmpty && !groupList.contains(selectedGroup.value)) {
      selectedGroup.value = '';
    } else if (groupList.isEmpty) {
      selectedGroup.value = '';
    }
  }

  Future<void> _onGroupChanged() async {
    selectedClass.value = '';
    classList.clear();
    _loadedClasses = [];
    _clearStudentData();
    await _fetchClasses();
  }

  Future<void> _fetchClasses() async {
    if (_sessionId == 0 || _groupId == 0) return;
    _loadedClasses =
        await sessionController.getClassList(_groupId, _sessionId);
    classList.assignAll(
      _loadedClasses.map((c) => c.name ?? '').where((n) => n.isNotEmpty),
    );
    if (selectedClass.value.isNotEmpty && !classList.contains(selectedClass.value)) {
      selectedClass.value = '';
    } else if (classList.isEmpty) {
      selectedClass.value = '';
    }
  }

  Future<void> _onClassChanged() async {
    selectedExamType.value = '';
    selectedSubject.value = '';
    examTypeList.clear();
    subjectList.clear();
    _loadedExamTypes = [];
    _loadedSubjects = [];
    mmValue.value = 0;
    mmCtrl.clear();
    _clearStudentData();
    if (_classId == 0) return;
    await Future.wait([_fetchExamTypes(), _fetchSubjects()]);
  }

  Future<void> _fetchExamTypes() async {
    try {
      final res = await _api.postJson(Endpoints.getExamType(), {
        'branchId': 0,
        'groupId': _groupId,
        'sessionId': _sessionId,
        'classId': _classId,
      });
      final list = (res as List? ?? [])
          .map((e) => ExamTypeModel.fromJson(e))
          .toList();
      _loadedExamTypes = list;
      examTypeList.assignAll(list.map((e) => e.name));
      if (selectedExamType.value.isNotEmpty && !examTypeList.contains(selectedExamType.value)) {
        selectedExamType.value = '';
      }
    } catch (_) {}
  }

  Future<void> _fetchSubjects() async {
    try {
      final res = await _api.postJson(
        Endpoints.getOnlySubject(_groupId, _classId, _sessionId),
        {},
      );
      final raw = List<Map<String, dynamic>>.from(res as List? ?? []);
      // Sort by serialNumber to preserve the school's defined order
      raw.sort((a, b) =>
          ((a['serialNumber'] as int?) ?? 0)
              .compareTo((b['serialNumber'] as int?) ?? 0));
      final list = raw
          .map((e) => SubjectModel(id: e['id'] ?? 0, name: e['name'] ?? ''))
          .where((s) => s.name.isNotEmpty)
          .toList();
      _loadedSubjects = list;
      subjectList.assignAll(list.map((e) => e.name));
      if (selectedSubject.value.isNotEmpty && !subjectList.contains(selectedSubject.value)) {
        selectedSubject.value = '';
      }
    } catch (_) {}
  }

  void _onExamTypeChanged() {
    final et =
        _loadedExamTypes.firstWhereOrNull((e) => e.name == selectedExamType.value);
    isExamLocked.value = et?.isLooked ?? false;
    mmValue.value = 0;
    mmCtrl.clear();
    _clearStudentData();
  }

  // ── MM ─────────────────────────────────────────────────────────────────
  Future<void> fetchMM() async {
    if (_examTypeId == 0 || _subjectId == 0) {
      Get.snackbar('Alert', 'Please select Exam Type and Subject',
          backgroundColor: Colors.orange, colorText: Colors.white);
      return;
    }
    isFetchingMM.value = true;
    try {
      final res = await _api.postJson(Endpoints.getMM(), {
        'examTypeId': _examTypeId,
        'subjectId': _subjectId,
        'mm': 0,
        'groupId': _groupId,
        'sessionId': _sessionId,
      });
      final list = (res as List? ?? []);
      if (list.isNotEmpty) {
        final mm = list[0]['minimumSubjects'] as int? ?? 0;
        mmValue.value = mm;
        mmCtrl.text = '$mm';
      } else {
        Get.snackbar('Alert', 'MM not found',
            backgroundColor: Colors.orange, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('Error', e.toString(),
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isFetchingMM.value = false;
    }
  }

  // ── Student list ───────────────────────────────────────────────────────
  Future<void> searchStudents() async {
    if (_groupId == 0 || _classId == 0) {
      Get.snackbar('Alert', 'Please select Group and Class',
          backgroundColor: Colors.orange, colorText: Colors.white);
      return;
    }
    if (mmValue.value == 0) {
      Get.snackbar('Alert', 'Please fetch MM first',
          backgroundColor: Colors.orange, colorText: Colors.white);
      return;
    }
    isLoading.value = true;
    _clearStudentData();
    try {
      await Future.wait([
        _loadExamNumbers(),
        _loadAssignedSubjects(),
      ]);

      final res = await _api.postJson(Endpoints.getStudentList(), {
        'isActive': -1,
        'branchId': 0,
        'sessionId': _sessionId,
        'groupId': _groupId,
        'classId': _classId,
        'top': 0,
        'searchText': '',
      });

      List<dynamic> listData = [];
      if (res is Map<String, dynamic>) {
        listData = res['result'] ?? res['data'] ?? [];
      } else if (res is List) {
        listData = res;
      }

      final raw = listData
          .map((e) => StudentListResponse.fromJson(e))
          .toList();

      // Sort: students with roll numbers first (sorted numerically), rest after
      final withRoll = raw
          .where((s) => (s.rollNumber ?? '').isNotEmpty)
          .toList()
        ..sort((a, b) {
          final ia = int.tryParse(a.rollNumber ?? '') ?? 0;
          final ib = int.tryParse(b.rollNumber ?? '') ?? 0;
          return ia.compareTo(ib);
        });
      final withoutRoll =
          raw.where((s) => (s.rollNumber ?? '').isEmpty).toList();
      final sorted = [...withRoll, ...withoutRoll];

      final mapped = sorted.map((s) {
        final existing = _examNumbers.firstWhereOrNull(
          (n) =>
              n.studentId == s.id &&
              n.examTypeId == _examTypeId &&
              n.subjectId == _subjectId,
        );
        final assigned = _assignedSubjects.isEmpty ||
            _assignedSubjects
                .any((a) => a.studentId == s.id && a.subjectId == _subjectId);
        return NumberSheetStudent(
          id: s.id ?? 0,
          rollNumber: s.rollNumber ?? '',
          name: s.firstName ?? 'N/A',
          marks: existing?.obtainedMarks,
          isSubjectAssigned: assigned,
        );
      }).toList();

      students.assignAll(mapped);
      isShowFilter.value = false;
    } catch (e) {
      Get.snackbar('Error', 'Failed to load students: $e',
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadExamNumbers() async {
    try {
      final res = await _api.postJson(Endpoints.getStudentExamNumbers(), {
        'examTypeId': _examTypeId,
        'sessionId': _sessionId,
      });
      _examNumbers = (res as List? ?? [])
          .map((e) => StudentExamNumber.fromJson(e))
          .toList();
    } catch (_) {
      _examNumbers = [];
    }
  }

  Future<void> _loadAssignedSubjects() async {
    try {
      final res = await _api.postJson(Endpoints.getStudentAssignedSubjects(), {
        'sessionId': _sessionId,
        'groupId': _groupId,
        'classId': _classId,
        'studentId': 0,
      });
      _assignedSubjects = (res as List? ?? [])
          .map((e) => AssignedSubject.fromJson(e))
          .toList();
    } catch (_) {
      _assignedSubjects = [];
    }
  }

  // ── Mark entry ─────────────────────────────────────────────────────────
  void onMarkChanged(int studentId, String value, int index) {
    final parsed = int.tryParse(value.trim());
    if (parsed == null) {
      _pendingMarks.remove(studentId);
      return;
    }
    if (mmValue.value > 0 && parsed > mmValue.value) {
      Get.snackbar(
        'Alert',
        'Marks ($parsed) cannot exceed MM (${mmValue.value})',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
      _pendingMarks.remove(studentId);
      return;
    }
    students[index].marks = parsed;
    _pendingMarks[studentId] = parsed;
  }

  // ── Bulk save ──────────────────────────────────────────────────────────
  Future<void> saveMarks() async {
    if (_pendingMarks.isEmpty) {
      Get.snackbar('Alert', 'No marks entered to save',
          backgroundColor: Colors.orange, colorText: Colors.white);
      return;
    }
    isSaving.value = true;
    try {
      final sheet = _pendingMarks.entries
          .map((e) => {
                'examTypeId': _examTypeId,
                'obtainedMarks': e.value,
                'studentId': e.key,
                'subjectId': _subjectId,
              })
          .toList();

      final payload = {
        'sessionId': _sessionId,
        'studentExamNumberSheet': sheet,
      };

      final res = await _api.postJson(Endpoints.bulkSaveMarks(), payload);
      if (res is Map && res['statusCode'] == 1) {
        Get.snackbar(
          'Success',
          res['responseText']?.toString() ?? 'Marks saved successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
        );
        _pendingMarks.clear();
      } else {
        Get.snackbar(
          'Error',
          res?['responseText']?.toString() ?? 'Failed to save marks',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
        );
      }
    } catch (e) {
      Get.snackbar('Error', e.toString(),
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isSaving.value = false;
    }
  }

  // ── Helpers ────────────────────────────────────────────────────────────
  void _clearStudentData() {
    students.clear();
    _pendingMarks.clear();
    _examNumbers = [];
    _assignedSubjects = [];
  }

  void _reset() {
    selectedGroup.value = '';
    selectedClass.value = '';
    selectedExamType.value = '';
    selectedSubject.value = '';
    groupList.clear();
    classList.clear();
    examTypeList.clear();
    subjectList.clear();
    mmValue.value = 0;
    mmCtrl.clear();
    _clearStudentData();
  }

  void toggleFilter() => isShowFilter.value = !isShowFilter.value;
}
