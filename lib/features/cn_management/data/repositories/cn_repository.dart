import 'dart:convert';
import 'dart:developer';

import 'package:get/get.dart';

import '../../../../core/services/api/api_service.dart';
import '../../../../core/services/api/endpoints.dart';
import '../models/gc_request_model.dart';

class CnRepository {
  final ApiService _apiService;

  CnRepository({ApiService? apiService})
      : _apiService = apiService ?? Get.find<ApiService>();

  Future<Map<String, dynamic>> addGc(GcRequestModel model) async {
    final jsonData = jsonEncode(model.toJson());
    log('CnRepository.addGc payload: $jsonData');

    final response = await _apiService.postMultipart(
      Endpoints.addGc(),
      fields: {'data': jsonData},
      headers: {},
    );

    if (response is Map<String, dynamic>) {
      return response;
    }
    return {'data': response};
  }
}
