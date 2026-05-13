import 'dart:io';
import 'package:flutter/material.dart';
import 'custom_camera.dart';

class CameraService {
  static Future<File?> openCustomCamera(BuildContext context) async {
    final f = await Navigator.of(context).push<File>(
      MaterialPageRoute(builder: (_) => const CustomCameraPage()),
    );
    return f;
  }
}
