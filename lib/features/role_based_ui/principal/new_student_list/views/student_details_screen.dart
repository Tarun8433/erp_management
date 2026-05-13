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
                    _buildDetailRow('Roll Number', student.rollNo),
                    _buildDetailRow('Academic Group', student.group),
                    _buildDetailRow('Current Class', student.className),
                  ]),
                  const SizedBox(height: 16),
                  _buildInfoSection(context, 'Personal Details', Icons.person_rounded, [
                    _buildDetailRow('Father\'s Name', student.fatherName),
                    _buildDetailRow('Mother\'s Name', student.motherName),
                    _buildDetailRow('Gender', student.gender),
                    _buildDetailRow('Date of Birth', student.dob),
                    _buildDetailRow('Religion', student.religion),
                  ]),
                  const SizedBox(height: 16),
                  _buildInfoSection(context, 'Identity & Contact', Icons.badge_rounded, [
                    _buildDetailRow('Phone Number', student.phone),
                    _buildDetailRow('Email Address', student.email),
                    _buildDetailRow('Aadhaar Card', student.aadhaar),
                    _buildDetailRow('PAN Number', student.pan),
                  ]),
                  const SizedBox(height: 16),
                  _buildInfoSection(context, 'Residential Address', Icons.location_on_rounded, [
                    _buildDetailRow('Village/Mohalla', student.village),
                    _buildDetailRow('Tehsil', student.tehsil),
                    _buildDetailRow('District', student.district),
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
    final scheme = Theme.of(context).colorScheme;
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
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: CircleAvatar(
              radius: 54,
              backgroundColor: scheme.primaryContainer,
              backgroundImage: NetworkImage(student.photoUrl),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            student.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'STUDENT ID: ${student.id}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
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
        color: Colors.white,
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
