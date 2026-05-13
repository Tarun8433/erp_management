import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../controllers/new_mpin_controller.dart';

class NewMpinScreen extends GetView<NewMpinController> {
  const NewMpinScreen({super.key});

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
                'create_new_mpin'.tr,
                style: textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'create_new_mpin_subtitle'.tr,
                style: textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 32),

              // MPIN Field
              CustomTextField(
                controller: controller.mpinController,
                focusNode: controller.mpinFocusNode,
                hintText: 'new_mpin'.tr,
                obscureText: true,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                inputFormatters: [
                  LengthLimitingTextInputFormatter(4),
                  FilteringTextInputFormatter.digitsOnly,
                ],
                textInputAction: TextInputAction.next,
                onSubmitted: (_) => controller.confirmMpinFocusNode.requestFocus(),
                suffixIcon: Icon(Icons.lock_outline, color: colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 16),

              // Confirm MPIN Field
              CustomTextField(
                controller: controller.confirmMpinController,
                focusNode: controller.confirmMpinFocusNode,
                hintText: 'confirm_mpin'.tr,
                obscureText: true,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                inputFormatters: [
                  LengthLimitingTextInputFormatter(4),
                  FilteringTextInputFormatter.digitsOnly,
                ],
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => controller.onResetMpin(),
                suffixIcon: Icon(Icons.lock_outline, color: colorScheme.onSurfaceVariant),
              ),

              const SizedBox(height: 32),

              Obx(() => CustomButton(
                    text: 'reset_mpin'.tr,
                    onPressed: controller.onResetMpin,
                    isLoading: controller.isLoading.value,
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
