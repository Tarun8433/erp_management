import 'dart:developer';

import 'package:erp_management/core/services/api/api_service.dart';
import 'package:erp_management/core/services/api/endpoints.dart';
import 'package:erp_management/features/role_based_ui/principal/staff/models/staff_model.dart';
import 'package:get/get.dart';

class StaffController extends GetxController {
  final ApiService _api = ApiService();

  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  // Full list from the API and the filtered view shown on screen.
  final RxList<StaffModel> _allStaff = <StaffModel>[].obs;
  final RxList<StaffModel> staff = <StaffModel>[].obs;

  final RxString searchText = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchStaff();
  }

  Future<void> fetchStaff() async {
    isLoading.value = true;
    error.value = '';
    try {
      // GetStaff is a POST with an empty body.
      final response = await _api.postJsonWithoutBody(Endpoints.getStaff());
      log('GetStaff response: $response');

      List<dynamic> list = [];
      if (response is List) {
        list = response;
      } else if (response is Map<String, dynamic>) {
        final result = response['result'] ?? response['data'];
        if (result is List) list = result;
      }

      final mapped = list
          .whereType<Map<String, dynamic>>()
          .map(StaffModel.fromJson)
          .toList();

      _allStaff.assignAll(mapped);
      _applyFilter();
      log('GetStaff parsed staff: ${_allStaff.length}');
    } catch (e) {
      error.value = e.toString();
      log('GetStaff error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void onSearch(String query) {
    searchText.value = query;
    _applyFilter();
  }

  void _applyFilter() {
    final q = searchText.value.trim().toLowerCase();
    if (q.isEmpty) {
      staff.assignAll(_allStaff);
      return;
    }
    staff.assignAll(
      _allStaff.where((s) {
        return s.name.toLowerCase().contains(q) ||
            s.designation.toLowerCase().contains(q) ||
            s.mobileNo.toLowerCase().contains(q) ||
            s.userName.toLowerCase().contains(q) ||
            s.email.toLowerCase().contains(q);
      }),
    );
  }
}
