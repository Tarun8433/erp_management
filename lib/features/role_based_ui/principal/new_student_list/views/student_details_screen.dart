import 'package:erp_management/features/role_based_ui/principal/new_student_list/controllers/student_list_controller.dart';
import 'package:flutter/material.dart';

class StudentDetailsScreen extends StatelessWidget {
  final Student student;
  const StudentDetailsScreen({super.key, required this.student});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: scheme.surfaceContainerLowest,
      appBar: AppBar(
        title: const Text('Student Profile'),
        centerTitle: false,
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(context),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildInfoSection(context, 'Academic Information', Icons.school_rounded, [
                    _buildDetailRow(context, 'Student ID', student.sid),
                    _buildDetailRow(context, 'SR Number', student.srNo),
                    _buildDetailRow(context, 'Roll Number', student.rollNo),
                    _buildDetailRow(context, 'Session', student.session),
                    _buildDetailRow(context, 'Academic Group', student.group),
                    _buildDetailRow(context, 'Current Class', student.className),
                    _buildDetailRow(context, 'Status', student.status),
                    _buildDetailRow(context, 'Admitted On', student.entryAt),
                  ]),
                  const SizedBox(height: 16),
                  _buildInfoSection(context, 'Personal Details', Icons.person_rounded, [
                    _buildDetailRow(context, 'Gender', student.gender),
                    _buildDetailRow(context, 'Date of Birth', student.dob),
                    _buildDetailRow(context, 'Religion', student.religion),
                    _buildDetailRow(context, 'Category', student.category),
                    _buildDetailRow(context, 'Sub Category', student.subCategory),
                  ]),
                  const SizedBox(height: 16),
                  _buildInfoSection(context, 'Parent Details', Icons.family_restroom_rounded, [
                    _buildDetailRow(context, 'Father\'s Name', student.fatherName),
                    _buildDetailRow(context, 'Father\'s Occupation', student.fatherOccupation),
                    _buildDetailRow(context, 'Father\'s Mobile', student.phone),
                    _buildDetailRow(context, 'Mother\'s Name', student.motherName),
                    _buildDetailRow(context, 'Mother\'s Occupation', student.motherOccupation),
                    _buildDetailRow(context, 'Mother\'s Mobile', student.motherMobile),
                  ]),
                  const SizedBox(height: 16),
                  _buildInfoSection(context, 'Identity & Contact', Icons.badge_rounded, [
                    _buildDetailRow(context, 'Email Address', student.email),
                    _buildDetailRow(context, 'Aadhaar Card', student.aadhaar),
                    _buildDetailRow(context, 'PEN Number', student.penNo),
                    _buildDetailRow(context, 'APAAR ID', student.apaarId),
                  ]),
                  const SizedBox(height: 16),
                  _buildInfoSection(context, 'Residential Address', Icons.location_on_rounded, [
                    _buildDetailRow(context, 'Village/Mohalla', student.village),
                    _buildDetailRow(context, 'Tehsil', student.tehsil),
                    _buildDetailRow(context, 'District', student.district),
                    _buildDetailRow(context, 'State', student.state),
                    _buildDetailRow(context, 'Pin Code', student.pinCode),
                  ]),
                  const SizedBox(height: 40),
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(bottom: 32, top: 16),
      decoration: BoxDecoration(
        color: scheme.primary,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(40)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: scheme.surface,
              shape: BoxShape.circle,
            ),
            child: CircleAvatar(
              radius: 54,
              backgroundColor: scheme.primaryContainer,
              backgroundImage: student.photoUrl.startsWith('http')
                  ? NetworkImage(student.photoUrl)
                  : null,
              child: student.photoUrl.startsWith('http')
                  ? null
                  : Icon(
                      Icons.person_rounded,
                      size: 54,
                      color: scheme.onPrimaryContainer,
                    ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            student.name,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: scheme.onPrimary,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: scheme.onPrimary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'STUDENT ID: ${student.id}',
              style: theme.textTheme.labelSmall?.copyWith(
                color: scheme.onPrimary,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(BuildContext context, String title, IconData icon, List<Widget> children) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.05)),
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
      padding: const EdgeInsets.symmetric(vertical: 8.0),
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
