import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../widgets/common_dialog.dart';

/// A centralized service to handle all app permissions
class AppPermissionHandler {
  AppPermissionHandler._();

  static final AppPermissionHandler _instance = AppPermissionHandler._();

  factory AppPermissionHandler() => _instance;

  /// Request camera permission
  /// Returns true if granted, false otherwise
  Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.request();

    if (status.isGranted) {
      return true;
    } else if (status.isPermanentlyDenied) {
      await _showPermissionDeniedDialog(
        title: 'Camera Permission Required',
        message: 'Camera access is required to take photos. Please enable it in settings.',
        permission: 'Camera',
      );
      return false;
    } else {
      // User denied, but can request again
      showCommonDialog(
        title: 'Permission Denied',
        message: 'Camera permission is required to take photos',
        isError: true,
      );
      return false;
    }
  }

  /// Request photo library/gallery permission
  /// Returns true if granted or limited, false otherwise
  Future<bool> requestGalleryPermission() async {
    PermissionStatus status;

    if (Platform.isAndroid) {
      // For Android 13+ (API 33+), use photos permission
      // For older Android, use storage permission
      if (await _isAndroid13OrHigher()) {
        status = await Permission.photos.request();
      } else {
        status = await Permission.storage.request();
      }
    } else {
      // iOS - use photos permission
      status = await Permission.photos.request();
    }

    if (status.isGranted || status.isLimited) {
      return true;
    } else if (status.isPermanentlyDenied) {
      await _showPermissionDeniedDialog(
        title: 'Gallery Permission Required',
        message: 'Photo library access is required to select photos. Please enable it in settings.',
        permission: 'Photos',
      );
      return false;
    } else {
      // User denied, but can request again
      showCommonDialog(
        title: 'Permission Denied',
        message: 'Photo library permission is required to select photos',
        isError: true,
      );
      return false;
    }
  }

  /// Check if camera permission is already granted
  Future<bool> isCameraPermissionGranted() async {
    return await Permission.camera.isGranted;
  }

  /// Check if gallery permission is already granted
  Future<bool> isGalleryPermissionGranted() async {
    if (Platform.isAndroid) {
      if (await _isAndroid13OrHigher()) {
        final status = await Permission.photos.status;
        return status.isGranted || status.isLimited;
      } else {
        return await Permission.storage.isGranted;
      }
    } else {
      final status = await Permission.photos.status;
      return status.isGranted || status.isLimited;
    }
  }

  /// Request multiple permissions at once
  /// Returns a map of permission results
  Future<Map<Permission, PermissionStatus>> requestMultiplePermissions(
    List<Permission> permissions,
  ) async {
    return await permissions.request();
  }

  /// Check if Android version is 13 or higher (API 33+)
  Future<bool> _isAndroid13OrHigher() async {
    if (!Platform.isAndroid) return false;

    // This is a simplified check. In production, you might want to use
    // device_info_plus package for accurate Android version detection
    try {
      return await Permission.photos.request() != PermissionStatus.denied;
    } catch (e) {
      return false;
    }
  }

  /// Show permission denied dialog with option to open app settings
  Future<void> _showPermissionDeniedDialog({
    required String title,
    required String message,
    required String permission,
  }) async {
    await Get.dialog(
      AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  /// Show a generic permission rationale dialog before requesting
  Future<bool> showPermissionRationale({
    required String title,
    required String message,
  }) async {
    bool shouldRequest = false;

    await Get.dialog(
      AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              shouldRequest = false;
              Get.back();
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              shouldRequest = true;
              Get.back();
            },
            child: const Text('Allow'),
          ),
        ],
      ),
      barrierDismissible: false,
    );

    return shouldRequest;
  }
}
