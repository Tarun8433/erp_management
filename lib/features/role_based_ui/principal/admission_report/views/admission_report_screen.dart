import 'package:erp_management/features/role_based_ui/principal/admission_report/controllers/admission_report_controller.dart';
import 'package:erp_management/features/role_based_ui/principal/admission_report/views/admission_report_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Opens the read-only detail view for [item]; its edit action reuses the
/// same pre-filled admission form as the list's edit icon.
void _openDetails(AdmissionReportController c, AdmissionReportItem item) {
  Get.to(
    () => AdmissionReportDetailsScreen(
      item: item,
      onEdit: () => c.openForEdit(item.id),
    ),
  );
}

class AdmissionReportScreen extends StatelessWidget {
  const AdmissionReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AdmissionReportController c = Get.put(AdmissionReportController());
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: scheme.surfaceContainerLowest,
      appBar: AppBar(
        title: const Text('New Admission Report'),
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
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
          // IconButton(
          //   icon: const Icon(Icons.settings_outlined),
          //   onPressed: () => _showSettingsDialog(context, c),
          //   tooltip: 'Report Settings',
          // ),
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
              if (c.reportItems.isEmpty) {
                return const Center(child: Text('No records found.'));
              }
              return c.viewMode.value == 'table'
                  ? _ReportTableView(controller: c)
                  : _ReportCardView(controller: c);
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar(BuildContext context, AdmissionReportController c) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 900;

    return Container(
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        spacing: 12,
        children: [
          // Row 1: Session | From Date | To Date
          Obx(() => Row(
                children: [
                  Expanded(
                    child: _buildFilterItem(
                      context,
                      'Session',
                      c.selectedSession,
                      c.sessions.toList(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildDateField(
                      context,
                      'From Date',
                      c.fromDateText,
                      () => c.pickFromDate(context),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildDateField(
                      context,
                      'To Date',
                      c.toDateText,
                      () => c.pickToDate(context),
                    ),
                  ),
                ],
              )),
          // Row 2: Group | Class (default ALL GROUP / ALL CLASS)
          Obx(() => Row(
                children: [
                  Expanded(
                    child: _buildFilterItem(
                      context,
                      'Group',
                      c.selectedGroup,
                      c.groups.toList(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildFilterItem(
                      context,
                      'Class',
                      c.selectedClass,
                      c.classes.toList(),
                    ),
                  ),
                ],
              )),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 46,
                  width: isMobile ? double.infinity : 300,
                  child: TextField(
                    onChanged: (v) => c.searchText.value = v,
                    decoration: InputDecoration(
                      labelText: 'Search Text',
                      hintText: 'Search by name/father name/mobile...',
                      prefixIcon: const Icon(Icons.search),
                      isDense: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: c.fetchReport,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Icon(Icons.search),
              ),
            ],
          ),
        ],
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
            width: Get.width,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                value: value.value.isEmpty ? null : value.value,
                hint: const Text('Select', style: TextStyle(fontSize: 13)),
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

  Widget _buildDateField(
    BuildContext context,
    String label,
    String value,
    VoidCallback onTap,
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
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            height: 46,
            width: Get.width,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value,
                    style: const TextStyle(fontSize: 13),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(
                  Icons.calendar_today_outlined,
                  size: 16,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ReportTableView extends StatelessWidget {
  final AdmissionReportController controller;
  const _ReportTableView({required this.controller});

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
              DataColumn(label: Text('Group', style: headerStyle)),
              DataColumn(label: Text('Class', style: headerStyle)),
              DataColumn(label: Text('AadharNo', style: headerStyle)),
              DataColumn(label: Text('Name', style: headerStyle)),
              DataColumn(label: Text('Status', style: headerStyle)),
              DataColumn(label: Text('Form', style: headerStyle)),
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
              DataColumn(label: Text('EntryAt', style: headerStyle)),
            ],
            rows: controller.reportItems
                .map(
                  (item) => DataRow(
                    cells: [
                      DataCell(Text(item.sNo.toString(), style: cellStyle)),
                      DataCell(
                        IconButton(
                          icon: const Icon(
                            Icons.edit_outlined,
                            size: 18,
                            color: Colors.blue,
                          ),
                          tooltip: 'Edit',
                          onPressed: () => controller.openForEdit(item.id),
                        ),
                      ),
                      DataCell(Text(item.sid, style: cellStyle)),
                      DataCell(Text(item.group, style: cellStyle)),
                      DataCell(Text(item.className, style: cellStyle)),
                      DataCell(Text(item.aadhaarNo, style: cellStyle)),
                      DataCell(Text(item.name, style: cellStyle)),
                      DataCell(
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.teal.shade50,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            item.status,
                            style: cellStyle.copyWith(
                              color: Colors.teal,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      DataCell(
                        ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.download, size: 14),
                          label: const Text(
                            'Download',
                            style: TextStyle(fontSize: 10),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                          ),
                        ),
                      ),
                      DataCell(Text(item.fatherName, style: cellStyle)),
                      DataCell(Text(item.motherName, style: cellStyle)),
                      DataCell(Text(item.mobileNo, style: cellStyle)),
                      DataCell(Text(item.district, style: cellStyle)),
                      DataCell(Text(item.tehsil, style: cellStyle)),
                      DataCell(Text(item.village, style: cellStyle)),
                      DataCell(Text(item.dob, style: cellStyle)),
                      DataCell(
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: Colors.grey.shade200,
                          backgroundImage: item.studentImage.startsWith('http')
                              ? NetworkImage(item.studentImage)
                              : null,
                          child: item.studentImage.startsWith('http')
                              ? null
                              : const Icon(
                                  Icons.person_rounded,
                                  size: 18,
                                  color: Colors.grey,
                                ),
                        ),
                      ),
                      DataCell(
                        Image.network(
                          item.finishedImage,
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              const Icon(Icons.image_not_supported),
                        ),
                      ),
                      DataCell(Text(item.srNo, style: cellStyle)),
                      DataCell(Text(item.religion, style: cellStyle)),
                      DataCell(Text(item.category, style: cellStyle)),
                      DataCell(Text(item.subCategory, style: cellStyle)),
                      DataCell(Text(item.gender, style: cellStyle)),
                      DataCell(Text(item.entryAt, style: cellStyle)),
                    ],
                  ),
                )
                .toList(),
          ),
        ),
      );
    });
  }
}

class _ReportCardView extends StatelessWidget {
  final AdmissionReportController controller;
  const _ReportCardView({required this.controller});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Obx(() {
      final fontSize = controller.baseFontSize.value;

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: controller.reportItems.length,
        itemBuilder: (context, index) {
          final item = controller.reportItems[index];
          return Card(
            elevation: 0,
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey.shade200),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: Colors.grey.shade200,
                        backgroundImage: item.studentImage.startsWith('http')
                            ? NetworkImage(item.studentImage)
                            : null,
                        child: item.studentImage.startsWith('http')
                            ? null
                            : const Icon(
                                Icons.person_rounded,
                                color: Colors.grey,
                              ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.name,
                              style: TextStyle(
                                fontSize: fontSize + 2,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'SID: ${item.sid} | SR No: ${item.srNo}',
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
                          color: Colors.teal.shade50,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          item.status,
                          style: TextStyle(
                            fontSize: fontSize - 2,
                            color: Colors.teal,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  _buildCardRow(
                    'Parents',
                    '${item.fatherName} / ${item.motherName}',
                    fontSize,
                  ),
                  _buildCardRow(
                    'Class/Group',
                    '${item.className} - ${item.group}',
                    fontSize,
                  ),
                  _buildCardRow('Mobile', item.mobileNo, fontSize),
                  _buildCardRow('Aadhaar', item.aadhaarNo, fontSize),
                  _buildCardRow('Religion', item.religion, fontSize),
                  _buildCardRow(
                    'Category',
                    '${item.category} (${item.subCategory})',
                    fontSize,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // TextButton.icon(
                      //   onPressed: () {},
                      //   icon: const Icon(Icons.download, size: 18),
                      //   label: const Text('Form'),
                      // ),
                      // const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _openDetails(controller, item),
                          child: const Text('View Details'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(
                          Icons.edit_outlined,
                          size: 20,
                          color: Colors.blue,
                        ),
                        tooltip: 'Edit',
                        onPressed: () => controller.openForEdit(item.id),
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
