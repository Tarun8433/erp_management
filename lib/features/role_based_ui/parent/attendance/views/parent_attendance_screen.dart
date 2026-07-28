import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/parent_attendance_controller.dart';

class ParentAttendanceScreen extends StatelessWidget {
  const ParentAttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(ParentAttendanceController());
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
      body: Obx(() {
        if (c.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return CustomScrollView(
          slivers: [
            _AppBar(controller: c),
            SliverToBoxAdapter(child: _ChildTabs(controller: c)),
            SliverToBoxAdapter(child: _MonthNav(controller: c)),
            SliverToBoxAdapter(child: _SummaryRow(controller: c)),
            SliverToBoxAdapter(child: _CalendarGrid(controller: c)),
            SliverToBoxAdapter(child: _Legend()),
            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        );
      }),
    );
  }
}

// ── App Bar ───────────────────────────────────────────────────────────────────

class _AppBar extends StatelessWidget {
  final ParentAttendanceController controller;
  const _AppBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final primaryLight =
        Color.lerp(scheme.primary, Colors.white, 0.38) ?? scheme.primary;

    return SliverAppBar(
      expandedHeight: 120,
      pinned: true,
      stretch: true,
      floating: false,
      backgroundColor: scheme.primary,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
        onPressed: () => Get.back(),
      ),
      title: const Text(
        'Attendance',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.pin,
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [scheme.primary, primaryLight],
            ),
          ),
          child: Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
              child: Row(
                children: [
                  const Icon(Icons.school_rounded,
                      color: Colors.white70, size: 13),
                  const SizedBox(width: 6),
                  Text(
                    'PRATIBHA INTER COLLEGE · DEWA-BARABANKI',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Child Selector Tabs ───────────────────────────────────────────────────────

class _ChildTabs extends StatelessWidget {
  final ParentAttendanceController controller;
  const _ChildTabs({required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Obx(() {
      return Container(
        color: scheme.surface,
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Child',
              style: theme.textTheme.labelSmall?.copyWith(
                color: scheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(controller.children.length, (i) {
                  final child = controller.children[i];
                  final isSelected = controller.selectedChildIndex.value == i;
                  return GestureDetector(
                    onTap: () => controller.selectChild(i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(right: 10, bottom: 14),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? scheme.primary
                            : scheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: isSelected
                              ? scheme.primary
                              : scheme.outlineVariant,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color:
                                      scheme.primary.withValues(alpha: 0.28),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                )
                              ]
                            : null,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircleAvatar(
                            radius: 10,
                            backgroundColor: isSelected
                                ? Colors.white.withValues(alpha: 0.25)
                                : scheme.primary.withValues(alpha: 0.12),
                            child: Text(
                              '${i + 1}',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: isSelected ? Colors.white : scheme.primary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            child.name,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                              color: isSelected
                                  ? Colors.white
                                  : scheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
            Divider(height: 1, color: scheme.outlineVariant),
          ],
        ),
      );
    });
  }
}

// ── Month Navigation ──────────────────────────────────────────────────────────

class _MonthNav extends StatelessWidget {
  final ParentAttendanceController controller;
  const _MonthNav({required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Obx(() {
      final isCurrentMonth = !controller.canGoNext;

      return Container(
        color: scheme.surface,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            // Prev month button
            _NavArrow(
              icon: Icons.chevron_left_rounded,
              onTap: controller.previousMonth,
              scheme: scheme,
            ),
            const SizedBox(width: 12),

            // Month label + badge
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.calendar_month_rounded,
                      size: 18, color: scheme.primary),
                  const SizedBox(width: 8),
                  Text(
                    controller.monthLabel,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: scheme.onSurface,
                    ),
                  ),
                  if (isCurrentMonth) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: scheme.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'Current',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: scheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(width: 12),
            // Next month button
            _NavArrow(
              icon: Icons.chevron_right_rounded,
              onTap: controller.canGoNext ? controller.nextMonth : null,
              scheme: scheme,
            ),
          ],
        ),
      );
    });
  }
}

class _NavArrow extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final ColorScheme scheme;

  const _NavArrow(
      {required this.icon, required this.onTap, required this.scheme});

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: enabled
                ? scheme.outlineVariant
                : scheme.outlineVariant.withValues(alpha: 0.4),
          ),
          color: enabled ? scheme.surface : Colors.transparent,
        ),
        child: Icon(
          icon,
          color: enabled
              ? scheme.onSurface
              : scheme.onSurfaceVariant.withValues(alpha: 0.3),
          size: 20,
        ),
      ),
    );
  }
}

// ── Summary Row ───────────────────────────────────────────────────────────────

class _SummaryRow extends StatelessWidget {
  final ParentAttendanceController controller;
  const _SummaryRow({required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Obx(() {
      final child = controller.selectedChild;
      final year = controller.selectedYear.value;
      final month = controller.selectedMonth.value;
      final present = child?.presentCount(year, month) ?? 0;
      final absent = child?.absentCount(year, month) ?? 0;
      final working = child?.workingDays(year, month) ?? 0;
      final pct =
          working > 0 ? ((present / working) * 100).toStringAsFixed(1) : '—';

      return Container(
        margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            _SummaryTile(
              value: '$present',
              label: 'Present',
              color: const Color(0xFF2E7D32),
              icon: Icons.check_circle_outline_rounded,
            ),
            _VertDivider(scheme: scheme),
            _SummaryTile(
              value: '$absent',
              label: 'Absent',
              color: const Color(0xFFC62828),
              icon: Icons.cancel_outlined,
            ),
            _VertDivider(scheme: scheme),
            _SummaryTile(
              value: '$working',
              label: 'Working',
              color: const Color(0xFF1565C0),
              icon: Icons.work_outline_rounded,
            ),
            _VertDivider(scheme: scheme),
            _SummaryTile(
              value: working > 0 ? '$pct%' : '—',
              label: 'Percentage',
              color: scheme.primary,
              icon: Icons.percent_rounded,
            ),
          ],
        ),
      );
    });
  }
}

class _SummaryTile extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  final IconData icon;

  const _SummaryTile({
    required this.value,
    required this.label,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(height: 4),
            Text(
              value,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VertDivider extends StatelessWidget {
  final ColorScheme scheme;
  const _VertDivider({required this.scheme});

  @override
  Widget build(BuildContext context) => Container(
        width: 1,
        height: 48,
        color: scheme.outlineVariant.withValues(alpha: 0.5),
      );
}

// ── Calendar Grid ─────────────────────────────────────────────────────────────

class _CalendarGrid extends StatelessWidget {
  final ParentAttendanceController controller;
  const _CalendarGrid({required this.controller});

  static const int _cols = 8;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Obx(() {
      final year = controller.selectedYear.value;
      final month = controller.selectedMonth.value;
      final days = controller.currentMonthDays;

      if (days.isEmpty) {
        return const Padding(
          padding: EdgeInsets.all(40),
          child: Center(child: CircularProgressIndicator()),
        );
      }

      // Calculate weekday offset (0 = Monday … 6 = Sunday)
      final firstWeekday = DateTime(year, month, 1).weekday - 1;
      // total cells = blank prefix + actual days, padded to multiple of _cols
      final totalPadded =
          ((firstWeekday + days.length + _cols - 1) ~/ _cols) * _cols;

      return Container(
        margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Column(
            children: [
              // Weekday header
              _WeekdayHeader(scheme: scheme, theme: theme),
              const Divider(height: 1),
              // Day rows
              Padding(
                padding: const EdgeInsets.all(10),
                child: _buildRows(
                    context, days, firstWeekday, totalPadded, theme, scheme),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildRows(
    BuildContext context,
    List<DayAttendance> days,
    int firstWeekday,
    int totalPadded,
    ThemeData theme,
    ColorScheme scheme,
  ) {
    final rows = <Widget>[];
    final List<_CellData?> cells = [];

    // Pad start
    for (int i = 0; i < firstWeekday; i++) {
      cells.add(null);
    }
    // Actual days
    for (final d in days) {
      cells.add(_CellData(day: d.day, status: d.status));
    }
    // Pad end to fill last row
    while (cells.length % _cols != 0) {
      cells.add(null);
    }

    // Build rows of _cols
    for (int rowStart = 0; rowStart < cells.length; rowStart += _cols) {
      final rowCells = cells.sublist(rowStart, rowStart + _cols);
      rows.add(_CalendarRow(cells: rowCells, theme: theme, scheme: scheme));
      if (rowStart + _cols < cells.length) {
        rows.add(const SizedBox(height: 6));
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: rows,
    );
  }
}

class _CellData {
  final int day;
  final AttendanceStatus status;
  const _CellData({required this.day, required this.status});
}

class _WeekdayHeader extends StatelessWidget {
  final ColorScheme scheme;
  final ThemeData theme;
  const _WeekdayHeader({required this.scheme, required this.theme});

  static const _labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S', ''];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: scheme.surfaceContainerLow,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      child: Row(
        children: List.generate(_labels.length, (i) {
          final isSun = i == 6;
          final isSat = i == 5;
          return Expanded(
            child: Center(
              child: Text(
                _labels[i],
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isSun || isSat
                      ? scheme.onSurfaceVariant.withValues(alpha: 0.5)
                      : scheme.onSurfaceVariant,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _CalendarRow extends StatelessWidget {
  final List<_CellData?> cells;
  final ThemeData theme;
  final ColorScheme scheme;

  const _CalendarRow(
      {required this.cells, required this.theme, required this.scheme});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: cells.map((cell) {
        if (cell == null) {
          return const Expanded(child: SizedBox());
        }
        return Expanded(
          child: _DayCell(data: cell, theme: theme, scheme: scheme),
        );
      }).toList(),
    );
  }
}

class _DayCell extends StatelessWidget {
  final _CellData data;
  final ThemeData theme;
  final ColorScheme scheme;

  const _DayCell(
      {required this.data, required this.theme, required this.scheme});

  @override
  Widget build(BuildContext context) {
    final Color badgeColor;
    final String label;
    final Color textColor;

    switch (data.status) {
      case AttendanceStatus.present:
        badgeColor = const Color(0xFF2E7D32);
        label = 'P';
        textColor = Colors.white;
      case AttendanceStatus.absent:
        badgeColor = const Color(0xFFC62828);
        label = 'A';
        textColor = Colors.white;
      case AttendanceStatus.holiday:
        badgeColor = const Color(0xFFF57C00).withValues(alpha: 0.15);
        label = 'H';
        textColor = const Color(0xFFF57C00);
      case AttendanceStatus.weekend:
        badgeColor = scheme.surfaceContainerHighest;
        label = '—';
        textColor = scheme.onSurfaceVariant.withValues(alpha: 0.4);
    }

    final bool isWeekendOrHoliday = data.status == AttendanceStatus.weekend ||
        data.status == AttendanceStatus.holiday;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Date number box
          Container(
            height: 26,
            decoration: BoxDecoration(
              border: Border.all(
                color: isWeekendOrHoliday
                    ? scheme.outlineVariant.withValues(alpha: 0.3)
                    : scheme.outlineVariant.withValues(alpha: 0.6),
                width: 0.5,
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(6),
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              '${data.day}',
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: isWeekendOrHoliday
                    ? FontWeight.w400
                    : FontWeight.w700,
                fontSize: 10,
                color: isWeekendOrHoliday
                    ? scheme.onSurfaceVariant.withValues(alpha: 0.4)
                    : scheme.onSurface,
              ),
            ),
          ),
          // P / A badge
          Container(
            height: 26,
            decoration: BoxDecoration(
              color: badgeColor,
              border: Border.all(
                color: isWeekendOrHoliday
                    ? scheme.outlineVariant.withValues(alpha: 0.3)
                    : Colors.transparent,
                width: 0.5,
              ),
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(6),
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              label,
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Legend ────────────────────────────────────────────────────────────────────

class _Legend extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    const items = [
      _LegendItem('P', Color(0xFF2E7D32), 'Present'),
      _LegendItem('A', Color(0xFFC62828), 'Absent'),
      _LegendItem('H', Color(0xFFF57C00), 'Holiday'),
      _LegendItem('—', null, 'Weekend'),
    ];

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: items.map((item) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: item.color?.withValues(alpha: item.label == 'H' ? 0.15 : 1.0)
                      ?? scheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(5),
                  border: item.color == null
                      ? Border.all(color: scheme.outlineVariant, width: 0.5)
                      : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  item.label,
                  style: TextStyle(
                    color: item.color != null
                        ? (item.label == 'H'
                            ? item.color
                            : Colors.white)
                        : scheme.onSurfaceVariant.withValues(alpha: 0.4),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                item.name,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _LegendItem {
  final String label;
  final Color? color;
  final String name;
  const _LegendItem(this.label, this.color, this.name);
}
