import 'package:erp_management/features/notification/notification_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'package:erp_management/core/utils/drawer_main/src/drawer_controller.dart';
import 'package:erp_management/core/utils/drawer_main/src/flutter_zoom_drawer.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/bottom_nav_bar/bottom_bar.dart';
import '../../menu/menu_screen.dart';
import '../../home/home_screen.dart';
import '../../profile/views/profile_screen.dart';
import '../../settings/setting_screen.dart';
import '../../settings/setting_controller.dart';

class NavBar extends StatefulWidget {
  const NavBar({super.key});

  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> with SingleTickerProviderStateMixin {
  late int currentPage;
  late TabController tabController;
  final ZoomDrawerController _drawerController = ZoomDrawerController();
  late final SettingController settingController;

  @override
  void initState() {
    super.initState();
    settingController = Get.isRegistered<SettingController>()
        ? Get.find<SettingController>()
        : Get.put(SettingController());
    currentPage = 0;
    tabController = TabController(length: 4, vsync: this);
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
              children: [
                const HomeScreen(),
                const NotificationScreen(),
                const ProfileScreen(),
                SettingScreen(scrollController: controller),
              ],
            ),
            barColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            borderRadius: BorderRadius.circular(25),
            width: MediaQuery.of(context).size.width,
            offset: 15,
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
                destinations: [
                  NavigationDestination(
                    icon: const Icon(Icons.grid_view_outlined),
                    selectedIcon: Icon(
                      Icons.grid_view_rounded,
                      color: AppColors.primary,
                    ),
                    label: 'home'.tr,
                  ),
                  NavigationDestination(
                    icon: const Icon(Icons.track_changes),
                    selectedIcon: Icon(
                      Icons.track_changes_outlined,
                      color: AppColors.primary,
                    ),
                    label: 'tracking'.tr,
                  ),
                  NavigationDestination(
                    icon: const Icon(Icons.person_outline_rounded),
                    selectedIcon: Icon(
                      Icons.person_rounded,
                      color: AppColors.primary,
                    ),
                    label: 'profile'.tr,
                  ),
                  NavigationDestination(
                    icon: const Icon(Icons.settings_outlined),
                    selectedIcon: Icon(
                      Icons.settings_rounded,
                      color: AppColors.primary,
                    ),
                    label: 'setting'.tr,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}
