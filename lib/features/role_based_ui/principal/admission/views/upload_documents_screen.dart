// upload_documents_screen.dart
 
import 'package:erp_management/features/role_based_ui/principal/admission/service/document_upload_tile.dart';
import 'package:erp_management/features/role_based_ui/principal/admission/service/image_picker_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/upload_documents_controller.dart';

class UploadDocumentsScreen extends StatelessWidget {
  UploadDocumentsScreen({super.key});

  final c = Get.put(UploadDocumentsController());
  final imagePickerService = ImagePickerService();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    // Static constants from controller
    const docs = UploadDocumentsController.documents;
    const docNames = UploadDocumentsController.documentNames;
    const docIcons = UploadDocumentsController.documentIcons;

    return Scaffold(
      backgroundColor: scheme.surfaceContainerLowest,
      appBar: AppBar(
        title: const Text('Upload Documents'),
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Get.back(),
        ),
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        elevation: 0,
      ),
      body: Obx(() {
        final uploadedCount = c.uploadedCount;

        return Column(
          children: [
            // Header with progress indicator
            Container(
              margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: scheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: theme.dividerColor.withValues(alpha: 0.4),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: scheme.primaryContainer.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.cloud_upload, color: scheme.primary),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Document Upload',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'All documents are optional — attach any you have',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: scheme.primaryContainer.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '$uploadedCount/${docs.length}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: scheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // Document list
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // All documents — none are mandatory.
                    Row(
                      children: [
                        Icon(
                          Icons.add_circle_outline,
                          size: 20,
                          color: scheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Documents (Optional)',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.3,
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ...docs.map(
                      (docKey) => DocumentUploadTile(
                        docKey: docKey,
                        label: docNames[docKey]!,
                        icon: docIcons[docKey]!,
                        uploadedFile: c.uploadedFiles[docKey],
                        isRequired: false,
                        isUploading: c.uploadProgress[docKey] ?? false,
                        uploadProgress: c.uploadPercent[docKey] ?? 0,
                        onUpload: () => _showImagePicker(context, docKey),
                        onRemove: () => c.removeUploadedFile(docKey),
                      ),
                    ),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
      bottomNavigationBar: Obx(() {
        final isSubmitting = c.isSubmitting.value;

        return Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            border: Border(
              top: BorderSide(color: theme.dividerColor.withValues(alpha: 0.6)),
            ),
          ),
          child: SafeArea(
            child: SizedBox(
              height: 52,
              width: double.infinity,
              child: FilledButton(
                onPressed: isSubmitting ? null : c.submitDocuments,
                style: FilledButton.styleFrom(
                  backgroundColor: scheme.primary,
                  foregroundColor: scheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: isSubmitting
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 12),
                          Text('Submitting...'),
                        ],
                      )
                    : Text(
                        'FINAL SUBMIT',
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                          fontSize: 16,
                        ),
                      ),
              ),
            ),
          ),
        );
      }),
    );
  }

  void _showImagePicker(BuildContext context, String docKey) {
    imagePickerService.showImagePickerOptions(
      context: context,
      onImageSelected: (file) {
        c.setUploadedFile(docKey, file);
      },
    );
  }
}
