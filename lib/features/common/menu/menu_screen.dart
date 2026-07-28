import 'dart:io';
import 'package:erp_management/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:erp_management/core/utils/drawer_main/src/flutter_zoom_drawer.dart';
import 'package:get/get.dart';
import 'package:erp_management/features/common/menu/controllers/menu_controller.dart'
    as app_menu;
import 'package:erp_management/features/common/menu/models/menu_response.dart';
import 'package:shimmer/shimmer.dart';
import 'package:erp_management/core/services/api/dilog/logout_confermation.dart';
import 'package:erp_management/routes/app_routes.dart';

const List<Color> _palette = [
  Color(0xFF1565C0),
  Color(0xFF00897B),
  Color(0xFF6A1B9A),
  Color(0xFFF57C00),
  Color(0xFF2E7D32),
  Color(0xFFC62828),
  Color(0xFF00838F),
  Color(0xFF4527A0),
];

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<app_menu.MenuController>();
    final isDark = context.isDarkMode;
    final theme = Theme.of(context);
    final bg = theme.colorScheme.surface;

    return Scaffold(
      backgroundColor: bg,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          _buildHeader(context, controller, isDark),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.menuItems.isEmpty) {
                return _buildShimmer(context);
              }
              return _buildMenuList(context, controller, isDark);
            }),
          ),
          _buildFooter(context, controller, isDark),
        ],
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────────

  Widget _buildHeader(
    BuildContext context,
    app_menu.MenuController controller,
    bool isDark,
  ) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.6)],
        ),
      ),

      padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
      child: SafeArea(
        bottom: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                ZoomDrawer.of(context)?.close();
                Get.toNamed(AppRoutes.principalProfile);
              },
              child: Obx(() {
                final path = controller.profileImagePath.value;
                return Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: theme.colorScheme.surfaceContainerHigh,
                    border: Border.all(
                      color: theme.colorScheme.outlineVariant,
                      width: 2,
                    ),
                  ),
                  child: ClipOval(
                    child: (path != null && File(path).existsSync())
                        ? Image.file(File(path), fit: BoxFit.cover)
                        : Icon(
                            Icons.person_rounded,
                            color: AppColors.primary,
                            size: 32,
                          ),
                  ),
                );
              }),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Obx(
                    () => Text(
                      controller.userName.value.isNotEmpty
                          ? controller.userName.value
                          : "User",
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Obx(
                    () => Text(
                      controller.userRole.value,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.w500,
                        height: 1.3,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => ZoomDrawer.of(context)?.close(),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.close_rounded,
                  color: theme.colorScheme.onSurface,
                  size: 22,
                ),
              ),
            ),
            SizedBox(width: Get.width * 0.1),
          ],
        ),
      ),
    );
  }

  // ── Shimmer ───────────────────────────────────────────────────────────────────

  Widget _buildShimmer(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final base = scheme.surfaceContainerHighest;
    final highlight = scheme.surfaceContainer;
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
      itemCount: 8,
      itemBuilder: (_, _) => Shimmer.fromColors(
        baseColor: base,
        highlightColor: highlight,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          height: 52,
          decoration: BoxDecoration(
            color: base,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  // ── Menu List ─────────────────────────────────────────────────────────────────

  Widget _buildMenuList(
    BuildContext context,
    app_menu.MenuController controller,
    bool isDark,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 0),
      itemCount: controller.menuItems.length,
      itemBuilder: (_, index) {
        final item = controller.menuItems[index];
        return _buildDynamicItem(context, item, controller, isDark, index);
      },
    );
  }

  // ── Static Tile ───────────────────────────────────────────────────────────────

  Widget _buildTile(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final textColor = theme.colorScheme.onSurface;
    final iconColor = theme.colorScheme.onSurfaceVariant;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(icon, color: iconColor, size: 22),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    label,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: textColor,
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: theme.colorScheme.outline,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Dynamic Item (expandable or leaf) ─────────────────────────────────────────

  Widget _buildDynamicItem(
    BuildContext context,
    MenuComponent item,
    app_menu.MenuController controller,
    bool isDark,
    int paletteIndex, {
    int level = 0,
  }) {
    final hasChildren = item.subMenu != null && item.subMenu!.isNotEmpty;
    final color = _palette[paletteIndex % _palette.length];

    if (!hasChildren) {
      return Padding(
        padding: EdgeInsets.only(left: level > 0 ? 16 : 0),
        child: _buildLeafTile(
          context,
          item: item,
          controller: controller,
          isDark: isDark,
          color: color,
          level: level,
        ),
      );
    }

    return Padding(
              padding: EdgeInsets.only(left: level > 0 ? 16 : 0),
      child: _ExpandableTile(
        item: item,
        isDark: isDark,
        level: level,
        color: color,
      
        icon: _iconForMenuItem(item.menuName, item.route),
        controller: controller,
        children: item.subMenu!
            .map(
              (sub) => Padding(
                padding: EdgeInsets.only(left: level > 0 ? 16 : 0),
                child: _buildDynamicItem(
                  context,
                  sub,
                  controller,
                  isDark,
                  paletteIndex,
                  level: level + 1,
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildLeafTile(
    BuildContext context, {
    required MenuComponent item,
    required app_menu.MenuController controller,
    required bool isDark,
    required Color color,
    required int level,
  }) {
    final theme = Theme.of(context);
    final textColor = theme.colorScheme.onSurface;
    final iconColor = theme.colorScheme.onSurfaceVariant;

    return SizedBox(
      width: Get.width * .8,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: (item.route != null && item.route!.isNotEmpty)
              ? () {
                  ZoomDrawer.of(context)?.close();
                  _handleNavigation(item.route!);
                }
              : null,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _palette[level].withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _iconForMenuItem(item.menuName, item.route),
                    color: iconColor,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    item.menuName ?? '',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: textColor,
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: theme.colorScheme.outline,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleNavigation(String route) {
    // Route strings come from the menu API. Keep these in sync with it.
    switch (route) {
      case '/Student/NewAdmission':
        Get.toNamed(AppRoutes.newAdmission);
        break;
      case '/Student/NewStudentList': // "New Admission List"
        Get.toNamed(AppRoutes.newAdmissionReport);
        break;
      case '/Student/AddStudent':
        Get.toNamed(AppRoutes.addStudent);
        break;
      case '/Student/StudentList':
        Get.toNamed(AppRoutes.studentList);
        break;
      case '/Student/Promote':
        Get.toNamed(AppRoutes.studentPromotion);
        break;
      case '/Student/SectionUpdate':
        Get.toNamed(AppRoutes.seasonUpdate);
        break;
      case '/Document/ManageStudentImages': // "Manage Student Image" / Missing Image
        Get.toNamed(AppRoutes.missingImages);
        break;
      case '/Attendence/Student': // note: API spelling is "Attendence"
      case '/Attendance/Student':
        Get.toNamed(AppRoutes.attendance);
        break;
      case '/Examination/NumberSheet':
      case '/Result/NumberSheet':
        Get.toNamed(AppRoutes.numberSheet);
        break;
      case '/Fees/DueFee':
        Get.toNamed(AppRoutes.dueFees);
        break;
      case '/Staff/StaffManagement':
        Get.toNamed(AppRoutes.staff);
        break;
      case '/Student/ClassWork':
        Get.toNamed(AppRoutes.classWork);
        break;

      case "/Attendence/AttendanceRegister":
        Get.toNamed(AppRoutes.attendanceMarking);
        break;
      case '/Student/HomeWork':
        Get.toNamed(AppRoutes.homeWork);
        break;
      case '/Dashboard/BranchAdmin':
      case '/Dashboard':
        // Already on Home — drawer was closed by the caller.
        break;
      default:
        // Routes with no screen yet (Collect Fee, Staff Attendance, Exam Schedule…).
        Get.snackbar(
          'Coming Soon',
          'This feature is not available yet.',
          snackPosition: SnackPosition.BOTTOM,
        );
    }
  }

  // ── Footer ────────────────────────────────────────────────────────────────────

  Widget _buildFooter(
    BuildContext context,
    app_menu.MenuController controller,
    bool isDark,
  ) {
    final borderColor = Theme.of(context).dividerColor;

    return Container(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: borderColor, width: 1)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        children: [
          _buildTile(
            context,
            icon: Icons.settings_outlined,
            label: 'setting'.tr,
            color: const Color(0xFF6C757D),
            isDark: isDark,
            onTap: () {
              ZoomDrawer.of(context)?.close();
              Get.toNamed(AppRoutes.settings);
            },
          ),
          _buildTile(
            context,
            icon: Icons.logout_rounded,
            label: 'logout'.tr,
            color: const Color(0xFFDC3545),
            isDark: isDark,
            onTap: () {
              ZoomDrawer.of(context)?.close();
              showLogoutConfirmationDialog(context);
            },
          ),
        ],
      ),
    );
  }
}

// ── Icon helper ───────────────────────────────────────────────────────────────

IconData _iconForMenuItem(String? name, String? route) {
  final n = (name ?? '').toLowerCase();
  final r = (route ?? '').toLowerCase();
  if (n.contains('dashboard') || r.contains('dashboard')) {
    return Icons.dashboard_outlined;
  }
  if (n.contains('new admission') || r.contains('newadmission')) {
    return Icons.person_add_outlined;
  }
  if (n.contains('admission list') ||
      n.contains('admission report') ||
      r.contains('admissionlist')) {
    return Icons.assignment_outlined;
  }
  if (n.contains('add student') || r.contains('addstudent')) {
    return Icons.person_add_alt_1_outlined;
  }
  if (n == 'studentlist' ||
      n.contains('student list') ||
      r.contains('studentlist')) {
    return Icons.format_list_bulleted;
  }
  if (n.contains('promote') || r.contains('promote')) {
    return Icons.trending_up_outlined;
  }
  if (n.contains('image') || r.contains('image')) {
    return Icons.photo_camera_outlined;
  }
  if (n.contains('section') || n.contains('season') || r.contains('section')) {
    return Icons.update_outlined;
  }
  if (n.contains('my task') || n.contains('mytask') || r.contains('task')) {
    return Icons.task_alt;
  }
  if (n.contains('class work') || r.contains('classwork')) {
    return Icons.class_outlined;
  }
  if (n.contains('home work') || r.contains('homework')) {
    return Icons.home_work_outlined;
  }
  if (n.contains('student')) return Icons.people_outlined;
  if (n.contains('exam') ||
      n.contains('number sheet') ||
      r.contains('numbersheet')) {
    return Icons.quiz_outlined;
  }
  if (n.contains('fee') || n.contains('payment') || n.contains('finance')) {
    return Icons.payments_outlined;
  }
  if (n.contains('attendance')) return Icons.fact_check_outlined;
  if (n.contains('report')) return Icons.assessment_outlined;
  if (n.contains('notice') || n.contains('circular')) {
    return Icons.announcement_outlined;
  }
  if (n.contains('transport') || n.contains('bus')) {
    return Icons.directions_bus_outlined;
  }
  if (n.contains('library')) return Icons.library_books_outlined;
  if (n.contains('staff') || n.contains('teacher')) {
    return Icons.school_outlined;
  }
  if (n.contains('setting')) return Icons.settings_outlined;
  return Icons.widgets_outlined;
}

// ── Expandable tile with animated arrow ───────────────────────────────────────

class _ExpandableTile extends StatefulWidget {
  final MenuComponent item;
  final bool isDark;
  final int level;
  final Color color;
  final IconData icon;
  final app_menu.MenuController controller;
  final List<Widget> children;

  const _ExpandableTile({
    required this.item,
    required this.isDark,
    required this.level,
    required this.color,
    required this.icon,
    required this.controller,
    required this.children,
  });

  @override
  State<_ExpandableTile> createState() => _ExpandableTileState();
}

class _ExpandableTileState extends State<_ExpandableTile> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.colorScheme.onSurface;
    final iconColor = theme.colorScheme.onSurfaceVariant;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: Get.width * .8,
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                onTap: () => setState(() => _isExpanded = !_isExpanded),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(widget.icon, color: iconColor, size: 22),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          widget.item.menuName ?? '',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: textColor,
                            fontWeight: FontWeight.w600,
                            height: 1.3,
                          ),
                        ),
                      ),
                      AnimatedRotation(
                        turns: _isExpanded ? 0.5 : 0,
                        duration: const Duration(milliseconds: 200),
                        child: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: widget.color,
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOutCubic,
            child: _isExpanded
                ? Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: widget.children,
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
