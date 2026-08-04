import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../core/utils/drawer_main/src/flutter_zoom_drawer.dart';
import '../../../../core/widgets/dashboard/role_scaffold.dart';
import '../../../../routes/app_routes.dart';
import '../controllers/teacher_dashboard_controller.dart';

class TeacherDashboardScreen extends GetView<TeacherDashboardController> {
  const TeacherDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return RoleScaffold(
      items: [
        RoleNavItem(
          icon: Icons.dashboard_outlined,
          selectedIcon: Icons.dashboard,
          label: 'Home',
          body: const _TeacherHomeBody(),
        ),
        RoleNavItem(
          icon: Icons.calendar_month_outlined,
          selectedIcon: Icons.calendar_month,
          label: 'Schedule',
          body: const _Placeholder(title: 'Schedule'),
        ),
        RoleNavItem(
          icon: Icons.groups_outlined,
          selectedIcon: Icons.groups,
          label: 'Students',
          body: const _Placeholder(title: 'Students'),
        ),
        RoleNavItem(
          icon: Icons.person_outline,
          selectedIcon: Icons.person,
          label: 'Profile',
          body: const _Placeholder(title: 'Profile'),
        ),
      ],
    );
  }
}

// ── Home tab ──────────────────────────────────────────────────────────────────

class _TeacherHomeBody extends GetView<TeacherDashboardController> {
  const _TeacherHomeBody();

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: controller.fetchDashboardStats,
      child: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context),
          const SliverToBoxAdapter(child: _NoticesSection()),
          //const SliverToBoxAdapter(child: _TeacherTodayCard()),
          const SliverToBoxAdapter(child: _TeacherStatsGrid()),
          const SliverToBoxAdapter(child: SizedBox(height: 110)),
        ],
      ),
    );
  }

  SliverAppBar _buildSliverAppBar(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final primaryLight =
        Color.lerp(scheme.primary, Colors.white, 0.38) ?? scheme.primary;
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Good Morning'
        : (hour < 17 ? 'Good Afternoon' : 'Good Evening');
    final dateStr = DateFormat('EEEE, d MMM yyyy').format(DateTime.now());

    return SliverAppBar(
      expandedHeight: 172,
      pinned: true,
      stretch: true,
      floating: false,
      automaticallyImplyLeading: false,
      backgroundColor: scheme.primary,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.transparent,
      elevation: 0,
      toolbarHeight: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
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
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(28),
              bottomRight: Radius.circular(28),
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 6, 12, 14),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Top row: menu · school name (centered) · profile
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _CircleButton(
                        icon: Icons.menu_rounded,
                        onTap: () => ZoomDrawer.of(context)?.toggle(),
                      ),
                      Expanded(
                        child: Obx(
                          () => Text(
                            controller.schoolName.value,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              height: 1.15,
                            ),
                          ),
                        ),
                      ),
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.25),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.6),
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          Icons.person_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    ],
                  ),
                  // Middle: teacher name + role (centered)
                  Obx(
                    () => Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          controller.teacherName.value,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            height: 1.2,
                          ),
                        ),
                        Text(
                          controller.userRole.value,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: Colors.white70,
                            fontWeight: FontWeight.w600,
                            height: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Bottom row: greeting (left) · date + bell (right)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        greeting,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        dateStr,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Obx(
                        () => _CircleButton(
                          icon: Icons.notifications_none_rounded,
                          onTap: () => Get.toNamed(AppRoutes.notifications),
                          badge: controller.unreadNotificationCount.value,
                        ),
                      ),
                    ],
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

// ── Circle button ─────────────────────────────────────────────────────────────

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final int? badge;
  const _CircleButton({required this.icon, required this.onTap, this.badge});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.2),
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          if (badge != null && badge! > 0)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                width: 16,
                height: 16,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '$badge',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Notices ───────────────────────────────────────────────────────────────────

class _NoticesSection extends GetView<TeacherDashboardController> {
  const _NoticesSection();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 0, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Row(
              children: [
                Text(
                  'Notice Bahsoard',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Obx(
                  () => controller.isNoticesLoading.value
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Obx(() {
            if (controller.notices.isEmpty &&
                !controller.isNoticesLoading.value) {
              return const Padding(
                padding: EdgeInsets.only(right: 20, bottom: 8),
                child: Text(
                  'No notices at the moment.',
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
              );
            }
            return SizedBox(
              height: 152,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: controller.notices.length,
                separatorBuilder: (_, i) => const SizedBox(width: 12),
                padding: const EdgeInsets.only(right: 20),
                itemBuilder: (_, i) => _NoticeCard(item: controller.notices[i]),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _NoticeCard extends StatelessWidget {
  final TeacherNoticeItem item;
  const _NoticeCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final diff = DateTime.now().difference(item.date);
    final timeAgo = diff.inMinutes < 60
        ? '${diff.inMinutes}m ago'
        : diff.inHours < 24
        ? '${diff.inHours}h ago'
        : '${diff.inDays}d ago';

    return Container(
      width: Get.width * .78,
      margin: const EdgeInsets.only(top: 4, bottom: 8, left: 4),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border(left: BorderSide(color: item.color, width: 4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: item.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.campaign_rounded,
                  color: item.color,
                  size: 17,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  item.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                timeAgo,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Text(
              item.body,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Live Insights card ────────────────────────────────────────────────────────

class _TeacherTodayCard extends GetView<TeacherDashboardController> {
  const _TeacherTodayCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              scheme.primary,
              Color.lerp(scheme.primaryContainer, scheme.surface, 0.55) ??
                  scheme.scrim,
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: scheme.primary.withValues(alpha: 0.1),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Left: Live Insights + students ──────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: scheme.onPrimaryContainer,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Live Insights',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: scheme.onPrimaryContainer,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: scheme.primary.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'My Class',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: scheme.primary,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Obx(
                    () => Text(
                      '${controller.classStudentsTotal.value}',
                      style: theme.textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: scheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                  Text(
                    'Total Students',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onPrimaryContainer.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Obx(() {
                    final pct =
                        double.tryParse(
                          controller.classAttendancePercent.value.replaceAll(
                            '%',
                            '',
                          ),
                        ) ??
                        0;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: pct / 100,
                            minHeight: 7,
                            backgroundColor: scheme.onPrimaryContainer
                                .withValues(alpha: 0.1),
                            valueColor: AlwaysStoppedAnimation(scheme.primary),
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          '${controller.classAttendancePercent.value} Attendance',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: scheme.onPrimaryContainer.withValues(
                              alpha: 0.65,
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 9,
                    ),
                    decoration: BoxDecoration(
                      color: scheme.primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.bar_chart_rounded,
                          color: scheme.onPrimary,
                          size: 14,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          'View Reports',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: scheme.onPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // ── Right: Teachers present ──────────────────────────────────
            Container(
              width: 90,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
              decoration: BoxDecoration(
                color: scheme.surface.withValues(alpha: 0.75),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_rounded, size: 40, color: scheme.primary),
                  const SizedBox(height: 8),
                  Obx(
                    () => Text(
                      '${controller.teachersPresent.value}',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: scheme.primary,
                      ),
                    ),
                  ),
                  Text(
                    'Teachers',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: scheme.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check_circle_outline_rounded,
                      size: 20,
                      color: scheme.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Present',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Stats grid ────────────────────────────────────────────────────────────────

class _TeacherStatsGrid extends GetView<TeacherDashboardController> {
  const _TeacherStatsGrid();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 40),
          child: Center(child: CircularProgressIndicator()),
        );
      }
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
        child: Column(
          children: [
            // Row 1 — Students (class only) | Staff
            _CardRow(
              left: _StatCard(
                title: 'Students',
                icon: Icons.school_rounded,
                accent: const Color(0xFF2E7D32),
                classOnly: true,
                rows: [
                  _SR('Total', controller.classStudentsTotal.value),
                  _SR(
                    'Present',
                    controller.classStudentsPresent.value,
                    valueColor: const Color(0xFF2E7D32),
                  ),
                  _SR(
                    'Absent',
                    controller.classStudentsAbsent.value,
                    valueColor: const Color(0xFFC62828),
                  ),
                ],
              ),
              right: _StatCard(
                title: 'Staff',
                icon: Icons.people_rounded,
                accent: const Color(0xFF1565C0),
                rows: [
                  _SR('Total', controller.totalStaff.value),
                  _SR(
                    'Present',
                    controller.staffPresent.value,
                    valueColor: const Color(0xFF2E7D32),
                  ),
                  _SR(
                    'Absent',
                    controller.staffAbsent.value,
                    valueColor: const Color(0xFFC62828),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Row 2 — Empty Periods (class only) | Complaints
            _CardRow(
              left: _StatCard(
                title: 'Empty Periods',
                icon: Icons.event_busy_rounded,
                accent: const Color(0xFF546E7A),
                classOnly: true,
                rows: [
                  _SR(
                    'Count',
                    controller.emptyPeriods.value,
                    emptyLabel: 'No empty periods',
                  ),
                ],
              ),
              right: _StatCard(
                title: 'Complaints',
                icon: Icons.report_problem_rounded,
                accent: const Color(0xFFBF360C),
                rows: [
                  _SR(
                    'Count',
                    controller.complaintsCount.value,
                    emptyLabel: 'No complaints',
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

// ── Card row ──────────────────────────────────────────────────────────────────

class _CardRow extends StatelessWidget {
  final Widget left;
  final Widget right;
  const _CardRow({required this.left, required this.right});

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: left),
          const SizedBox(width: 14),
          Expanded(child: right),
        ],
      ),
    );
  }
}

// ── Stat row data ─────────────────────────────────────────────────────────────

class _SR {
  final String label;
  final int value;
  final Color? valueColor;
  final String? emptyLabel;
  const _SR(this.label, this.value, {this.valueColor, this.emptyLabel});
}

// ── Stat card ─────────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color accent;
  final List<_SR> rows;
  final bool classOnly;

  const _StatCard({
    required this.title,
    required this.icon,
    required this.accent,
    required this.rows,
    this.classOnly = false,
  });

  static final _fmt = NumberFormat('#,##,###');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: isDark ? 0.12 : 0.08),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Colored header strip ──────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  accent,
                  Color.lerp(accent, Colors.white, isDark ? 0.1 : 0.22) ??
                      accent,
                ],
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.22),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(icon, color: Colors.white, size: 16),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        title,
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.2,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                if (classOnly) ...[
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.22),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Allotted Class Only',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // ── Stat rows ─────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
            child: Column(
              children: rows.map((r) {
                final display = r.value == 0 && r.emptyLabel != null
                    ? null
                    : _fmt.format(r.value);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: display == null
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              r.emptyLabel!,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: scheme.onSurfaceVariant.withValues(
                                  alpha: 0.55,
                                ),
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              r.label,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: scheme.onSurfaceVariant,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              display,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: r.valueColor ?? scheme.onSurface,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Placeholder tab ───────────────────────────────────────────────────────────

class _Placeholder extends StatelessWidget {
  final String title;
  const _Placeholder({required this.title});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(title, style: Theme.of(context).textTheme.titleLarge),
    );
  }
}
