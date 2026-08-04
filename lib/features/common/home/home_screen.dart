import 'dart:async';
import 'package:erp_management/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:erp_management/core/constants/app_colors.dart';
import 'package:erp_management/core/utils/drawer_main/src/flutter_zoom_drawer.dart';
import 'package:erp_management/features/common/home/widgets/home_simmer.dart';
import 'package:erp_management/features/common/profile/controllers/profile_controller.dart';
import 'package:erp_management/features/common/menu/controllers/menu_controller.dart'
    as app_menu;
import 'package:erp_management/features/common/menu/models/menu_response.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Get controllers
    final profileController = Get.find<ProfileController>();
    final menuController = Get.find<app_menu.MenuController>();

    return Scaffold(
      //backgroundColor: AppColors.darkBackground,
      backgroundColor: Get.isDarkMode
          ? AppColors.black
          : AppColors.primaryBlue3,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 200.0,
            backgroundColor: context.theme.primaryColor,
            leading: GestureDetector(
              onTap: () => ZoomDrawer.of(context)?.toggle(),
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: Obx(
                  () => CircleAvatar(
                    backgroundColor: AppColors.white,
                    radius: 25,
                    backgroundImage:
                        profileController.profileImage.value != null
                        ? FileImage(profileController.profileImage.value!)
                        : null,
                    child: profileController.profileImage.value == null
                        ? Icon(Icons.menu, color: context.theme.primaryColor)
                        : null,
                  ),
                ),
              ),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Obx(
                  () => Text(
                    '${'hi'.tr}, ${profileController.userName.value.split(' ')[0]}!',
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.white, width: 2),
                  ),
                  child: Badge.count(
                    count: 9,
                    child: const Icon(
                      Icons.notifications,
                      size: 24,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: const _AppBarBackgroundSlider(),
            ),
          ),

          SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(
                color: Get.isDarkMode
                    ? AppColors.black
                    : AppColors.primaryBlue3,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(25),
                  topRight: Radius.circular(25),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Menu Grid
                  _buildMenuGrid(context, menuController),
                  const SizedBox(height: 86),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuGrid(
    BuildContext context,
    app_menu.MenuController controller,
  ) {
    return Obx(() {
      if (controller.isLoading.value && controller.menuItems.isEmpty) {
        return HomeSimmerWidget();
      }

      // Filter out Dashboard
      final visibleItems = controller.menuItems
          .where((item) => item.menuName?.toLowerCase() != 'dashboard')
          .toList();

      if (visibleItems.isEmpty) {
        return SizedBox();
      }

      // Build two passes: first collect all groups, then interleave banner
      final List<Widget> groupWidgets = [];
      List<MenuComponent> standaloneItems = [];
      int groupIndex = 0; // track group position for odd/even styling

      for (var item in visibleItems) {
        if (item.subMenu == null || item.subMenu!.isEmpty) {
          standaloneItems.add(item);
        } else {
          if (standaloneItems.isNotEmpty) {
            final isEven = groupIndex % 2 == 0;
            groupWidgets.add(
              _buildStandaloneGrid(
                context,
                standaloneItems,
                controller,
                isEven: isEven,
              ),
            );
            groupWidgets.add(const SizedBox(height: 20));
            standaloneItems = [];
            groupIndex++;
          }
          final isEven = groupIndex % 2 == 0;
          groupWidgets.add(
            Container(
              margin: const EdgeInsets.only(bottom: 0),
              decoration: BoxDecoration(
                color: isEven
                    ? (context.isDarkMode
                          ? AppColors.darkBackground
                          : AppColors.transparent)
                    : (context.isDarkMode
                          ? context.theme.primaryColor.withOpacity(0.15)
                          : context.theme.primaryColor.withOpacity(0.06)),
                borderRadius: BorderRadius.circular(0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 12,
                      bottom: 12,
                      top: 12,
                      right: 12,
                    ),
                    child: Text(
                      item.menuName ?? '',
                      style: context.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  GridView.builder(
                    padding: EdgeInsets.fromLTRB(12, 0, 12, 0),
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: isEven ? 2 : 4,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 0,
                      childAspectRatio: 1.1,
                      mainAxisExtent: isEven ? 75 : 110,
                    ),
                    itemCount: item.subMenu!.length,
                    itemBuilder: (context, childIndex) {
                      final child = item.subMenu![childIndex];
                      return _buildMenuCard(
                        context,
                        child,
                        controller,
                        isEven: isEven,
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
          groupIndex++;
        }
      }

      if (standaloneItems.isNotEmpty) {
        final isEven = groupIndex % 2 == 0;
        groupWidgets.add(
          _buildStandaloneGrid(
            context,
            standaloneItems,
            controller,
            isEven: isEven,
          ),
        );
        groupWidgets.add(const SizedBox(height: 20));
      }

      // ── Change this number to show the banner after a different group ──
      // 1 = after 1st grid, 2 = after 2nd grid, etc.
      const int showBannerAfterGroup = 3;
      // const int showBannerAfterGroup1 = 5;
      final List<Widget> widgets = [];
      bool bannerInserted = false;
      int groupCount = 0;

      for (int i = 0; i < groupWidgets.length; i++) {
        widgets.add(groupWidgets[i]);

        // Count only real grid groups, not SizedBox spacers
        if (groupWidgets[i] is! SizedBox) {
          groupCount++;
        }

        // Insert banner after the desired group
        if (!bannerInserted && groupCount == showBannerAfterGroup
        // || groupCount == showBannerAfterGroup1
        ) {
          widgets.add(_buildInfoBanner(context));
          widgets.add(const SizedBox(height: 4));
          bannerInserted = true;
        }
      }
      if (!bannerInserted) {
        widgets.add(_buildInfoBanner(context));
        widgets.add(const SizedBox(height: 4));
      }

      return ListView(
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: widgets,
      );
    });
  }

  Widget _buildInfoBanner(BuildContext context) {
    final banners = [
      (
        hint: 'tip',
        title: 'Update your profile to stay compliant',
        icon: Icons.person_pin_outlined,
        color: const Color(0xFF6A1B9A),
      ),
      (
        hint: 'feature',
        title: 'Track shipments in real-time',
        icon: Icons.local_shipping_outlined,
        color: const Color(0xFF1E88E5),
      ),
      (
        hint: 'reminder',
        title: 'Check your pending tickets',
        icon: Icons.confirmation_number_outlined,
        color: const Color(0xFF00897B),
      ),
    ];

    return _BannerCarousel(banners: banners);
  }

  Widget _buildStandaloneGrid(
    BuildContext context,
    List<MenuComponent> items,
    app_menu.MenuController controller, {
    bool isEven = true,
  }) {
    return GridView.builder(
      padding: EdgeInsets.fromLTRB(12, 12, 12, 0),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isEven ? 2 : 4,
        crossAxisSpacing: 8,
        mainAxisSpacing: 0,
        childAspectRatio: 1.1,
        mainAxisExtent: isEven ? 75 : 100,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return _buildMenuCard(
          context,
          items[index],
          controller,
          isEven: isEven,
        );
      },
    );
  }

  Widget _buildMenuCard(
    BuildContext context,
    MenuComponent item,
    app_menu.MenuController controller, {
    bool isEven = true,
  }) {
    // ── Even style: white card, colored icon ──
    // ── Odd style: colored card, white icon ──
    final cardColor = isEven
        ? (context.isDarkMode ? AppColors.grey800 : AppColors.white)
        : context.theme.primaryColor;
    final iconBgColor = isEven
        ? Get.isDarkMode
              ? AppColors.white.withValues(alpha: 0.5)
              : AppColors.primary.withValues(alpha: 0.2)
        : AppColors.white.withValues(alpha: 0.5);
    final iconColor = isEven
        ? Get.isDarkMode
              ? AppColors.white
              : context.theme.primaryColor
        : AppColors.white;
    final textColor = isEven
        ? null
        : Get.isDarkMode
        ? AppColors.white
        : context.theme.primaryColor;

    return InkWell(
      onTap: () {
        if (item.subMenu != null && item.subMenu!.isNotEmpty) {
          _showSubMenuBottomSheet(context, item, controller);
        } else {
          // Handle tap for items without sub-menu if route is provided
          if (item.route != null && item.route!.isNotEmpty) {
            _handleNavigation(item.route!);
          }
        }
      },
      borderRadius: BorderRadius.circular(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            height: 65,
            width: isEven ? Get.width * 0.5 : 65,
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: iconBgColor,
                    shape: BoxShape.circle,
                  ),
                  child: controller.isNetworkIcon(item.icon)
                      ? Image.network(
                          controller.getFullIconUrl(item.icon!),
                          width:
                              context.textTheme.headlineSmall?.fontSize ?? 20,
                          height:
                              context.textTheme.headlineSmall?.fontSize ?? 20,
                          fit: BoxFit.contain,
                          errorBuilder: (c, e, s) => Icon(
                            Icons.image_not_supported_outlined,
                            size:
                                context.textTheme.headlineSmall?.fontSize ?? 20,
                            color: iconColor,
                          ),
                        )
                      : Icon(
                          (item.route == '/master/process/support-ticket' ||
                                  (item.route?.contains('support-ticket') ??
                                      false))
                              ? Icons.support_agent_outlined
                              : controller.getIcon(item.icon),
                          size: context.textTheme.headlineSmall?.fontSize ?? 20,
                          color: iconColor,
                        ),
                ),
                !isEven
                    ? const SizedBox.shrink()
                    : SizedBox(
                        width: Get.width * 0.3,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 4, left: 8),
                          child: Text(
                            item.menuName ?? 'unknown_menu'.tr,
                            textAlign: TextAlign.start,
                            style: context.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: textColor,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          isEven
              ? const SizedBox.shrink()
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    item.menuName ?? 'unknown_menu'.tr,
                    textAlign: TextAlign.center,
                    style: context.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
        ],
      ),
    );
  }

  void _showSubMenuBottomSheet(
    BuildContext context,
    MenuComponent parentItem,
    app_menu.MenuController controller,
  ) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: context.theme.scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.grey.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              parentItem.menuName ?? 'menu'.tr,
              style: context.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Flexible(
              child: ListView.separated(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: parentItem.subMenu!.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final child = parentItem.subMenu![index];
                  return _buildBottomSheetMenuItem(context, child, controller);
                },
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildBottomSheetMenuItem(
    BuildContext context,
    MenuComponent item,
    app_menu.MenuController controller,
  ) {
    final hasChildren = item.subMenu != null && item.subMenu!.isNotEmpty;

    if (hasChildren) {
      return ExpansionTile(
        tilePadding: EdgeInsets.zero,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: controller.isNetworkIcon(item.icon)
              ? Image.network(
                  controller.getFullIconUrl(item.icon!),
                  width: 20,
                  height: 20,
                  fit: BoxFit.contain,
                  errorBuilder: (c, e, s) => Icon(
                    Icons.image_not_supported_outlined,
                    color: AppColors.primary,
                    size: 20,
                  ),
                )
              : Icon(
                  controller.getIcon(item.icon),
                  color: AppColors.primary,
                  size: 20,
                ),
        ),
        title: Text(item.menuName ?? '', style: context.textTheme.titleMedium),
        children: item.subMenu!
            .map(
              (child) => _buildBottomSheetMenuItem(context, child, controller),
            )
            .toList(),
      );
    }

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: controller.isNetworkIcon(item.icon)
            ? Image.network(
                controller.getFullIconUrl(item.icon!),
                width: 20,
                height: 20,
                fit: BoxFit.contain,
                errorBuilder: (c, e, s) => Icon(
                  Icons.image_not_supported_outlined,
                  color: AppColors.primary,
                  size: 20,
                ),
              )
            : Icon(
                (item.route == '/master/process/support-ticket' ||
                        (item.route?.contains('support-ticket') ?? false))
                    ? Icons.support_agent_outlined
                    : controller.getIcon(item.icon),
                color: AppColors.primary,
                size: 20,
              ),
      ),
      title: Text(item.menuName ?? '', style: context.textTheme.titleMedium),
      trailing: const Icon(
        Icons.chevron_right,
        size: 20,
        color: AppColors.grey,
      ),
      onTap: () {
        Get.back(); // Close bottom sheet
        if (item.route != null && item.route!.isNotEmpty) {
          _handleNavigation(item.route!);
        }
      },
    );
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
      // Already on home
    } else {
      try {
        Get.toNamed(route);
      } catch (e) {
        debugPrint('Route $route not found: $e');
      }
    }
  }
}

class _AppBarBackgroundSlider extends StatefulWidget {
  const _AppBarBackgroundSlider();

  @override
  State<_AppBarBackgroundSlider> createState() =>
      _AppBarBackgroundSliderState();
}

class _AppBarBackgroundSliderState extends State<_AppBarBackgroundSlider> {
  final List<String> _images = const [
    'assets/backg.jpg',
    'assets/background.png',
    'assets/paulsteuber-dockland-4431309_1280.jpg',
  ];
  late final PageController _pageController;
  Timer? _timer;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted || !_pageController.hasClients) return;
      _currentIndex = (_currentIndex + 1) % _images.length;
      _pageController.animateToPage(
        _currentIndex,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
      setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        PageView.builder(
          controller: _pageController,
          itemCount: _images.length,
          physics: const NeverScrollableScrollPhysics(),
          onPageChanged: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          itemBuilder: (context, index) {
            return Image.asset(
              _images[index],
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(color: Theme.of(context).primaryColor);
              },
            );
          },
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withValues(alpha: 0.10),
                Colors.black.withValues(alpha: 0.30),
              ],
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 16,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_images.length, (index) {
              final isActive = index == _currentIndex;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: isActive ? 16 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: isActive
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.65),
                  borderRadius: BorderRadius.circular(999),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}

// UI Builder for the Main Action
Widget buildPrimaryButton(
  BuildContext context,
  String label,
  IconData icon,
  Color color,
  VoidCallback onPressed,
) {
  return Container(
    decoration: BoxDecoration(
      boxShadow: [
        BoxShadow(
          color: color.withOpacity(0.35),
          blurRadius: 16,
          offset: const Offset(0, 8), // Soft bottom shadow
        ),
      ],
    ),
    child: ElevatedButton.icon(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 20),
        elevation: 0, // Disable default harsh elevation
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      icon: Icon(icon, size: 26),
      label: Text(
        label,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    ),
  );
}

// ─── Auto-scrolling info banner ───────────────────────────────────────────────

class _BannerCarousel extends StatefulWidget {
  final List<({String hint, String title, IconData icon, Color color})> banners;

  const _BannerCarousel({required this.banners});

  @override
  State<_BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<_BannerCarousel> {
  late final PageController _pageController;
  late final Timer _timer;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted) return;
      final next = (_currentPage + 1) % widget.banners.length;
      _pageController.animateToPage(
        next,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: Stack(
        children: [
          // Slides
          PageView.builder(
            controller: _pageController,
            itemCount: widget.banners.length,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemBuilder: (context, index) {
              final b = widget.banners[index];
              return _BannerSlide(
                hint: b.hint,
                title: b.title,
                icon: b.icon,
                accentColor: b.color,
              );
            },
          ),
          // Dot indicators at bottom-left
          Positioned(
            bottom: 10,
            left: 20,
            child: Row(
              children: List.generate(widget.banners.length, (i) {
                final active = i == _currentPage;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.only(right: 6),
                  width: active ? 24 : 8,
                  height: 4,
                  decoration: BoxDecoration(
                    color: active
                        ? Colors.white
                        : Colors.white.withOpacity(0.35),
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class _BannerSlide extends StatelessWidget {
  final String hint;
  final String title;
  final IconData icon;
  final Color accentColor;

  const _BannerSlide({
    required this.hint,
    required this.title,
    required this.icon,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(0),
      ),
      child: Stack(
        children: [
          // Decorative blurred circle on the right
          Positioned(
            right: -20,
            top: -8,
            child: Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: accentColor.withOpacity(0.18),
              ),
            ),
          ),
          // Icon illustration on the right
          Positioned(
            right: 16,
            top: 0,
            bottom: 0,
            child: Icon(icon, size: 25, color: accentColor.withOpacity(0.85)),
          ),
          // Text content
          Padding(
            padding: const EdgeInsets.only(
              left: 20,
              top: 0,
              right: 90,
              bottom: 8,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Text(
                //   hint,
                //   style: TextStyle(
                //     color: Colors.white.withOpacity(0.55),
                //     fontSize: 12,
                //     fontWeight: FontWeight.w400,
                //     letterSpacing: 0.3,
                //   ),
                // ),
                // const SizedBox(height: 4),
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        title,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          height: 1.3,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_forward,
                        size: 14,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
