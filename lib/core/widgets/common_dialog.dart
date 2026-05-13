import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../routes/app_routes.dart';
import '../utils/local_storage/storage_helper.dart';
import '../constants/app_colors.dart';

void showCommonDialog({
  String? title,
  required String message,
  String confirmText = 'OK',
  VoidCallback? onConfirm,
  bool isError = false,
  bool barrierDismissible = true,
}) {
  final combined = '${title ?? ''} $message'.toLowerCase();
  final bool isSessionExpired = combined.contains('session_expired') || combined.contains('session expired');

  VoidCallback? finalOnConfirm = onConfirm;

  if (isSessionExpired) {
    finalOnConfirm = () {
      onConfirm?.call();

      FocusManager.instance.primaryFocus?.unfocus();
      StorageHelper.clearAllLocalData().then((_) {
        if (Get.currentRoute != AppRoutes.auth) {
          Get.offAllNamed(AppRoutes.auth);
        }
      }).catchError((_) {
        if (Get.currentRoute != AppRoutes.auth) {
          Get.offAllNamed(AppRoutes.auth);
        }
      });
    };
  }

  Get.dialog(
    Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      elevation: 10,
      backgroundColor: Get.isDarkMode
          ? AppColors.darkSurface
          : AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: isError ? AppColors.error : AppColors.success,
              size: 60,
            ),
            const SizedBox(height: 20),
            if (title != null) ...[
              Text(
                title,
                textAlign: TextAlign.center,
                style: Get.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Get.isDarkMode
                      ? AppColors.darkOnSurface
                      : AppColors.onSurface,
                ),
              ),
              const SizedBox(height: 10),
            ],
            Text(
              message,
              textAlign: TextAlign.center,
              style: Get.textTheme.bodyMedium?.copyWith(
                color: Get.isDarkMode ? AppColors.grey400 : AppColors.grey700,
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  Get.back();
                  finalOnConfirm?.call();
                },
                child: Text(
                  confirmText,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
    barrierDismissible: isSessionExpired ? false : barrierDismissible,
  );
}
