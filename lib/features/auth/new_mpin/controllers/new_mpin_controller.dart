import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/widgets/common_dialog.dart';
import '../../../../routes/app_routes.dart';
import '../../data/repositories/auth_repository.dart';
import '../../../../core/utils/local_storage/storage_helper.dart';

class NewMpinController extends GetxController {
  final AuthRepository _authRepository = Get.find<AuthRepository>();
  final mpinController = TextEditingController();
  final confirmMpinController = TextEditingController();
  final RxBool isLoading = false.obs;
  
  final mpinFocusNode = FocusNode();
  final confirmMpinFocusNode = FocusNode();

  @override
  void onClose() {
    mpinController.dispose();
    confirmMpinController.dispose();
    mpinFocusNode.dispose();
    confirmMpinFocusNode.dispose();
    super.onClose();
  }

  Future<void> onResetMpin() async {
    if (isLoading.value) return;
    final mpin = mpinController.text.trim();
    if (mpin.length != 4 || int.tryParse(mpin) == null) {
      showCommonDialog(
        title: 'error'.tr,
        message: 'Please enter a valid 4-digit MPIN',
        isError: true,
      );
      return;
    }
    if (mpinController.text != confirmMpinController.text) {
      showCommonDialog(
        title: 'error'.tr,
        message: 'mpins_do_not_match'.tr,
        isError: true,
      );
      return;
    }
    final args = Get.arguments ?? {};
    final mobile = (args['mobile'] ?? '').toString();
    final resetToken = (args['resetToken'] ?? '').toString();
    if (mobile.isEmpty) {
      showCommonDialog(
        title: 'error'.tr,
        message: 'Mobile number missing in flow',
        isError: true,
      );
      return;
    }

    try {
      isLoading.value = true;
      FocusManager.instance.primaryFocus?.unfocus();
      final response = resetToken.trim().isNotEmpty
          ? await _authRepository.forgotMpin(
              mobile: mobile,
              resetToken: resetToken.trim(),
              mpin: mpin,
            )
          : await _authRepository.setMpin(
              mobile: mobile,
              mpin: mpin,
              
            );
      final status = response['status']?.toString();
      final message = response['message']?.toString();
      if (status == 'success') {
        await StorageHelper.saveLocalMpin(mpin);
        await StorageHelper.markPinSetCompleted();
        final fromLogin = (args['fromLogin'] == true);
        if (fromLogin) {
          Get.offAllNamed(AppRoutes.dashboard);
        } else {
          Get.offAllNamed(AppRoutes.auth);
        }
        showCommonDialog(
          title: 'success'.tr,
          message: message ?? 'MPIN set successfully',
        );
      } else {
        showCommonDialog(
          title: 'error'.tr,
          message: message ?? 'Failed to set MPIN',
          isError: true,
        );
      }
    } catch (e) {
      showCommonDialog(
        title: 'error'.tr,
        message: 'Failed to set MPIN: $e',
        isError: true,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
