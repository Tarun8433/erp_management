import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../core/utils/drawer_main/src/flutter_zoom_drawer.dart';
import '../../../../../core/utils/role_router.dart';
import '../../../../../core/widgets/dashboard/alert_card.dart';
import '../../../../../core/widgets/dashboard/dashboard_header.dart';
import '../../../../../core/widgets/dashboard/dashboard_section.dart';
import '../../../../../core/widgets/dashboard/info_tile.dart';
import '../../../../../core/widgets/dashboard/quick_action_button.dart';
import '../../../../../core/widgets/dashboard/role_scaffold.dart';
import '../../../../../core/widgets/dashboard/stat_card.dart';
import '../controllers/principal_dashboard_controller.dart';
import '../../../../../routes/app_routes.dart';

class PrincipalDashboardScreen extends GetView<PrincipalDashboardController> {
  const PrincipalDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return RoleScaffold(
      items: [
        RoleNavItem(
          icon: Icons.dashboard_outlined,
          label: 'Home',
          body: const _PrincipalHomeBody(),
        ),
        const RoleNavItem(
          icon: Icons.calendar_month_outlined,
          label: 'Schedule',
          body: _Placeholder(title: 'Schedule'),
        ),
        const RoleNavItem(
          icon: Icons.message_outlined,
          label: 'Messages',
          body: _Placeholder(title: 'Messages'),
        ),
        RoleNavItem(
          icon: Icons.person_outline,
          label: 'Profile',
          body: _ProfileTab(onLogout: RoleRouter.logout),
        ),
      ],
    );
  }
}

class _PrincipalHomeBody extends GetView<PrincipalDashboardController> {
  const _PrincipalHomeBody();

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: controller.fetchOverview,
      child: ListView(
        children: [
          Obx(
            () => DashboardHeader(
              avatarText: 'PW',
              title: 'EduManage',
              subtitle: 'Welcome, ${controller.principalName.value}',
              notificationCount: 3,
              onAvatarTap: () => ZoomDrawer.of(context)?.toggle(),
            ),
          ),
          _WelcomeBanner(),
          const SizedBox(height: 4),
          _StatsRow(),
          const _AttendanceCard(),
          DashboardSection(
            title: 'Quick Actions',
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                SizedBox(
                  width: (MediaQuery.of(context).size.width - 42) / 3,
                  child: QuickActionButton(
                    icon: Icons.person_add_alt_1_outlined,
                    label: 'New Admission',
                    onTap: () => Get.toNamed(AppRoutes.newAdmission),
                  ),
                ),
                SizedBox(
                  width: (MediaQuery.of(context).size.width - 42) / 3,
                  child: QuickActionButton(
                    icon: Icons.group_outlined,
                    label: 'Student List',
                    onTap: () => Get.toNamed(AppRoutes.studentList),
                  ),
                ),
                SizedBox(
                  width: (MediaQuery.of(context).size.width - 42) / 3,
                  child: QuickActionButton(
                    icon: Icons.update_outlined,
                    label: 'Season Update',
                    onTap: () => Get.toNamed(AppRoutes.seasonUpdate),
                  ),
                ),
                SizedBox(
                  width: (MediaQuery.of(context).size.width - 42) / 3,
                  child: QuickActionButton(
                    icon: Icons.person_add_outlined,
                    label: 'Add Student',
                    onTap: () => Get.toNamed(AppRoutes.addStudent),
                  ),
                ),
                SizedBox(
                  width: (MediaQuery.of(context).size.width - 42) / 3,
                  child: QuickActionButton(
                    icon: Icons.assessment_outlined,
                    label: 'Reports',
                    onTap: () => Get.toNamed(AppRoutes.newAdmissionReport),
                  ),
                ),
                SizedBox(
                  width: (MediaQuery.of(context).size.width - 42) / 3,
                  child: QuickActionButton(
                    icon: Icons.trending_up_outlined,
                    label: 'Promotion',
                    onTap: () => Get.toNamed(AppRoutes.studentPromotion),
                  ),
                ),
              ],
            ),
          ),
          DashboardSection(
            title: 'Recent Activities',
            actionLabel: 'View All',
            onActionTap: () {},
            child: Column(
              children: const [
                InfoTile(
                  icon: Icons.payments_outlined,
                  title: 'Fees processed for Grade 10-A',
                  subtitle: '15 minutes ago - Financial',
                ),
                InfoTile(
                  icon: Icons.person_add_alt_outlined,
                  title: 'New Teacher Registration: Sarah K.',
                  subtitle: '2 hours ago - HR',
                ),
                InfoTile(
                  icon: Icons.celebration_outlined,
                  title: 'Holiday Announcement sent to Parents',
                  subtitle: '4 hours ago - Communication',
                ),
              ],
            ),
          ),
          DashboardSection(
            title: 'School Alerts',
            child: Column(
              children: const [
                AlertCard(
                  icon: Icons.warning_amber_outlined,
                  title: 'Unpaid Staff Salary Notice',
                  message: '3 payroll entries require immediate review.',
                  tone: AlertTone.warning,
                ),
                SizedBox(height: 8),
                AlertCard(
                  icon: Icons.science_outlined,
                  title: 'Low Stock: Science Lab',
                  message: 'Chemical inventory below 15% threshold.',
                  tone: AlertTone.info,
                ),
              ],
            ),
          ),
          const SizedBox(height: 110),
        ],
      ),
    );
  }
}

class _WelcomeBanner extends GetView<PrincipalDashboardController> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Obx(
        () => Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: 'Welcome, ${controller.principalName.value}\n',
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              TextSpan(
                text: 'Here is your institutional overview for today.',
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatsRow extends GetView<PrincipalDashboardController> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Obx(
              () => StatCard(
                icon: Icons.groups_2_outlined,
                label: 'Total Students',
                value: '${controller.totalStudents.value}',
                subtitle:
                    '+${controller.newStudentsThisMonth.value} this month',
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Obx(
              () => StatCard(
                icon: Icons.school_outlined,
                label: 'Teachers',
                value: '${controller.teachersPresent.value}',
                subtitle: 'All Present',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AttendanceCard extends GetView<PrincipalDashboardController> {
  const _AttendanceCard();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Obx(
        () => StatCard(
          icon: Icons.event_available_outlined,
          label: 'Daily Attendance',
          value: controller.attendancePercent.value,
          subtitle: 'Slightly above average',
        ),
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
          Text('Profile', style: Theme.of(context).textTheme.titleLarge),
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
