// document_upload_tile.dart
import 'dart:io';
import 'package:flutter/material.dart';
 
class DocumentUploadTile extends StatelessWidget {
  final String docKey;
  final String label;
  final IconData icon;
  final File? uploadedFile;
  final bool isRequired;
  final bool isUploading;
  final double uploadProgress;
  final VoidCallback onUpload;
  final VoidCallback onRemove;

  const DocumentUploadTile({
    super.key,
    required this.docKey,
    required this.label,
    required this.icon,
    required this.uploadedFile,
    required this.isRequired,
    required this.isUploading,
    required this.uploadProgress,
    required this.onUpload,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: uploadedFile != null
              ? Colors.green.withValues(alpha: 0.5)
              : theme.dividerColor.withValues(alpha: 0.4),
          width: uploadedFile != null ? 1.5 : 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: uploadedFile != null ? null : onUpload,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Icon
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: scheme.primaryContainer.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, size: 24, color: scheme.primary),
                ),
                const SizedBox(width: 14),

                // Label and badge
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              label,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (!isRequired)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'Optional',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      if (uploadedFile != null) ...[
                        Row(
                          children: [
                            const Icon(Icons.check_circle,
                                size: 14, color: Colors.green),
                            const SizedBox(width: 4),
                            Text(
                              'Uploaded',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.green,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ] else ...[
                        Text(
                          isRequired ? 'Required' : 'Optional',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isRequired ? Colors.red : Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                if (uploadedFile != null)
                  GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (_) => Dialog(
                          backgroundColor: Colors.transparent,
                          insetPadding: const EdgeInsets.all(10),
                          child: Stack(
                            alignment: Alignment.topRight,
                            children: [
                              InteractiveViewer(
                                child: Image.file(uploadedFile!,
                                    fit: BoxFit.contain),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close,
                                    color: Colors.white, size: 30),
                                onPressed: () => Navigator.pop(context),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    child: Stack(
                      alignment: Alignment.topRight,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            uploadedFile!,
                            key: ValueKey(uploadedFile!.path),
                            width: 70,
                            height: 70,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 70,
                                height: 70,
                                color: scheme.errorContainer,
                                child: Icon(Icons.error_outline,
                                    color: scheme.error, size: 20),
                              );
                            },
                          ),
                        ),
                        Positioned(
                          right: -4,
                          top: -4,
                          child: GestureDetector(
                            onTap: onRemove,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                                border:
                                    Border.all(color: Colors.white, width: 1.5),
                              ),
                              child: const Icon(Icons.close,
                                  size: 10, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                else if (isUploading)
                  SizedBox(
                    width: 70,
                    height: 70,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CircularProgressIndicator(
                          value: uploadProgress / 100,
                          strokeWidth: 3,
                          color: scheme.primary,
                        ),
                        Text(
                          '${uploadProgress.toInt()}%',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color:
                          scheme.surfaceContainerHighest.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: theme.dividerColor.withValues(alpha: 0.5),
                      ),
                    ),
                    child: Icon(Icons.add_photo_alternate,
                        size: 28, color: scheme.primary),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}