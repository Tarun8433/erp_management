import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/utils/drawer_main/src/flutter_zoom_drawer.dart';
import '../../../../core/utils/role_router.dart';
import '../../../../core/widgets/dashboard/dashboard_header.dart';
import '../../../../core/widgets/dashboard/dashboard_section.dart';
import '../../../../core/widgets/dashboard/info_tile.dart';
import '../../../../core/widgets/dashboard/role_scaffold.dart';
import '../../../../core/widgets/dashboard/stat_card.dart';
import '../controllers/parent_dashboard_controller.dart';

class ParentDashboardScreen extends GetView<ParentDashboardController> {
  const ParentDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return RoleScaffold(
      items: [
        const RoleNavItem(
          icon: Icons.dashboard_outlined,
          label: 'Home',
          body: _ParentHomeBody(),
        ),
        const RoleNavItem(
          icon: Icons.school_outlined,
          label: 'Academics',
          body: _Placeholder(title: 'Academics'),
        ),
        const RoleNavItem(
          icon: Icons.payments_outlined,
          label: 'Fees',
          body: _Placeholder(title: 'Fees'),
        ),
        RoleNavItem(
          icon: Icons.message_outlined,
          label: 'Messages',
          body: _ProfileTab(onLogout: RoleRouter.logout),
        ),
      ],
    );
  }
}

class _ParentHomeBody extends GetView<ParentDashboardController> {
  const _ParentHomeBody();

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
              avatarText: 'A',
              title: controller.childName.value,
              subtitle: controller.childGrade.value,
              onAvatarTap: () => ZoomDrawer.of(context)?.toggle(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "TODAY'S ATTENDANCE",
                          style: textTheme.labelSmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            letterSpacing: 0.6,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Obx(
                          () => Row(
                            children: [
                              Icon(
                                Icons.check_circle,
                                size: 18,
                                color: colorScheme.tertiary,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                controller.attendanceStatus.value,
                                style: textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Obx(
                          () => Text(
                            controller.attendanceCheckIn.value,
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Obx(
                    () => CircleAvatar(
                      radius: 28,
                      backgroundColor: colorScheme.primaryContainer,
                      child: Text(
                        controller.attendancePercent.value,
                        style: textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: Obx(
                    () => StatCard(
                      icon: Icons.payments_outlined,
                      label: 'Upcoming Fee',
                      value: controller.feeAmount.value,
                      subtitle: controller.feeDueLabel.value,
                      accentColor: colorScheme.error,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Obx(
                    () => StatCard(
                      icon: Icons.event_outlined,
                      label: 'Next Exam',
                      value: controller.nextExamSubject.value,
                      subtitle: controller.nextExamMeta.value,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                child: const Text('PAY NOW'),
              ),
            ),
          ),
          DashboardSection(
            title: 'Academic Overview',
            actionLabel: 'VIEW ALL',
            onActionTap: () {},
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'MID-TERM REPORT',
                        style: textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          letterSpacing: 0.6,
                        ),
                      ),
                      Obx(
                        () => Text(
                          'Final Grade: ${controller.midTermGrade.value}',
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Obx(
                    () => Column(
                      children: controller.subjects
                          .map(
                            (s) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 90,
                                    child: Text(s.subject),
                                  ),
                                  Expanded(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: LinearProgressIndicator(
                                        value: s.percent / 100,
                                        minHeight: 6,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text('${s.percent}%'),
                                ],
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          DashboardSection(
            title: 'Latest Teacher Remarks',
            child: Obx(
              () => Column(
                children: controller.remarks
                    .map(
                      (r) => Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: colorScheme.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: colorScheme.outlineVariant.withValues(
                              alpha: 0.5,
                            ),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            InfoTile(
                              icon: Icons.account_circle_outlined,
                              title: r.teacher,
                              subtitle: r.subjectLabel,
                              trailingLabel: r.date,
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              child: Text(
                                '"${r.remark}"',
                                style: textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              child: TextButton.icon(
                                onPressed: () {},
                                icon: const Icon(Icons.reply, size: 16),
                                label: Text('REPLY TO ${r.teacher.toUpperCase()}'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
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
          Text('Messages', style: Theme.of(context).textTheme.titleLarge),
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
