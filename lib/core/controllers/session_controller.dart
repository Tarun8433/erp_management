import 'dart:developer';

import 'package:get/get.dart';
import '../services/api/api_service.dart';
import '../services/api/endpoints.dart';
import '../models/session_model.dart';
import '../widgets/common_dialog.dart';
import '../models/category_model.dart';

class SessionController extends GetxController {
  final ApiService _apiService = ApiService();

  final RxList<SessionModel> sessionList = <SessionModel>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchSessionList();
  }

  Future<void> fetchSessionList() async {
    try {
      isLoading.value = true;
      final response = await _apiService.postJson(Endpoints.getSessionList(), {});
      log('[Session] fetchSessionList raw type=${response.runtimeType} response=$response');

      // Accept a list whether it's the top-level response or nested under
      // result/data — don't gate on statusCode (other endpoints don't).
      final data = _extractList(response);
      if (data.isNotEmpty) {
        sessionList.value =
            data.map((e) => SessionModel.fromJson(e)).toList();
      } else if (response is Map<String, dynamic> &&
          !(response['statusCode'] == 1 ||
              response['statusCode'] == 200 ||
              response['isSuccess'] == true)) {
        showCommonDialog(
          title: 'Error',
          message: response['responseText'] ??
              response['message'] ??
              'Failed to fetch session list',
          isError: true,
        );
      }
      log('[Session] sessionList loaded: count=${sessionList.length} '
          'names=${sessionList.map((e) => '${e.sessionName}(active=${e.isActive})').toList()}');
    } catch (e) {
      print('Fetch Session List error: $e');
      showCommonDialog(
        title: 'Error',
        message: 'Something went wrong while fetching sessions.',
        isError: true,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<List<CategoryModel>> getGroupList(int sessionId) async {
    try {
      final response = await _apiService.postJson(Endpoints.getClassGroupList(sessionId), {});
      log('[Session] getGroupList(sessionId=$sessionId) raw=$response');
      final data = _extractList(response);
      final groups = data.map((e) => CategoryModel.fromJson(e)).toList();
      log('[Session] getGroupList parsed ${groups.length} groups: '
          '${groups.map((g) => '${g.name}(id=${g.id})').toList()}');
      return groups;
    } catch (e) {
      log('[Session] getGroupList error: $e');
    }
    return [];
  }

  Future<List<CategoryModel>> getClassList(int groupId, int sessionId) async {
    try {
      final response = await _apiService.postJson(Endpoints.getClassMasterList(groupId, sessionId), {});
      log('[Session] getClassList(groupId=$groupId, sessionId=$sessionId) raw=$response');
      final data = _extractList(response);
      final classes = data.map((e) => CategoryModel.fromJson(e)).toList();
      log('[Session] getClassList parsed ${classes.length} classes: '
          '${classes.map((c) => '${c.name}(id=${c.id})').toList()}');
      return classes;
    } catch (e) {
      log('[Session] getClassList error: $e');
    }
    return [];
  }

  /// Pulls a list out of a response that may be a top-level List or a Map with
  /// the rows under `result` / `data` (ignores statusCode).
  List<dynamic> _extractList(dynamic response) {
    if (response is List) return response;
    if (response is Map<String, dynamic>) {
      final r = response['result'] ?? response['data'];
      if (r is List) return r;
    }
    return const [];
  }
}
