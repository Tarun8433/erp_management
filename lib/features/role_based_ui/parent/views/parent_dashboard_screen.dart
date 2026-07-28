import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../core/utils/drawer_main/src/flutter_zoom_drawer.dart';
import '../../../../core/widgets/dashboard/role_dashboard_header.dart';
import '../../../../core/widgets/dashboard/role_scaffold.dart';
import '../../../../routes/app_routes.dart';
import '../controllers/parent_dashboard_controller.dart';

class ParentDashboardScreen extends GetView<ParentDashboardController> {
  const ParentDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return RoleScaffold(
      items: [
        RoleNavItem(
          icon: Icons.home_outlined,
          selectedIcon: Icons.home_rounded,
          label: 'Home',
          body: const _ParentHomeBody(),
        ),
        RoleNavItem(
          icon: Icons.event_available_outlined,
          selectedIcon: Icons.event_available_rounded,
          label: 'Attendance',
          body: const _Placeholder(title: 'Attendance'),
        ),
        RoleNavItem(
          icon: Icons.receipt_long_outlined,
          selectedIcon: Icons.receipt_long_rounded,
          label: 'Fees',
          body: const _Placeholder(title: 'Fees'),
        ),
        RoleNavItem(
          icon: Icons.notifications_none_rounded,
          selectedIcon: Icons.notifications_rounded,
          label: 'Alerts',
          body: const _Placeholder(title: 'Notifications'),
        ),
      ],
    );
  }
}

// ── Home Tab ──────────────────────────────────────────────────────────────────

class _ParentHomeBody extends GetView<ParentDashboardController> {
  const _ParentHomeBody();

  static const _childLabels = ['Child 1', 'Child 2', 'Child 3'];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _childLabels.length,
      child: RefreshIndicator(
        onRefresh: controller.fetchOverview,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Obx(
                () => RoleDashboardHeader(
                  schoolName: '',
                  name: controller.parentName.value,
                  role: 'Parent',
                  onMenu: () => ZoomDrawer.of(context)?.toggle(),
                  onBell: () => Get.toNamed(AppRoutes.notifications),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: _NewsBanner()),
            const SliverToBoxAdapter(child: _ActionGrid()),
            const SliverToBoxAdapter(child: SizedBox(height: 110)),
          ],
        ),
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
      expandedHeight: 148,
      pinned: true,
      centerTitle: false,
      stretch: true,
      floating: false,
      automaticallyImplyLeading: false,
      backgroundColor: scheme.primary,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.transparent,
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(0),
          bottomRight: Radius.circular(0),
        ),
      ),
      titleSpacing: 8,
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: _CircleButton(
          icon: Icons.menu_rounded,
          onTap: () => ZoomDrawer.of(context)?.toggle(),
        ),
      ),
      title: Obx(() => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                controller.parentName.value.isNotEmpty
                    ? controller.parentName.value
                    : 'Parent',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                'Parent / Guardian',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: Colors.white70,
                  fontWeight: FontWeight.w400,
                  height: 1.2,
                ),
              ),
            ],
          )),
      actions: [
        _CircleButton(
          icon: Icons.notifications_none_rounded,
          onTap: () {},
          badge: 2,
        ),
        const SizedBox(width: 8),
        Obx(() => GestureDetector(
              onTap: () => Get.toNamed(AppRoutes.parentProfile),
              child: Container(
                width: 38,
                height: 38,
                margin: const EdgeInsets.only(right: 16),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.25),
                  border: Border.all(
                      color: Colors.white.withValues(alpha: 0.6), width: 2),
                ),
                child: Center(
                  child: Text(
                    controller.childAvatarText.value,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            )),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(40),
        child: Container(
          color: scheme.primary,
          child: TabBar(
            isScrollable: false,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white54,
            labelStyle: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
            unselectedLabelStyle: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
            indicatorColor: Colors.white,
            indicatorWeight: 2.5,
            dividerColor: Colors.white.withValues(alpha: 0.15),
            tabs: _ParentHomeBody._childLabels
                .map((c) => Tab(text: c.toUpperCase()))
                .toList(),
          ),
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
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 48),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.school_rounded,
                          color: Colors.white70, size: 13),
                      const SizedBox(width: 5),
                      Text(
                        'PRATIBHA INTER COLLEGE · DEWA-BARABANKI',
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(greeting,
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: Colors.white70)),
                  const SizedBox(height: 1),
                  Text(dateStr,
                      style: theme.textTheme.labelSmall
                          ?.copyWith(color: Colors.white54)),
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
                    color: Colors.red, shape: BoxShape.circle),
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

// ── News Banner ───────────────────────────────────────────────────────────────

class _NewsBanner extends StatefulWidget {
  const _NewsBanner();

  @override
  State<_NewsBanner> createState() => _NewsBannerState();
}

class _NewsBannerState extends State<_NewsBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<Offset> _slideAnim;

  static const _news =
      '📢  Annual Sports Day on Oct 25  •  Fee submission deadline: Oct 30  '
      '•  Parent-Teacher meeting on Nov 5  •  School closed on Nov 1 (Holiday)  ';

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
    _slideAnim = Tween<Offset>(
      begin: const Offset(1.0, 0),
      end: const Offset(-1.0, 0),
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.linear));
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      height: 40,
      margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: scheme.primary,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
                bottomLeft: Radius.circular(10),
              ),
            ),
            child: Text(
              'NEWS',
              style: theme.textTheme.labelSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.8,
              ),
            ),
          ),
          Expanded(
            child: ClipRect(
              child: SlideTransition(
                position: _slideAnim,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    _news,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.visible,
                    softWrap: false,
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

// ── Action Grid ───────────────────────────────────────────────────────────────

class _ActionEntry {
  final IconData icon;
  final String label;
  final Color accent;
  final VoidCallback onTap;

  const _ActionEntry({
    required this.icon,
    required this.label,
    required this.accent,
    required this.onTap,
  });
}

class _ActionGrid extends StatelessWidget {
  const _ActionGrid();

  static List<_ActionEntry?> _buildTiles() => [
        _ActionEntry(
          icon: Icons.person_outline_rounded,
          label: 'Profile',
          accent: const Color(0xFF5C6BC0),
          onTap: () => Get.toNamed(AppRoutes.parentProfile),
        ),
        _ActionEntry(
          icon: Icons.event_available_outlined,
          label: 'Attendance',
          accent: const Color(0xFF26A69A),
          onTap: () => Get.toNamed(AppRoutes.parentAttendance),
        ),
        _ActionEntry(
          icon: Icons.receipt_long_outlined,
          label: 'Fee',
          accent: const Color(0xFFEF5350),
          onTap: () => Get.toNamed(AppRoutes.parentFee),
        ),
        _ActionEntry(
          icon: Icons.schedule_outlined,
          label: 'Time Table',
          accent: const Color(0xFF1E88E5),
          onTap: () => Get.toNamed(AppRoutes.parentTimetable),
        ),
        _ActionEntry(
          icon: Icons.assignment_outlined,
          label: 'Home Work',
          accent: const Color(0xFF43A047),
          onTap: () {},
        ),
        _ActionEntry(
          icon: Icons.class_outlined,
          label: 'Class Work',
          accent: const Color(0xFFF57C00),
          onTap: () {},
        ),
        _ActionEntry(
          icon: Icons.quiz_outlined,
          label: 'Exam',
          accent: const Color(0xFF8E24AA),
          onTap: () {},
        ),
        _ActionEntry(
          icon: Icons.assessment_outlined,
          label: 'Result',
          accent: const Color(0xFF00897B),
          onTap: () => Get.toNamed(AppRoutes.parentResult),
        ),
        _ActionEntry(
          icon: Icons.folder_copy_outlined,
          label: 'Documents',
          accent: const Color(0xFF6D4C41),
          onTap: () {},
        ),
        _ActionEntry(
          icon: Icons.notifications_active_outlined,
          label: 'Notification',
          accent: const Color(0xFF1976D2),
          onTap: () {},
        ),
        _ActionEntry(
          icon: Icons.directions_bus_outlined,
          label: 'Transport',
          accent: const Color(0xFF00838F),
          onTap: () {},
        ),
        null,
      ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final tiles = _buildTiles();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Quick Access',
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              Icon(Icons.more_horiz_rounded, color: scheme.onSurfaceVariant),
            ],
          ),
          const SizedBox(height: 14),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.0,
            ),
            itemCount: tiles.length,
            itemBuilder: (context, i) {
              final tile = tiles[i];
              if (tile == null) return const SizedBox.shrink();
              return _ActionCard(tile: tile, scheme: scheme, theme: theme);
            },
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final _ActionEntry tile;
  final ColorScheme scheme;
  final ThemeData theme;

  const _ActionCard(
      {required this.tile, required this.scheme, required this.theme});

  @override
  Widget build(BuildContext context) {
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: tile.onTap,
      child: Container(
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: tile.accent.withValues(alpha: isDark ? 0.12 : 0.08),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Colored header strip
            Container(
              height: 6,
              decoration: BoxDecoration(
                color: tile.accent,
                borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20)),
              ),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: tile.accent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(tile.icon, color: tile.accent, size: 24),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Text(
                      tile.label,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        height: 1.3,
                        color: scheme.onSurface,
                      ),
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

// ── Placeholder ───────────────────────────────────────────────────────────────

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
