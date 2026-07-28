import 'package:erp_management/features/role_based_ui/principal/missing_images/controllers/missing_images_controller.dart';
import 'package:erp_management/features/role_based_ui/principal/new_student_list/models/student_list_response.dart';
import 'package:erp_management/core/utils/drawer_main/src/flutter_zoom_drawer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MissingImagesScreen extends StatelessWidget {
  const MissingImagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(MissingImagesController());
    final scheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: scheme.surfaceContainerLowest,
        appBar: AppBar(
          title: const Text('Missing Images'),
          centerTitle: false,
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Navigator.of(context).canPop()
                  ? Icons.arrow_back_rounded
                  : Icons.menu_rounded,
            ),
            onPressed: () {
              if (Navigator.of(context).canPop()) {
                Get.back();
              } else {
                ZoomDrawer.of(context)?.toggle();
              }
            },
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
                if (c.allStudents.isEmpty && c.searchText.value.isEmpty) {
                  return _buildEmptyState(
                    context,
                    icon: Icons.group_outlined,
                    message: 'No students found',
                    sub: 'Select filters and tap search to load students',
                  );
                }
                if (c.filteredStudents.isEmpty) {
                  return _buildEmptyState(
                    context,
                    icon: Icons.search_off_rounded,
                    message: 'No results found',
                    sub: 'Try a different search term',
                  );
                }
                return c.viewMode.value == 'table'
                    ? _MissingImagesTableView(controller: c)
                    : _MissingImagesCardView(controller: c);
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterBar(BuildContext context, MissingImagesController c) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      color: scheme.surface,
      child: Column(
        children: [
          _buildFilterItem(
            context,
            'Session',
            c.selectedSession,
            c.sessionYearList,
          ),
          Row(
            children: [
              Expanded(
                child: _buildFilterItem(
                  context,
                  'Group',
                  c.selectedGroup,
                  c.groupList,
                ),
              ),
              const SizedBox(width: 12),

              Expanded(
                child: _buildFilterItem(
                  context,
                  'Class',
                  c.selectedClass,
                  c.classList,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: c.searchCtrl,
                  onChanged: c.onSearch,
                  decoration: _inputDecoration(
                    context,
                    'Search by name / roll no',
                    Icons.search_rounded,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              _buildActionButton(
                context,
                Icons.search,
                Colors.blue.shade700,
                c.fetchMissingImages,
                tooltip: 'Search',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
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
    RxList<String> items,
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
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                value: value.value.isEmpty ? null : value.value,
                hint: Text('Select $label', style: const TextStyle(fontSize: 13)),
                items: items
                    .map(
                      (e) => DropdownMenuItem(
                        value: e,
                        child: Text(
                          e,
                          style: const TextStyle(fontSize: 13),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (v) {
                  if (v != null) value.value = v;
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(
    BuildContext context, {
    required IconData icon,
    required String message,
    required String sub,
  }) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: scheme.primary.withValues(alpha: 0.1)),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(sub),
        ],
      ),
    );
  }
}

// ─── Table View ──────────────────────────────────────────────────────────────

class _MissingImagesTableView extends StatelessWidget {
  final MissingImagesController controller;
  const _MissingImagesTableView({required this.controller});

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
              DataColumn(label: Text('Upload Photo', style: headerStyle)),
              DataColumn(label: Text('SR No', style: headerStyle)),
              DataColumn(label: Text('Name', style: headerStyle)),
              DataColumn(label: Text('Roll No', style: headerStyle)),
              DataColumn(label: Text('Group', style: headerStyle)),
              DataColumn(label: Text('Class', style: headerStyle)),
              DataColumn(label: Text('Father Name', style: headerStyle)),
              DataColumn(label: Text('Mother Name', style: headerStyle)),
              DataColumn(label: Text('Mobile No', style: headerStyle)),
              DataColumn(label: Text('DOB', style: headerStyle)),
              DataColumn(label: Text('District', style: headerStyle)),
              DataColumn(label: Text('Tehsil', style: headerStyle)),
              DataColumn(label: Text('Village/Mohalla', style: headerStyle)),
            ],
            rows: List.generate(controller.filteredStudents.length, (index) {
              final s = controller.filteredStudents[index];
              return DataRow(
                cells: [
                  DataCell(Text((index + 1).toString(), style: cellStyle)),
                  DataCell(
                    IconButton(
                      icon: const Icon(
                        Icons.add_a_photo_rounded,
                        size: 20,
                        color: Colors.blue,
                      ),
                      tooltip: 'Upload Photo',
                      onPressed: () =>
                          _showImagePicker(context, s, controller),
                    ),
                  ),
                  DataCell(Text(s.srno ?? '-', style: cellStyle)),
                  DataCell(
                    Text(
                      '${s.firstName ?? ''} ${s.lastName ?? ''}'.trim(),
                      style: cellStyle,
                    ),
                  ),
                  DataCell(Text(s.rollNumber ?? '-', style: cellStyle)),
                  DataCell(Text(s.groupName ?? '-', style: cellStyle)),
                  DataCell(Text(s.className ?? '-', style: cellStyle)),
                  DataCell(Text(s.fatherName ?? '-', style: cellStyle)),
                  DataCell(Text(s.motherName ?? '-', style: cellStyle)),
                  DataCell(Text(s.fatherMobile ?? '-', style: cellStyle)),
                  DataCell(Text(s.dob ?? '-', style: cellStyle)),
                  DataCell(Text(s.district ?? '-', style: cellStyle)),
                  DataCell(Text(s.tehsil ?? '-', style: cellStyle)),
                  DataCell(Text(s.villageMohalla ?? '-', style: cellStyle)),
                ],
              );
            }),
          ),
        ),
      );
    });
  }
}

// ─── Card View ───────────────────────────────────────────────────────────────

class _MissingImagesCardView extends StatelessWidget {
  final MissingImagesController controller;
  const _MissingImagesCardView({required this.controller});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Obx(() {
      final fontSize = controller.baseFontSize.value;

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: controller.filteredStudents.length,
        itemBuilder: (context, index) {
          final s = controller.filteredStudents[index];
          final name = '${s.firstName ?? ''} ${s.lastName ?? ''}'.trim();

          return Card(
            elevation: 0,
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Colors.grey.shade200),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // ── Header row ──────────────────────────────────────
                  Row(
                    children: [
                      // Photo area — shows image if available, else upload prompt
                      GestureDetector(
                        onTap: () => _showImagePicker(context, s, controller),
                        child: _StudentPhotoWidget(
                          photoUrl: s.photo,
                          size: 52,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name.isEmpty ? '-' : name,
                              style: TextStyle(
                                fontSize: fontSize + 2,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'SR: ${s.srno ?? '-'} | Roll: ${s.rollNumber ?? '-'}',
                              style: TextStyle(
                                fontSize: fontSize - 1,
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Missing photo badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'No Photo',
                          style: TextStyle(
                            fontSize: fontSize - 2,
                            color: Colors.orange.shade700,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  // ── Info rows ────────────────────────────────────────
                  _cardRow(
                    'Class/Group',
                    '${s.className ?? '-'} - ${s.groupName ?? '-'}',
                    fontSize,
                  ),
                  _cardRow('Father', s.fatherName ?? '-', fontSize),
                  _cardRow('Mother', s.motherName ?? '-', fontSize),
                  _cardRow('Mobile', s.fatherMobile ?? '-', fontSize),
                  _cardRow('DOB', s.dob ?? '-', fontSize),
                  _cardRow('District', s.district ?? '-', fontSize),
                  _cardRow('Village', s.villageMohalla ?? '-', fontSize),
                  const SizedBox(height: 12),
                  // ── Action ───────────────────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton.icon(
                        icon: const Icon(Icons.add_a_photo_rounded, size: 16),
                        label: const Text('Upload Photo'),
                        onPressed: () =>
                            _showImagePicker(context, s, controller),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
    });
  }

  Widget _cardRow(String label, String value, double fontSize) {
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

// ─── Student photo widget ─────────────────────────────────────────────────────

class _StudentPhotoWidget extends StatelessWidget {
  final String? photoUrl;
  final double size;
  const _StudentPhotoWidget({required this.photoUrl, required this.size});

  bool get _hasPhoto =>
      photoUrl != null && photoUrl!.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        shape: BoxShape.circle,
        border: Border.all(
          color: scheme.primary.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: ClipOval(
        child: _hasPhoto
            ? Image.network(
                photoUrl!,
                fit: BoxFit.cover,
                width: size,
                height: size,
                errorBuilder: (context, error, stackTrace) => _placeholder(scheme),
                loadingBuilder: (_, child, progress) => progress == null
                    ? child
                    : const Center(
                        child: CircularProgressIndicator(strokeWidth: 1.5),
                      ),
              )
            : _placeholder(scheme),
      ),
    );
  }

  Widget _placeholder(ColorScheme scheme) => Icon(
        Icons.add_a_photo_rounded,
        size: size * 0.45,
        color: scheme.primary.withValues(alpha: 0.7),
      );
}

// ─── Shared helpers ───────────────────────────────────────────────────────────

void _showImagePicker(
  BuildContext context,
  StudentListResponse student,
  MissingImagesController controller,
) {
  final name =
      '${student.firstName ?? ''} ${student.lastName ?? ''}'.trim();

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) {
      final scheme = Theme.of(ctx).colorScheme;
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),

              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: scheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.add_a_photo_rounded,
                      color: scheme.primary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Upload Student Photo',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (name.isNotEmpty)
                          Text(
                            name,
                            style: TextStyle(
                              fontSize: 12,
                              color: scheme.onSurfaceVariant,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Divider(height: 1),
              const SizedBox(height: 16),

              // Option tiles
              _PickerTile(
                icon: Icons.photo_library_rounded,
                iconColor: Colors.purple,
                iconBg: Colors.purple.shade50,
                title: 'Choose from Gallery',
                subtitle: 'Select an existing photo from your device',
                onTap: () => controller.pickFromGallery(student),
              ),
              const SizedBox(height: 12),
              _PickerTile(
                icon: Icons.camera_alt_rounded,
                iconColor: Colors.blue.shade700,
                iconBg: Colors.blue.shade50,
                title: 'Take a Photo',
                subtitle: 'Open camera to capture a new photo',
                onTap: () => controller.pickFromCamera(student),
              ),
              const SizedBox(height: 20),

              // Cancel
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Get.back(),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Cancel'),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

class _PickerTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _PickerTile({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade200),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 26),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

InputDecoration _inputDecoration(
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
