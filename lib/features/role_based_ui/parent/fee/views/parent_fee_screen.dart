import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/parent_fee_controller.dart';

class ParentFeeScreen extends StatelessWidget {
  const ParentFeeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(ParentFeeController());
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: scheme.surfaceContainerLowest,
      body: Obx(() => Stack(
            children: [
              CustomScrollView(
                slivers: [
                  _AppBar(controller: c),
                  SliverToBoxAdapter(child: _ChildTabs(controller: c)),
                  SliverToBoxAdapter(child: _StudentHeader(controller: c)),
                  SliverToBoxAdapter(child: _SummaryCards(controller: c)),
                  SliverToBoxAdapter(child: _FeeTable(controller: c)),
                  const SliverToBoxAdapter(child: SizedBox(height: 120)),
                ],
              ),
              // Floating pay bar (shown when rows are selected)
              if (c.selectedRows.isNotEmpty)
                Positioned(
                  bottom: 20,
                  left: 20,
                  right: 20,
                  child: _PayBar(controller: c),
                ),
            ],
          )),
    );
  }
}

// ── App Bar ───────────────────────────────────────────────────────────────────

class _AppBar extends StatelessWidget {
  final ParentFeeController controller;
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
        'Fee',
        style: TextStyle(
            color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
      ),
      actions: [
        Obx(() {
          final isTuition =
              controller.feeType.value == FeeType.tuition;
          return GestureDetector(
            onTap: controller.toggleFeeType,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 16),
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isTuition
                    ? Colors.white.withValues(alpha: 0.2)
                    : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: Colors.white.withValues(alpha: 0.6), width: 1.5),
              ),
              child: Text(
                isTuition ? 'TRANSPORT FEE' : 'TUITION FEE',
                style: TextStyle(
                  color: isTuition ? Colors.white : scheme.primary,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.4,
                ),
              ),
            ),
          );
        }),
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

// ── Child Tabs ────────────────────────────────────────────────────────────────

class _ChildTabs extends StatelessWidget {
  final ParentFeeController controller;
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
                  children:
                      List.generate(controller.children.length, (i) {
                    final child = controller.children[i];
                    final isSelected =
                        controller.selectedChildIndex.value == i;
                    return GestureDetector(
                      onTap: () => controller.selectChild(i),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(right: 10, bottom: 14),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 9),
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
                            Icon(
                              Icons.person_outline_rounded,
                              size: 14,
                              color: isSelected
                                  ? Colors.white
                                  : scheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              child.name.split(' ').first,
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
        ));
  }
}

// ── Student Header ────────────────────────────────────────────────────────────

class _StudentHeader extends StatelessWidget {
  final ParentFeeController controller;
  const _StudentHeader({required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Obx(() {
      final child = controller.selectedChild;
      if (child == null) return const SizedBox.shrink();

      return Container(
        color: scheme.surface,
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: scheme.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.school_outlined, color: scheme.primary, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    child.name.toUpperCase(),
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: scheme.onSurface,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    child.className,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Obx(() {
              final label = controller.feeType.value == FeeType.tuition
                  ? 'Tuition Fee'
                  : 'Transport Fee';
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: scheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border:
                      Border.all(color: scheme.primary.withValues(alpha: 0.3)),
                ),
                child: Text(
                  label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: scheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            }),
          ],
        ),
      );
    });
  }
}

// ── Summary Cards ─────────────────────────────────────────────────────────────

class _SummaryCards extends StatelessWidget {
  final ParentFeeController controller;
  const _SummaryCards({required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Obx(() {
      final totalFee = controller.totalFee;
      final totalPaid = controller.totalPaid;
      final totalDue = controller.totalDue;

      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: Row(
          children: [
            _SummaryCard(
              title: 'TOTAL\nFEE',
              value: '₹$totalFee',
              color: const Color(0xFF1565C0),
              icon: Icons.receipt_long_outlined,
              isDark: isDark,
              scheme: scheme,
              theme: theme,
            ),
            const SizedBox(width: 12),
            _SummaryCard(
              title: 'TOTAL\nPAID',
              value: '₹$totalPaid',
              color: const Color(0xFF2E7D32),
              icon: Icons.check_circle_outline_rounded,
              isDark: isDark,
              scheme: scheme,
              theme: theme,
            ),
            const SizedBox(width: 12),
            _SummaryCard(
              title: 'TOTAL\nDUE',
              value: '₹$totalDue',
              color: const Color(0xFFC62828),
              icon: Icons.warning_amber_rounded,
              isDark: isDark,
              scheme: scheme,
              theme: theme,
            ),
          ],
        ),
      );
    });
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  final IconData icon;
  final bool isDark;
  final ColorScheme scheme;
  final ThemeData theme;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.color,
    required this.icon,
    required this.isDark,
    required this.scheme,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: isDark ? 0.12 : 0.08),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: color,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  Icon(icon, color: Colors.white, size: 14),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      title.replaceAll('\n', ' '),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.3,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Text(
                value,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Fee Table ─────────────────────────────────────────────────────────────────

class _FeeTable extends StatelessWidget {
  final ParentFeeController controller;
  const _FeeTable({required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Obx(() {
      final entries = controller.currentEntries;

      return Container(
        margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
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
            ...List.generate(entries.length, (i) {
              return _TableRow(
                index: i,
                entry: entries[i],
                controller: controller,
                theme: theme,
                scheme: scheme,
                isEven: i % 2 == 0,
              );
            }),
          ],
        ),
      );
    });
  }
}

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
            Color.lerp(scheme.primary, Colors.white, 0.22) ?? scheme.primary,
          ],
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Row(
        children: [
          _HeaderCell('SELECT', flex: 2, theme: theme, center: true),
          _HeaderCell('MONTH', flex: 3, theme: theme, center: false),
          _HeaderCell('DETAIL', flex: 6, theme: theme, center: false),
          _HeaderCell('AMOUNT', flex: 3, theme: theme, center: true),
          _HeaderCell('ACTION', flex: 3, theme: theme, center: true),
        ],
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  final String label;
  final int flex;
  final ThemeData theme;
  final bool center;
  const _HeaderCell(this.label,
      {required this.flex, required this.theme, required this.center});

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
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

class _TableRow extends StatelessWidget {
  final int index;
  final FeeEntry entry;
  final ParentFeeController controller;
  final ThemeData theme;
  final ColorScheme scheme;
  final bool isEven;

  const _TableRow({
    required this.index,
    required this.entry,
    required this.controller,
    required this.theme,
    required this.scheme,
    required this.isEven,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isSelected = controller.isSelected(index);
      final isDue = entry.status == FeeStatus.due;
      final isPaid = entry.status == FeeStatus.paid;
      final isEmpty = entry.status == FeeStatus.notGenerated;

      Color rowBg;
      if (isSelected) {
        rowBg = scheme.primary.withValues(alpha: 0.08);
      } else {
        rowBg = isEven
            ? scheme.surface
            : scheme.surfaceContainerLowest;
      }

      return AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        color: rowBg,
        child: Column(
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  // SELECT checkbox
                  Expanded(
                    flex: 2,
                    child: Center(
                      child: isDue
                          ? GestureDetector(
                              onTap: () => controller.toggleRow(index),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 150),
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? scheme.primary
                                      : Colors.transparent,
                                  border: Border.all(
                                    color: isSelected
                                        ? scheme.primary
                                        : scheme.outlineVariant,
                                    width: 1.5,
                                  ),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: isSelected
                                    ? const Icon(Icons.check_rounded,
                                        color: Colors.white, size: 14)
                                    : null,
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                  ),
                  // MONTH
                  Expanded(
                    flex: 3,
                    child: Text(
                      entry.monthLabel,
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight:
                            entry.monthLabel == 'OLD DUE'
                                ? FontWeight.w700
                                : FontWeight.w600,
                        color: isEmpty
                            ? scheme.onSurfaceVariant.withValues(alpha: 0.5)
                            : scheme.onSurface,
                      ),
                    ),
                  ),
                  // DETAIL
                  Expanded(
                    flex: 6,
                    child: Text(
                      entry.detail,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: isEmpty
                            ? scheme.onSurfaceVariant.withValues(alpha: 0.3)
                            : scheme.onSurfaceVariant,
                        height: 1.4,
                      ),
                    ),
                  ),
                  // AMOUNT
                  Expanded(
                    flex: 3,
                    child: Text(
                      entry.amount > 0 ? '₹${entry.amount}' : '',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isPaid
                            ? const Color(0xFF2E7D32)
                            : isDue
                                ? const Color(0xFFC62828)
                                : scheme.onSurfaceVariant
                                    .withValues(alpha: 0.3),
                      ),
                    ),
                  ),
                  // ACTION
                  Expanded(
                    flex: 3,
                    child: isEmpty
                        ? const SizedBox.shrink()
                        : isPaid
                            ? _PaidButton(
                                entry: entry,
                                theme: theme,
                                controller: controller,
                              )
                            : isDue
                                ? _PayFeeButton(
                                    entry: entry,
                                    theme: theme,
                                    controller: controller,
                                  )
                                : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
            Divider(
              height: 1,
              color: scheme.outlineVariant.withValues(alpha: 0.4),
            ),
          ],
        ),
      );
    });
  }
}

// ── Action Buttons ────────────────────────────────────────────────────────────

class _PaidButton extends StatelessWidget {
  final FeeEntry entry;
  final ThemeData theme;
  final ParentFeeController controller;
  const _PaidButton(
      {required this.entry, required this.theme, required this.controller});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showFeeSlip(context, entry, theme, controller),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFF1B5E20),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(6)),
            ),
            child: const Center(
              child: Text(
                'PAID',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFF2E7D32),
              borderRadius:
                  const BorderRadius.vertical(bottom: Radius.circular(6)),
            ),
            child: const Center(
              child: Text(
                'FEE SLIP',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showFeeSlip(BuildContext ctx, FeeEntry entry, ThemeData theme,
      ParentFeeController c) {
    final scheme = theme.colorScheme;
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(24),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: scheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2E7D32).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.receipt_long_outlined,
                      color: Color(0xFF2E7D32), size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Fee Receipt',
                          style: theme.textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold)),
                      Text(
                        c.selectedChild?.name ?? '',
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: scheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2E7D32).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text('PAID',
                      style: TextStyle(
                        color: Color(0xFF2E7D32),
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      )),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _slipRow('Month', entry.monthLabel, theme, scheme),
            _slipRow('Detail', entry.detail, theme, scheme),
            _slipRow('Amount', '₹${entry.amount}', theme, scheme,
                valueColor: const Color(0xFF2E7D32)),
            _slipRow('Status', 'PAID', theme, scheme,
                valueColor: const Color(0xFF2E7D32)),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => Navigator.pop(ctx),
                icon: const Icon(Icons.download_outlined, size: 18),
                label: const Text('Download Receipt'),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

Widget _slipRow(String label, String value, ThemeData theme, ColorScheme scheme,
    {Color? valueColor}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(label,
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: scheme.onSurfaceVariant)),
        ),
        Text('  :  ',
            style: theme.textTheme.bodySmall
                ?.copyWith(color: scheme.onSurfaceVariant)),
        Expanded(
          child: Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: valueColor ?? scheme.onSurface,
            ),
          ),
        ),
      ],
    ),
  );
}

class _PayFeeButton extends StatelessWidget {
  final FeeEntry entry;
  final ThemeData theme;
  final ParentFeeController controller;
  const _PayFeeButton(
      {required this.entry, required this.theme, required this.controller});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showPayDialog(context, entry, theme, controller),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFC62828),
          borderRadius: BorderRadius.circular(6),
        ),
        child: const Center(
          child: Text(
            'PAY FEE',
            style: TextStyle(
              color: Colors.white,
              fontSize: 9,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }

  void _showPayDialog(BuildContext ctx, FeeEntry entry, ThemeData theme,
      ParentFeeController c) {
    final scheme = theme.colorScheme;
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: scheme.surface,
            borderRadius: BorderRadius.circular(24),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: scheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFC62828).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.payment_rounded,
                        color: Color(0xFFC62828), size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Pay Fee',
                            style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold)),
                        Text(
                          '${entry.monthLabel} · ${c.selectedChild?.name ?? ''}',
                          style: theme.textTheme.bodySmall?.copyWith(
                              color: scheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _slipRow('Month', entry.monthLabel, theme, scheme),
              _slipRow('Detail', entry.detail, theme, scheme),
              _slipRow('Amount', '₹${entry.amount}', theme, scheme,
                  valueColor: const Color(0xFFC62828)),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3E0),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: const Color(0xFFFF8F00).withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline,
                        color: Color(0xFFFF8F00), size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Online payment integration coming soon. '
                        'Please visit the school office to pay.',
                        style: theme.textTheme.bodySmall?.copyWith(
                            color: const Color(0xFFE65100)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => Navigator.pop(ctx),
                  icon: const Icon(Icons.close_rounded, size: 18),
                  label: const Text('Close'),
                  style: FilledButton.styleFrom(
                    backgroundColor: scheme.surfaceContainerHighest,
                    foregroundColor: scheme.onSurface,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Floating Pay Bar (multi-select) ───────────────────────────────────────────

class _PayBar extends StatelessWidget {
  final ParentFeeController controller;
  const _PayBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Obx(() {
      final count = controller.selectedRows.length;
      final total = controller.selectedTotal;

      return Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: scheme.primary,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: scheme.primary.withValues(alpha: 0.4),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$count month${count > 1 ? 's' : ''} selected',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: Colors.white70,
                  ),
                ),
                Text(
                  '₹$total',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Spacer(),
            TextButton(
              onPressed: controller.clearSelection,
              style: TextButton.styleFrom(foregroundColor: Colors.white70),
              child: const Text('Clear'),
            ),
            const SizedBox(width: 8),
            FilledButton(
              onPressed: () => _showBulkPayDialog(context, theme, controller),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: scheme.primary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 10),
              ),
              child: const Text(
                'PAY NOW',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
          ],
        ),
      );
    });
  }

  void _showBulkPayDialog(
      BuildContext ctx, ThemeData theme, ParentFeeController c) {
    final scheme = theme.colorScheme;
    showModalBottomSheet(
      context: ctx,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(24),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Pay ₹${c.selectedTotal}',
                style: theme.textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('${c.selectedRows.length} month(s) selected',
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: scheme.onSurfaceVariant)),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3E0),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: const Color(0xFFFF8F00).withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline,
                      color: Color(0xFFFF8F00), size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Online payment integration coming soon. '
                      'Please visit the school office.',
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: const Color(0xFFE65100)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  c.clearSelection();
                },
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('OK'),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
