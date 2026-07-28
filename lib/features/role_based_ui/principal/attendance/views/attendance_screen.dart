import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/attendance_controller.dart';
import '../../../../../core/models/category_model.dart';
import '../models/attendance_student_model.dart';
import '../models/shift_model.dart';
import 'package:erp_management/routes/app_routes.dart';

class AttendanceScreen extends StatelessWidget {
  const AttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(AttendanceController());
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: scheme.surfaceContainerLowest,
      appBar: AppBar(
        title: const Text('Student Attendance'),
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
            tooltip: 'Mark Attendance',
            icon: const Icon(Icons.edit_calendar_rounded),
            onPressed: () => Get.toNamed(AppRoutes.attendanceMarking),
          ),
          Obx(() {
            if (!c.hasSearched.value) return const SizedBox.shrink();
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (c.viewMode.value == 'table')
                  IconButton(
                    tooltip: 'Column visibility',
                    icon: const Icon(Icons.view_column_rounded),
                    onPressed: () => _showColumnPicker(context, c),
                  ),
                IconButton(
                  tooltip: c.viewMode.value == 'card'
                      ? 'Table view'
                      : 'Card view',
                  onPressed: c.toggleView,
                  icon: Icon(
                    c.viewMode.value == 'card'
                        ? Icons.table_rows_rounded
                        : Icons.grid_view_rounded,
                  ),
                ),
              ],
            );
          }),
        ],
      ),
      body: Column(
        children: [
          _FilterBar(controller: c),
          Expanded(
            child: Obx(() {
              if (c.isSearching.value) return _buildLoader(scheme);
              if (!c.hasSearched.value) return _buildPrompt(context);
              return _ResultsView(controller: c);
            }),
          ),
        ],
      ),
    );
  }

  void _showColumnPicker(BuildContext context, AttendanceController c) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        final theme = Theme.of(context);
        final scheme = theme.colorScheme;
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: scheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(
                    Icons.view_column_rounded,
                    size: 20,
                    color: scheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Table Columns',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      for (final key in AttendanceController.allColumns) {
                        c.columnVisibility[key] = true;
                      }
                    },
                    child: const Text('Show all'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Obx(
                () => Column(
                  children: AttendanceController.allColumns.map((key) {
                    final visible = c.columnVisibility[key] ?? true;
                    final label = AttendanceController.columnLabels[key] ?? key;
                    final isOnly =
                        c.columnVisibility.values.where((v) => v).length == 1;
                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: () => c.toggleColumn(key),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 4,
                            horizontal: 4,
                          ),
                          child: Row(
                            children: [
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: visible
                                      ? scheme.primary
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: visible
                                        ? scheme.primary
                                        : scheme.outline,
                                    width: 2,
                                  ),
                                ),
                                child: visible
                                    ? const Icon(
                                        Icons.check_rounded,
                                        size: 15,
                                        color: Colors.white,
                                      )
                                    : null,
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Text(
                                  label,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: visible
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                    color:
                                        (visible == false ||
                                            (visible && isOnly))
                                        ? scheme.onSurfaceVariant
                                        : scheme.onSurface,
                                  ),
                                ),
                              ),
                              if (visible && isOnly)
                                Text(
                                  'min 1',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: scheme.error,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLoader(ColorScheme scheme) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircularProgressIndicator(color: scheme.primary),
        const SizedBox(height: 14),
        Text(
          'Fetching attendance…',
          style: TextStyle(color: scheme.onSurfaceVariant),
        ),
      ],
    ),
  );

  Widget _buildPrompt(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: scheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.how_to_reg_rounded,
              size: 44,
              color: scheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Select filters and tap Search',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Attendance summary will appear here',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Results wrapper ───────────────────────────────────────────────────────────

class _ResultsView extends StatelessWidget {
  final AttendanceController controller;
  const _ResultsView({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _SummaryBar(controller: controller),

        Expanded(
          child: Obx(() {
            final list = controller.filteredStudents;
            if (list.isEmpty) {
              return Center(
                child: Text(
                  'No students found',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              );
            }
            return controller.viewMode.value == 'table'
                ? _TableView(
                    students: list,
                    visibility: Map.from(controller.columnVisibility),
                  )
                : _CardView(students: list);
          }),
        ),
      ],
    );
  }
}

// ── Summary Bar ───────────────────────────────────────────────────────────────

class _SummaryBar extends StatelessWidget {
  final AttendanceController controller;
  const _SummaryBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Obx(
      () => Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.dividerColor),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _StatChip(
              label: 'Total',
              count: controller.totalCount,
              color: scheme.primary,
            ),
            _vDivider(),
            _StatChip(
              label: 'Present',
              count: controller.presentCount,
              color: const Color(0xFF2E7D32),
            ),
            _vDivider(),
            _StatChip(
              label: 'Absent',
              count: controller.absentCount,
              color: const Color(0xFFC62828),
            ),
            _vDivider(),
            _StatChip(
              label: 'Late',
              count: controller.lateCount,
              color: const Color(0xFFF57C00),
            ),
            _vDivider(),
            _StatChip(
              label: 'Unmarked',
              count: controller.notMarkedCount,
              color: scheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  Widget _vDivider() => Container(
    width: 1,
    height: 32,
    color: Colors.grey.withValues(alpha: 0.2),
  );
}

class _StatChip extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  const _StatChip({
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$count',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w900,
            color: color,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

// ── Search Box ────────────────────────────────────────────────────────────────

class _SearchBox extends StatelessWidget {
  final AttendanceController controller;
  const _SearchBox({required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(0,0, 8, 0),
      child: TextField(
        onChanged: (v) => controller.searchQuery.value = v,
        style: theme.textTheme.bodySmall,
        decoration: InputDecoration(
          hintText: 'Search by name, ID…',
          hintStyle: theme.textTheme.bodySmall?.copyWith(
            color: scheme.onSurfaceVariant,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            size: 18,
            color: scheme.onSurfaceVariant,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 10,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: theme.dividerColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: theme.dividerColor),
          ),
          filled: true,
          fillColor: scheme.surface,
        ),
      ),
    );
  }
}

// ── Table View ────────────────────────────────────────────────────────────────

class _TableView extends StatelessWidget {
  final List<AttendanceStudentModel> students;
  final Map<String, bool> visibility;
  const _TableView({required this.students, required this.visibility});

  // Fixed widths / flex per column key.
  static const _widths = {
    'serial': FixedColumnWidth(40),
    'sid': FixedColumnWidth(68),
    'firstName': FlexColumnWidth(2.2),
    'fatherName': FlexColumnWidth(2),
    'status': FixedColumnWidth(80),
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    // Build ordered list of visible column keys.
    final cols = AttendanceController.allColumns
        .where((k) => visibility[k] == true)
        .toList();

    // Map visible columns to their indexed widths for Table.
    final colWidths = <int, TableColumnWidth>{
      for (int i = 0; i < cols.length; i++)
        i: _widths[cols[i]] ?? const FlexColumnWidth(1),
    };

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Table(
          border: TableBorder(
            horizontalInside: BorderSide(color: theme.dividerColor, width: 0.8),
            borderRadius: BorderRadius.circular(14),
          ),
          columnWidths: colWidths,
          children: [
            // Header
            TableRow(
              decoration: BoxDecoration(color: scheme.primary),
              children: cols
                  .map(
                    (k) => _th(
                      AttendanceController.columnLabels[k] ?? k,
                      scheme,
                      center: k == 'status' || k == 'serial',
                    ),
                  )
                  .toList(),
            ),
            // Data rows
            for (int i = 0; i < students.length; i++)
              TableRow(
                decoration: BoxDecoration(
                  color: i.isEven
                      ? scheme.surface
                      : scheme.surfaceContainerLowest,
                ),
                children: cols.map((k) {
                  final s = students[i];
                  return switch (k) {
                    'serial' => _tdCenter('${i + 1}', theme, scheme),
                    'sid' => _td(s.sid, theme, scheme),
                    'firstName' => _td(s.firstName, theme, scheme),
                    'fatherName' => _td(
                      s.fatherName,
                      theme,
                      scheme,
                      muted: true,
                    ),
                    'status' => Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 6,
                      ),
                      child: Center(child: _StatusBadge(status: s.status)),
                    ),
                    _ => const SizedBox.shrink(),
                  };
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _th(String text, ColorScheme scheme, {bool center = false}) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
    child: Text(
      text,
      textAlign: center ? TextAlign.center : TextAlign.start,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w800,
        color: scheme.onPrimary,
        letterSpacing: 0.4,
      ),
    ),
  );

  Widget _tdCenter(String text, ThemeData theme, ColorScheme scheme) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 8),
    child: Text(
      text,
      textAlign: TextAlign.center,
      style: theme.textTheme.bodySmall?.copyWith(
        color: scheme.onSurface,
        fontWeight: FontWeight.w600,
      ),
      overflow: TextOverflow.ellipsis,
    ),
  );

  Widget _td(
    String text,
    ThemeData theme,
    ColorScheme scheme, {
    bool muted = false,
  }) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 8),
    child: Text(
      text,
      style: theme.textTheme.bodySmall?.copyWith(
        color: muted ? scheme.onSurfaceVariant : scheme.onSurface,
        fontWeight: muted ? FontWeight.w400 : FontWeight.w600,
      ),
      overflow: TextOverflow.ellipsis,
    ),
  );
}

// ── Card View ─────────────────────────────────────────────────────────────────

class _CardView extends StatelessWidget {
  final List<AttendanceStudentModel> students;
  const _CardView({required this.students});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      itemCount: students.length,
      itemBuilder: (_, i) =>
          _AttendanceCard(student: students[i], serial: i + 1),
    );
  }
}

class _AttendanceCard extends StatelessWidget {
  final AttendanceStudentModel student;
  final int serial;
  const _AttendanceCard({required this.student, required this.serial});

  Color _statusColor(String? s, ColorScheme scheme) => switch (s) {
    'P' => const Color(0xFF2E7D32),
    'A' => const Color(0xFFC62828),
    'L' => const Color(0xFFF57C00),
    'H' => const Color(0xFF1565C0),
    _ => scheme.onSurfaceVariant,
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final color = _statusColor(student.status, scheme);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border(left: BorderSide(color: color, width: 4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '$serial',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    color: color,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    student.firstName,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: scheme.onSurface,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Icon(
                        Icons.person_outline_rounded,
                        size: 12,
                        color: scheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          student.fatherName,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: scheme.primaryContainer.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'ID: ${student.sid}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: scheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            _StatusBadge(status: student.status, large: true),
          ],
        ),
      ),
    );
  }
}

// ── Status Badge ──────────────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  final String? status;
  final bool large;
  const _StatusBadge({this.status, this.large = false});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final (label, color) = switch (status) {
      'P' => ('Present', const Color(0xFF2E7D32)),
      'A' => ('Absent', const Color(0xFFC62828)),
      'L' => ('Late', const Color(0xFFF57C00)),
      'H' => ('Holiday', const Color(0xFF1565C0)),
      _ => ('—', scheme.onSurfaceVariant),
    };

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: large ? 12 : 8,
        vertical: large ? 6 : 3,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: large ? 12 : 10,
          fontWeight: FontWeight.w800,
          color: color,
        ),
      ),
    );
  }
}

// ── Filter Bar ────────────────────────────────────────────────────────────────

class _FilterBar extends StatelessWidget {
  final AttendanceController controller;
  const _FilterBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: scheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _GroupDropdown(controller: controller)),
              const SizedBox(width: 10),
              Expanded(child: _ClassDropdown(controller: controller)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _DateField(controller: controller)),
              const SizedBox(width: 10),
              Expanded(child: _ShiftDropdown(controller: controller)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _SearchBox(controller: controller)),
              SizedBox(
               width: 130,
                child: OutlinedButton.icon(
                  onPressed: controller.search,
                  icon: Icon(
                    Icons.search_rounded,
                    size: 18,
                    color: scheme.primary,
                  ),
                  label: Text(
                    'Filter',
                    style: TextStyle(color: scheme.primary),
                  ),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(44),
                    side: BorderSide(color: scheme.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),

              // const SizedBox(width: 10),
              // Expanded(
              //   child: OutlinedButton.icon(
              //     onPressed: () {},
              //     icon:
              //         Icon(Icons.save_rounded, size: 18, color: scheme.primary),
              //     label:
              //         Text('Save', style: TextStyle(color: scheme.primary)),
              //     style: OutlinedButton.styleFrom(
              //       minimumSize: const Size.fromHeight(44),
              //       side: BorderSide(color: scheme.primary),
              //       shape: RoundedRectangleBorder(
              //           borderRadius: BorderRadius.circular(10)),
              //     ),
              //   ),
              // ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Dropdown widgets ──────────────────────────────────────────────────────────

class _GroupDropdown extends StatelessWidget {
  final AttendanceController controller;
  const _GroupDropdown({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => _DropdownField<CategoryModel>(
        label: 'Group',
        hint: controller.isGroupLoading.value ? 'Loading…' : 'Select',
        value: controller.selectedGroup.value,
        items: controller.groupList,
        itemLabel: (g) => g.name ?? '',
        onChanged: controller.isGroupLoading.value
            ? null
            : (v) => controller.selectedGroup.value = v,
      ),
    );
  }
}

class _ClassDropdown extends StatelessWidget {
  final AttendanceController controller;
  const _ClassDropdown({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => _DropdownField<CategoryModel>(
        label: 'Class',
        hint: controller.selectedGroup.value == null
            ? 'Select group first'
            : controller.isClassLoading.value
            ? 'Loading…'
            : 'Select',
        value: controller.selectedClass.value,
        items: controller.classList,
        itemLabel: (c) => c.name ?? '',
        onChanged:
            (controller.isClassLoading.value ||
                controller.selectedGroup.value == null)
            ? null
            : (v) => controller.selectedClass.value = v,
      ),
    );
  }
}

class _ShiftDropdown extends StatelessWidget {
  final AttendanceController controller;
  const _ShiftDropdown({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => _DropdownField<ShiftModel>(
        label: 'Shift',
        hint: controller.isShiftLoading.value ? 'Loading…' : 'Select',
        value: controller.selectedShift.value,
        items: controller.shiftList,
        itemLabel: (s) => s.name,
        onChanged: controller.isShiftLoading.value
            ? null
            : (v) => controller.selectedShift.value = v,
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  final AttendanceController controller;
  const _DateField({required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Attendance Date *',
          style: theme.textTheme.labelSmall?.copyWith(
            color: scheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        GestureDetector(
          onTap: () => controller.pickDate(context),
          child: Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(color: theme.dividerColor),
              borderRadius: BorderRadius.circular(8),
              color: scheme.surface,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Obx(() {
                    final date = controller.selectedDate.value;
                    return Text(
                      date == null ? 'Select date' : controller.formattedDate,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: date == null
                            ? scheme.onSurfaceVariant
                            : scheme.onSurface,
                      ),
                      overflow: TextOverflow.ellipsis,
                    );
                  }),
                ),
                Icon(
                  Icons.calendar_today_rounded,
                  size: 16,
                  color: scheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _DropdownField<T> extends StatelessWidget {
  final String label;
  final String hint;
  final T? value;
  final List<T> items;
  final String Function(T) itemLabel;
  final void Function(T?)? onChanged;

  const _DropdownField({
    required this.label,
    required this.hint,
    required this.value,
    required this.items,
    required this.itemLabel,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label *',
          style: theme.textTheme.labelSmall?.copyWith(
            color: scheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: theme.dividerColor),
            borderRadius: BorderRadius.circular(8),
            color: scheme.surface,
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              isExpanded: true,
              value: (value != null && items.contains(value)) ? value : null,
              hint: Text(
                hint,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.onSurface,
              ),
              icon: Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 18,
                color: scheme.onSurfaceVariant,
              ),
              onChanged: onChanged,
              items: items
                  .map(
                    (e) => DropdownMenuItem<T>(
                      value: e,
                      child: Text(
                        itemLabel(e),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }
}
