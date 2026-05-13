import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../controllers/forget_mpin_controller.dart';

class ForgetMpinScreen extends GetView<ForgetMpinController> {
  const ForgetMpinScreen({super.key});

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
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'forgot_mpin_title'.tr,
                style: textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'forgot_mpin_subtitle'.tr,
                style: textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 32),
          
              // Phone Field
              CustomTextField(
                controller: controller.phoneController,
                focusNode: controller.phoneFocusNode,
                hintText: 'phone_number'.tr,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                onSubmitted: (_) => controller.selectDate(context),
                suffixIcon: Icon(Icons.phone_android_outlined, color: colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 16),
          
              // // DOB Field
              // GestureDetector(
              //   onTap: () => controller.selectDate(context),
              //   child: AbsorbPointer(
              //     child: CustomTextField(
              //       controller: controller.dobController,
              //       focusNode: controller.dobFocusNode,
              //       hintText: 'date_of_birth'.tr,
              //       readOnly: true, // Make it read-only since we use DatePicker
              //       suffixIcon: Icon(Icons.calendar_today_outlined, color: colorScheme.onSurfaceVariant),
              //     ),
              //   ),
              // ),
          Spacer(),
              // const SizedBox(height: 32),
          
              Obx(() => CustomButton(
                    text: 'verify_reset'.tr,
                    onPressed: controller.onVerify,
                    isLoading: controller.isLoading.value,
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
