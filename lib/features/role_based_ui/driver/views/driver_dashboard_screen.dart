import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/utils/drawer_main/src/flutter_zoom_drawer.dart';
import '../../../../core/utils/role_router.dart';
import '../../../../core/widgets/dashboard/dashboard_header.dart';
import '../../../../core/widgets/dashboard/dashboard_section.dart';
import '../../../../core/widgets/dashboard/role_scaffold.dart';
import '../../../../core/widgets/dashboard/stat_card.dart';
import '../controllers/driver_dashboard_controller.dart';

class DriverDashboardScreen extends GetView<DriverDashboardController> {
  const DriverDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return RoleScaffold(
      items: [
        const RoleNavItem(
          icon: Icons.dashboard_outlined,
          label: 'Home',
          body: _DriverHomeBody(),
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

class _DriverHomeBody extends GetView<DriverDashboardController> {
  const _DriverHomeBody();

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
              avatarText: 'DM',
              title: 'EduManage',
              subtitle: 'Live Dashboard - ${controller.routeLabel.value}',
              onAvatarTap: () => ZoomDrawer.of(context)?.toggle(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                ),
              ),
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'NEXT STOP',
                    style: textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      letterSpacing: 0.6,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Obx(
                    () => Text(
                      controller.nextStop.value,
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Obx(
                    () => Text(
                      controller.etaLabel.value,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    height: 110,
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer.withValues(
                        alpha: 0.3,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.map_outlined,
                        size: 40,
                        color: colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: controller.triggerEmergency,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.error,
                        foregroundColor: colorScheme.onError,
                      ),
                      icon: const Icon(Icons.warning_amber_outlined),
                      label: const Text('EMERGENCY'),
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
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.alt_route),
                    label: const Text("Today's Route"),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.groups_outlined),
                    label: const Text('Students'),
                  ),
                ),
              ],
            ),
          ),
          DashboardSection(
            title: 'Student Pickup List',
            actionLabel: () {
              return '${controller.pickedCount}/${controller.totalCount} Picked Up';
            }(),
            child: Obx(
              () => Column(
                children: controller.pickups
                    .map(
                      (p) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: ListTile(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(
                              color: colorScheme.outlineVariant.withValues(
                                alpha: 0.5,
                              ),
                            ),
                          ),
                          leading: CircleAvatar(
                            backgroundColor: p.absent
                                ? colorScheme.errorContainer
                                : colorScheme.primaryContainer,
                            child: Icon(
                              p.absent
                                  ? Icons.cancel_outlined
                                  : Icons.person_outline,
                              color: p.absent
                                  ? colorScheme.onErrorContainer
                                  : colorScheme.onPrimaryContainer,
                            ),
                          ),
                          title: Text(p.name),
                          subtitle: Text(p.stop),
                          trailing: p.absent
                              ? const Icon(Icons.block)
                              : Obx(
                                  () => Switch(
                                    value: p.pickedUp.value,
                                    onChanged: (_) =>
                                        controller.togglePickup(p),
                                  ),
                                ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: Obx(
                    () => StatCard(
                      icon: Icons.timer_outlined,
                      label: 'Driving Time Today',
                      value: controller.drivingTime.value,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Obx(
                    () => StatCard(
                      icon: Icons.straighten_outlined,
                      label: 'Route Completed',
                      value: controller.routeCompleted.value,
                    ),
                  ),
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
