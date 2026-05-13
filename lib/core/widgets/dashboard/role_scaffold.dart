import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../constants/app_colors.dart';
import '../../utils/bottom_nav_bar/bottom_bar.dart';
import '../../utils/drawer_main/src/drawer_controller.dart';
import '../../utils/drawer_main/src/flutter_zoom_drawer.dart';
import '../../../features/menu/menu_screen.dart';
import '../../../features/settings/setting_controller.dart';

class RoleNavItem {
  final IconData icon;
  final IconData? selectedIcon;
  final String label;
  final Widget body;

  const RoleNavItem({
    required this.icon,
    this.selectedIcon,
    required this.label,
    required this.body,
  });
}

/// Shared scaffold used by all role dashboards.
/// Wraps role-specific tab bodies with the same ZoomDrawer + floating
/// BottomBar pattern as the home `NavBar`, while letting each role pass its
/// own list of [RoleNavItem]s for the bottom navigation destinations.
class RoleScaffold extends StatefulWidget {
  final List<RoleNavItem> items;
  final int initialIndex;

  const RoleScaffold({super.key, required this.items, this.initialIndex = 0});

  @override
  State<RoleScaffold> createState() => _RoleScaffoldState();
}

class _RoleScaffoldState extends State<RoleScaffold>
    with SingleTickerProviderStateMixin {
  late int currentPage = widget.initialIndex;
  late TabController tabController;
  final ZoomDrawerController _drawerController = ZoomDrawerController();
  late final SettingController settingController;

  @override
  void initState() {
    super.initState();
    settingController = Get.isRegistered<SettingController>()
        ? Get.find<SettingController>()
        : Get.put(SettingController());
    tabController = TabController(
      length: widget.items.length,
      vsync: this,
      initialIndex: widget.initialIndex,
    );
    tabController.addListener(() {
      if (!tabController.indexIsChanging) {
        setState(() {
          currentPage = tabController.index;
        });
      }
    });
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      currentPage = index;
    });
    tabController.animateTo(index);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Obx(() {
      return ZoomDrawer(
        style: settingController.drawerStyle.value,
        controller: _drawerController,
        menuScreen: const MenuScreen(),
        borderRadius: 24.0,
        showShadow: true,
        menuScreenWidth: double.infinity,
        angle: 1.0,
        drawerShadowsBackgroundColor: Colors.grey,
        slideWidth: MediaQuery.of(context).size.width * 0.80,
        mainScreenScale: .2,
        mainScreen: PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) async {
            if (didPop) return;

            final bool? confirm = await showDialog<bool>(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: const Text('Exit'),
                  content: const Text('Are you sure you want to exit?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: Text('cancel'.tr),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: Text('confirm'.tr),
                    ),
                  ],
                );
              },
            );
            if (confirm == true) {
              await SystemNavigator.pop();
            }
          },
          child: BottomBar(
            body: (context, controller) => TabBarView(
              controller: tabController,
              physics: const NeverScrollableScrollPhysics(),
              children: widget.items
                  .map(
                    (e) => Scaffold(
                      backgroundColor: Get.isDarkMode
                          ? Colors.black
                          : AppColors.background,
                      body: SafeArea(child: e.body),
                    ),
                  )
                  .toList(),
            ),
            barColor: isDark ? const Color(0xFF1E1E1E) : AppColors.grey200,
            borderRadius: BorderRadius.circular(160),
            width: MediaQuery.of(context).size.width,
            offset: 12,
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
            hideOnScroll: false,
            showIcon: false,
            child: NavigationBarTheme(
              data: NavigationBarThemeData(
                indicatorColor: AppColors.primary.withValues(alpha: 0.1),
                labelTextStyle: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    );
                  }
                  return theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white70 : Colors.black54,
                  );
                }),
              ),
              child: NavigationBar(
                height: 70,
                backgroundColor: Colors.transparent,
                elevation: 0,
                selectedIndex: currentPage,
                onDestinationSelected: _onItemTapped,
                destinations: widget.items
                    .map(
                      (item) => NavigationDestination(
                        icon: Icon(item.icon),
                        selectedIcon: Icon(
                          item.selectedIcon ?? item.icon,
                          color: AppColors.primary,
                        ),
                        label: item.label,
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
        ),
      );
    });
  }
}
