import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/parent_profile_controller.dart';
import '../../principal/new_student_list/controllers/student_list_controller.dart';

class ParentProfileScreen extends StatelessWidget {
  const ParentProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(ParentProfileController());
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: scheme.surfaceContainerLowest,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context, c),
          SliverToBoxAdapter(
            child: Obx(() {
              if (c.isLoading.value) {
                return const SizedBox(
                  height: 300,
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              return Column(
                children: [
                  _ParentInfoCard(controller: c),
                  _ChildrenSection(controller: c),
                  const SizedBox(height: 40),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  SliverAppBar _buildSliverAppBar(
      BuildContext context, ParentProfileController c) {
    final theme = Theme.of(context);

    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      stretch: true,
      backgroundColor: const Color(0xFF4527A0),
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
        onPressed: () => Get.back(),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.edit_outlined, color: Colors.white),
          onPressed: () {},
          tooltip: 'Edit Profile',
        ),
      ],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.pin,
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF4527A0), Color(0xFF7E57C2)],
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(28),
              bottomRight: Radius.circular(28),
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 32),
                Obx(() {
                  final initials = _initials(c.parentName.value);
                  return Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Color(0xFF7E57C2), Color(0xFF4527A0)],
                      ),
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        initials,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 30,
                        ),
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 12),
                Obx(() => Text(
                      c.parentName.value.isEmpty ? 'Parent' : c.parentName.value,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    )),
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Parent',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
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

String _initials(String name) {
  final parts = name.trim().split(' ').where((p) => p.isNotEmpty).toList();
  if (parts.isEmpty) return 'P';
  if (parts.length == 1) return parts[0][0].toUpperCase();
  return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
}

// ── Parent Info Card ──────────────────────────────────────────────────────────

class _ParentInfoCard extends StatelessWidget {
  final ParentProfileController controller;
  const _ParentInfoCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final c = controller;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(icon: Icons.person_rounded, title: 'My Profile'),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: scheme.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: theme.dividerColor.withValues(alpha: 0.4)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Obx(() => _InfoRow(
                      icon: Icons.badge_outlined,
                      label: 'Name',
                      value: c.parentName.value.isEmpty
                          ? '—'
                          : c.parentName.value,
                      iconColor: const Color(0xFF4527A0),
                    )),
                _divider(theme),
                Obx(() => _InfoRow(
                      icon: Icons.phone_outlined,
                      label: 'Mobile',
                      value: c.parentMobile.value.isEmpty
                          ? '—'
                          : c.parentMobile.value,
                      iconColor: const Color(0xFF00897B),
                    )),
                _divider(theme),
                Obx(() => _InfoRow(
                      icon: Icons.email_outlined,
                      label: 'Email',
                      value: c.parentEmail.value.isEmpty
                          ? '—'
                          : c.parentEmail.value,
                      iconColor: const Color(0xFF1565C0),
                    )),
                _divider(theme),
                Obx(() => _InfoRow(
                      icon: Icons.numbers_outlined,
                      label: 'User ID',
                      value: c.parentUserId.value.isEmpty
                          ? '—'
                          : c.parentUserId.value,
                      iconColor: const Color(0xFFF57C00),
                      isLast: true,
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider(ThemeData theme) => Divider(
        height: 1,
        indent: 56,
        color: theme.dividerColor.withValues(alpha: 0.4),
      );
}

// ── Children Section (StatefulWidget for view-mode toggle) ────────────────────

class _ChildrenSection extends StatefulWidget {
  final ParentProfileController controller;
  const _ChildrenSection({required this.controller});

  @override
  State<_ChildrenSection> createState() => _ChildrenSectionState();
}

class _ChildrenSectionState extends State<_ChildrenSection> {
  bool _isTableView = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final c = widget.controller;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
      child: Obx(() {
        if (c.children.isEmpty) return const SizedBox.shrink();
        final selectedIdx = c.selectedChildIndex.value;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header row with view-toggle ─────────────────────────────
            Row(
              children: [
                const Icon(Icons.child_care_rounded,
                    size: 18, color: Color(0xFF4527A0)),
                const SizedBox(width: 8),
                Text(
                  'My Children',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF4527A0),
                    letterSpacing: 0.4,
                  ),
                ),
                const Spacer(),
                Text('${c.children.length} registered',
                    style: theme.textTheme.bodySmall),
                const SizedBox(width: 8),
                // Toggle: Cards ↔ Table
                GestureDetector(
                  onTap: () => setState(() => _isTableView = !_isTableView),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: _isTableView
                          ? const Color(0xFF4527A0)
                          : const Color(0xFF4527A0).withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: const Color(0xFF4527A0).withValues(alpha: 0.35),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _isTableView
                              ? Icons.grid_view_rounded
                              : Icons.table_rows_rounded,
                          size: 14,
                          color: _isTableView
                              ? Colors.white
                              : const Color(0xFF4527A0),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          _isTableView ? 'Card View' : 'Table View',
                          style: TextStyle(
                            color: _isTableView
                                ? Colors.white
                                : const Color(0xFF4527A0),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // ── Content: table or card view ─────────────────────────────
            if (_isTableView) ...[
              _ProfileTable(c: c),
            ] else ...[
              // Child switcher chips
              SizedBox(
                height: 116,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: c.children.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 12),
                  itemBuilder: (_, i) {
                    final child = c.children[i];
                    final isSelected = selectedIdx == i;
                    return GestureDetector(
                      onTap: () {
                        c.selectedChildIndex.value = i;
                        c.selectedTab.value = 0;
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 110,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF4527A0)
                              : Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFF4527A0)
                                : Theme.of(context)
                                    .dividerColor
                                    .withValues(alpha: 0.4),
                            width: isSelected ? 2 : 1,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: const Color(0xFF4527A0)
                                        .withValues(alpha: 0.3),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ]
                              : null,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: isSelected
                                  ? Colors.white.withValues(alpha: 0.2)
                                  : const Color(0xFF4527A0)
                                      .withValues(alpha: 0.1),
                              child: Text(
                                _initials(child.name),
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : const Color(0xFF4527A0),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              child.name.split(' ').first,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: isSelected
                                    ? Colors.white
                                    : Theme.of(context).colorScheme.onSurface,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              child.className,
                              style: TextStyle(
                                fontSize: 10,
                                color: isSelected
                                    ? Colors.white.withValues(alpha: 0.8)
                                    : Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              // Selected child detail card
              Obx(() {
                final child = c.selectedChild;
                if (child == null) return const SizedBox.shrink();
                return _ChildDetailCard(child: child, controller: c);
              }),
            ],
          ],
        );
      }),
    );
  }
}

// ── Profile Table (horizontal-scrollable, sticky label column) ────────────────

class _TR {
  final String label;
  final String parentValue;
  final List<String> childValues;
  final bool isSection;
  final Color? sectionColor;

  const _TR(this.label, this.parentValue, this.childValues)
      : isSection = false,
        sectionColor = null;

  const _TR.section(this.label, Color color)
      : parentValue = '',
        childValues = const [],
        isSection = true,
        sectionColor = color;
}

class _ProfileTable extends StatelessWidget {
  final ParentProfileController c;
  const _ProfileTable({required this.c});

  static const double _labelW = 108;
  static const double _cellW = 118;
  static const double _rowH = 44;
  static const double _sectionH = 28;
  static const double _headerH = 48;
  static const Color _accent = Color(0xFF4527A0);

  @override
  Widget build(BuildContext context) {
    return Obx(() => _buildTable(context));
  }

  Widget _buildTable(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final children = c.children;
    final n = children.length;
    final fc = n > 0 ? children[0] : null; // first child (proxy for parent address)

    String pv(String v) => v.isEmpty ? '—' : v;
    String cv(int i, String v) => i < n ? (v.isEmpty ? '—' : v) : '';

    final rows = <_TR>[
      const _TR.section('IDENTITY', Color(0xFF4527A0)),
      _TR('Parent ID', pv(c.parentUserId.value),
          List.generate(n, (_) => '—')),
      _TR('Father', pv(fc?.fatherName ?? ''),
          List.generate(n, (i) => cv(i, children[i].fatherName))),
      _TR('Mother', pv(fc?.motherName ?? ''),
          List.generate(n, (i) => cv(i, children[i].motherName))),
      _TR('Mobile', pv(c.parentMobile.value),
          List.generate(n, (i) => cv(i, children[i].phone))),
      _TR('Email', pv(c.parentEmail.value),
          List.generate(n, (_) => '—')),
      const _TR.section('ACADEMIC', Color(0xFF1565C0)),
      _TR('Name', '—',
          List.generate(n, (i) => cv(i, children[i].name))),
      _TR('Class', '—',
          List.generate(n, (i) => cv(i, children[i].className))),
      _TR('Group', '—',
          List.generate(n, (i) => cv(i, children[i].group))),
      _TR('Roll No', '—',
          List.generate(n, (i) => cv(i, children[i].rollNo))),
      _TR('SID', '—',
          List.generate(n, (i) => cv(i, children[i].sid))),
      _TR('SR No', '—',
          List.generate(n, (i) => cv(i, children[i].srNo))),
      _TR('Status', '—',
          List.generate(n, (i) => cv(i, children[i].status))),
      const _TR.section('PERSONAL', Color(0xFF2E7D32)),
      _TR('DOB', '—',
          List.generate(n, (i) => cv(i, children[i].dob))),
      _TR('Gender', '—',
          List.generate(n, (i) => cv(i, children[i].gender))),
      _TR('Religion', '—',
          List.generate(n, (i) => cv(i, children[i].religion))),
      _TR('Category', '—',
          List.generate(n, (i) => cv(i, children[i].category))),
      _TR('Aadhaar No', '—',
          List.generate(n, (i) => cv(i, children[i].aadhaar))),
      _TR('PEN No', '—',
          List.generate(n, (i) => cv(i, children[i].een))),
      _TR('APAAR ID', '—',
          List.generate(n, (i) => cv(i, children[i].apaarId))),
      const _TR.section('ADDRESS', Color(0xFF00695C)),
      _TR('Village', pv(fc?.village ?? ''),
          List.generate(n, (i) => cv(i, children[i].village))),
      _TR('Tehsil', pv(fc?.tehsil ?? ''),
          List.generate(n, (i) => cv(i, children[i].tehsil))),
      _TR('District', pv(fc?.district ?? ''),
          List.generate(n, (i) => cv(i, children[i].district))),
      _TR('State', pv(fc?.state ?? ''),
          List.generate(n, (i) => cv(i, children[i].state))),
      _TR('PIN Code', pv(fc?.pinCode ?? ''),
          List.generate(n, (i) => cv(i, children[i].pinCode))),
    ];

    final colLabels = [
      'PARENT',
      ...List.generate(n, (i) => 'CHILD ${i + 1}'),
    ];
    final numCols = colLabels.length;

    return Container(
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.12 : 0.05),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Sticky label column ────────────────────────────────────────
          SizedBox(
            width: _labelW,
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: Border(
                  right: BorderSide(
                    color: theme.dividerColor.withValues(alpha: 0.5),
                    width: 1.5,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Column header cell
                  Container(
                    height: _headerH,
                    color: _accent,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'FIELD',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                  // Label cells
                  for (int r = 0; r < rows.length; r++)
                    _LabelCell(row: rows[r], rowIndex: r, theme: theme, scheme: scheme),
                ],
              ),
            ),
          ),

          // ── Scrollable data columns ────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: numCols * _cellW,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Column header row
                    Row(
                      children: List.generate(numCols, (col) {
                        final isParent = col == 0;
                        return Container(
                          width: _cellW,
                          height: _headerH,
                          decoration: BoxDecoration(
                            color: isParent
                                ? _accent
                                : _accent.withValues(alpha: 0.82 - col * 0.05),
                            border: col > 0
                                ? Border(
                                    left: BorderSide(
                                      color: Colors.white.withValues(alpha: 0.2),
                                    ),
                                  )
                                : null,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            colLabels[col],
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.6,
                            ),
                          ),
                        );
                      }),
                    ),
                    // Data rows
                    for (int r = 0; r < rows.length; r++)
                      _DataRow(
                        row: rows[r],
                        rowIndex: r,
                        numCols: numCols,
                        theme: theme,
                        scheme: scheme,
                        cellW: _cellW,
                        rowH: _rowH,
                        sectionH: _sectionH,
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LabelCell extends StatelessWidget {
  final _TR row;
  final int rowIndex;
  final ThemeData theme;
  final ColorScheme scheme;

  const _LabelCell({
    required this.row,
    required this.rowIndex,
    required this.theme,
    required this.scheme,
  });

  @override
  Widget build(BuildContext context) {
    if (row.isSection) {
      return Container(
        height: _ProfileTable._sectionH,
        color: row.sectionColor?.withValues(alpha: 0.08),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        alignment: Alignment.centerLeft,
        child: Text(
          row.label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: row.sectionColor,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.9,
          ),
        ),
      );
    }
    final odd = rowIndex % 2 == 1;
    return Container(
      height: _ProfileTable._rowH,
      color: odd ? scheme.surfaceContainerLowest : Colors.transparent,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      alignment: Alignment.centerLeft,
      child: Text(
        row.label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: scheme.onSurfaceVariant,
          fontWeight: FontWeight.w600,
        ),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

class _DataRow extends StatelessWidget {
  final _TR row;
  final int rowIndex;
  final int numCols;
  final ThemeData theme;
  final ColorScheme scheme;
  final double cellW;
  final double rowH;
  final double sectionH;

  const _DataRow({
    required this.row,
    required this.rowIndex,
    required this.numCols,
    required this.theme,
    required this.scheme,
    required this.cellW,
    required this.rowH,
    required this.sectionH,
  });

  @override
  Widget build(BuildContext context) {
    if (row.isSection) {
      return Container(
        height: sectionH,
        color: row.sectionColor?.withValues(alpha: 0.08),
      );
    }
    final odd = rowIndex % 2 == 1;
    return Row(
      children: List.generate(numCols, (col) {
        final value = col == 0
            ? row.parentValue
            : (col - 1 < row.childValues.length
                ? row.childValues[col - 1]
                : '');
        final isDash = value == '—';
        return Container(
          width: cellW,
          height: rowH,
          decoration: BoxDecoration(
            color: odd ? scheme.surfaceContainerLowest : Colors.transparent,
            border: col > 0
                ? Border(
                    left: BorderSide(
                      color: theme.dividerColor.withValues(alpha: 0.3),
                      width: 0.5,
                    ),
                  )
                : null,
          ),
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Text(
            value,
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: isDash ? FontWeight.w400 : FontWeight.w600,
              color: isDash
                  ? scheme.onSurfaceVariant.withValues(alpha: 0.35)
                  : scheme.onSurface,
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        );
      }),
    );
  }
}

// ── Child Detail Card (tabbed) ────────────────────────────────────────────────

class _ChildDetailCard extends StatelessWidget {
  final Student child;
  final ParentProfileController controller;
  const _ChildDetailCard({required this.child, required this.controller});

  static const _tabs = ['Personal', 'Academic', 'Guardian', 'Documents'];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Child header strip
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF4527A0), Color(0xFF7E57C2)],
              ),
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                  child: Text(
                    _initials(child.name),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        child.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${child.className} · ${child.group}',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: child.status == 'Active'
                        ? const Color(0xFF43A047).withValues(alpha: 0.2)
                        : Colors.red.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: child.status == 'Active'
                            ? const Color(0xFF43A047)
                            : Colors.red,
                        width: 1),
                  ),
                  child: Text(
                    child.status,
                    style: TextStyle(
                      color: child.status == 'Active'
                          ? const Color(0xFF43A047)
                          : Colors.red,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Tab bar
          Obx(() {
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: List.generate(_tabs.length, (i) {
                  final isActive = controller.selectedTab.value == i;
                  return GestureDetector(
                    onTap: () => controller.selectedTab.value = i,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isActive
                            ? const Color(0xFF4527A0)
                            : scheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _tabs[i],
                        style: TextStyle(
                          color: isActive ? Colors.white : scheme.onSurfaceVariant,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            );
          }),
          const Divider(height: 1),
          // Tab body
          Obx(() {
            switch (controller.selectedTab.value) {
              case 0:
                return _PersonalTab(child: child);
              case 1:
                return _AcademicTab(child: child);
              case 2:
                return _GuardianTab(child: child);
              case 3:
                return _DocumentsTab(child: child);
              default:
                return const SizedBox.shrink();
            }
          }),
        ],
      ),
    );
  }
}

// ── Tab: Personal ─────────────────────────────────────────────────────────────

class _PersonalTab extends StatelessWidget {
  final Student child;
  const _PersonalTab({required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 44,
                  backgroundColor:
                      const Color(0xFF4527A0).withValues(alpha: 0.1),
                  backgroundImage: child.photoUrl.isNotEmpty
                      ? NetworkImage(child.photoUrl)
                      : null,
                  child: child.photoUrl.isEmpty
                      ? Text(
                          _initials(child.name),
                          style: const TextStyle(
                            color: Color(0xFF4527A0),
                            fontWeight: FontWeight.bold,
                            fontSize: 28,
                          ),
                        )
                      : null,
                ),
                const SizedBox(height: 8),
                Text(
                  child.name,
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _InfoGroup(rows: [
            _InfoRowData(Icons.cake_outlined, 'Date of Birth', child.dob,
                const Color(0xFFF57C00)),
            _InfoRowData(Icons.wc_outlined, 'Gender', child.gender,
                const Color(0xFF1565C0)),
            _InfoRowData(Icons.church_outlined, 'Religion', child.religion,
                const Color(0xFF6A1B9A)),
            _InfoRowData(Icons.group_outlined, 'Category', child.category,
                const Color(0xFF2E7D32)),
            _InfoRowData(Icons.badge_outlined, 'Aadhaar No', child.aadhaar,
                const Color(0xFFC62828)),
            _InfoRowData(Icons.numbers_outlined, 'APAAR ID', child.apaarId,
                const Color(0xFF00697B)),
            _InfoRowData(Icons.numbers_outlined, 'PEN No', child.een,
                const Color(0xFF4527A0)),
          ]),
          const SizedBox(height: 16),
          _GroupLabel('Address'),
          _InfoGroup(rows: [
            _InfoRowData(Icons.home_outlined, 'Village/Mohalla', child.village,
                const Color(0xFF4527A0)),
            _InfoRowData(Icons.location_city_outlined, 'Tehsil', child.tehsil,
                const Color(0xFF4527A0)),
            _InfoRowData(Icons.map_outlined, 'District', child.district,
                const Color(0xFF4527A0)),
            _InfoRowData(Icons.location_on_outlined, 'State', child.state,
                const Color(0xFF4527A0)),
            _InfoRowData(Icons.pin_outlined, 'Pin Code', child.pinCode,
                const Color(0xFF4527A0)),
          ]),
        ],
      ),
    );
  }
}

// ── Tab: Academic ─────────────────────────────────────────────────────────────

class _AcademicTab extends StatelessWidget {
  final Student child;
  const _AcademicTab({required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              _StatPill(
                  label: 'SID', value: child.sid, color: const Color(0xFF4527A0)),
              const SizedBox(width: 10),
              _StatPill(
                  label: 'SR No',
                  value: child.srNo,
                  color: const Color(0xFF00897B)),
              const SizedBox(width: 10),
              _StatPill(
                  label: 'Roll',
                  value: child.rollNo,
                  color: const Color(0xFFF57C00)),
            ],
          ),
          const SizedBox(height: 16),
          _InfoGroup(rows: [
            _InfoRowData(Icons.class_outlined, 'Class', child.className,
                const Color(0xFF1565C0)),
            _InfoRowData(Icons.group_work_outlined, 'Group', child.group,
                const Color(0xFF6A1B9A)),
            _InfoRowData(
                Icons.verified_outlined,
                'Status',
                child.status,
                child.status == 'Active'
                    ? const Color(0xFF43A047)
                    : Colors.red),
            _InfoRowData(Icons.calendar_today_outlined, 'Enrolled On',
                child.entryAt, const Color(0xFF00838F)),
          ]),
        ],
      ),
    );
  }
}

// ── Tab: Guardian ─────────────────────────────────────────────────────────────

class _GuardianTab extends StatelessWidget {
  final Student child;
  const _GuardianTab({required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _GroupLabel('Father'),
          _InfoGroup(rows: [
            _InfoRowData(Icons.person_outline, 'Name', child.fatherName,
                const Color(0xFF1565C0)),
            _InfoRowData(Icons.phone_outlined, 'Mobile', child.phone,
                const Color(0xFF00897B)),
            _InfoRowData(Icons.work_outline, 'Occupation',
                child.fatherOccupation, const Color(0xFFF57C00)),
          ]),
          const SizedBox(height: 16),
          _GroupLabel('Mother'),
          _InfoGroup(rows: [
            _InfoRowData(Icons.person_outline, 'Name', child.motherName,
                const Color(0xFF6A1B9A)),
            _InfoRowData(Icons.work_outline, 'Occupation',
                child.motherOccupation, const Color(0xFFF57C00)),
          ]),
          const SizedBox(height: 16),
          _GroupLabel('Guardian'),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest
                  .withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline,
                    size: 18, color: theme.colorScheme.onSurfaceVariant),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    child.isGuardianSameAsFather
                        ? 'Guardian is same as Father'
                        : child.guardianName.isEmpty
                            ? 'No guardian details recorded'
                            : child.guardianName,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Tab: Documents ────────────────────────────────────────────────────────────

class _DocumentsTab extends StatelessWidget {
  final Student child;
  const _DocumentsTab({required this.child});

  static const _docGradients = [
    [Color(0xFFEDE7F6), Color(0xFFD1C4E9)],
    [Color(0xFFE3F2FD), Color(0xFFBBDEFB)],
    [Color(0xFFE8F5E9), Color(0xFFC8E6C9)],
    [Color(0xFFFFF3E0), Color(0xFFFFE0B2)],
    [Color(0xFFFCE4EC), Color(0xFFF8BBD0)],
    [Color(0xFFE0F7FA), Color(0xFFB2EBF2)],
  ];

  @override
  Widget build(BuildContext context) {
    final docs = [
      _DocEntry('Student Photo', Icons.person_rounded, child.photoUrl,
          _docGradients[0], const Color(0xFF4527A0)),
      _DocEntry('Aadhaar Front', Icons.badge_outlined, child.aadhaar,
          _docGradients[1], const Color(0xFF1565C0)),
      _DocEntry('Aadhaar Back', Icons.badge_outlined, '',
          _docGradients[2], const Color(0xFF2E7D32)),
      _DocEntry('Father Aadhaar', Icons.badge_outlined, '',
          _docGradients[3], const Color(0xFFF57C00)),
      _DocEntry('Mother Aadhaar', Icons.badge_outlined, '',
          _docGradients[4], const Color(0xFFE91E63)),
      _DocEntry('Transfer Cert.', Icons.description_outlined, '',
          _docGradients[5], const Color(0xFF00838F)),
    ];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          childAspectRatio: 1.2,
        ),
        itemCount: docs.length,
        itemBuilder: (_, i) => _DocCard(doc: docs[i]),
      ),
    );
  }
}

class _DocEntry {
  final String label;
  final IconData icon;
  final String url;
  final List<Color> gradient;
  final Color iconColor;
  const _DocEntry(
      this.label, this.icon, this.url, this.gradient, this.iconColor);
}

class _DocCard extends StatelessWidget {
  final _DocEntry doc;
  const _DocCard({required this.doc});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasUrl = doc.url.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: doc.gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: hasUrl && doc.url.startsWith('http')
          ? ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(doc.url, fit: BoxFit.cover,
                      errorBuilder: (_, _, _) =>
                          _docPlaceholder(doc, theme)),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 6),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Colors.black54],
                        ),
                        borderRadius: BorderRadius.vertical(
                            bottom: Radius.circular(16)),
                      ),
                      child: Text(
                        doc.label,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
            )
          : _docPlaceholder(doc, theme),
    );
  }

  Widget _docPlaceholder(_DocEntry doc, ThemeData theme) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: doc.iconColor.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(doc.icon, color: doc.iconColor, size: 22),
        ),
        const SizedBox(height: 8),
        Text(
          doc.label,
          textAlign: TextAlign.center,
          style: theme.textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: doc.iconColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          doc.url.isEmpty ? 'Not uploaded' : 'View',
          style: theme.textTheme.labelSmall?.copyWith(
            color: doc.url.isEmpty ? Colors.black38 : doc.iconColor,
          ),
        ),
      ],
    );
  }
}

// ── Shared helpers ────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  const _SectionHeader({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF4527A0)),
        const SizedBox(width: 8),
        Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF4527A0),
            letterSpacing: 0.4,
          ),
        ),
      ],
    );
  }
}

class _GroupLabel extends StatelessWidget {
  final String label;
  const _GroupLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.1,
            ),
      ),
    );
  }
}

class _InfoRowData {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  const _InfoRowData(this.icon, this.label, this.value, this.color);
}

class _InfoGroup extends StatelessWidget {
  final List<_InfoRowData> rows;
  const _InfoGroup({required this.rows});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.4)),
      ),
      child: Column(
        children: List.generate(rows.length, (i) {
          final row = rows[i];
          return Column(
            children: [
              _InfoRow(
                icon: row.icon,
                label: row.label,
                value: row.value.isEmpty ? '—' : row.value,
                iconColor: row.color,
                isLast: i == rows.length - 1,
              ),
              if (i < rows.length - 1)
                Divider(
                  height: 1,
                  indent: 56,
                  color: theme.dividerColor.withValues(alpha: 0.4),
                ),
            ],
          );
        }),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color iconColor;
  final bool isLast;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.iconColor,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: iconColor),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _StatPill(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value.isEmpty ? '—' : value,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
