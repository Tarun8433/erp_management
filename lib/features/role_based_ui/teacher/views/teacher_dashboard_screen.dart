import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/utils/drawer_main/src/flutter_zoom_drawer.dart';
import '../../../../core/utils/role_router.dart';
import '../../../../core/widgets/dashboard/dashboard_header.dart';
import '../../../../core/widgets/dashboard/dashboard_section.dart';
import '../../../../core/widgets/dashboard/info_tile.dart';
import '../../../../core/widgets/dashboard/role_scaffold.dart';
import '../../../../core/widgets/dashboard/stat_card.dart';
import '../controllers/teacher_dashboard_controller.dart';

class TeacherDashboardScreen extends GetView<TeacherDashboardController> {
  const TeacherDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return RoleScaffold(
      items: [
        const RoleNavItem(
          icon: Icons.dashboard_outlined,
          label: 'Home',
          body: _TeacherHomeBody(),
        ),
        const RoleNavItem(
          icon: Icons.calendar_month_outlined,
          label: 'Schedule',
          body: _Placeholder(title: 'Schedule'),
        ),
        const RoleNavItem(
          icon: Icons.groups_outlined,
          label: 'Students',
          body: _Placeholder(title: 'Students'),
        ),
        RoleNavItem(
          icon: Icons.menu_book_outlined,
          label: 'Gradebook',
          body: _ProfileTab(onLogout: RoleRouter.logout),
        ),
      ],
    );
  }
}

class _TeacherHomeBody extends GetView<TeacherDashboardController> {
  const _TeacherHomeBody();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return RefreshIndicator(
      onRefresh: controller.fetchOverview,
      child: ListView(
        children: [
          Obx(
            () => DashboardHeader(
              avatarText: 'SM',
              title: controller.teacherName.value,
              subtitle: controller.grade.value,
              notificationCount: 1,
              onAvatarTap: () => ZoomDrawer.of(context)?.toggle(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Good Morning, Sarah',
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Your classes for today, Tuesday, Oct 24th.',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              children: [
                Expanded(
                  child: Obx(
                    () => StatCard(
                      icon: Icons.flag_outlined,
                      label: 'High',
                      value: '${controller.attendancePending.value}',
                      subtitle: 'Attendance Pending',
                      accentColor: colorScheme.error,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Obx(
                    () => StatCard(
                      icon: Icons.event_note_outlined,
                      label: 'Next Week',
                      value: '${controller.upcomingExams.value}',
                      subtitle: 'Upcoming Exams',
                    ),
                  ),
                ),
              ],
            ),
          ),
          DashboardSection(
            title: "Today's Classes",
            actionLabel: 'VIEW ALL',
            onActionTap: () {},
            child: Obx(
              () => Column(
                children: controller.todayClasses
                    .map(
                      (c) => InfoTile(
                        icon: c.isNow
                            ? Icons.play_circle_outline
                            : Icons.schedule,
                        title: c.name,
                        subtitle: '${c.room} - ${c.time}',
                        trailingLabel: c.isNow ? 'NOW' : null,
                        iconColor: c.isNow ? colorScheme.primary : null,
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
          DashboardSection(
            title: 'Recent Messages',
            child: Obx(
              () => Column(
                children: controller.messages
                    .map(
                      (m) => InfoTile(
                        icon: Icons.account_circle_outlined,
                        title: m.sender,
                        subtitle: m.preview,
                        trailingLabel: m.isNew ? 'NEW' : m.timeAgo,
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ElevatedButton(
              onPressed: () {},
              child: const Text('OPEN MESSENGER'),
            ),
          ),
          const SizedBox(height: 110),
        ],
      ),
    );
  }
}

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

class _ProfileTab extends StatelessWidget {
  final Future<void> Function() onLogout;
  const _ProfileTab({required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Gradebook', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () => onLogout(),
            icon: const Icon(Icons.logout),
            label: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
