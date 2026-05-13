// image_picker_service.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';

class ImagePickerService {
  final ImagePicker _picker = ImagePicker();

  Future<File?> pickImage({
    required BuildContext context,
    ImageSource source = ImageSource.gallery,
    int maxSizeMB = 5,
  }) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 80,
      );

      if (pickedFile == null) return null;

      final file = File(pickedFile.path);
      final sizeInBytes = await file.length();
      final sizeInMB = sizeInBytes / (1024 * 1024);

      if (sizeInMB > maxSizeMB) {
        Get.snackbar(
          'File Too Large',
          'Please select an image under $maxSizeMB MB',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        return null;
      }

      return file;
    } catch (e) {
      debugPrint('Error picking image: $e');
      return null;
    }
  }

  Future<void> showImagePickerOptions({
    required BuildContext context,
    required Function(File) onImageSelected,
  }) async {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.photo_library, size: 28),
              title: const Text('Choose from Gallery'),
              onTap: () async {
                Navigator.pop(ctx);
                final file = await pickImage(
                  context: context,
                  source: ImageSource.gallery,
                );
                if (file != null) {
                  _showPreviewDialog(
                    context: context,
                    imageFile: file,
                    onImageSelected: onImageSelected,
                    scheme: scheme,
                  );
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, size: 28),
              title: const Text('Take a Photo'),
              onTap: () async {
                Navigator.pop(ctx);
                final file = await pickImage(
                  context: context,
                  source: ImageSource.camera,
                );
                if (file != null) {
                  _showPreviewDialog(
                    context: context,
                    imageFile: file,
                    onImageSelected: onImageSelected,
                    scheme: scheme,
                  );
                }
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showPreviewDialog({
    required BuildContext context,
    required File imageFile,
    required Function(File) onImageSelected,
    required ColorScheme scheme,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Image Preview',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.5,
                      ),
                      child: Image.file(imageFile, fit: BoxFit.contain),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            Navigator.pop(ctx);
                            final cropped = await _cropImage(imageFile, scheme);
                            if (cropped != null) {
                              _showPreviewDialog(
                                context: context,
                                imageFile: cropped,
                                onImageSelected: onImageSelected,
                                scheme: scheme,
                              );
                            } else {
                              _showPreviewDialog(
                                context: context,
                                imageFile: imageFile,
                                onImageSelected: onImageSelected,
                                scheme: scheme,
                              );
                            }
                          },
                          icon: const Icon(Icons.edit_rounded),
                          label: const Text('Edit'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(ctx);
                            onImageSelected(imageFile);
                          },
                          icon: const Icon(Icons.check_rounded),
                          label: const Text('Continue'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            backgroundColor: scheme.primary,
                            foregroundColor: scheme.onPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Positioned(
              right: 0,
              top: 0,
              child: IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () => Navigator.pop(ctx),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.grey[200],
                  padding: const EdgeInsets.all(4),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<File?> _cropImage(File imageFile, ColorScheme scheme) async {
    try {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: imageFile.path,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Image',
            toolbarColor: scheme.primary,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            cropFrameColor: scheme.primary,
            statusBarColor: scheme.primary,
            activeControlsWidgetColor: scheme.primary,
            lockAspectRatio: false,
            aspectRatioPresets: [
              CropAspectRatioPreset.square,
              CropAspectRatioPreset.ratio3x2,
              CropAspectRatioPreset.original,
              CropAspectRatioPreset.ratio4x3,
              CropAspectRatioPreset.ratio16x9,
            ],
          ),
          IOSUiSettings(
            title: 'Crop Image',
            aspectRatioPresets: [
              CropAspectRatioPreset.square,
              CropAspectRatioPreset.ratio3x2,
              CropAspectRatioPreset.original,
              CropAspectRatioPreset.ratio4x3,
              CropAspectRatioPreset.ratio16x9,
            ],
          ),
        ],
      );
      return croppedFile != null ? File(croppedFile.path) : null;
    } catch (e) {
      debugPrint('Error cropping image: $e');
      return null;
    }
  }
}
