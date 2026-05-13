import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../controllers/new_password_controller.dart';

class NewPasswordScreen extends GetView<NewPasswordController> {
  const NewPasswordScreen({super.key});

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
                'create_new_password'.tr,
                style: textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'create_new_password_subtitle'.tr,
                style: textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 32),

              // Password Field
              Obx(() => CustomTextField(
                controller: controller.passwordController,
                focusNode: controller.passwordFocusNode,
                hintText: 'new_password'.tr,
                obscureText: !controller.isPasswordVisible.value,
                textInputAction: TextInputAction.next,
                onSubmitted: (_) => controller.confirmPasswordFocusNode.requestFocus(),
                suffixIcon: IconButton(
                  icon: Icon(
                    controller.isPasswordVisible.value
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  onPressed: controller.togglePasswordVisibility,
                ),
              )),
              const SizedBox(height: 16),

              // Confirm Password Field
              Obx(() => CustomTextField(
                controller: controller.confirmPasswordController,
                focusNode: controller.confirmPasswordFocusNode,
                hintText: 'confirm_password'.tr,
                obscureText: !controller.isConfirmPasswordVisible.value,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => controller.onResetPassword(),
                suffixIcon: IconButton(
                  icon: Icon(
                    controller.isConfirmPasswordVisible.value
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  onPressed: controller.toggleConfirmPasswordVisibility,
                ),
              )),

              const SizedBox(height: 32),

              CustomButton(
                text: 'reset_password'.tr,
                onPressed: () {
                  if (controller.isLoading.value) return;
                  controller.onResetPassword();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
