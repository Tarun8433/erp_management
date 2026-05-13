import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/widgets/common_dialog.dart';
import 'package:erp_management/routes/app_routes.dart';
import '../../data/repositories/auth_repository.dart';
import '../../controllers/auth_controller.dart';

class VerificationController extends GetxController {
  final AuthRepository _authRepository = Get.find<AuthRepository>();

  AuthController? _authController;

  final List<TextEditingController> otpControllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> focusNodes = List.generate(6, (_) => FocusNode());

  final RxInt remainingSeconds = 30.obs;
  final RxBool canResend = false.obs;
  Timer? _timer;

  final RxString verificationType =
      ''.obs; // 'signup', 'forgot_password', 'forgot_mpin'
  final RxString mobileNumber = ''.obs;
  final RxBool isVerifying = false.obs;
  final RxBool isResending = false.obs;
  final RxnString resetToken = RxnString();
  final RxnString resetTokenExpiresIn = RxnString();

  @override
  void onInit() {
    super.onInit();
    if (Get.isRegistered<AuthController>()) {
      _authController = Get.find<AuthController>();
    }

    if (Get.arguments != null) {
      verificationType.value = Get.arguments['type'] ?? '';
      mobileNumber.value = Get.arguments['mobile'] ?? '';
    }
    startTimer();
  }

  @override
  void onClose() {
    _timer?.cancel();
    for (var controller in otpControllers) {
      controller.dispose();
    }
    for (var node in focusNodes) {
      node.dispose();
    }
    super.onClose();
  }

  void startTimer() {
    startTimerWithSeconds(30);
  }

  void startTimerWithSeconds(int seconds) {
    remainingSeconds.value = seconds;
    canResend.value = false;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingSeconds.value > 0) {
        remainingSeconds.value--;
      } else {
        canResend.value = true;
        timer.cancel();
      }
    });
  }

  void onDigitEntered(int index, String value) {
    if (value.isNotEmpty && index < 5) {
      focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      focusNodes[index - 1].requestFocus();
    }
  }

  Future<void> onVerify() async {
    if (isVerifying.value) return;
    String otp = otpControllers.map((e) => e.text).join();
    if (otp.length == 6) {
      isVerifying.value = true;
      try {
        // For other flows (forgot password/mpin), verify OTP first
        try {
          final response = await _authRepository.verifyOtp(
            mobileNumber.value,
            otp,
            verificationType.value == 'forgot_mpin'
                ? "FORGOT_MPIN"
                : "FORGOT_PASSWORD",
          );

          if (response['status'] == 'success') {
            final data = response['data'];
            resetToken.value = data is Map
                ? data['resetToken']?.toString()
                : null;
            resetTokenExpiresIn.value = data is Map
                ? data['expiresIn']?.toString()
                : null;
            showCommonDialog(
              title: 'Success',
              message: response['message'] ?? 'Otp verified successfully',
              onConfirm: () {
                if (verificationType.value == 'forgot_password') {
                  Get.offNamed(
                    AppRoutes.newPassword,
                    arguments: {
                      'mobile': mobileNumber.value,
                      'resetToken': resetToken.value,
                      'expiresIn': resetTokenExpiresIn.value,
                    },
                  );
                } else if (verificationType.value == 'forgot_mpin') {
                  Get.offNamed(
                    AppRoutes.newMpin,
                    arguments: {
                      'mobile': mobileNumber.value,
                      'resetToken': resetToken.value,
                      'expiresIn': resetTokenExpiresIn.value,
                    },
                  );
                }
              },
            );
          } else {
            showCommonDialog(
              title: 'Error',
              message: response['message'] ?? 'Invalid OTP',
              isError: true,
            );
          }
        } catch (e) {
          showCommonDialog(
            title: 'Error',
            message: 'Verification failed: $e',
            isError: true,
          );
        }
      } finally {
        isVerifying.value = false;
      }
    } else {
      showCommonDialog(
        title: 'Error',
        message: 'Please enter a valid 6-digit OTP',
        isError: true,
      );
    }
  }

  Future<void> onResendCode() async {
    if (!canResend.value || isResending.value) return;
    isResending.value = true;
    try {
      try {
        final isLoginFlow =
            verificationType.value.isEmpty || verificationType.value == 'login';
        final response = await _authRepository.sendOtp(
          mobileNumber.value,
          isLoginFlow
              ? "LOGIN"
              : (verificationType.value == 'forgot_mpin'
                    ? "FORGOT_MPIN"
                    : "FORGOT_PASSWORD"),
          isLogin: isLoginFlow,
        );
        debugPrint("OTP Response: ${jsonEncode(response)}");
        final status = response['status']?.toString();
        final message = response['message']?.toString();
        final meta = response['_meta'];
        final statusCode = meta is Map
            ? int.tryParse(meta['statusCode']?.toString() ?? '')
            : null;
        final retryAfterSeconds = meta is Map
            ? int.tryParse(meta['retryAfterSeconds']?.toString() ?? '')
            : null;

        if (status == 'success') {
          showCommonDialog(
            title: 'Success',
            message: message ?? 'Verification code resent',
          );
          startTimer();
          return;
        }

        if (statusCode == 429 &&
            retryAfterSeconds != null &&
            retryAfterSeconds > 0) {
          showCommonDialog(
            title: 'Error',
            message: message ?? 'Too many OTP requests. Try again later.',
            isError: true,
          );
          startTimerWithSeconds(retryAfterSeconds);
          return;
        }

        showCommonDialog(
          title: 'Error',
          message: message ?? 'Failed to resend code',
          isError: true,
        );
      } catch (e) {
        showCommonDialog(
          title: 'Error',
          message: 'Failed to resend code: $e',
          isError: true,
        );
      }
    } finally {
      isResending.value = false;
    }
  }
}
