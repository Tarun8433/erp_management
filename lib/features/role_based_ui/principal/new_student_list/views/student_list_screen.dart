import 'package:erp_management/core/constants/app_colors.dart';
import 'package:erp_management/features/role_based_ui/principal/new_student_list/controllers/student_list_controller.dart';
import 'package:erp_management/features/role_based_ui/principal/new_student_list/views/edit_student_screen.dart';
import 'package:erp_management/features/role_based_ui/principal/new_student_list/views/student_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class StudentListScreen extends StatelessWidget {
  const StudentListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final StudentListController c = Get.put(StudentListController());
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: scheme.surfaceContainerLowest,
        appBar: AppBar(
          title: const Text('Student List'),
          centerTitle: false,
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => Get.back(),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.text_decrease),
              onPressed: () => c.updateFontSize(-1),
              tooltip: 'Decrease Font Size',
            ),
            IconButton(
              icon: const Icon(Icons.text_increase),
              onPressed: () => c.updateFontSize(1),
              tooltip: 'Increase Font Size',
            ),
            Obx(
              () => IconButton(
                icon: Icon(
                  c.viewMode.value == 'table'
                      ? Icons.grid_view_rounded
                      : Icons.table_chart_rounded,
                ),
                onPressed: c.toggleViewMode,
                tooltip: 'Toggle View Mode',
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            _buildFilterBar(context, c),
            Expanded(
              child: Obx(() {
                if (c.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (c.students.isEmpty) {
                  return _buildEmptyState(context);
                }

                return c.viewMode.value == 'table'
                    ? _StudentTableView(controller: c)
                    : _StudentCardView(controller: c);
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterBar(BuildContext context, StudentListController c) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      color: scheme.surface,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildFilterItem(
                  context,
                  'Session',
                  c.selectedSession,
                  c.sessionYearList,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildFilterItem(
                  context,
                  'Group',
                  c.selectedGroup,
                  c.groupList,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildFilterItem(
                  context,
                  'Class',
                  c.selectedClass,
                  c.classList,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildFilterItem(context, 'Status', c.selectedStatus, [
                  'All',
                  'Active',
                  'Inactive',
                ]),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  onChanged: c.filterStudents,
                  decoration: _getInputDecoration(
                    context,
                    'Search by name/aadhar name/mobile no,SID,SRNO',
                    Icons.search_rounded,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Horizontal "Menu Bar" of Action Buttons
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildActionBarButton(
                    context,
                    Icons.search,
                    Colors.blue.shade700,
                    () => c.searchStudents(),
                    tooltip: 'Search',
                  ),
                  // const SizedBox(width: 8),
                  // _buildActionBarButton(
                  //   context,
                  //   Icons.grid_on_rounded,
                  //   Colors.orange.shade700,
                  //   () {},
                  //   tooltip: 'Export Excel',
                  // ),
                  // const SizedBox(width: 8),
                  // _buildActionBarButton(
                  //   context,
                  //   Icons.copy_rounded,
                  //   Colors.teal.shade700,
                  //   () {},
                  //   tooltip: 'Copy',
                  // ),
                  // const SizedBox(width: 8),
                  // _buildActionBarButton(
                  //   context,
                  //   Icons.delete_sweep_rounded,
                  //   Colors.red.shade700,
                  //   () {},
                  //   tooltip: 'Clear',
                  // ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionBarButton(
    BuildContext context,
    IconData icon,
    Color color,
    VoidCallback onTap, {
    String? tooltip,
  }) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Tooltip(
            message: tooltip ?? '',
            child: Icon(icon, color: Colors.white, size: 20),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterItem(
    BuildContext context,
    String label,
    RxString value,
    List<String> items,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Obx(
          () => Container(
            width: double.infinity,
            height: 46,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).dividerColor),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                value: value.value.isEmpty ? null : value.value,
                hint: Text(
                  'Select',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                items: items
                    .map(
                      (e) => DropdownMenuItem(
                        value: e,
                        child: Text(
                          e,
                          style: Theme.of(context).textTheme.bodySmall,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (v) => value.value = v!,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person_search_rounded,
            size: 64,
            color: scheme.primary.withValues(alpha: 0.1),
          ),
          const SizedBox(height: 16),
          Text(
            'No records found',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            'Select filters and click search to load students',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _StudentTableView extends StatelessWidget {
  final StudentListController controller;
  const _StudentTableView({required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Obx(() {
      final fontSize = controller.baseFontSize.value;
      final headerStyle = TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
        color: scheme.onPrimary,
      );
      final cellStyle = TextStyle(fontSize: fontSize);

      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SingleChildScrollView(
          child: DataTable(
            headingRowColor: WidgetStateProperty.all(
              scheme.primary.withValues(alpha: 0.9),
            ),
            dataRowMaxHeight: 60,
            columnSpacing: 24,
            border: TableBorder.all(color: theme.dividerColor, width: 0.5),
            columns: [
              DataColumn(label: Text('S.No.', style: headerStyle)),
              DataColumn(label: Text('Action', style: headerStyle)),
              DataColumn(label: Text('SID', style: headerStyle)),
              DataColumn(label: Text('EEN', style: headerStyle)),
              DataColumn(label: Text('Group', style: headerStyle)),
              DataColumn(label: Text('Class', style: headerStyle)),
              DataColumn(label: Text('Name', style: headerStyle)),
              DataColumn(label: Text('Status', style: headerStyle)),
              DataColumn(label: Text('Father Name', style: headerStyle)),
              DataColumn(label: Text('Mother Name', style: headerStyle)),
              DataColumn(label: Text('MobileNo', style: headerStyle)),
              DataColumn(label: Text('District', style: headerStyle)),
              DataColumn(label: Text('Tehsil', style: headerStyle)),
              DataColumn(label: Text('VillageOrMohalla', style: headerStyle)),
              DataColumn(label: Text('DOB', style: headerStyle)),
              DataColumn(label: Text('Image', style: headerStyle)),
              DataColumn(label: Text('Finished Image', style: headerStyle)),
              DataColumn(label: Text('SRNO', style: headerStyle)),
              DataColumn(label: Text('Religion', style: headerStyle)),
              DataColumn(label: Text('Category', style: headerStyle)),
              DataColumn(label: Text('SubCategory', style: headerStyle)),
              DataColumn(label: Text('Gender', style: headerStyle)),
              DataColumn(label: Text('Aadhar No', style: headerStyle)),
              DataColumn(label: Text('Pen No', style: headerStyle)),
              DataColumn(label: Text('Apaar Id', style: headerStyle)),
              DataColumn(label: Text('EntryAt', style: headerStyle)),
            ],
            rows: List.generate(controller.filteredStudents.length, (index) {
              final student = controller.filteredStudents[index];
              return DataRow(
                cells: [
                  DataCell(Text((index + 1).toString(), style: cellStyle)),
                  DataCell(
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.edit,
                            size: 18,
                            color: Colors.blue,
                          ),
                          onPressed: () {
                            controller.prepareEdit(student);
                            Get.to(() => const EditStudentScreen());
                          },
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.remove_red_eye,
                            size: 18,
                            color: Colors.green,
                          ),
                          onPressed: () => Get.to(
                            () => StudentDetailsScreen(student: student),
                          ),
                        ),
                      ],
                    ),
                  ),
                  DataCell(Text(student.sid, style: cellStyle)),
                  DataCell(Text(student.een, style: cellStyle)),
                  DataCell(Text(student.group, style: cellStyle)),
                  DataCell(Text(student.className, style: cellStyle)),
                  DataCell(Text(student.name, style: cellStyle)),
                  DataCell(
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: student.status == 'Active'
                            ? Colors.green.shade50
                            : Colors.red.shade50,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        student.status,
                        style: cellStyle.copyWith(
                          color: student.status == 'Active'
                              ? Colors.green
                              : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  DataCell(Text(student.fatherName, style: cellStyle)),
                  DataCell(Text(student.motherName, style: cellStyle)),
                  DataCell(Text(student.phone, style: cellStyle)),
                  DataCell(Text(student.district, style: cellStyle)),
                  DataCell(Text(student.tehsil, style: cellStyle)),
                  DataCell(Text(student.village, style: cellStyle)),
                  DataCell(Text(student.dob, style: cellStyle)),
                  DataCell(
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: scheme.surfaceContainerHighest,
                      backgroundImage: student.photoUrl.startsWith('http')
                          ? NetworkImage(student.photoUrl)
                          : null,
                      child: student.photoUrl.startsWith('http')
                          ? null
                          : Icon(
                              Icons.person_rounded,
                              size: 18,
                              color: scheme.onSurfaceVariant,
                            ),
                    ),
                  ),
                  DataCell(
                    Image.network(
                      student.finishedImage,
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          const Icon(Icons.image_not_supported),
                    ),
                  ),
                  DataCell(Text(student.srNo, style: cellStyle)),
                  DataCell(Text(student.religion, style: cellStyle)),
                  DataCell(Text(student.category, style: cellStyle)),
                  DataCell(Text(student.subCategory, style: cellStyle)),
                  DataCell(Text(student.gender, style: cellStyle)),
                  DataCell(Text(student.aadhaar, style: cellStyle)),
                  DataCell(Text(student.penNo, style: cellStyle)),
                  DataCell(Text(student.apaarId, style: cellStyle)),
                  DataCell(Text(student.entryAt, style: cellStyle)),
                ],
              );
            }),
          ),
        ),
      );
    });
  }
}

class _StudentCardView extends StatelessWidget {
  final StudentListController controller;
  const _StudentCardView({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final fontSize = controller.baseFontSize.value;

      return ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: controller.filteredStudents.length,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final student = controller.filteredStudents[index];
          return _StudentProfileCard(
            student: student,
            controller: controller,
            fontSize: fontSize,
          );
        },
      );
    });
  }
}

class _StudentProfileCard extends StatelessWidget {
  final Student student;
  final StudentListController controller;
  final double fontSize;

  const _StudentProfileCard({
    required this.student,
    required this.controller,
    required this.fontSize,
  });

  bool get _isActive => student.status == 'Active';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.dividerColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        child: Column(
          children: [
            _buildHeader(context, scheme),
            const SizedBox(height: 12),
            Text(
              student.name.isEmpty ? 'Unknown' : student.name.toUpperCase(),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: fontSize + 6,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.3,
                color: scheme.onSurface,
              ),
            ),
            Divider(height: 24, color: theme.dividerColor),
            _buildDetails(context, scheme),
            const SizedBox(height: 16),
            _buildViewDetailsButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ColorScheme scheme) {
    return SizedBox(
      height: 96,
      child: Stack(
        children: [
          // SID + Gender (top-left)
          Align(
            alignment: Alignment.topLeft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SID: ${student.sid.isEmpty ? '—' : student.sid}',
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.bold,
                    color: scheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  student.gender.isEmpty ? '—' : student.gender,
                  style: TextStyle(
                    fontSize: fontSize - 1,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          // Status badge (top-right)
          Align(
            alignment: Alignment.topRight,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: _isActive ? Colors.green.shade50 : Colors.red.shade50,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _isActive
                      ? Colors.green.shade200
                      : Colors.red.shade200,
                ),
              ),
              child: Text(
                student.status,
                style: TextStyle(
                  fontSize: fontSize - 1,
                  color: _isActive ? Colors.green.shade700 : Colors.red.shade700,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          // Avatar + update-photo button (centered)
          Align(
            alignment: Alignment.topCenter,
            child: _buildAvatar(context, scheme),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(BuildContext context, ColorScheme scheme) {
    return Obx(() {
      final localPhoto = controller.updatedPhotos[student.id];
      final hasNetwork = student.photoUrl.startsWith('http');
      final ImageProvider? image = localPhoto != null
          ? FileImage(localPhoto)
          : (hasNetwork ? NetworkImage(student.photoUrl) : null);

      return SizedBox(
        width: 92,
        height: 92,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: scheme.primary, width: 2),
              ),
              child: CircleAvatar(
                radius: 42,
                backgroundColor: scheme.surfaceContainerHighest,
                backgroundImage: image,
                onBackgroundImageError: image != null ? (_, __) {} : null,
                child: image == null
                    ? Icon(
                        Icons.person_rounded,
                        size: 40,
                        color: scheme.onSurfaceVariant,
                      )
                    : null,
              ),
            ),
            // Update photo button
            Positioned(
              right: -2,
              top: -2,
              child: GestureDetector(
                onTap: () => controller.updatePhoto(context, student),
                child: Tooltip(
                  message: 'Update Photo',
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: scheme.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: scheme.surface, width: 2),
                    ),
                    child: Icon(
                      Icons.camera_alt_rounded,
                      size: 15,
                      color: scheme.onPrimary,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildDetails(BuildContext context, ColorScheme scheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Parent row with an inline edit pencil for quick editing.
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _row(
                'PARENT',
                'Mr. ${student.fatherName.isEmpty ? '—' : student.fatherName}'
                    '   Mrs. ${student.motherName.isEmpty ? '—' : student.motherName}',
                scheme,
              ),
            ),
            InkWell(
              onTap: () {
                controller.prepareEdit(student);
                Get.to(() => const EditStudentScreen());
              },
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: scheme.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.edit_outlined,
                  size: fontSize + 4,
                  color: scheme.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _row('CLASS', '${student.className} - ${student.group}', scheme),
        _row('MOBILE', student.phone, scheme),
        _row('VILLAGE', student.village, scheme),
        _row('TEHSIL', student.tehsil, scheme),
        _row('DISTRICT', student.district, scheme),
        _row('STATE', student.state, scheme),
        _row('PIN CODE', student.pinCode, scheme),
      ],
    );
  }

  Widget _row(String label, String value, ColorScheme scheme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 96,
            child: Text(
              label,
              style: TextStyle(
                fontSize: fontSize - 1,
                fontWeight: FontWeight.w600,
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value.trim().isEmpty ? '—' : value,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w500,
                color: scheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildViewDetailsButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => Get.to(() => StudentDetailsScreen(student: student)),
        icon: Icon(Icons.visibility_outlined, size: fontSize + 4),
        label: Text(
          'View Details',
          style: TextStyle(
            fontSize: fontSize + 2,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}

InputDecoration _getInputDecoration(
  BuildContext context,
  String label,
  IconData icon,
) {
  final theme = Theme.of(context);
  final scheme = theme.colorScheme;
  return InputDecoration(
    labelText: label,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: theme.dividerColor),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: theme.dividerColor),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: scheme.primary, width: 1.4),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
    isDense: true,
    prefixIcon: Icon(icon, size: 20),
  );
}
