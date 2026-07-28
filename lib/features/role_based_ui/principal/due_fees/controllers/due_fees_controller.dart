import 'dart:developer';

import 'package:erp_management/core/controllers/session_controller.dart';
import 'package:erp_management/core/models/category_model.dart';
import 'package:erp_management/core/services/api/api_service.dart';
import 'package:erp_management/core/services/api/endpoints.dart';
import 'package:erp_management/features/role_based_ui/principal/due_fees/models/due_fee_model.dart';
import 'package:get/get.dart';

class DueFeesController extends GetxController {
  final ApiService _api = ApiService();
  final SessionController _sessionCtrl = Get.put(SessionController());

  // Filter selections (display names; ids are resolved at fetch time).
  final RxString selectedSession = ''.obs;
  final RxString selectedGroup = ''.obs;
  final RxString selectedClass = ''.obs;
  final RxString selectedMonth = ''.obs;
  final RxString searchBy = ''.obs;

  // Dropdown sources.
  final RxList<String> sessions = <String>[].obs;
  final RxList<String> groups = <String>[].obs;
  final RxList<String> classes = <String>[].obs;

  // Financial-year months: April(4) → March(3).
  final List<Map<String, dynamic>> monthOptions = const [
    {'id': 4, 'name': 'April'},
    {'id': 5, 'name': 'May'},
    {'id': 6, 'name': 'June'},
    {'id': 7, 'name': 'July'},
    {'id': 8, 'name': 'August'},
    {'id': 9, 'name': 'September'},
    {'id': 10, 'name': 'October'},
    {'id': 11, 'name': 'November'},
    {'id': 12, 'name': 'December'},
    {'id': 1, 'name': 'January'},
    {'id': 2, 'name': 'February'},
    {'id': 3, 'name': 'March'},
  ];

  List<String> get monthNames =>
      monthOptions.map((e) => e['name'] as String).toList();

  // State.
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;
  final RxList<DueFeeModel> reports = <DueFeeModel>[].obs;
  final RxBool hasSearched = false.obs;

  /// Sum of the outstanding amount across all loaded rows.
  double get totalDueAmount =>
      reports.fold(0.0, (sum, r) => sum + r.totalDue);

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
    ever(_sessionCtrl.sessionList, (list) => _applySessions(list));
    if (_sessionCtrl.sessionList.isNotEmpty) {
      _applySessions(_sessionCtrl.sessionList);
    }
  }

  void _applySessions(List list) {
    final names = list
        .map((e) => e.sessionName ?? '')
        .where((n) => n.isNotEmpty)
        .toList();
    sessions.assignAll(names.cast<String>());
    if (selectedSession.value.isNotEmpty &&
        !names.contains(selectedSession.value)) {
      selectedSession.value = '';
    }
  }

  Future<void> _fetchGroups() async {
    groups.clear();
    _loadedGroups = [];
    selectedGroup.value = '';

    final session = _sessionCtrl.sessionList.firstWhereOrNull(
      (e) => e.sessionName == selectedSession.value,
    );
    if (session == null || session.sessionId == null) return;

    _loadedGroups = await _sessionCtrl.getGroupList(session.sessionId!);
    groups.assignAll(
      _loadedGroups.map((g) => g.name ?? '').where((n) => n.isNotEmpty),
    );
  }

  Future<void> _fetchClasses() async {
    classes.clear();
    _loadedClasses = [];
    selectedClass.value = '';

    final session = _sessionCtrl.sessionList.firstWhereOrNull(
      (e) => e.sessionName == selectedSession.value,
    );
    final group = _loadedGroups.firstWhereOrNull(
      (g) => g.name == selectedGroup.value,
    );
    if (session == null ||
        session.sessionId == null ||
        group == null ||
        group.id == null) {
      return;
    }

    _loadedClasses = await _sessionCtrl.getClassList(
      group.id!,
      session.sessionId!,
    );
    classes.assignAll(
      _loadedClasses.map((c) => c.name ?? '').where((n) => n.isNotEmpty),
    );
  }

  int get _monthId {
    final m = monthOptions.firstWhereOrNull(
      (e) => e['name'] == selectedMonth.value,
    );
    return (m?['id'] as int?) ?? 0;
  }

  Future<void> fetchDueFees() async {
    isLoading.value = true;
    hasSearched.value = true;
    error.value = '';
    try {
      final session = _sessionCtrl.sessionList.firstWhereOrNull(
        (e) => e.sessionName == selectedSession.value,
      );
      final group = _loadedGroups.firstWhereOrNull(
        (g) => g.name == selectedGroup.value,
      );
      final cls = _loadedClasses.firstWhereOrNull(
        (c) => c.name == selectedClass.value,
      );

      // GetFeeReportReq. FeeAttributeId is intentionally not sent.
      final payload = <String, dynamic>{
        'classId': cls?.id ?? 0,
        'groupId': group?.id ?? 0,
        'sessionId': session?.sessionId ?? 0,
        'monthId': _monthId,
        'searchBy': searchBy.value,
      };

      log('GetDueFeeReport payload: $payload');
      final response = await _api.postJson(
        Endpoints.getDueFeeReport(),
        payload,
      );
      log('GetDueFeeReport response: $response');

      // Extract the list wherever the server places it.
      List<dynamic> list = [];
      if (response is Map<String, dynamic>) {
        final result = response['result'] ?? response['data'];
        if (result is List) {
          list = result;
        } else if (result is Map<String, dynamic>) {
          final inner = result['result'] ?? result['data'] ?? result['list'];
          if (inner is List) list = inner;
        }
      } else if (response is List) {
        list = response;
      }

      final mapped = list
          .whereType<Map<String, dynamic>>()
          .map(DueFeeModel.fromJson)
          .toList();

      reports.assignAll(mapped);
      log('GetDueFeeReport parsed rows: ${reports.length}');
      for (final r in reports) {
        log('DueFee row: $r');
      }
    } catch (e) {
      error.value = e.toString();
      log('GetDueFeeReport error: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
