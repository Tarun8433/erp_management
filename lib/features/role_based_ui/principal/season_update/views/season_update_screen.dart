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
      body: Obx(() {
        if (c.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildFilterBar(context, c)),
            if (c.students.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: Text('No students found.')),
              )
            else if (c.viewMode.value == 'table')
              SliverToBoxAdapter(child: _SeasonUpdateTableView(controller: c))
            else
              _SeasonUpdateCardView(controller: c),
          ],
        );
      }),
    );
  }

  Widget _buildFilterBar(BuildContext context, SeasonUpdateController c) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 900;

    return Container(
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        children: [
          _ResponsiveRow(
            children: [
              _buildFilterItem(
                context,
                'Session *',
                c.selectedSession,
                c.sessions,
              ),
              _buildFilterItem(context, 'Group *', c.selectedGroup, c.groups),
              _buildFilterItem(context, 'Class *', c.selectedClass, c.classes),
            ],
          ),
          const SizedBox(height: 12),
          _ResponsiveRow(
            children: [
              _buildFilterItem(
                context,
                'Records',
                c.selectedRecords,
                c.recordsOptions,
              ),
              _buildFilterItem(
                context,
                'Exam Type',
                c.selectedExamType,
                c.examTypes,
              ),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(context, '% From', c.percentFrom),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildTextField(context, '% To', c.percentTo),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  context,
                  'Search Text (Optional)',
                  c.searchText,
                  hint: 'SID, Name, Mobile',
                ),
              ),
              const SizedBox(width: 12),
              _buildActionButton(
                icon: Icons.search,
                color: Colors.blue.shade700,
                onPressed: c.fetchStudents,
              ),
              const SizedBox(width: 8),
              _buildActionButton(
                icon: Icons.update,
                label: 'Update Section',
                color: Colors.blue.shade800,
                onPressed: c.updateSection,
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
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                value: value.value,
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

  Widget _buildTextField(
    BuildContext context,
    String label,
    RxString value, {
    String? hint,
  }) {
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
            decoration: InputDecoration(
              hintText: hint,
              isDense: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
            ),
            style: const TextStyle(fontSize: 13),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    String? label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    if (label == null) {
      return ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          minimumSize: const Size(46, 46),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: EdgeInsets.zero,
        ),
        child: Icon(icon),
      );
    }
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}

class _ResponsiveRow extends StatelessWidget {
  final List<Widget> children;
  const _ResponsiveRow({required this.children});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    if (size.width < 600) {
      return Column(
        children: children
            .map(
              (c) =>
                  Padding(padding: const EdgeInsets.only(bottom: 12), child: c),
            )
            .toList(),
      );
    }
    return Row(
      children: children
          .map(
            (c) => Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: c == children.last ? 0 : 12),
                child: c,
              ),
            ),
          )
          .toList(),
    );
  }
}

class _SeasonUpdateTableView extends StatelessWidget {
  final SeasonUpdateController controller;
  const _SeasonUpdateTableView({required this.controller});

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
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(
            scheme.primary.withValues(alpha: 0.9),
          ),
          dataRowMaxHeight: 60,
          columnSpacing: 24,
          border: TableBorder.all(color: Colors.grey.shade200, width: 0.5),
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
            DataColumn(label: Text('Action', style: headerStyle)),
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
                DataCell(const SizedBox.shrink()),
              ],
            );
          }),
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
    final scheme = Theme.of(context).colorScheme;

    return Obx(() {
      final fontSize = controller.baseFontSize.value;

      return SliverPadding(
        padding: const EdgeInsets.all(16),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            final item = controller.students[index];
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
                    ),
                    Obx(
                      () => item.status.value == 'Updated'
                          ? _buildCardRow(
                              'Updated To',
                              'Class ${item.updatedClass.value} on ${item.updateDate.value}',
                              fontSize,
                            )
                          : const SizedBox.shrink(),
                    ),
                    _buildCardRow(
                      'Parents',
                      '${item.fatherName} / ${item.motherName}',
                      fontSize,
                    ),
                    _buildCardRow('Mobile', item.mobileNo, fontSize),
                  ],
                ),
              ),
            );
          }, childCount: controller.students.length),
        ),
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
