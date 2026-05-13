import 'package:erp_management/core/widgets/searchable_dropdown.dart';
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
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 900;
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
                  const SizedBox(width: 8),
                  _buildActionBarButton(
                    context,
                    Icons.grid_on_rounded,
                    Colors.orange.shade700,
                    () {},
                    tooltip: 'Export Excel',
                  ),
                  const SizedBox(width: 8),
                  _buildActionBarButton(
                    context,
                    Icons.copy_rounded,
                    Colors.teal.shade700,
                    () {},
                    tooltip: 'Copy',
                  ),
                  const SizedBox(width: 8),
                  _buildActionBarButton(
                    context,
                    Icons.delete_sweep_rounded,
                    Colors.red.shade700,
                    () {},
                    tooltip: 'Clear',
                  ),
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
            height: 46,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value.value.isEmpty
                    ? (items.isNotEmpty ? items[0] : null)
                    : value.value,
                items: items
                    .map(
                      (e) => DropdownMenuItem(
                        value: e,
                        child: Text(e, style: const TextStyle(fontSize: 13)),
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
          const Text(
            'No records found',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          const Text('Select filters and click search to load students'),
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
    final scheme = Theme.of(context).colorScheme;

    return Obx(() {
      final fontSize = controller.baseFontSize.value;
      final headerStyle = TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
        color: Colors.white,
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
            border: TableBorder.all(color: Colors.grey.shade200, width: 0.5),
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
                      backgroundImage: NetworkImage(student.photoUrl),
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
    final scheme = Theme.of(context).colorScheme;

    return Obx(() {
      final fontSize = controller.baseFontSize.value;

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: controller.filteredStudents.length,
        itemBuilder: (context, index) {
          final student = controller.filteredStudents[index];
          return Card(
            elevation: 0,
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Colors.grey.shade200),
            ),
            child: InkWell(
              onTap: () => Get.to(() => StudentDetailsScreen(student: student)),
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 26,
                          backgroundImage: NetworkImage(student.photoUrl),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                student.name,
                                style: TextStyle(
                                  fontSize: fontSize + 2,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'SID: ${student.sid} | SR No: ${student.srNo}',
                                style: TextStyle(
                                  fontSize: fontSize - 2,
                                  color: scheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: student.status == 'Active'
                                ? Colors.green.shade50
                                : Colors.red.shade50,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            student.status,
                            style: TextStyle(
                              fontSize: fontSize - 2,
                              color: student.status == 'Active'
                                  ? Colors.green
                                  : Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    _buildCardRow(
                      'Parents',
                      '${student.fatherName} / ${student.motherName}',
                      fontSize,
                    ),
                    _buildCardRow(
                      'Class/Group',
                      '${student.className} - ${student.group}',
                      fontSize,
                    ),
                    _buildCardRow('Mobile', student.phone, fontSize),
                    _buildCardRow('Aadhaar', student.aadhaar, fontSize),
                    _buildCardRow('Religion', student.religion, fontSize),
                    _buildCardRow('Category', student.category, fontSize),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.edit,
                            size: 20,
                            color: Colors.blue,
                          ),
                          onPressed: () {
                            controller.prepareEdit(student);
                            Get.to(() => const EditStudentScreen());
                          },
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () => Get.to(
                            () => StudentDetailsScreen(student: student),
                          ),
                          child: const Text('View Details'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    });
  }

  Widget _buildCardRow(String label, String value, double fontSize) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontSize: fontSize - 1,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: fontSize - 1,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
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
