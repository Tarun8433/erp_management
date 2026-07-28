import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:erp_management/core/utils/drawer_main/src/flutter_zoom_drawer.dart';
import 'package:erp_management/features/common/settings/setting_controller.dart';
import '../../../core/constants/app_colors.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settingController = Get.isRegistered<SettingController>()
        ? Get.find<SettingController>()
        : Get.put(SettingController());

    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'notification'.tr,
          style: context.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: context.theme.appBarTheme.backgroundColor,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: Icon(Icons.menu, color: Colors.white),
          onPressed: () => ZoomDrawer.of(context)?.toggle(),
        ),
      ),
      body: Obx(() {
        final scale = settingController.fontSizeMultiplier.value;
        final iconSize = 64.0 * scale;
        final iconPadding = 24.0 * scale;
        final gapLarge = 24.0 * scale;
        final gapSmall = 8.0 * scale;

        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(iconPadding),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.notifications_none_rounded,
                  size: iconSize,
                  color: AppColors.primary,
                ),
              ),
              SizedBox(height: gapLarge),
              Text(
                'no_notifications_yet'.tr,
                style: context.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.grey500,
                ),
              ),
              SizedBox(height: gapSmall),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20 * scale),
                child: Text(
                  'no_notifications_message'.tr,
                  textAlign: TextAlign.center,
                  style: context.textTheme.bodyLarge?.copyWith(
                    color: AppColors.grey600,
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
