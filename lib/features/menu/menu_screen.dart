import 'dart:io';
import 'package:flutter/material.dart';
import 'package:erp_management/core/utils/drawer_main/src/flutter_zoom_drawer.dart';
import 'package:get/get.dart';
import 'package:erp_management/features/menu/controllers/menu_controller.dart'
    as app_menu;
import 'package:erp_management/features/menu/models/menu_response.dart';
import 'package:shimmer/shimmer.dart';
import 'package:erp_management/core/services/api/dilog/logout_confermation.dart';
import 'package:erp_management/routes/app_routes.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensure controller is available
    final controller = Get.put(app_menu.MenuController());

    return Scaffold(
      body: Stack(
        children: [
          Container(
            // decoration: const BoxDecoration(
            //   image: DecorationImage(
            //     image: AssetImage("assets/background.png"),
            //     fit: BoxFit.cover,
            //   ),
            // ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: context.isDarkMode
                    ? [
                        Colors.black.withValues(alpha: 0.7),
                        Colors.black.withValues(alpha: 1),
                      ]
                    : [
                        Colors.white.withValues(alpha: 0.7),
                        Colors.white.withValues(alpha: 1),
                      ],
              ),
            ),
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Obx(() {
                        final imagePath = controller.profileImagePath.value;
                        if (imagePath != null && File(imagePath).existsSync()) {
                          return CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.white,
                            backgroundImage: FileImage(File(imagePath)),
                            onBackgroundImageError: (_, e) {
                              // Fallback if image fails to load
                            },
                          );
                        }
                        return CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.white,
                          child: Icon(
                            Icons.person,
                            size: 30,
                            color: context.theme.primaryColor,
                          ),
                        );
                      }),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Obx(
                            () => Text(
                              '${'hi'.tr}, ${controller.userName.value.isNotEmpty ? controller.userName.value : "User"}',
                              style: context.textTheme.titleLarge?.copyWith(
                                color: context.isDarkMode
                                    ? Colors.white
                                    : Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Obx(
                            () => Text(
                              controller.userRole.value,
                              style: context.textTheme.bodyMedium?.copyWith(
                                color: context.isDarkMode
                                    ? Colors.white70
                                    : Colors.black54,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Divider(
                  color: context.isDarkMode ? Colors.white30 : Colors.black12,
                ),

                // Dynamic Menu Items
                Expanded(
                  child: Obx(() {
                    if (controller.isLoading.value &&
                        controller.menuItems.isEmpty) {
                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        itemCount: 8,
                        itemBuilder: (context, index) {
                          return Shimmer.fromColors(
                            baseColor: context.isDarkMode
                                ? Colors.white24
                                : Colors.grey[300]!,
                            highlightColor: context.isDarkMode
                                ? Colors.white12
                                : Colors.grey[100]!,
                            child: ListTile(
                              leading: Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: context.isDarkMode
                                      ? Colors.white
                                      : Colors.black,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              title: Container(
                                width: double.infinity,
                                height: 16,
                                decoration: BoxDecoration(
                                  color: context.isDarkMode
                                      ? Colors.white
                                      : Colors.black,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    }

                    if (controller.menuItems.isEmpty) {
                      // Fallback to static items if empty or failed to load
                      return ListView(
                        children: [
                          _buildStaticItem(context, Icons.home, 'home'.tr, () {
                            ZoomDrawer.of(context)?.close();
                          }),
                          _buildStaticItem(
                            context,
                            Icons.settings,
                            'setting'.tr,
                            () {
                              ZoomDrawer.of(context)?.close();
                              Get.toNamed(AppRoutes.settings);
                            },
                          ),
                          _buildStaticItem(
                            context,
                            Icons.person_add_alt_1_outlined,
                            'New Admission',
                            () {
                              ZoomDrawer.of(context)?.close();
                              Get.toNamed(AppRoutes.newAdmission);
                            },
                          ),
                          _buildStaticItem(
                            context,
                            Icons.group_outlined,
                            'Student List',
                            () {
                              ZoomDrawer.of(context)?.close();
                              Get.toNamed(AppRoutes.studentList);
                            },
                          ),
                          _buildStaticItem(
                            context,
                            Icons.assessment_outlined,
                            'Admission Report',
                            () {
                              ZoomDrawer.of(context)?.close();
                              Get.toNamed(AppRoutes.newAdmissionReport);
                            },
                          ),
                          _buildStaticItem(
                            context,
                            Icons.trending_up_outlined,
                            'Student Promotion',
                            () {
                              ZoomDrawer.of(context)?.close();
                              Get.toNamed(AppRoutes.studentPromotion);
                            },
                          ),
                          _buildStaticItem(
                            context,
                            Icons.update_outlined,
                            'Season Update',
                            () {
                              ZoomDrawer.of(context)?.close();
                              Get.toNamed(AppRoutes.seasonUpdate);
                            },
                          ),
                          _buildStaticItem(
                            context,
                            Icons.person_add_outlined,
                            'Add Student',
                            () {
                              ZoomDrawer.of(context)?.close();
                              Get.toNamed(AppRoutes.addStudent);
                            },
                          ),
                        ],
                      );
                    }

                    return ListView.builder(
                      itemCount:
                          controller.menuItems.length +
                          2, // Home + Dynamic Items + (Settings/Logout group)
                      itemBuilder: (context, index) {
                        // 0: Home
                        if (index == 0) {
                          return _buildStaticItem(
                            context,
                            Icons.home,
                            'home'.tr,
                            () {
                              ZoomDrawer.of(context)?.close();
                            },
                          );
                        }

                        // Dynamic Items
                        if (index <= controller.menuItems.length) {
                          final item = controller.menuItems[index - 1];
                          return _buildDynamicMenuItem(
                            context,
                            item,
                            controller,
                          );
                        }

                        // Settings and Logout at the end
                        if (index == controller.menuItems.length + 1) {
                          return Column(
                            children: [
                              Divider(
                                color: context.isDarkMode
                                    ? Colors.white30
                                    : Colors.black12,
                              ),
                              _buildStaticItem(
                                context,
                                Icons.settings,
                                'setting'.tr,
                                () {
                                  ZoomDrawer.of(context)?.close();
                                  Get.toNamed(AppRoutes.settings);
                                },
                              ),
                              _buildStaticItem(
                                context,
                                Icons.logout,
                                'logout'.tr,
                                () {
                                  ZoomDrawer.of(context)?.close();
                                  showLogoutConfirmationDialog(context);
                                },
                              ),
                              const SizedBox(height: 20),
                            ],
                          );
                        }

                        return const SizedBox.shrink();
                      },
                    );
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDynamicMenuItem(
    BuildContext context,
    MenuComponent item,
    app_menu.MenuController controller, {
    int level = 0,
  }) {
    final hasChildren = item.subMenu != null && item.subMenu!.isNotEmpty;
    final bool isDark = context.isDarkMode;
    final Color textColor = isDark ? Colors.white : Colors.black87;
    final Color subTextColor = isDark ? Colors.white70 : Colors.black54;
    final Color iconColor = isDark ? Colors.white54 : Colors.black45;
    final double leftIndent = 16.0 + (level * 20.0);

    if (hasChildren) {
      return Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: ExpansionTile(
          iconColor: iconColor,
          collapsedIconColor: iconColor,
          tilePadding: EdgeInsets.only(left: leftIndent, right: 16),
          leading: level == 0
              ? _buildItemIcon(context, item, controller, iconColor)
              : null,
          title: Text(
            item.menuName ?? '',
            style: TextStyle(
              color: level == 0 ? textColor : subTextColor,
              fontWeight: level == 0 ? FontWeight.bold : FontWeight.w600,
              fontSize: level == 0 ? 15.0 : 14.0,
            ),
          ),
          children: item.subMenu!
              .map(
                (sub) => _buildDynamicMenuItem(
                  context,
                  sub,
                  controller,
                  level: level + 1,
                ),
              )
              .toList(),
        ),
      );
    }

    // Leaf item — no children
    return InkWell(
      onTap: (item.route != null && item.route!.isNotEmpty)
          ? () {
              ZoomDrawer.of(context)?.close();
              _handleNavigation(item.route!);
            }
          : null,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: EdgeInsets.only(
          left: leftIndent,
          right: 16,
          top: 11,
          bottom: 11,
        ),
        child: Row(
          children: [
            if (level == 0) ...[
              _buildItemIcon(context, item, controller, iconColor),
              const SizedBox(width: 12),
            ] else ...[
              Container(
                width: 5,
                height: 5,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color: iconColor,
                  shape: BoxShape.circle,
                ),
              ),
            ],
            Expanded(
              child: Text(
                item.menuName ?? '',
                style: TextStyle(
                  color: level == 0 ? textColor : subTextColor,
                  fontWeight:
                      level == 0 ? FontWeight.w600 : FontWeight.w500,
                  fontSize: level == 0 ? 15.0 : 14.0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemIcon(
    BuildContext context,
    MenuComponent item,
    app_menu.MenuController controller,
    Color iconColor,
  ) {
    if (controller.isNetworkIcon(item.icon)) {
      return Image.network(
        controller.getFullIconUrl(item.icon!),
        width: 20,
        height: 20,
        fit: BoxFit.contain,
        errorBuilder: (_, e, s) => Icon(
          Icons.image_not_supported_outlined,
          color: iconColor,
          size: 20,
        ),
      );
    }
    return Icon(controller.getIcon(item.icon), color: iconColor, size: 20);
  }

  void _handleNavigation(String route) {
    // Map API routes to AppRoutes
    if (route == '/Student/NewAdmission') {
      Get.toNamed(AppRoutes.newAdmission);
    } else if (route == '/Student/NewAdmissionList') {
      Get.toNamed(AppRoutes.newAdmissionReport);
    } else if (route == '/Student/AddStudent') {
      Get.toNamed(AppRoutes.addStudent);
    } else if (route == '/Student/StudentList') {
      Get.toNamed(AppRoutes.studentList);
    } else if (route == '/Student/Promote') {
      Get.toNamed(AppRoutes.studentPromotion);
    } else if (route == '/Student/SectionUpdate') {
      Get.toNamed(AppRoutes.seasonUpdate);
    } else if (route == '/Dashboard') {
      // Stay on Home
    } else {
      try {
        Get.toNamed(route);
      } catch (e) {
        debugPrint('Route $route not found: $e');
      }
    }
  }

  Widget _buildStaticItem(
    BuildContext context,
    IconData icon,
    String title,
    VoidCallback onTap,
  ) {
    final bool isDashboard =
        title.toLowerCase() == 'home' || title.toLowerCase() == 'dashboard';
    final Color textColor = context.isDarkMode ? Colors.white : Colors.black87;
    final Color activeBgColor = context.isDarkMode
        ? Colors.white.withValues(alpha: 0.1)
        : Colors.grey.withValues(alpha: 0.1);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isDashboard ? activeBgColor : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: context.isDarkMode ? Colors.white70 : Colors.black54,
                size: 22,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: context.textTheme.bodyLarge?.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
