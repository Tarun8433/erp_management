import 'dart:developer';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import '../../../../core/services/api/api_service.dart';
import '../../../../core/services/api/endpoints.dart';
import '../models/push_notification_model.dart';
import '../../../role_based_ui/principal/home/controllers/principal_dashboard_controller.dart';

class NotificationsController extends GetxController {
  final scrollController = ScrollController();

  final items = <PushNotificationModel>[].obs;
  final isLoading = false.obs;
  final isLoadingMore = false.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;
  final hasMore = true.obs;

  int _page = 1;
  static const int _pageSize = 20;

  @override
  void onInit() {
    super.onInit();
    fetchNotifications(refresh: true);
    scrollController.addListener(_onScroll);
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }

  void _onScroll() {
    if (scrollController.position.pixels >=
            scrollController.position.maxScrollExtent - 200 &&
        !isLoadingMore.value &&
        hasMore.value) {
      _loadMore();
    }
  }

  Future<void> fetchNotifications({bool refresh = false}) async {
    if (refresh) {
      _page = 1;
      hasMore.value = true;
      hasError.value = false;
      isLoading.value = true;
    }

    try {
      final raw = await ApiService()
          .getJson(Endpoints.userPushNotifications(page: _page, pageSize: _pageSize));

      final list = _parse(raw);
      if (refresh) {
        items.assignAll(list);
      } else {
        items.addAll(list);
      }
      if (list.length < _pageSize) hasMore.value = false;
    } catch (e) {
      if (refresh) {
        hasError.value = true;
        errorMessage.value = e.toString().replaceFirst('Exception: ', '');
      }
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  Future<void> _loadMore() async {
    isLoadingMore.value = true;
    _page++;
    await fetchNotifications();
  }

  List<PushNotificationModel> _parse(dynamic raw) {
    if (raw is List) {
      return raw
          .whereType<Map<String, dynamic>>()
          .map(PushNotificationModel.fromJson)
          .toList();
    }
    if (raw is Map<String, dynamic>) {
      final result = raw['result'];
      if (result is List) {
        return result
            .whereType<Map<String, dynamic>>()
            .map(PushNotificationModel.fromJson)
            .toList();
      }
    }
    return [];
  }

  int get unreadCount => items.where((n) => !n.isRead).length;

  Future<void> markAsRead(PushNotificationModel item) async {
    if (item.isRead) return;

    // Optimistic update.
    final idx = items.indexOf(item);
    if (idx != -1) items[idx] = item.copyWith(isRead: true);

    try {
      await ApiService().postJsonWithoutBody(Endpoints.markNotificationAsRead(item.id));
      _syncDashboardBadge(decrement: 1);
    } catch (e) {
      // Rollback on failure.
      if (idx != -1) items[idx] = item;
      log('[Notifications] markAsRead error: $e');
    }
  }

  Future<void> markAllAsRead() async {
    final unread = items.where((n) => !n.isRead).toList();
    if (unread.isEmpty) return;

    // Optimistic update — mark all read locally.
    for (int i = 0; i < items.length; i++) {
      if (!items[i].isRead) items[i] = items[i].copyWith(isRead: true);
    }

    try {
      await ApiService().postJsonWithoutBody(Endpoints.markAllNotificationsAsRead());
      _syncDashboardBadge(clearAll: true);
    } catch (e) {
      // Rollback.
      for (int i = 0; i < items.length; i++) {
        final original = unread.firstWhereOrNull((n) => n.id == items[i].id);
        if (original != null) items[i] = original;
      }
      log('[Notifications] markAllAsRead error: $e');
    }
  }

  void _syncDashboardBadge({int decrement = 0, bool clearAll = false}) {
    try {
      final dashboard = Get.find<PrincipalDashboardController>();
      if (clearAll) {
        dashboard.clearUnread();
      } else {
        dashboard.decrementUnread(decrement);
      }
    } catch (_) {
      // Dashboard controller may not be registered (other roles).
    }
  }
}
