import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../controllers/parent_timetable_controller.dart';

class ParentTimetableScreen extends StatelessWidget {
  const ParentTimetableScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(ParentTimetableController());
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
      body: CustomScrollView(
        slivers: [
          _AppBar(controller: c),
          SliverToBoxAdapter(child: _ChildTabs(controller: c)),
          SliverToBoxAdapter(child: _DateDayControls(controller: c)),
          SliverToBoxAdapter(child: _ClassBanner(controller: c)),
          SliverToBoxAdapter(child: _TimetableTable(controller: c)),
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }
}

// ── App Bar ───────────────────────────────────────────────────────────────────

class _AppBar extends StatelessWidget {
  final ParentTimetableController controller;
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
      backgroundColor: scheme.primary,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
        onPressed: () => Get.back(),
      ),
      title: const Text(
        'Time Table',
        style: TextStyle(
            color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
      ),
      actions: [
        Obx(() => Container(
              margin: const EdgeInsets.only(right: 16),
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: Colors.white.withValues(alpha: 0.5), width: 1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.schedule_rounded,
                      color: Colors.white, size: 14),
                  const SizedBox(width: 6),
                  Text(
                    controller.activeDayLabel,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            )),
      ],
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
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
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
  final ParentTimetableController controller;
  const _ChildTabs({required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Obx(() => Container(
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
                    final isSel = controller.selectedChildIndex.value == i;
                    return GestureDetector(
                      onTap: () => controller.selectChild(i),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(right: 10, bottom: 14),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 9),
                        decoration: BoxDecoration(
                          color: isSel
                              ? scheme.primary
                              : scheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                              color: isSel
                                  ? scheme.primary
                                  : scheme.outlineVariant),
                          boxShadow: isSel
                              ? [
                                  BoxShadow(
                                    color: scheme.primary
                                        .withValues(alpha: 0.28),
                                    blurRadius: 10,
                                    offset: const Offset(0, 3),
                                  )
                                ]
                              : null,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.person_outline_rounded,
                                size: 14,
                                color: isSel
                                    ? Colors.white
                                    : scheme.onSurfaceVariant),
                            const SizedBox(width: 6),
                            Text(
                              child.name.split(' ').first,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                                color: isSel
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
        ));
  }
}

// ── Date + Day Controls ───────────────────────────────────────────────────────

class _DateDayControls extends StatelessWidget {
  final ParentTimetableController controller;
  const _DateDayControls({required this.controller});

  static const _days = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT'];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Obx(() => Container(
          color: scheme.surface,
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Row 1: Date picker  +  AUTO badge
              Row(
                children: [
                  // Date chip
                  GestureDetector(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: controller.selectedDate.value,
                        firstDate: DateTime(2025),
                        lastDate: DateTime(2027),
                      );
                      if (picked != null) controller.pickDate(picked);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 9),
                      decoration: BoxDecoration(
                        color: scheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: scheme.outlineVariant),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.calendar_today_outlined,
                              size: 15, color: scheme.primary),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'SELECT DATE',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: scheme.onSurfaceVariant,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                  fontSize: 9,
                                ),
                              ),
                              Text(
                                DateFormat('dd MMM yyyy')
                                    .format(controller.selectedDate.value),
                                style: theme.textTheme.labelMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: scheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 8),
                          Icon(Icons.arrow_drop_down_rounded,
                              color: scheme.onSurfaceVariant, size: 18),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(),
                  // AUTO / manual day indicator
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 9),
                    decoration: BoxDecoration(
                      color: controller.isAutoDay
                          ? scheme.primary.withValues(alpha: 0.1)
                          : scheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: controller.isAutoDay
                            ? scheme.primary.withValues(alpha: 0.4)
                            : scheme.outlineVariant,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          controller.activeDayLabel,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: scheme.primary,
                            letterSpacing: 1,
                          ),
                        ),
                        Text(
                          controller.isAutoDay ? 'AUTO' : 'MANUAL',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: controller.isAutoDay
                                ? scheme.primary
                                : scheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                            fontSize: 9,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Row 2: Day chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    // AUTO chip
                    _DayChip(
                      label: 'AUTO',
                      isSelected: controller.isAutoDay,
                      scheme: scheme,
                      theme: theme,
                      onTap: () {
                        if (!controller.isAutoDay) {
                          controller.manualDay.value = '';
                        }
                      },
                    ),
                    const SizedBox(width: 8),
                    ..._days.map((d) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: _DayChip(
                            label: d,
                            isSelected: !controller.isAutoDay &&
                                controller.manualDay.value == d,
                            scheme: scheme,
                            theme: theme,
                            onTap: () => controller.selectDay(d),
                          ),
                        )),
                  ],
                ),
              ),
            ],
          ),
        ));
  }
}

class _DayChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final ColorScheme scheme;
  final ThemeData theme;
  final VoidCallback onTap;

  const _DayChip({
    required this.label,
    required this.isSelected,
    required this.scheme,
    required this.theme,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? scheme.primary : scheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
          border:
              Border.all(color: isSelected ? scheme.primary : scheme.outlineVariant),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: scheme.primary.withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ]
              : null,
        ),
        child: Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
            color: isSelected ? Colors.white : scheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

// ── Class Banner ──────────────────────────────────────────────────────────────

class _ClassBanner extends StatelessWidget {
  final ParentTimetableController controller;
  const _ClassBanner({required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Obx(() {
      final child = controller.selectedChild;
      if (child == null) return const SizedBox.shrink();

      return Container(
        margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
        padding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: scheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.class_outlined,
                  color: scheme.primary, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TIME TABLE — ${child.className.toUpperCase()}',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: scheme.onSurface,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${controller.currentPeriods.where((p) => !p.isBreak).length} periods · '
                    '${DateFormat('EEEE, d MMM').format(controller.selectedDate.value)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            // Period count badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: scheme.primary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                controller.activeDayLabel,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  letterSpacing: 1,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}

// ── Timetable Table ───────────────────────────────────────────────────────────

class _TimetableTable extends StatelessWidget {
  final ParentTimetableController controller;
  const _TimetableTable({required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Obx(() {
      final periods = controller.currentPeriods;

      if (periods.isEmpty) {
        return Container(
          margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            color: scheme.surface,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              Icon(Icons.event_busy_outlined,
                  size: 48, color: scheme.onSurfaceVariant.withValues(alpha: 0.4)),
              const SizedBox(height: 12),
              Text(
                'No timetable for this day',
                style: theme.textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant),
              ),
            ],
          ),
        );
      }

      return Container(
        margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            _TableHeader(theme: theme, scheme: scheme),
            ...List.generate(periods.length, (i) {
              final p = periods[i];
              final isCurrent = controller.isCurrentPeriod(p);
              return _PeriodRow(
                period: p,
                isEven: i % 2 == 0,
                isCurrent: isCurrent,
                theme: theme,
                scheme: scheme,
                isDark: isDark,
              );
            }),
          ],
        ),
      );
    });
  }
}

// ── Table Header ──────────────────────────────────────────────────────────────

class _TableHeader extends StatelessWidget {
  final ThemeData theme;
  final ColorScheme scheme;
  const _TableHeader({required this.theme, required this.scheme});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            scheme.primary,
            Color.lerp(scheme.primary, Colors.white, 0.2) ?? scheme.primary,
          ],
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          _Head('PERIOD', flex: 2, center: true, theme: theme),
          _Head('TIME', flex: 3, center: false, theme: theme),
          _Head('TEACHER', flex: 4, center: false, theme: theme),
          _Head('SUBJECT', flex: 4, center: false, theme: theme),
          _Head('SUB SUBJECT', flex: 4, center: false, theme: theme),
        ],
      ),
    );
  }
}

class _Head extends StatelessWidget {
  final String label;
  final int flex;
  final bool center;
  final ThemeData theme;
  const _Head(this.label,
      {required this.flex, required this.center, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Text(
        label,
        textAlign: center ? TextAlign.center : TextAlign.left,
        style: theme.textTheme.labelSmall?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

// ── Period Row ────────────────────────────────────────────────────────────────

class _PeriodRow extends StatelessWidget {
  final Period period;
  final bool isEven;
  final bool isCurrent;
  final ThemeData theme;
  final ColorScheme scheme;
  final bool isDark;

  const _PeriodRow({
    required this.period,
    required this.isEven,
    required this.isCurrent,
    required this.theme,
    required this.scheme,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    if (period.isBreak) return _BreakRow(theme: theme, scheme: scheme, period: period);

    Color rowBg;
    if (isCurrent) {
      rowBg = scheme.primary.withValues(alpha: isDark ? 0.18 : 0.07);
    } else {
      rowBg = isEven ? scheme.surface : scheme.surfaceContainerLowest;
    }

    // Subject color mapping
    final subjectColor = _subjectColor(period.subject);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      color: rowBg,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                // PERIOD number
                Expanded(
                  flex: 2,
                  child: Center(
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: isCurrent
                            ? scheme.primary
                            : subjectColor.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${period.number}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isCurrent
                                ? Colors.white
                                : subjectColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                // TIME
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        period.startTime,
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: scheme.onSurface,
                          fontSize: 10,
                        ),
                      ),
                      Text(
                        period.endTime,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
                // TEACHER
                Expanded(
                  flex: 4,
                  child: Text(
                    period.teacher,
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: scheme.onSurface,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // SUBJECT
                Expanded(
                  flex: 4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: subjectColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      period.subject,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: subjectColor,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                // SUB SUBJECT
                Expanded(
                  flex: 4,
                  child: Text(
                    period.subSubject,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                      fontSize: 10,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
              ],
            ),
          ),
          // Current period indicator strip
          if (isCurrent)
            Container(
              height: 2,
              color: scheme.primary,
            )
          else
            Divider(
              height: 1,
              color: scheme.outlineVariant.withValues(alpha: 0.4),
            ),
        ],
      ),
    );
  }

  Color _subjectColor(String subject) {
    final s = subject.toLowerCase();
    if (s.contains('math')) return const Color(0xFF1565C0);
    if (s.contains('science') || s.contains('physics') ||
        s.contains('chemistry') || s.contains('biology') ||
        s.contains('evs')) {
      return const Color(0xFF2E7D32);
    }
    if (s.contains('english')) return const Color(0xFF6A1B9A);
    if (s.contains('hindi') || s.contains('sanskrit')) {
      return const Color(0xFFE65100);
    }
    if (s.contains('social') || s.contains('history') ||
        s.contains('geography') || s.contains('civics')) {
      return const Color(0xFF00695C);
    }
    if (s.contains('computer')) return const Color(0xFF1976D2);
    if (s.contains('physical') || s.contains('sport') ||
        s.contains('yoga') || s.contains('dance')) {
      return const Color(0xFFAD1457);
    }
    if (s.contains('art') || s.contains('music') ||
        s.contains('drawing') || s.contains('craft')) {
      return const Color(0xFFF57C00);
    }
    if (s.contains('general') || s.contains('moral')) {
      return const Color(0xFF546E7A);
    }
    return const Color(0xFF455A64);
  }
}

// ── Break Row ─────────────────────────────────────────────────────────────────

class _BreakRow extends StatelessWidget {
  final ThemeData theme;
  final ColorScheme scheme;
  final Period period;
  const _BreakRow(
      {required this.theme, required this.scheme, required this.period});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFFFF8E1),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Center(
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: const Color(0xFFF57C00).withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(Icons.coffee_outlined,
                      size: 16, color: Color(0xFFF57C00)),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  period.startTime,
                  style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFF57C00)),
                ),
                Text(
                  period.endTime,
                  style: TextStyle(
                      fontSize: 10,
                      color:
                          const Color(0xFFF57C00).withValues(alpha: 0.7)),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 12,
            child: Text(
              'BREAK  ·  ${period.startTime} – ${period.endTime}',
              style: theme.textTheme.labelMedium?.copyWith(
                color: const Color(0xFFF57C00),
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
