import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/services/api/api_service.dart';
import '../../../../core/services/api/endpoints.dart';
import '../../../../core/utils/local_storage/storage_helper.dart';

class TeacherNoticeItem {
  final int id;
  final String title;
  final String body;
  final DateTime date;
  final Color color;

  const TeacherNoticeItem({
    required this.id,
    required this.title,
    required this.body,
    required this.date,
    required this.color,
  });
}

class TeacherDashboardController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  // ── User info ─────────────────────────────────────────────────────────────────
  final RxString teacherName = ''.obs;
  final RxString userRole = ''.obs;
  final RxString schoolName = ''.obs;
  final RxString className = ''.obs;

  // ── Students (allotted class only) ────────────────────────────────────────────
  final RxInt classStudentsTotal = 0.obs;
  final RxInt classStudentsPresent = 0.obs;
  final RxInt classStudentsAbsent = 0.obs;
  final RxString classAttendancePercent = '0%'.obs;

  // ── Staff ─────────────────────────────────────────────────────────────────────
  final RxInt totalStaff = 0.obs;
  final RxInt staffPresent = 0.obs;
  final RxInt staffAbsent = 0.obs;
  RxInt get teachersPresent => staffPresent;

  // ── Empty periods & Complaints ────────────────────────────────────────────────
  final RxInt emptyPeriods = 0.obs;
  final RxInt complaintsCount = 0.obs;

  // ── Notifications ─────────────────────────────────────────────────────────────
  final RxInt unreadNotificationCount = 0.obs;

  // ── Notices ───────────────────────────────────────────────────────────────────
  final notices = <TeacherNoticeItem>[].obs;
  final isNoticesLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadUserInfo();
    fetchDashboardStats();
    fetchUnreadCount();
    fetchNotices();
  }

  Future<void> _loadUserInfo() async {
    final details = await StorageHelper.getUserDetails();
    final role = await StorageHelper.getSelectedRole();
    final rawName =
        details?.displayName ?? await StorageHelper.getLoginName() ?? '';
    final rawSchool = details?.name ??
        await StorageHelper.getSchoolName() ??
        await StorageHelper.getSelectedBranch() ??
        '';
    teacherName.value =
        rawName.isNotEmpty ? _titleCase(rawName) : 'Teacher';
    schoolName.value = rawSchool;
    userRole.value =
        (role != null && role.isNotEmpty) ? _titleCase(role) : 'Teacher';
    // TODO: load allotted class from teacher profile API
    className.value = 'Junior EM - 6A';
  }

  static String _titleCase(String s) => s
      .split(RegExp(r'[\s_]+'))
      .map((w) =>
          w.isEmpty ? '' : '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}')
      .join(' ');

  Future<void> fetchDashboardStats() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      // TODO: replace with real dashboard API
      await Future.delayed(const Duration(milliseconds: 300));

      classStudentsTotal.value = 42;
      classStudentsPresent.value = 38;
      classStudentsAbsent.value = 4;
      final pct = classStudentsTotal.value > 0
          ? (classStudentsPresent.value / classStudentsTotal.value * 100)
          : 0.0;
      classAttendancePercent.value = '${pct.toStringAsFixed(1)}%';

      totalStaff.value = 68;
      staffPresent.value = 64;
      staffAbsent.value = 4;

      emptyPeriods.value = 2;
      complaintsCount.value = 1;
    } catch (e) {
      errorMessage.value = 'Could not load overview. Please try again.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchUnreadCount() async {
    try {
      final raw =
          await ApiService().getJson(Endpoints.unreadNotificationCount());
      if (raw is Map<String, dynamic>) {
        unreadNotificationCount.value =
            (raw['unreadCount'] as num?)?.toInt() ?? 0;
      }
    } catch (e) {
      log('[TeacherDashboard] fetchUnreadCount error: $e');
    }
  }

  Future<void> fetchNotices() async {
    isNoticesLoading.value = true;
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      notices.assignAll([
        TeacherNoticeItem(
          id: 1,
          title: 'Annual Sports Day',
          body: 'Annual Sports Day will be held on 15 June. All students must participate.',
          date: DateTime.now().subtract(const Duration(hours: 2)),
          color: const Color(0xFF1565C0),
        ),
        TeacherNoticeItem(
          id: 2,
          title: 'Exam Schedule Released',
          body: 'Final exam timetable has been uploaded. Please check the notice board.',
          date: DateTime.now().subtract(const Duration(days: 1)),
          color: const Color(0xFF2E7D32),
        ),
        TeacherNoticeItem(
          id: 3,
          title: 'Staff Meeting',
          body: 'Mandatory staff meeting on 5 June at 10 AM in the conference room.',
          date: DateTime.now().subtract(const Duration(days: 2)),
          color: const Color(0xFFC62828),
        ),
      ]);
    } catch (e) {
      log('[TeacherDashboard] fetchNotices error: $e');
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
