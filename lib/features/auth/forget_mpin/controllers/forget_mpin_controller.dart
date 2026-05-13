import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../routes/app_routes.dart';
import '../../../../core/widgets/common_dialog.dart';
import '../../data/repositories/auth_repository.dart';

class ForgetMpinController extends GetxController {
  final AuthRepository _authRepository = Get.find<AuthRepository>();
  final phoneController = TextEditingController();
  final dobController = TextEditingController();
  final RxBool isLoading = false.obs;
  
  final phoneFocusNode = FocusNode();
  final dobFocusNode = FocusNode();

  @override
  void onClose() {
    phoneController.dispose();
    dobController.dispose();
    phoneFocusNode.dispose();
    dobFocusNode.dispose();
    super.onClose();
  }

  Future<void> selectDate(BuildContext context) async {
    final DateTime today = DateTime.now();
    final DateTime lastDate = DateTime(today.year, today.month, today.day);

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(today.year - 18, today.month, today.day),
      firstDate: DateTime(1900),
      lastDate: lastDate,
    );

    if (picked != null) {
      dobController.text =
          "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
    }
  }

  Future<void> onVerify() async {
    if (isLoading.value) return;
    final mobile = phoneController.text.trim();
    if (mobile.length != 10 || int.tryParse(mobile) == null) {
      showCommonDialog(
        title: 'Error',
        message: 'Please enter a valid 10-digit phone number',
        isError: true,
      );
      return;
    }

    try {
      isLoading.value = true;
      final response = await _authRepository.sendOtp(
        mobile,
        "FORGOT_MPIN",
        isLogin: false,
        countryCode: '91',
      );
      final status = response['status']?.toString();
      final message = response['message']?.toString();
      if (status == 'success') {
        showCommonDialog(
          title: 'Success',
          message: message ?? 'OTP sent successfully',
          onConfirm: () {
            Get.toNamed(
              AppRoutes.verification,
              arguments: {
                'type': 'forgot_mpin',
                'mobile': mobile,
              },
            );
          },
        );
      } else {
        showCommonDialog(
          title: 'Error',
          message: message ?? 'Failed to send OTP',
          isError: true,
        );
      }
    } catch (e) {
      showCommonDialog(
        title: 'Error',
        message: 'Failed to send OTP: $e',
        isError: true,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
