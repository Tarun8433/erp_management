import 'package:erp_management/features/role_based_ui/principal/student_promotion/controllers/student_promotion_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class StudentPromotionScreen extends StatelessWidget {
  const StudentPromotionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final StudentPromotionController c = Get.put(StudentPromotionController());
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: scheme.surfaceContainerLowest,
      appBar: AppBar(
        title: const Text('Student Promotion'),
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
                  ? _PromotionTableView(controller: c)
                  : _PromotionCardView(controller: c);
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar(BuildContext context, StudentPromotionController c) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 900;

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
                  c.sessionYearList,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildFilterItem(
                  context,
                  'Group *',
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
                  'Class *',
                  c.selectedClass,
                  c.classList,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildFilterItem(
                  context,
                  'Status *',
                  c.selectedStatus,
                  c.statuses,
                ),
              ),
            ],
          ),
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
                      hintText: 'name mobile sid',
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
                  onPressed: c.promoteSelected,
                  icon: const Icon(Icons.trending_up, size: 18),
                  label: const Text('Promote Student'),
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
                value: value.value.isEmpty ? null : value.value,
                hint: Text('Select', style: Theme.of(context).textTheme.bodySmall),
                items: items
                    .map(
                      (e) => DropdownMenuItem(
                        value: e,
                        child: Text(e, style: Theme.of(context).textTheme.bodySmall),
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

  void _showSettingsDialog(BuildContext context, StudentPromotionController c) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Promotion Settings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Adjust Font Size'),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline),
                  onPressed: () => c.updateFontSize(-1),
                ),
                Obx(
                  () => Text(
                    c.baseFontSize.value.toStringAsFixed(0),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: () => c.updateFontSize(1),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Close')),
        ],
      ),
    );
  }
}

class _PromotionTableView extends StatelessWidget {
  final StudentPromotionController controller;
  const _PromotionTableView({required this.controller});

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
              DataColumn(label: Text('Promoted To Class', style: headerStyle)),
              DataColumn(label: Text('Date Of Promotion', style: headerStyle)),
              DataColumn(label: Text('Name', style: headerStyle)),
              DataColumn(label: Text('Father Name', style: headerStyle)),
              DataColumn(label: Text('Mother Name', style: headerStyle)),
              DataColumn(label: Text('MobileNo', style: headerStyle)),
              DataColumn(label: Text('Action', style: headerStyle)),
            ],
            rows: controller.students
                .map(
                  (item) => DataRow(
                    cells: [
                      DataCell(
                        Row(
                          children: [
                            Obx(
                              () => item.status.value == 'Not Promoted'
                                  ? Checkbox(
                                      value: item.isSelected.value,
                                      onChanged: (v) =>
                                          item.isSelected.value = v ?? false,
                                    )
                                  : const SizedBox(
                                      width: 48,
                                    ), // Match checkbox width
                            ),
                            Text(item.sNo.toString(), style: cellStyle),
                          ],
                        ),
                      ),
                      DataCell(Text(item.sid, style: cellStyle)),
                      DataCell(Text(item.group, style: cellStyle)),
                      DataCell(Text(item.currentClass, style: cellStyle)),
                      DataCell(Text(item.currentSession, style: cellStyle)),
                      DataCell(
                        Obx(() {
                          final isPromoted = item.status.value == 'Promoted';
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: isPromoted
                                  ? Colors.teal.shade50
                                  : Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              item.status.value,
                              style: cellStyle.copyWith(
                                color: isPromoted ? Colors.teal : Colors.blue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        }),
                      ),
                      DataCell(
                        Obx(
                          () => Text(
                            item.promotedToClass.value,
                            style: cellStyle,
                          ),
                        ),
                      ),
                      DataCell(
                        Obx(
                          () =>
                              Text(item.promotionDate.value, style: cellStyle),
                        ),
                      ),
                      DataCell(Text(item.name, style: cellStyle)),
                      DataCell(Text(item.fatherName, style: cellStyle)),
                      DataCell(Text(item.motherName, style: cellStyle)),
                      DataCell(Text(item.mobileNo, style: cellStyle)),
                      DataCell(
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.person,
                                color: Colors.blueGrey,
                                size: 20,
                              ),
                              onPressed: () =>
                                  controller.showProfileDetails(item),
                              tooltip: 'View Profile',
                            ),
                            Obx(
                              () => item.status.value == 'Promoted'
                                  ? IconButton(
                                      icon: const Icon(
                                        Icons.history,
                                        color: Colors.blue,
                                        size: 20,
                                      ),
                                      onPressed: () =>
                                          controller.undoPromotion(item),
                                      tooltip: 'Undo Promotion',
                                    )
                                  : const SizedBox.shrink(),
                            ),
                          ],
                        ),
                      ),
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

class _PromotionCardView extends StatelessWidget {
  final StudentPromotionController controller;
  const _PromotionCardView({required this.controller});

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
                        () => item.status.value == 'Not Promoted'
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
                        final isPromoted = item.status.value == 'Promoted';
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: isPromoted
                                ? Colors.teal.shade50
                                : Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            item.status.value,
                            style: TextStyle(
                              fontSize: fontSize - 2,
                              color: isPromoted ? Colors.teal : Colors.blue,
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
                    '${item.currentSession} | Class ${item.currentClass}',
                    fontSize,
                    scheme,
                  ),
                  Obx(
                    () => item.status.value == 'Promoted'
                        ? _buildCardRow(
                            'Promoted To',
                            'Class ${item.promotedToClass.value} on ${item.promotionDate.value}',
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
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Obx(
                        () => item.status.value == 'Promoted'
                            ? TextButton.icon(
                                onPressed: () => controller.undoPromotion(item),
                                icon: const Icon(Icons.history, size: 18),
                                label: const Text('Undo Promotion'),
                              )
                            : const SizedBox.shrink(),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () => controller.showProfileDetails(item),
                        child: const Text('View Profile'),
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

  Widget _buildCardRow(String label, String value, double fontSize, ColorScheme scheme) {
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
