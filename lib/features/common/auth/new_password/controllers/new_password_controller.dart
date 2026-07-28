import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../core/widgets/common_dialog.dart';
import '../../../../../routes/app_routes.dart';
import '../../data/repositories/auth_repository.dart';

class NewPasswordController extends GetxController {
  final AuthRepository _authRepository = Get.find<AuthRepository>();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  
  final passwordFocusNode = FocusNode();
  final confirmPasswordFocusNode = FocusNode();

  var isPasswordVisible = false.obs;
  var isConfirmPasswordVisible = false.obs;
  final RxBool isLoading = false.obs;

  @override
  void onClose() {
    passwordController.dispose();
    confirmPasswordController.dispose();
    passwordFocusNode.dispose();
    confirmPasswordFocusNode.dispose();
    super.onClose();
  }

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordVisible.value = !isConfirmPasswordVisible.value;
  }

  Future<void> onResetPassword() async {
    if (isLoading.value) return;
    if (passwordController.text != confirmPasswordController.text) {
      showCommonDialog(
        title: 'error'.tr,
        message: 'passwords_do_not_match'.tr,
        isError: true,
      );
      return;
    }
    final args = Get.arguments ?? {};
    final mobile = (args['mobile'] ?? '').toString().trim();
    final resetToken = (args['resetToken'] ?? '').toString().trim();
    if (mobile.isEmpty || resetToken.isEmpty) {
      showCommonDialog(
        title: 'error'.tr,
        message: 'Mobile/reset token missing in flow',
        isError: true,
      );
      return;
    }

    FocusManager.instance.primaryFocus?.unfocus();
    try {
      isLoading.value = true;
      final response = await _authRepository.forgotPassword(
        mobile: mobile,
        resetToken: resetToken,
        password: passwordController.text,
      );
      final status = response is Map ? response['status']?.toString() : null;
      final message = response is Map ? response['message']?.toString() : null;
      if (status?.toLowerCase() == 'success') {
        Get.offAllNamed(AppRoutes.auth);
        showCommonDialog(
          title: 'success'.tr,
          message: message ?? 'password_reset_success'.tr,
        );
        return;
      }
      showCommonDialog(
        title: 'error'.tr,
        message: message ?? 'Failed to reset password',
        isError: true,
      );
    } catch (e) {
      showCommonDialog(
        title: 'error'.tr,
        message: e.toString().replaceAll('Exception:', '').trim(),
        isError: true,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
