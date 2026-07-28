import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/season_update_controller.dart';

class SeasonUpdateScreen extends StatelessWidget {
  const SeasonUpdateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final SeasonUpdateController c = Get.put(SeasonUpdateController());
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: scheme.surfaceContainerLowest,
      appBar: AppBar(
        title: const Text('Student Section Update'),
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
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
                return const Center(child: Text('No students found.'));
              }
              return c.viewMode.value == 'table'
                  ? _SeasonUpdateTableView(controller: c)
                  : _SeasonUpdateCardView(controller: c);
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar(BuildContext context, SeasonUpdateController c) {
    return Container(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 8),
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildFilterItem(
                  context,
                  'Session *',
                  c.selectedSession,
                  c.sessions,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildFilterItem(
                  context,
                  'Group *',
                  c.selectedGroup,
                  c.groups,
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
                  'Class *',
                  c.selectedClass,
                  c.classes,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildFilterItem(
                  context,
                  'Records',
                  c.selectedRecords,
                  c.recordsOptions,
                ),
              ),
            ],
          ),
          // Exam Type & percentage range only apply to result-based records.
          Obx(() {
            if (c.selectedRecords.value == 'WITHOUT RESULT') {
              return const SizedBox.shrink();
            }
            return Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Row(
                children: [
                  Expanded(
                    child: _buildFilterItem(
                      context,
                      'Exam Type',
                      c.selectedExamType,
                      c.examTypes,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            context,
                            '% From',
                            c.percentFrom,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildTextField(context, '% To', c.percentTo),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 46,
                  child: TextField(
                    onChanged: (v) => c.searchText.value = v,
                    decoration: InputDecoration(
                      labelText: 'SearchText (Optional)',
                      hintText: 'SID, Name, Mobile',
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
                onPressed: c.fetchStudents,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade700,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
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
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: c.updateSection,
                  icon: const Icon(Icons.update, size: 18),
                  label: const Text('Update Section'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade800,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
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
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).dividerColor),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                value: items.contains(value.value) ? value.value : null,
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
                onChanged: (v) => value.value = v ?? '',
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(
    BuildContext context,
    String label,
    RxString value,
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
        SizedBox(
          height: 46,
          child: TextField(
            onChanged: (v) => value.value = v,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            style: const TextStyle(fontSize: 13),
          ),
        ),
      ],
    );
  }
}

class _SeasonUpdateTableView extends StatelessWidget {
  final SeasonUpdateController controller;
  const _SeasonUpdateTableView({required this.controller});

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
              DataColumn(
                label: Row(
                  children: [
                    Checkbox(
                      value: controller.selectAll.value,
                      onChanged: controller.toggleSelectAll,
                      side: const BorderSide(color: Colors.white, width: 1.5),
                    ),
                    Text('S.No.', style: headerStyle),
                  ],
                ),
              ),
              DataColumn(label: Text('SID', style: headerStyle)),
              DataColumn(label: Text('Group', style: headerStyle)),
              DataColumn(label: Text('Class', style: headerStyle)),
              DataColumn(label: Text('Session', style: headerStyle)),
              DataColumn(label: Text('Status', style: headerStyle)),
              DataColumn(label: Text('Updated Class', style: headerStyle)),
              DataColumn(label: Text('Date Of Update', style: headerStyle)),
              DataColumn(label: Text('Name', style: headerStyle)),
              DataColumn(label: Text('Father Name', style: headerStyle)),
              DataColumn(label: Text('Mother Name', style: headerStyle)),
              DataColumn(label: Text('MobileNo', style: headerStyle)),
            ],
            rows: List.generate(controller.students.length, (index) {
              final item = controller.students[index];
              return DataRow(
                cells: [
                  DataCell(
                    Row(
                      children: [
                        Obx(
                          () => item.status.value == 'Not Updated'
                              ? Checkbox(
                                  value: item.isSelected.value,
                                  onChanged: (v) =>
                                      item.isSelected.value = v ?? false,
                                )
                              : const SizedBox(width: 48),
                        ),
                        Text((index + 1).toString(), style: cellStyle),
                      ],
                    ),
                  ),
                  DataCell(Text(item.sid, style: cellStyle)),
                  DataCell(Text(item.group, style: cellStyle)),
                  DataCell(Text(item.className, style: cellStyle)),
                  DataCell(Text(item.session, style: cellStyle)),
                  DataCell(
                    Obx(() {
                      final isUpdated = item.status.value == 'Updated';
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isUpdated
                              ? Colors.teal.shade50
                              : Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          item.status.value,
                          style: cellStyle.copyWith(
                            color: isUpdated ? Colors.teal : Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    }),
                  ),
                  DataCell(
                    Obx(() => Text(item.updatedClass.value, style: cellStyle)),
                  ),
                  DataCell(
                    Obx(() => Text(item.updateDate.value, style: cellStyle)),
                  ),
                  DataCell(Text(item.name, style: cellStyle)),
                  DataCell(Text(item.fatherName, style: cellStyle)),
                  DataCell(Text(item.motherName, style: cellStyle)),
                  DataCell(Text(item.mobileNo, style: cellStyle)),
                ],
              );
            }),
          ),
        ),
      );
    });
  }
}

class _SeasonUpdateCardView extends StatelessWidget {
  final SeasonUpdateController controller;
  const _SeasonUpdateCardView({required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Obx(() {
      final fontSize = controller.baseFontSize.value;

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: controller.students.length,
        itemBuilder: (context, index) {
          final item = controller.students[index];
          return Card(
            elevation: 0,
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: theme.dividerColor),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Obx(
                        () => item.status.value == 'Not Updated'
                            ? Checkbox(
                                value: item.isSelected.value,
                                onChanged: (v) =>
                                    item.isSelected.value = v ?? false,
                              )
                            : const SizedBox(width: 8),
                      ),
                      const SizedBox(width: 8),
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
                              'SID: ${item.sid} | Group: ${item.group}',
                              style: TextStyle(
                                fontSize: fontSize - 2,
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Obx(() {
                        final isUpdated = item.status.value == 'Updated';
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: isUpdated
                                ? Colors.teal.shade50
                                : Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            item.status.value,
                            style: TextStyle(
                              fontSize: fontSize - 2,
                              color: isUpdated ? Colors.teal : Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                  const Divider(height: 24),
                  _buildCardRow(
                    'Current',
                    '${item.session} | Class ${item.className}',
                    fontSize,
                    scheme,
                  ),
                  Obx(
                    () => item.status.value == 'Updated'
                        ? _buildCardRow(
                            'Updated To',
                            'Class ${item.updatedClass.value} on ${item.updateDate.value}',
                            fontSize,
                            scheme,
                          )
                        : const SizedBox.shrink(),
                  ),
                  _buildCardRow(
                    'Parents',
                    '${item.fatherName} / ${item.motherName}',
                    fontSize,
                    scheme,
                  ),
                  _buildCardRow('Mobile', item.mobileNo, fontSize, scheme),
                ],
              ),
            ),
          );
        },
      );
    });
  }

  Widget _buildCardRow(
    String label,
    String value,
    double fontSize,
    ColorScheme scheme,
  ) {
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
                color: scheme.onSurfaceVariant,
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
