import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../controllers/forget_password_controller.dart';

class ForgetPasswordScreen extends GetView<ForgetPasswordController> {
  const ForgetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
          onPressed: () => Get.back(),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'forgot_password_title'.tr,
                style: textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'forgot_password_subtitle'.tr,
                style: textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 32),

              // Toggle Method (Email / Phone)
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Obx(() => Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          if (!controller.isEmailMethod.value) controller.toggleMethod();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: controller.isEmailMethod.value
                                ? colorScheme.surface
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: controller.isEmailMethod.value
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.05),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : [],
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'email'.tr,
                            style: textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: controller.isEmailMethod.value
                                  ? colorScheme.primary
                                  : colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          if (controller.isEmailMethod.value) controller.toggleMethod();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: !controller.isEmailMethod.value
                                ? colorScheme.surface
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: !controller.isEmailMethod.value
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.05),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : [],
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'phone'.tr,
                            style: textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: !controller.isEmailMethod.value
                                  ? colorScheme.primary
                                  : colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                )),
              ),
              const SizedBox(height: 32),

              // Input Field
              Obx(() => AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: controller.isEmailMethod.value
                    ? CustomTextField(
                        key: const ValueKey('email_input'),
                        controller: controller.emailController,
                        focusNode: controller.emailFocusNode,
                        hintText: 'email'.tr,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => controller.onSendCode(),
                        suffixIcon: Icon(Icons.email_outlined, color: colorScheme.onSurfaceVariant),
                      )
                    : CustomTextField(
                        key: const ValueKey('phone_input'),
                        controller: controller.phoneController,
                        focusNode: controller.phoneFocusNode,
                        hintText: 'phone_number'.tr,
                        keyboardType: TextInputType.phone,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => controller.onSendCode(),
                        suffixIcon: Icon(Icons.phone_android_outlined, color: colorScheme.onSurfaceVariant),
                      ),
              )),

              const SizedBox(height: 32),

              Obx(() => CustomButton(
                    text: 'send_code'.tr,
                    onPressed: controller.onSendCode,
                    isLoading: controller.isLoading.value,
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
