import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../core/controllers/session_controller.dart';
import '../../../../../core/services/api/api_service.dart';
import '../../../../../core/services/api/endpoints.dart';
import '../../../../../core/utils/local_storage/storage_helper.dart';

class NoticeItem {
  final int id;
  final String title;
  final String body;
  final DateTime date;
  final Color color;

  const NoticeItem({
    required this.id,
    required this.title,
    required this.body,
    required this.date,
    required this.color,
  });
}

class PrincipalDashboardController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  // User info
  final RxString principalName = ''.obs;
  final RxString userRole = ''.obs;
  final RxString schoolName = ''.obs;

  // ── Students ─────────────────────────────────────────────────────────────────
  final RxInt totalStudents = 0.obs;
  final RxInt studentsPresent = 0.obs;
  final RxInt studentsAbsent = 0.obs;
  final RxString attendancePercent = '0%'.obs;

  // Total classes (from dashboard API; no dedicated card yet).
  final RxInt totalClasses = 0.obs;

  // ── Staff ─────────────────────────────────────────────────────────────────────
  final RxInt totalStaff = 0.obs;
  final RxInt staffPresent = 0.obs;
  final RxInt staffAbsent = 0.obs;
  // alias kept for Live Insights card
  RxInt get teachersPresent => staffPresent;

  // ── Fee Transactions ─────────────────────────────────────────────────────────
  final RxInt feeCashTrs = 0.obs;
  final RxInt feeCashAmount = 0.obs;
  final RxInt feeOnlineTrs = 0.obs;
  final RxInt feeOnlineAmount = 0.obs;

  // ── Fee Discount ─────────────────────────────────────────────────────────────
  final RxInt feeDiscountTrs = 0.obs;
  final RxInt feeDiscountAmount = 0.obs;

  // ── Expense ───────────────────────────────────────────────────────────────────
  final RxInt expenseCashTrs = 0.obs;
  final RxInt expenseCashAmount = 0.obs;
  final RxInt expenseOnlineTrs = 0.obs;
  final RxInt expenseOnlineAmount = 0.obs;

  // ── Available Amount ──────────────────────────────────────────────────────────
  final RxInt availableCash = 0.obs;
  final RxInt availableOnline = 0.obs;
  final RxInt availableTotal = 0.obs;

  // ── Empty Periods & Complaints ───────────────────────────────────────────────
  final RxInt emptyPeriods = 0.obs;
  final RxInt complaintsCount = 0.obs;

  // ── Notifications ─────────────────────────────────────────────────────────────
  final RxInt unreadNotificationCount = 0.obs;

  // ── Notices ───────────────────────────────────────────────────────────────────
  final notices = <NoticeItem>[].obs;
  final isNoticesLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadUserInfo();
    fetchDashboardStats();
    fetchDashboardData();
    fetchUnreadCount();
    fetchNotices();
  }

  /// Calls Dashboard/GetDashboardData with the active session id (token is
  /// added automatically) and logs the raw response + its type for inspection.
  Future<void> fetchDashboardData() async {
    final sessionCtrl = Get.put(SessionController());
    if (sessionCtrl.sessionList.isNotEmpty) {
      await _callDashboardData(sessionCtrl);
    } else {
      // Session list loads asynchronously — call once it's ready.
      once(sessionCtrl.sessionList, (_) => _callDashboardData(sessionCtrl));
    }
  }

  Future<void> _callDashboardData(SessionController sessionCtrl) async {
    final active =
        sessionCtrl.sessionList.firstWhereOrNull((s) => s.isActive == true);
    final sessionId = active?.sessionId ?? 0;
    try {
      final res = await ApiService().postJson(
        Endpoints.getDashboardData(),
        {'sessionId': sessionId},
      );
      log('[Dashboard] GetDashboardData (sessionId=$sessionId) '
          'type=${res.runtimeType}');
      log('[Dashboard] GetDashboardData response: $res');
      if (res is Map<String, dynamic>) _applyDashboardData(res);
    } catch (e) {
      log('[Dashboard] GetDashboardData error: $e');
    }
  }

  /// Binds every section of GetDashboardData: students, staff, fee, expense,
  /// available amount, empty classes and complaints. Only the fee discount
  /// transaction count has no API source and stays at its default.
  void _applyDashboardData(Map<String, dynamic> d) {
    int toInt(dynamic v) =>
        v is num ? v.round() : int.tryParse('${v ?? ''}') ?? 0;

    totalStudents.value = toInt(d['totalStudent']);
    totalStaff.value = toInt(d['totalStaff']);
    totalClasses.value = toInt(d['totalClass']);

    final stu = d['studentAttendanceData'];
    if (stu is Map) {
      studentsPresent.value = toInt(stu['totalPresent']);
      studentsAbsent.value = toInt(stu['totalAbsent']);
    }
    final pct = totalStudents.value > 0
        ? (studentsPresent.value / totalStudents.value * 100)
        : 0.0;
    attendancePercent.value = '${pct.toStringAsFixed(1)}%';

    final staff = d['staffAttendanceData'];
    if (staff is Map) {
      staffPresent.value = toInt(staff['totalPresent']);
      staffAbsent.value = toInt(staff['totalAbsent']);
    }

    final fee = d['feeTransactionData'];
    if (fee is Map) {
      feeCashTrs.value = toInt(fee['cashTransactionCount']);
      feeCashAmount.value = toInt(fee['totalCash']);
      feeOnlineTrs.value = toInt(fee['onlineTransactionCount']);
      feeOnlineAmount.value = toInt(fee['totalOnline']);
      feeDiscountAmount.value = toInt(fee['totalDiscount']);
    }

    final expense = d['expenseSummary'];
    if (expense is Map) {
      expenseCashTrs.value = toInt(expense['cashTransaction']);
      expenseCashAmount.value = toInt(expense['totalCashAmount']);
      expenseOnlineTrs.value = toInt(expense['onlineTransaction']);
      expenseOnlineAmount.value = toInt(expense['totalOnlineAmount']);
    }

    final available = d['availableAmountSummary'];
    if (available is Map) {
      availableCash.value = toInt(available['cash']);
      availableOnline.value = toInt(available['online']);
      availableTotal.value = toInt(available['total']);
    }

    // The API returns a single blank-string row when there are no empty
    // classes, so count only rows that actually carry a class name.
    final emptyClasses = d['emptyClassSummary'];
    if (emptyClasses is List) {
      emptyPeriods.value = emptyClasses
          .whereType<Map>()
          .where((e) => '${e['className'] ?? ''}'.trim().isNotEmpty)
          .length;
    }

    // Same convention for complaints: a blank-message row means "none".
    final complaints = d['complaints'];
    if (complaints is List) {
      complaintsCount.value = complaints
          .whereType<Map>()
          .where((e) => '${e['message'] ?? ''}'.trim().isNotEmpty)
          .length;
    }
  }

  Future<void> _loadUserInfo() async {
    final details = await StorageHelper.getUserDetails();
    final role = await StorageHelper.getSelectedRole();
    final rawName = details?.displayName ?? await StorageHelper.getLoginName() ?? '';
    final rawSchool = details?.name ??
        await StorageHelper.getSchoolName() ??
        await StorageHelper.getSelectedBranch() ??
        '';
    principalName.value = rawName.isNotEmpty ? _titleCase(rawName) : 'User';
    schoolName.value = rawSchool;
    userRole.value = (role != null && role.isNotEmpty) ? _titleCase(role) : 'Principal';
  }

  static String _titleCase(String s) => s
      .split(RegExp(r'[\s_]+'))
      .map((w) => w.isEmpty ? '' : '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}')
      .join(' ');

  Future<void> fetchDashboardStats() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      // TODO: replace with real dashboard summary API when available
      await Future.delayed(const Duration(milliseconds: 300));

      // Expense, available amount, empty periods and complaints now come from
      // GetDashboardData (_applyDashboardData); these fields default to 0 until
      // that response arrives. Fee discount transaction count has no API source.
      feeDiscountTrs.value = 0;
    } catch (e) {
      errorMessage.value = 'Could not load overview. Please try again.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchUnreadCount() async {
    try {
      final raw = await ApiService().getJson(Endpoints.unreadNotificationCount());
      if (raw is Map<String, dynamic>) {
        unreadNotificationCount.value = (raw['unreadCount'] as num?)?.toInt() ?? 0;
      }
    } catch (e) {
      log('[Dashboard] fetchUnreadCount error: $e');
    }
  }

  Future<void> fetchNotices() async {
    isNoticesLoading.value = true;
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      notices.assignAll([
        NoticeItem(
          id: 1,
          title: 'Annual Sports Day',
          body: 'Annual Sports Day will be held on 15 June. All students must participate.',
          date: DateTime.now().subtract(const Duration(hours: 2)),
          color: const Color(0xFF1565C0),
        ),
        NoticeItem(
          id: 2,
          title: 'Exam Schedule Released',
          body: 'Final exam timetable has been uploaded. Please check the notice board.',
          date: DateTime.now().subtract(const Duration(days: 1)),
          color: const Color(0xFF2E7D32),
        ),
        NoticeItem(
          id: 3,
          title: 'Fee Reminder',
          body: 'Last date to submit tuition fee is 10 June. Late fee will be charged.',
          date: DateTime.now().subtract(const Duration(days: 2)),
          color: const Color(0xFFC62828),
        ),
        NoticeItem(
          id: 4,
          title: 'Parent Meeting',
          body: 'Parent-teacher meeting scheduled for 20 June. Attendance is mandatory.',
          date: DateTime.now().subtract(const Duration(days: 3)),
          color: const Color(0xFFF57C00),
        ),
      ]);
    } catch (e) {
      log('[Dashboard] fetchNotices error: $e');
    } finally {
      isNoticesLoading.value = false;
    }
  }

  void decrementUnread([int by = 1]) {
    if (unreadNotificationCount.value > 0) {
      unreadNotificationCount.value =
          (unreadNotificationCount.value - by).clamp(0, 9999);
    }
  }

  void clearUnread() => unreadNotificationCount.value = 0;
}
