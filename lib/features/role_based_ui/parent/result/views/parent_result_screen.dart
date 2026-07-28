import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/parent_result_controller.dart';

class ParentResultScreen extends StatelessWidget {
  const ParentResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(ParentResultController());
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: scheme.surfaceContainerLowest,
      body: CustomScrollView(
        slivers: [
          _AppBar(c: c),
          SliverToBoxAdapter(child: _ChildTabs(c: c)),
          SliverToBoxAdapter(child: _FilterRow(c: c)),
          SliverToBoxAdapter(child: _ClassBanner(c: c)),
          SliverToBoxAdapter(child: _ViewToggle(c: c)),
          SliverToBoxAdapter(
            child: Obx(() => c.isCardView.value
                ? _ResultCards(c: c)
                : _ResultTable(c: c)),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }
}

// ── App Bar ───────────────────────────────────────────────────────────────────

class _AppBar extends StatelessWidget {
  final ParentResultController c;
  const _AppBar({required this.c});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final light = Color.lerp(scheme.primary, Colors.white, 0.38) ?? scheme.primary;

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
      title: const Text('Result',
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.pin,
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [scheme.primary, light],
            ),
          ),
          child: Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
              child: Row(children: [
                const Icon(Icons.school_rounded, color: Colors.white70, size: 13),
                const SizedBox(width: 6),
                Text('PRATIBHA INTER COLLEGE · DEWA-BARABANKI',
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white, fontWeight: FontWeight.w600)),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Child Tabs ────────────────────────────────────────────────────────────────

class _ChildTabs extends StatelessWidget {
  final ParentResultController c;
  const _ChildTabs({required this.c});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Obx(() => Container(
          color: scheme.surface,
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Select Child',
                style: theme.textTheme.labelSmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.8)),
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(c.children.length, (i) {
                  final child = c.children[i];
                  final sel = c.selectedChildIndex.value == i;
                  return GestureDetector(
                    onTap: () => c.selectChild(i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(right: 10, bottom: 14),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 9),
                      decoration: BoxDecoration(
                        color: sel ? scheme.primary : scheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                            color: sel ? scheme.primary : scheme.outlineVariant),
                        boxShadow: sel
                            ? [BoxShadow(
                                color: scheme.primary.withValues(alpha: 0.28),
                                blurRadius: 10, offset: const Offset(0, 3))]
                            : null,
                      ),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(Icons.person_outline_rounded,
                            size: 14,
                            color: sel ? Colors.white : scheme.onSurfaceVariant),
                        const SizedBox(width: 6),
                        Text(child.name.split(' ').first,
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                                color: sel ? Colors.white : scheme.onSurface)),
                      ]),
                    ),
                  );
                }),
              ),
            ),
            Divider(height: 1, color: scheme.outlineVariant),
          ]),
        ));
  }
}

// ── Filter Row ────────────────────────────────────────────────────────────────

class _FilterRow extends StatelessWidget {
  final ParentResultController c;
  const _FilterRow({required this.c});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Obx(() => Container(
          color: scheme.surface,
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // SESSION
              Expanded(
                child: _FilterDropdown(
                  label: 'SESSION',
                  value: c.selectedSession.value,
                  items: ParentResultController.sessions,
                  scheme: scheme,
                  theme: theme,
                  onChanged: (v) => c.selectedSession.value = v,
                ),
              ),
              const SizedBox(width: 10),
              // CLASS (auto)
              Expanded(
                child: _FilterInfo(
                  label: 'CLASS',
                  value: c.selectedChild?.className ?? '—',
                  hint: 'Auto from child selection',
                  scheme: scheme,
                  theme: theme,
                ),
              ),
              const SizedBox(width: 10),
              // EXAM TYPE
              Expanded(
                child: _FilterDropdown(
                  label: 'EXAM TYPE',
                  value: ParentResultController
                      .examFilterOptions[c.selectedExamFilter.value],
                  items: ParentResultController.examFilterOptions,
                  scheme: scheme,
                  theme: theme,
                  onChanged: (v) => c.selectedExamFilter.value =
                      ParentResultController.examFilterOptions.indexOf(v),
                ),
              ),
            ],
          ),
        ));
  }
}

class _FilterDropdown extends StatelessWidget {
  final String label;
  final String value;
  final List<String> items;
  final ColorScheme scheme;
  final ThemeData theme;
  final void Function(String) onChanged;

  const _FilterDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.scheme,
    required this.theme,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showPicker(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: scheme.outlineVariant),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label,
              style: theme.textTheme.labelSmall?.copyWith(
                  color: scheme.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 9,
                  letterSpacing: 0.6)),
          const SizedBox(height: 4),
          Row(children: [
            Expanded(
              child: Text(value,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w600, color: scheme.onSurface)),
            ),
            Icon(Icons.arrow_drop_down_rounded,
                size: 16, color: scheme.onSurfaceVariant),
          ]),
        ]),
      ),
    );
  }

  void _showPicker(BuildContext ctx) {
    final scheme = Theme.of(ctx).colorScheme;
    showModalBottomSheet(
      context: ctx,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const SizedBox(height: 12),
          Container(width: 40, height: 4,
              decoration: BoxDecoration(
                  color: scheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(label,
                style: Theme.of(ctx).textTheme.titleSmall
                    ?.copyWith(fontWeight: FontWeight.bold)),
          ),
          const Divider(height: 20),
          ...items.map((item) => ListTile(
                title: Text(item),
                trailing: item == value
                    ? Icon(Icons.check_rounded, color: scheme.primary)
                    : null,
                onTap: () {
                  onChanged(item);
                  Navigator.pop(ctx);
                },
              )),
          const SizedBox(height: 12),
        ]),
      ),
    );
  }
}

class _FilterInfo extends StatelessWidget {
  final String label;
  final String value;
  final String hint;
  final ColorScheme scheme;
  final ThemeData theme;

  const _FilterInfo({
    required this.label,
    required this.value,
    required this.hint,
    required this.scheme,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: scheme.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: scheme.primary.withValues(alpha: 0.25)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text(label,
              style: theme.textTheme.labelSmall?.copyWith(
                  color: scheme.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 9,
                  letterSpacing: 0.6)),
          const SizedBox(width: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
            decoration: BoxDecoration(
              color: scheme.primary,
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text('AUTO',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 7,
                    fontWeight: FontWeight.bold)),
          ),
        ]),
        const SizedBox(height: 4),
        Text(value,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelSmall
                ?.copyWith(fontWeight: FontWeight.w600, color: scheme.onSurface)),
      ]),
    );
  }
}

// ── Class Banner ──────────────────────────────────────────────────────────────

class _ClassBanner extends StatelessWidget {
  final ParentResultController c;
  const _ClassBanner({required this.c});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Obx(() {
      final child = c.selectedChild;
      if (child == null) return const SizedBox.shrink();
      return Container(
        margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10, offset: const Offset(0, 3))],
        ),
        child: Row(children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: scheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.assessment_outlined, color: scheme.primary, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('RESULT — ${child.className.toUpperCase()}',
                style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold, color: scheme.onSurface)),
            const SizedBox(height: 3),
            Text('Session: ${c.selectedSession.value}  ·  '
                '${ParentResultController.examFilterOptions[c.selectedExamFilter.value]}',
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: scheme.onSurfaceVariant)),
          ])),
          // Quick summary pill
          Obx(() {
            final tot = c.grandTotalObtained;
            final max = c.grandTotalMax;
            if (tot == null) {
              return _badge('PENDING', const Color(0xFFF57C00));
            }
            final pct = max > 0 ? (tot / max * 100) : 0.0;
            final color = pct >= 60
                ? const Color(0xFF2E7D32)
                : pct >= 33
                    ? const Color(0xFF1565C0)
                    : const Color(0xFFC62828);
            return _badge('${pct.toStringAsFixed(1)}%', color);
          }),
        ]),
      );
    });
  }
}

Widget _badge(String label, Color color) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(label,
          style: TextStyle(
              color: color, fontWeight: FontWeight.bold, fontSize: 12)),
    );

// ── Result Table ──────────────────────────────────────────────────────────────

class _ResultTable extends StatelessWidget {
  final ParentResultController c;
  const _ResultTable({required this.c});

  // Column widths
  static const double _subjW = 120;
  static const double _mmW = 46;
  static const double _obtW = 54;
  static const double _examW = _mmW + _obtW; // 100 per exam group
  static const double _h1 = 40; // exam label row
  static const double _h2 = 34; // M.M./OBT.M. row
  static const double _rowH = 44; // data row
  static const double _sumH = 44; // summary row

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Obx(() {
      final subjects = c.currentSubjects;
      final examIndices = c.visibleExamIndices;

      if (subjects.isEmpty) {
        return Container(
          margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
              color: scheme.surface,
              borderRadius: BorderRadius.circular(20)),
          child: Column(children: [
            Icon(Icons.assessment_outlined,
                size: 48,
                color: scheme.onSurfaceVariant.withValues(alpha: 0.4)),
            const SizedBox(height: 12),
            Text('No result data available',
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: scheme.onSurfaceVariant)),
          ]),
        );
      }

      return Container(
        margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 12, offset: const Offset(0, 3))],
        ),
        clipBehavior: Clip.antiAlias,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Sticky subject column ───────────────────────────────
            _SubjectColumn(
              subjects: subjects,
              examIndices: examIndices,
              c: c,
              theme: theme,
              scheme: scheme,
              isDark: isDark,
            ),
            // ── Scrollable exam columns ─────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: _ExamColumns(
                  subjects: subjects,
                  examIndices: examIndices,
                  c: c,
                  theme: theme,
                  scheme: scheme,
                  isDark: isDark,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}

// ── Sticky subject column ─────────────────────────────────────────────────────

class _SubjectColumn extends StatelessWidget {
  final List<SubjectResult> subjects;
  final List<int> examIndices;
  final ParentResultController c;
  final ThemeData theme;
  final ColorScheme scheme;
  final bool isDark;

  const _SubjectColumn({
    required this.subjects,
    required this.examIndices,
    required this.c,
    required this.theme,
    required this.scheme,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final divColor = scheme.outlineVariant.withValues(alpha: 0.5);
    return SizedBox(
      width: _ResultTable._subjW,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(right: BorderSide(color: divColor, width: 1.5)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Exam label row (blank)
          _cell(height: _ResultTable._h1, color: scheme.primary,
              child: const SizedBox.shrink()),
          // Column header row
          _cell(
            height: _ResultTable._h2,
            color: scheme.primary.withValues(alpha: 0.85),
            child: Padding(
              padding: const EdgeInsets.only(left: 12),
              child: Text('SUBJECT',
                  style: theme.textTheme.labelSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.3)),
            ),
          ),
          // Subject rows
          ...subjects.asMap().entries.map((e) {
            final i = e.key;
            final sub = e.value;
            final odd = i % 2 == 1;
            return _cell(
              height: _ResultTable._rowH,
              color: odd ? scheme.surfaceContainerLowest : scheme.surface,
              child: Padding(
                padding: const EdgeInsets.only(left: 12),
                child: Text(sub.name,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelSmall
                        ?.copyWith(fontWeight: FontWeight.w600,
                            color: scheme.onSurface)),
              ),
            );
          }),
          // Summary rows
          _summaryLabelCell('TOTAL', scheme, theme),
          _summaryLabelCell('RESULT', scheme, theme),
          _summaryLabelCell('DIVISION', scheme, theme),
        ]),
      ),
    );
  }

  Widget _summaryLabelCell(String label, ColorScheme sc, ThemeData t) {
    final color = label == 'TOTAL'
        ? sc.primary.withValues(alpha: 0.08)
        : label == 'RESULT'
            ? const Color(0xFF2E7D32).withValues(alpha: 0.07)
            : const Color(0xFF1565C0).withValues(alpha: 0.07);
    return _cell(
      height: _ResultTable._sumH,
      color: color,
      child: Padding(
        padding: const EdgeInsets.only(left: 12),
        child: Text(label,
            style: t.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.bold, color: sc.onSurface,
                letterSpacing: 0.4)),
      ),
    );
  }

  Widget _cell({required double height, Color? color, required Widget child}) {
    return Container(
      height: height,
      width: _ResultTable._subjW,
      color: color,
      alignment: Alignment.centerLeft,
      child: child,
    );
  }
}

// ── Scrollable exam columns ───────────────────────────────────────────────────

class _ExamColumns extends StatelessWidget {
  final List<SubjectResult> subjects;
  final List<int> examIndices;
  final ParentResultController c;
  final ThemeData theme;
  final ColorScheme scheme;
  final bool isDark;

  const _ExamColumns({
    required this.subjects,
    required this.examIndices,
    required this.c,
    required this.theme,
    required this.scheme,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final totalW = examIndices.length * _ResultTable._examW;
    final divColor = scheme.outlineVariant.withValues(alpha: 0.4);

    return SizedBox(
      width: totalW,
      child: Column(children: [
        // ── Row 1: Exam labels ───────────────────────────────────────
        Row(children: examIndices.map((ei) {
          return _examHeaderGroup(ei, divColor);
        }).toList()),

        // ── Row 2: M.M. / OBT.M. headers ───────────────────────────
        Row(children: examIndices.expand((ei) {
          return [
            _subHeader('M.M.', ei, isFirst: true),
            _subHeader('OBT. M.', ei, isFirst: false),
          ];
        }).toList()),

        // ── Data rows ─────────────────────────────────────────────────
        ...subjects.asMap().entries.map((entry) {
          final si = entry.key;
          final sub = entry.value;
          final odd = si % 2 == 1;
          return Row(children: examIndices.expand((ei) {
            final mark = sub.exams[ei];
            return [
              _dataCell(_fmtMM(mark.maxMarks), ei, si,
                  isFirst: true,
                  odd: odd,
                  color: scheme.onSurfaceVariant.withValues(alpha: 0.6)),
              _dataCell(_fmtObt(mark), ei, si,
                  isFirst: false,
                  odd: odd,
                  color: _obtColor(mark, scheme)),
            ];
          }).toList());
        }),

        // ── TOTAL row ─────────────────────────────────────────────────
        Row(children: examIndices.expand((ei) {
          final mm = c.totalMaxMarks(ei);
          final obt = c.totalObtained(ei);
          final bg = scheme.primary.withValues(alpha: 0.08);
          return [
            _summaryCell('$mm', bg, scheme, isFirst: true),
            _summaryCell(obt != null ? '$obt' : '—', bg, scheme,
                isFirst: false,
                color: obt != null ? scheme.primary : scheme.onSurfaceVariant),
          ];
        }).toList()),

        // ── RESULT row ─────────────────────────────────────────────────
        Row(children: examIndices.expand((ei) {
          final bg = const Color(0xFF2E7D32).withValues(alpha: 0.07);
          final obt = c.totalObtained(ei);
          final mm = c.totalMaxMarks(ei);
          String res = '—';
          Color col = scheme.onSurfaceVariant;
          if (obt != null && mm > 0) {
            res = (obt / mm) >= 0.33 ? 'PASS' : 'FAIL';
            col = res == 'PASS'
                ? const Color(0xFF2E7D32)
                : const Color(0xFFC62828);
          }
          return [
            _summaryCell('', bg, scheme, isFirst: true),
            _summaryCell(res, bg, scheme, isFirst: false, color: col),
          ];
        }).toList()),

        // ── DIVISION row ──────────────────────────────────────────────
        Row(children: examIndices.expand((ei) {
          final bg = const Color(0xFF1565C0).withValues(alpha: 0.07);
          final obt = c.totalObtained(ei);
          final mm = c.totalMaxMarks(ei);
          String div = '—';
          Color col = scheme.onSurfaceVariant;
          if (obt != null && mm > 0) {
            final pct = obt / mm * 100;
            if (pct >= 60) { div = '1st'; col = const Color(0xFF2E7D32); }
            else if (pct >= 45) { div = '2nd'; col = const Color(0xFF1565C0); }
            else if (pct >= 33) { div = '3rd'; col = const Color(0xFFF57C00); }
            else { div = 'FAIL'; col = const Color(0xFFC62828); }
          }
          return [
            _summaryCell('', bg, scheme, isFirst: true),
            _summaryCell(div, bg, scheme, isFirst: false, color: col),
          ];
        }).toList()),
      ]),
    );
  }

  // ── Helpers ─────────────────────────────────────────────────────────────────

  String _fmtMM(int mm) => '$mm';
  String _fmtObt(ExamMark m) => m.isDeclared ? '${m.obtained}' : '—';

  Color _obtColor(ExamMark m, ColorScheme sc) {
    if (!m.isDeclared) return sc.onSurfaceVariant.withValues(alpha: 0.4);
    return m.isPassing ? const Color(0xFF2E7D32) : const Color(0xFFC62828);
  }

  Widget _examHeaderGroup(int ei, Color divColor) {
    return Container(
      width: _ResultTable._examW,
      height: _ResultTable._h1,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            scheme.primary.withValues(alpha: 0.9 - ei * 0.08),
            scheme.primary.withValues(alpha: 0.78 - ei * 0.08),
          ],
        ),
        border: Border(left: BorderSide(color: Colors.white.withValues(alpha: 0.2))),
      ),
      alignment: Alignment.center,
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text(ParentResultController.examShortLabels[ei],
            style: theme.textTheme.labelSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5)),
        Text(_examSubLabel(ei),
            style: const TextStyle(color: Colors.white70, fontSize: 9)),
      ]),
    );
  }

  String _examSubLabel(int ei) {
    const sub = ['UT-1', 'UT-2', 'Half Yearly', 'Annual'];
    return sub[ei];
  }

  Widget _subHeader(String label, int ei, {required bool isFirst}) {
    return Container(
      width: isFirst ? _ResultTable._mmW : _ResultTable._obtW,
      height: _ResultTable._h2,
      decoration: BoxDecoration(
        color: scheme.primary.withValues(alpha: 0.82 - ei * 0.07),
        border: Border(
          left: BorderSide(
            color: Colors.white.withValues(alpha: isFirst ? 0.2 : 0.1),
          ),
        ),
      ),
      alignment: Alignment.center,
      child: Text(label,
          style: theme.textTheme.labelSmall?.copyWith(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 9)),
    );
  }

  Widget _dataCell(String value, int ei, int si,
      {required bool isFirst, required bool odd, Color? color}) {
    return Container(
      width: isFirst ? _ResultTable._mmW : _ResultTable._obtW,
      height: _ResultTable._rowH,
      decoration: BoxDecoration(
        color: odd ? scheme.surfaceContainerLowest : scheme.surface,
        border: Border(
          left: BorderSide(
            color: scheme.outlineVariant.withValues(alpha: isFirst ? 0.5 : 0.25),
            width: 0.5,
          ),
        ),
      ),
      alignment: Alignment.center,
      child: Text(value,
          style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: isFirst ? FontWeight.w500 : FontWeight.bold,
              color: color ?? scheme.onSurface,
              fontSize: isFirst ? 11 : 12)),
    );
  }

  Widget _summaryCell(String value, Color bg, ColorScheme sc,
      {required bool isFirst, Color? color}) {
    return Container(
      width: isFirst ? _ResultTable._mmW : _ResultTable._obtW,
      height: _ResultTable._sumH,
      color: bg,
      alignment: Alignment.center,
      child: value.isEmpty
          ? const SizedBox.shrink()
          : Text(value,
              style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color ?? sc.onSurface,
                  fontSize: 11)),
    );
  }
}

// ── View Toggle ───────────────────────────────────────────────────────────────

class _ViewToggle extends StatelessWidget {
  final ParentResultController c;
  const _ViewToggle({required this.c});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Obx(() {
      final isCard = c.isCardView.value;
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        child: Row(
          children: [
            Text(
              isCard ? 'Card View' : 'Table View',
              style: theme.textTheme.labelMedium?.copyWith(
                color: scheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            // Segmented toggle
            Container(
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: scheme.outlineVariant),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _ToggleBtn(
                    icon: Icons.table_rows_rounded,
                    label: 'Table',
                    selected: !isCard,
                    scheme: scheme,
                    theme: theme,
                    onTap: () { if (isCard) c.toggleView(); },
                  ),
                  _ToggleBtn(
                    icon: Icons.grid_view_rounded,
                    label: 'Cards',
                    selected: isCard,
                    scheme: scheme,
                    theme: theme,
                    onTap: () { if (!isCard) c.toggleView(); },
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _ToggleBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final ColorScheme scheme;
  final ThemeData theme;
  final VoidCallback onTap;

  const _ToggleBtn({
    required this.icon,
    required this.label,
    required this.selected,
    required this.scheme,
    required this.theme,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? scheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(11),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 15,
                color: selected ? Colors.white : scheme.onSurfaceVariant),
            const SizedBox(width: 5),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: selected ? Colors.white : scheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Result Cards ──────────────────────────────────────────────────────────────

class _ResultCards extends StatelessWidget {
  final ParentResultController c;
  const _ResultCards({required this.c});

  static const _examFullNames = [
    'Unit Test 1', 'Unit Test 2', 'Half Yearly', 'Annual Exam'
  ];
  static const _examColors = [
    Color(0xFF1565C0), Color(0xFF6A1B9A),
    Color(0xFF00695C), Color(0xFFBF360C),
  ];

  @override
  Widget build(BuildContext context) {
    final examIndices = c.visibleExamIndices;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Column(
        children: examIndices.map((ei) => _ExamCard(
          examIndex: ei,
          examLabel: ParentResultController.examShortLabels[ei],
          examFullName: _examFullNames[ei],
          accentColor: _examColors[ei],
          subjects: c.currentSubjects,
          totalMM: c.totalMaxMarks(ei),
          totalObt: c.totalObtained(ei),
          controller: c,
        )).toList(),
      ),
    );
  }
}

class _ExamCard extends StatelessWidget {
  final int examIndex;
  final String examLabel;
  final String examFullName;
  final Color accentColor;
  final List<SubjectResult> subjects;
  final int totalMM;
  final int? totalObt;
  final ParentResultController controller;

  const _ExamCard({
    required this.examIndex,
    required this.examLabel,
    required this.examFullName,
    required this.accentColor,
    required this.subjects,
    required this.totalMM,
    required this.totalObt,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final pct = (totalObt != null && totalMM > 0)
        ? (totalObt! / totalMM * 100)
        : null;
    final isPending = totalObt == null;

    // Result & division
    String result = '—';
    String division = '—';
    Color resultColor = scheme.onSurfaceVariant;
    Color divColor = scheme.onSurfaceVariant;

    if (pct != null) {
      result = pct >= 33 ? 'PASS' : 'FAIL';
      resultColor = pct >= 33 ? const Color(0xFF2E7D32) : const Color(0xFFC62828);
      if (pct >= 60) { division = '1st Division'; divColor = const Color(0xFF2E7D32); }
      else if (pct >= 45) { division = '2nd Division'; divColor = const Color(0xFF1565C0); }
      else if (pct >= 33) { division = '3rd Division'; divColor = const Color(0xFFF57C00); }
      else { division = 'FAIL'; divColor = const Color(0xFFC62828); }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: isDark ? 0.14 : 0.10),
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // ── Gradient header ─────────────────────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  accentColor,
                  Color.lerp(accentColor, Colors.white, isDark ? 0.08 : 0.24) ??
                      accentColor,
                ],
              ),
            ),
            child: Row(
              children: [
                // Exam badge
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.description_outlined,
                      color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                // Exam info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(examLabel,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          )),
                      Text(examFullName,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.white70,
                          )),
                    ],
                  ),
                ),
                // Status badge
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: Colors.white.withValues(alpha: 0.4)),
                  ),
                  child: Text(
                    isPending ? 'PENDING' : result,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Score summary strip ─────────────────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 12),
            color: accentColor.withValues(alpha: isDark ? 0.12 : 0.06),
            child: Column(
              children: [
                Row(
                  children: [
                    _scorePill('MAX MARKS', '$totalMM', accentColor, theme),
                    const SizedBox(width: 10),
                    _scorePill(
                      'OBTAINED',
                      isPending ? '—' : '${totalObt!}',
                      isPending
                          ? scheme.onSurfaceVariant
                          : (pct! >= 33
                              ? const Color(0xFF2E7D32)
                              : const Color(0xFFC62828)),
                      theme,
                    ),
                    const SizedBox(width: 10),
                    _scorePill(
                      'PERCENTAGE',
                      isPending ? '—' : '${pct!.toStringAsFixed(1)}%',
                      isPending ? scheme.onSurfaceVariant : accentColor,
                      theme,
                    ),
                  ],
                ),
                if (!isPending) ...[
                  const SizedBox(height: 10),
                  // Progress bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: pct! / 100,
                      minHeight: 7,
                      backgroundColor:
                          scheme.outlineVariant.withValues(alpha: 0.4),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        pct >= 60
                            ? const Color(0xFF2E7D32)
                            : pct >= 33
                                ? accentColor
                                : const Color(0xFFC62828),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // ── Subject rows ────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 10, 18, 0),
            child: Column(
              children: subjects.asMap().entries.map((entry) {
                final i = entry.key;
                final sub = entry.value;
                final mark = sub.exams[examIndex];
                final obtColor = !mark.isDeclared
                    ? scheme.onSurfaceVariant.withValues(alpha: 0.4)
                    : mark.isPassing
                        ? const Color(0xFF2E7D32)
                        : const Color(0xFFC62828);

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 9),
                      child: Row(
                        children: [
                          // Subject number circle
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color:
                                  accentColor.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '${i + 1}',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: accentColor,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          // Subject name
                          Expanded(
                            child: Text(
                              sub.name,
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: scheme.onSurface,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          // M.M. / Obtained
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${mark.obtained ?? '—'}',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: obtColor,
                                ),
                              ),
                              Text(
                                ' / ${mark.maxMarks}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: scheme.onSurfaceVariant,
                                ),
                              ),
                              // Pass/fail dot
                              const SizedBox(width: 6),
                              Container(
                                width: 7,
                                height: 7,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: !mark.isDeclared
                                      ? scheme.outlineVariant
                                      : mark.isPassing
                                          ? const Color(0xFF2E7D32)
                                          : const Color(0xFFC62828),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (i < subjects.length - 1)
                      Divider(
                        height: 1,
                        color:
                            scheme.outlineVariant.withValues(alpha: 0.4),
                      ),
                  ],
                );
              }).toList(),
            ),
          ),

          // ── Footer: Total + Division ────────────────────────────────
          Container(
            margin: const EdgeInsets.fromLTRB(18, 10, 18, 0),
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: isDark ? 0.12 : 0.06),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _FooterStat(
                    label: 'TOTAL',
                    value: isPending
                        ? '— / $totalMM'
                        : '${totalObt!} / $totalMM',
                    color: accentColor,
                    theme: theme,
                  ),
                ),
                Container(
                    width: 1,
                    height: 32,
                    color: scheme.outlineVariant.withValues(alpha: 0.4)),
                Expanded(
                  child: _FooterStat(
                    label: 'RESULT',
                    value: result,
                    color: resultColor,
                    theme: theme,
                    center: true,
                  ),
                ),
                Container(
                    width: 1,
                    height: 32,
                    color: scheme.outlineVariant.withValues(alpha: 0.4)),
                Expanded(
                  child: _FooterStat(
                    label: 'DIVISION',
                    value: division,
                    color: divColor,
                    theme: theme,
                    center: true,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

// ── Small helpers for card view ───────────────────────────────────────────────

Widget _scorePill(String label, String value, Color color, ThemeData theme) {
  return Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                  color: color,
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5)),
          const SizedBox(height: 3),
          Text(value,
              style: TextStyle(
                  color: color,
                  fontSize: 14,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    ),
  );
}

class _FooterStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final ThemeData theme;
  final bool center;

  const _FooterStat({
    required this.label,
    required this.value,
    required this.color,
    required this.theme,
    this.center = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        crossAxisAlignment:
            center ? CrossAxisAlignment.center : CrossAxisAlignment.start,
        children: [
          Text(label,
              style: theme.textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 9,
                  letterSpacing: 0.6,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 3),
          Text(value,
              style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 12)),
        ],
      ),
    );
  }
}
