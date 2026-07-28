import 'package:flutter/material.dart';

import '../controllers/admission_report_controller.dart';

/// Read-only detail view for one admission report row.
///
/// Mirrors the layout of the student list's detail screen: grouped sections,
/// and an em dash wherever the server sent no value so an empty field never
/// reads as data. Editing is reachable from the app bar and the bottom action.
class AdmissionReportDetailsScreen extends StatelessWidget {
  final AdmissionReportItem item;
  final VoidCallback onEdit;

  const AdmissionReportDetailsScreen({
    super.key,
    required this.item,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: scheme.surfaceContainerLowest,
      appBar: AppBar(
        title: const Text('Student Details'),
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit Details',
            onPressed: onEdit,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(context),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildInfoSection(
                    context,
                    'Academic Information',
                    Icons.school_rounded,
                    [
                      _buildDetailRow(context, 'Student ID', item.sid),
                      _buildDetailRow(context, 'SR Number', item.srNo),
                      _buildDetailRow(context, 'Academic Group', item.group),
                      _buildDetailRow(context, 'Current Class', item.className),
                      _buildDetailRow(context, 'Status', item.status),
                      _buildDetailRow(context, 'Admitted On', item.entryAt),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildInfoSection(
                    context,
                    'Personal Details',
                    Icons.person_rounded,
                    [
                      _buildDetailRow(context, 'Gender', item.gender),
                      _buildDetailRow(context, 'Date of Birth', item.dob),
                      _buildDetailRow(context, 'Religion', item.religion),
                      _buildDetailRow(context, 'Category', item.category),
                      _buildDetailRow(context, 'Sub Category', item.subCategory),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildInfoSection(
                    context,
                    'Parent Details',
                    Icons.family_restroom_rounded,
                    [
                      _buildDetailRow(
                        context,
                        'Father\'s Name',
                        item.fatherName,
                      ),
                      _buildDetailRow(
                        context,
                        'Mother\'s Name',
                        item.motherName,
                      ),
                      _buildDetailRow(context, 'Mobile Number', item.mobileNo),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildInfoSection(context, 'Identity', Icons.badge_rounded, [
                    _buildDetailRow(context, 'Aadhaar Card', item.aadhaarNo),
                  ]),
                  const SizedBox(height: 16),
                  _buildInfoSection(
                    context,
                    'Residential Address',
                    Icons.location_on_rounded,
                    [
                      _buildDetailRow(context, 'Village/Mohalla', item.village),
                      _buildDetailRow(context, 'Tehsil', item.tehsil),
                      _buildDetailRow(context, 'District', item.district),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: FilledButton.icon(
                      onPressed: onEdit,
                      icon: const Icon(Icons.edit_outlined),
                      label: const Text('Edit Details'),
                      style: FilledButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final hasPhoto = item.studentImage.startsWith('http');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24),
      color: scheme.primary,
      child: Column(
        children: [
          CircleAvatar(
            radius: 46,
            backgroundColor: scheme.onPrimary.withValues(alpha: 0.2),
            backgroundImage: hasPhoto ? NetworkImage(item.studentImage) : null,
            child: hasPhoto
                ? null
                : Icon(Icons.person_rounded, size: 46, color: scheme.onPrimary),
          ),
          const SizedBox(height: 12),
          Text(
            item.name.trim().isEmpty ? '—' : item.name,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleLarge?.copyWith(
              color: scheme.onPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'STUDENT ID: ${item.sid.trim().isEmpty ? '—' : item.sid}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: scheme.onPrimary.withValues(alpha: 0.8),
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(
    BuildContext context,
    String title,
    IconData icon,
    List<Widget> children,
  ) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: scheme.primary),
              const SizedBox(width: 10),
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: scheme.primary,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1),
          ),
          ...children,
        ],
      ),
    );
  }

  /// Renders a label/value row. Shows an em dash when the server sent no
  /// value, so an empty field reads as "not recorded" rather than as data.
  Widget _buildDetailRow(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final hasValue = value.trim().isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          Flexible(
            child: Text(
              hasValue ? value : '—',
              textAlign: TextAlign.end,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: hasValue ? FontWeight.w800 : FontWeight.w500,
                color: hasValue ? scheme.onSurface : scheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
