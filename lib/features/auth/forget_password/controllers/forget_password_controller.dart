import 'dart:convert';

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../../core/widgets/common_dialog.dart';
import '../../../../routes/app_routes.dart';
import '../../data/repositories/auth_repository.dart';

class ForgetPasswordController extends GetxController {
  final AuthRepository _authRepository = Get.find<AuthRepository>();
  
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  
  final emailFocusNode = FocusNode();
  final phoneFocusNode = FocusNode();

  // Observable state
  var isEmailMethod = true.obs;
  final RxBool isLoading = false.obs;

  @override
  void onClose() {
    emailController.dispose();
    phoneController.dispose();
    emailFocusNode.dispose();
    phoneFocusNode.dispose();
    super.onClose();
  }

  void toggleMethod() {
    isEmailMethod.value = !isEmailMethod.value;
    if (isEmailMethod.value) {
      Future.delayed(const Duration(milliseconds: 100), () => emailFocusNode.requestFocus());
    } else {
      Future.delayed(const Duration(milliseconds: 100), () => phoneFocusNode.requestFocus());
    }
  }

  Future<void> onSendCode() async {
    if (isLoading.value) return;
    if (isEmailMethod.value) {
      if (emailController.text.isEmpty || !GetUtils.isEmail(emailController.text)) {
        showCommonDialog(
          title: 'Error',
          message: 'Please enter a valid email',
          isError: true,
        );
        return;
      }
      // TODO: Implement email OTP flow
      showCommonDialog(
        title: 'Info',
        message: 'Email OTP not implemented yet',
      );
    } else {
      if (phoneController.text.isEmpty || phoneController.text.length != 10) {
        showCommonDialog(
          title: 'Error',
          message: 'Please enter a valid 10-digit phone number',
          isError: true,
        );
        return;
      }
      
      try {
        isLoading.value = true;
        final response = await _authRepository.sendOtp(phoneController.text, "FORGOT_PASSWORD");
         debugPrint("OTP Response: ${jsonEncode(response)}");
        if (response['status'] == 'success') {
          showCommonDialog(
            title: 'Success',
            message: response['message'] ?? 'OTP sent successfully',
            onConfirm: () {
               Get.toNamed(
                AppRoutes.verification, 
                arguments: {
                  'type': 'forgot_password',
                  'mobile': phoneController.text,
                }
              );
            },
          );
        } else {
          showCommonDialog(
            title: 'Error',
            message: response['message'] ?? 'Failed to send OTP',
            isError: true,
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
}
