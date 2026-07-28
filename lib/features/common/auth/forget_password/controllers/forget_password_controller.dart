import 'dart:developer';

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../../../core/services/api/api_service.dart';
import '../../../../../core/services/api/endpoints.dart';
import '../../../../../core/widgets/common_dialog.dart';

class ForgetPasswordController extends GetxController {
  final ApiService _api = ApiService();

  final userIdController = TextEditingController();
  final userIdFocusNode = FocusNode();

  final RxBool isLoading = false.obs;

  @override
  void onClose() {
    userIdController.dispose();
    userIdFocusNode.dispose();
    super.onClose();
  }

  /// Sends a password-reset link to the user's registered email via
  /// POST /api/Account/SendResetPasswordLink?userName=<userId>.
  Future<void> onSendCode() async {
    if (isLoading.value) return;
    final userId = userIdController.text.trim();
    if (userId.isEmpty) {
      showCommonDialog(
        title: 'Error',
        message: 'Please enter your User ID',
        isError: true,
      );
      return;
    }
    try {
      isLoading.value = true;
      final uri = Endpoints.sendResetPasswordLink().replace(
        queryParameters: {'userName': userId},
      );
      final response = await _api.postJsonWithoutBody(uri);
      log('SendResetPasswordLink response: $response');

      final failed = response is Map && response['statusCode'] == -1;
      if (failed) {
        showCommonDialog(
          title: 'Error',
          message:
              response['responseText']?.toString() ??
              'Failed to send reset link',
          isError: true,
        );
      } else {
        showCommonDialog(
          title: 'Success',
          message:
              (response is Map ? response['responseText']?.toString() : null) ??
              'A password reset link has been sent to your registered email address.',
          onConfirm: () => Get.back(),
        );
      }
    } catch (e) {
      showCommonDialog(
        title: 'Error',
        message: 'Something went wrong: $e',
        isError: true,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
