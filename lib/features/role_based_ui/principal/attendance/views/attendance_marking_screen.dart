import 'package:erp_management/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/attendance_marking_controller.dart';
import '../models/attendance_student_model.dart';
import '../models/attendance_type.dart';
import '../../../../../../../core/models/category_model.dart';
import '../models/shift_model.dart';

class AttendanceMarkingScreen extends StatelessWidget {
  const AttendanceMarkingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(AttendanceMarkingController());
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Mark Attendance'),
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          Obx(() {
            if (!c.hasLoaded.value) return const SizedBox.shrink();
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
                  icon: Icon(
                    c.viewMode.value == 'card'
                        ? Icons.table_rows_rounded
                        : Icons.grid_view_rounded,
                  ),
                  onPressed: c.toggleView,
                ),
              ],
            );
          }),
        ],
      ),
      body: Column(
        children: [
          _FilterCard(c: c),
          Obx(() {
            if (!c.hasLoaded.value) return const SizedBox.shrink();
            return _SummaryBar(c: c);
          }),
          Obx(() {
            if (!c.hasLoaded.value) return const SizedBox.shrink();
            return _SearchAndBulkRow(c: c);
          }),
          Expanded(
            child: Obx(() {
              if (c.isLoading.value) {
                return SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                );
              }
              if (!c.hasLoaded.value) {
                return const Center(
                  child: Text(
                    'Select filters and tap Load Students',
                    style: TextStyle(color: Colors.grey),
                  ),
                );
              }
              if (c.filteredStudents.isEmpty) {
                return const Center(child: Text('No students found'));
              }
              if (c.viewMode.value == 'table') {
                return _TableView(c: c);
              }
              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(12, 4, 12, 100),
                itemCount: c.filteredStudents.length,
                itemBuilder: (_, i) =>
                    _StudentMarkCard(student: c.filteredStudents[i], c: c),
              );
            }),
          ),
        ],
      ),
      bottomNavigationBar: Obx(() {
        if (!c.hasLoaded.value) return const SizedBox.shrink();
        return _SaveBar(c: c);
      }),
    );
  }

  void _showColumnPicker(BuildContext context, AttendanceMarkingController c) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Columns',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    for (final k in AttendanceMarkingController.allColumns) {
                      c.columnVisibility[k] = true;
                    }
                  },
                  child: const Text('Show all'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Obx(() {
              final vis = Map<String, bool>.from(c.columnVisibility);
              final visibleCount = vis.values.where((v) => v).length;
              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children: AttendanceMarkingController.allColumns.map((key) {
                  final isOn = vis[key] ?? true;
                  final isLast = visibleCount == 1 && isOn;
                  return FilterChip(
                    label: Text(
                      AttendanceMarkingController.columnLabels[key] ?? key,
                    ),
                    selected: isOn,
                    onSelected: isLast ? null : (_) => c.toggleColumn(key),
                    selectedColor: const Color(
                      0xFF1565C0,
                    ).withValues(alpha: 0.15),
                    checkmarkColor: const Color(0xFF1565C0),
                    labelStyle: TextStyle(
                      color: isOn ? const Color(0xFF1565C0) : Colors.grey,
                      fontWeight: isOn ? FontWeight.w600 : FontWeight.normal,
                    ),
                  );
                }).toList(),
              );
            }),
            const SizedBox(height: 4),
            Obx(() {
              final visibleCount = c.columnVisibility.values
                  .where((v) => v)
                  .length;
              if (visibleCount > 1) return const SizedBox.shrink();
              return const Padding(
                padding: EdgeInsets.only(top: 4),
                child: Text(
                  'At least one column must be visible',
                  style: TextStyle(color: Colors.red, fontSize: 12),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

// ── Filter card ───────────────────────────────────────────────────────────────

class _FilterCard extends StatelessWidget {
  final AttendanceMarkingController c;
  const _FilterCard({required this.c});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF1565C0),
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _SessionDrop(c: c)),
              const SizedBox(width: 8),
              Expanded(child: _GroupDrop(c: c)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _ClassDrop(c: c)),
              const SizedBox(width: 8),
              Expanded(child: _ShiftDrop(c: c)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _DatePicker(c: c)),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: c.loadStudents,
                icon: const Icon(Icons.search),
                label: const Text('Load'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Get.isDarkMode
                      ? AppColors.black
                      : Colors.white,
                  foregroundColor: Get.isDarkMode
                      ? Colors.white
                      : const Color(0xFF1565C0),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SessionDrop extends StatelessWidget {
  final AttendanceMarkingController c;
  const _SessionDrop({required this.c});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => _DropWrapper(
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            dropdownColor: Theme.of(context).colorScheme.surface,
            value: c.sessionList.contains(c.selectedSession.value)
                ? c.selectedSession.value
                : null,
            isExpanded: true,
            hint: const Text(
              'Session',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
            items: c.sessionList
                .map(
                  (s) => DropdownMenuItem(
                    value: s,
                    child: Text(s, style: const TextStyle(fontSize: 13)),
                  ),
                )
                .toList(),
            onChanged: (v) => c.selectedSession.value = v ?? '',
          ),
        ),
      ),
    );
  }
}

class _GroupDrop extends StatelessWidget {
  final AttendanceMarkingController c;
  const _GroupDrop({required this.c});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => _DropWrapper(
        child: c.isGroupLoading.value
            ? const _LoadingIndicator()
            : DropdownButtonHideUnderline(
                child: DropdownButton<CategoryModel>(
                  dropdownColor: Theme.of(context).colorScheme.surface,
                  value: c.selectedGroup.value,
                  isExpanded: true,
                  hint: const Text(
                    'Group',
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                  items: c.groupList
                      .map(
                        (g) => DropdownMenuItem(
                          value: g,
                          child: Text(
                            g.name ?? '',
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => c.selectedGroup.value = v,
                ),
              ),
      ),
    );
  }
}

class _ClassDrop extends StatelessWidget {
  final AttendanceMarkingController c;
  const _ClassDrop({required this.c});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => _DropWrapper(
        child: c.isClassLoading.value
            ? const _LoadingIndicator()
            : DropdownButtonHideUnderline(
                child: DropdownButton<CategoryModel>(
                  dropdownColor: Theme.of(context).colorScheme.surface,
                  value: c.selectedClass.value,
                  isExpanded: true,
                  hint: const Text(
                    'Class',
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                  items: c.classList
                      .map(
                        (cl) => DropdownMenuItem(
                          value: cl,
                          child: Text(
                            cl.name ?? '',
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => c.selectedClass.value = v,
                ),
              ),
      ),
    );
  }
}

class _ShiftDrop extends StatelessWidget {
  final AttendanceMarkingController c;
  const _ShiftDrop({required this.c});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => _DropWrapper(
        child: c.isShiftLoading.value
            ? const _LoadingIndicator()
            : DropdownButtonHideUnderline(
                child: DropdownButton<ShiftModel>(
                  dropdownColor: Theme.of(context).colorScheme.surface,
                  value: c.selectedShift.value,
                  isExpanded: true,
                  hint: const Text(
                    'Shift',
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                  items: c.shiftList
                      .map(
                        (s) => DropdownMenuItem(
                          value: s,
                          child: Text(
                            s.name,
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => c.selectedShift.value = v,
                ),
              ),
      ),
    );
  }
}

class _DatePicker extends StatelessWidget {
  final AttendanceMarkingController c;
  const _DatePicker({required this.c});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => _DropWrapper(
        child: InkWell(
          onTap: () => c.pickDate(context),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_today_rounded,
                  size: 16,
                  color: Colors.grey,
                ),
                const SizedBox(width: 6),
                Text(
                  c.formattedDate.isEmpty ? 'Pick date' : c.formattedDate,
                  style: TextStyle(
                    fontSize: 13,
                    color: c.formattedDate.isEmpty
                        ? Colors.grey
                        : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LoadingIndicator extends StatelessWidget {
  const _LoadingIndicator();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(10),
      child: Row(
        children: [
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ],
      ),
    );
  }
}

class _DropWrapper extends StatelessWidget {
  final Widget child;
  const _DropWrapper({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(10),
      ),
      child: child,
    );
  }
}

// ── Summary bar ───────────────────────────────────────────────────────────────

class _SummaryBar extends StatelessWidget {
  final AttendanceMarkingController c;
  const _SummaryBar({required this.c});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      child: Obx(
        () => Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _SummaryChip('P', c.presentCount, const Color(0xFF2E7D32)),
            _SummaryChip('A', c.absentCount, const Color(0xFFC62828)),
            _SummaryChip('H', c.halfDayCount, const Color(0xFFF57C00)),
            _SummaryChip('Ho', c.holidayCount, const Color(0xFF1565C0)),
            _SummaryChip('--', c.unmarkedCount, Colors.grey),
          ],
        ),
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  const _SummaryChip(this.label, this.count, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            '$count',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Search + bulk row ─────────────────────────────────────────────────────────

class _SearchAndBulkRow extends StatelessWidget {
  final AttendanceMarkingController c;
  const _SearchAndBulkRow({required this.c});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      color: theme.colorScheme.surface,
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              onChanged: (v) => c.searchQuery.value = v,
              decoration: InputDecoration(
                hintText: 'Search student…',
                prefixIcon: const Icon(Icons.search, size: 20),
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: theme.dividerColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: theme.dividerColor),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          _BulkDropdown(c: c),
        ],
      ),
    );
  }
}

class _BulkDropdown extends StatelessWidget {
  final AttendanceMarkingController c;
  const _BulkDropdown({required this.c});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).dividerColor),
          borderRadius: BorderRadius.circular(10),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<AttendanceTypeOption>(
            value: c.bulkType.value,
            hint: const Text('Set All', style: TextStyle(fontSize: 13)),
            items: AttendanceTypeOption.values
                .map(
                  (t) => DropdownMenuItem(
                    value: t,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: t.color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(t.label, style: const TextStyle(fontSize: 13)),
                      ],
                    ),
                  ),
                )
                .toList(),
            onChanged: c.applyBulk,
          ),
        ),
      ),
    );
  }
}

// ── Card view ─────────────────────────────────────────────────────────────────

class _StudentMarkCard extends StatelessWidget {
  final AttendanceStudentModel student;
  final AttendanceMarkingController c;
  const _StudentMarkCard({required this.student, required this.c});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Obx(() {
      final selectedId = c.markingMap[student.id];
      final selected = AttendanceTypeOption.fromId(selectedId);

      return Card(
        margin: const EdgeInsets.only(bottom: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 1,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color:
                          selected?.color.withValues(alpha: 0.15) ??
                          theme.colorScheme.surfaceContainerHighest,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        student.firstName.isNotEmpty
                            ? student.firstName[0].toUpperCase()
                            : '?',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: selected?.color ?? Colors.grey,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          student.firstName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          '${student.sid}  •  Father: ${student.fatherName}',
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (selected != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: selected.color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        selected.label,
                        style: TextStyle(
                          color: selected.color,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: AttendanceTypeOption.values
                    .map(
                      (opt) => Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: _RadioChip(
                            option: opt,
                            isSelected: selectedId == opt.id,
                            onTap: () => c.setMark(student.id, opt.id),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        ),
      );
    });
  }
}

class _RadioChip extends StatelessWidget {
  final AttendanceTypeOption option;
  final bool isSelected;
  final VoidCallback onTap;
  const _RadioChip({
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? option.color
              : option.color.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? option.color
                : option.color.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              size: 14,
              color: isSelected ? Colors.white : option.color,
            ),
            const SizedBox(width: 3),
            Flexible(
              child: Text(
                option.label,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? Colors.white : option.color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Table view ────────────────────────────────────────────────────────────────

class _TableView extends StatelessWidget {
  final AttendanceMarkingController c;
  const _TableView({required this.c});

  static const _colW = <String, double>{
    'serial': 36,
    'sid': 76,
    'name': 130,
    'father': 120,
    'P': 46,
    'A': 46,
    'H': 46,
    'Ho': 46,
  };

  static const _markCols = {'P', 'A', 'H', 'Ho'};

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Obx(() {
      final vis = Map<String, bool>.from(c.columnVisibility);
      final cols = AttendanceMarkingController.allColumns
          .where((k) => vis[k] == true)
          .toList();
      final students = c.filteredStudents;

      return SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(cols, isDark),
              Divider(height: 1, thickness: 1, color: theme.dividerColor),
              ...students.asMap().entries.map(
                (e) => _TableRow(
                  index: e.key + 1,
                  student: e.value,
                  cols: cols,
                  colW: _colW,
                  markCols: _markCols,
                  c: c,
                ),
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildHeader(List<String> cols, bool isDark) {
    return Container(
      color: isDark ? const Color(0xFF2A2D34) : const Color(0xFFE3EAF5),
      child: Row(
        children: cols.map((k) {
          return SizedBox(
            width: _colW[k],
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
              child: Text(
                AttendanceMarkingController.columnLabels[k] ?? k,
                textAlign: _markCols.contains(k)
                    ? TextAlign.center
                    : TextAlign.left,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                  color: _markCols.contains(k)
                      ? _markColor(k)
                      : const Color(0xFF1565C0),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Color _markColor(String col) => switch (col) {
    'P' => const Color(0xFF2E7D32),
    'A' => const Color(0xFFC62828),
    'H' => const Color(0xFFF57C00),
    'Ho' => const Color(0xFF1565C0),
    _ => Colors.grey,
  };
}

class _TableRow extends StatelessWidget {
  final int index;
  final AttendanceStudentModel student;
  final List<String> cols;
  final Map<String, double> colW;
  final Set<String> markCols;
  final AttendanceMarkingController c;

  const _TableRow({
    required this.index,
    required this.student,
    required this.cols,
    required this.colW,
    required this.markCols,
    required this.c,
  });

  static const _typeForCol = <String, AttendanceTypeOption>{
    'P': AttendanceTypeOption.present,
    'A': AttendanceTypeOption.absent,
    'H': AttendanceTypeOption.halfDay,
    'Ho': AttendanceTypeOption.holiday,
  };

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Obx(() {
      final selectedId = c.markingMap[student.id];
      final isEven = index % 2 == 0;

      return Container(
        color: isDark
            ? (isEven ? const Color(0xFF23262C) : const Color(0xFF1B1D22))
            : (isEven ? const Color(0xFFF7F9FF) : Colors.white),
        child: Row(
          children: cols.map((k) {
            return SizedBox(
              width: colW[k],
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                child: _cell(k, selectedId),
              ),
            );
          }).toList(),
        ),
      );
    });
  }

  Widget _cell(String col, int? selectedId) {
    switch (col) {
      case 'serial':
        return Text(
          '$index',
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        );
      case 'sid':
        return Text(
          student.sid,
          style: const TextStyle(fontSize: 12),
          overflow: TextOverflow.ellipsis,
        );
      case 'name':
        return Text(
          student.firstName,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          overflow: TextOverflow.ellipsis,
        );
      case 'father':
        return Text(
          student.fatherName,
          style: const TextStyle(fontSize: 12),
          overflow: TextOverflow.ellipsis,
        );
      default:
        final opt = _typeForCol[col]!;
        final isSelected = selectedId == opt.id;
        return GestureDetector(
          onTap: () => c.setMark(student.id, opt.id),
          child: Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 120),
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: isSelected
                    ? opt.color
                    : opt.color.withValues(alpha: 0.08),
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? opt.color
                      : opt.color.withValues(alpha: 0.35),
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check_rounded,
                      size: 16,
                      color: Colors.white,
                    )
                  : null,
            ),
          ),
        );
    }
  }
}

// ── Save bar ──────────────────────────────────────────────────────────────────

class _SaveBar extends StatelessWidget {
  final AttendanceMarkingController c;
  const _SaveBar({required this.c});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: Obx(
          () => FilledButton.icon(
            onPressed: c.isSaving.value ? null : c.saveBulk,
            icon: c.isSaving.value
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.save_rounded),
            label: Text(
              c.isSaving.value
                  ? 'Saving…'
                  : 'Save Attendance (${c.students.length})',
              style: const TextStyle(fontSize: 15),
            ),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF1565C0),
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
