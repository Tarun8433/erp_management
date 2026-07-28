import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:erp_management/core/services/api/api_service.dart';
import 'package:erp_management/core/services/api/endpoints.dart';
import 'package:erp_management/features/common/menu/models/menu_response.dart';
import 'package:erp_management/core/utils/local_storage/storage_helper.dart';

class MenuController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();

  final RxList<MenuComponent> menuItems = <MenuComponent>[].obs;
  final RxBool isLoading = false.obs;
  final RxString userRole = ''.obs;
  final RxString userName = ''.obs;
  final RxString userEmail = ''.obs;
  final Rx<String?> profileImagePath = Rx<String?>(null);

  @override
  void onInit() {
    super.onInit();
    _loadUserInfo();
     _loadCachedMenu(); // temporarily disable to get fresh menu
    fetchAppMenu();
    loadProfileImage();
  }

  Future<void> loadProfileImage() async {
    final path = await StorageHelper.getProfileImage();
    profileImagePath.value = path;
  }

  Future<void> _loadUserInfo() async {
    final details = await StorageHelper.getUserDetails();
    final role = await StorageHelper.getSelectedRole();

    final rawName = details?.displayName.isNotEmpty == true
        ? details!.displayName
        : await StorageHelper.getLoginName() ?? '';

    userName.value = rawName.isNotEmpty ? _titleCase(rawName) : 'User';
    userEmail.value = details?.email ?? '';
    userRole.value = (role != null && role.isNotEmpty) ? _titleCase(role) : '';
  }

  static String _titleCase(String s) => s
      .split(RegExp(r'[\s_]+'))
      .map((w) => w.isEmpty ? '' : '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}')
      .join(' ');

  Future<void> _loadCachedMenu() async {
    final savedMenu = await StorageHelper.getRoleComponent();
    if (savedMenu.isNotEmpty) {
      menuItems.assignAll(savedMenu);
    }
  }

  Future<void> fetchAppMenu() async {
    try {
      isLoading.value = true;
      final details = await StorageHelper.getUserDetails();
      final roleID = details?.roleId;
      if (roleID == null) {
        log('Selected role ID is empty');
        return;
      }
      final response = await _apiService.getJson(Endpoints.getAppMenu(roleID.toString()));
      log('Get App Menu Response: $response');

      final menuResponse = MenuResponse.fromJson(response);
      if (menuResponse.status == true && menuResponse.data != null) {
        menuItems.assignAll(menuResponse.data!);
        await StorageHelper.saveRoleComponent(menuResponse.data!);
      }
    } catch (e) {
      log('Error fetching app menu: $e');
    } finally {
      isLoading.value = false;
    }
  }

  IconData getIcon(String? iconString) {
    if (iconString == null || iconString.isEmpty) return Icons.widgets_outlined;

    switch (iconString) {
      // Navigation & Layout
      case 'pi pi-home':        return Icons.home_outlined;
      case 'pi pi-th-large':   return Icons.grid_view_outlined;
      case 'pi pi-bars':        return Icons.menu;
      case 'pi pi-sitemap':     return Icons.account_tree_outlined;

      // People
      case 'pi pi-user':        return Icons.person_outline;
      case 'pi pi-users':       return Icons.people_outlined;
      case 'pi pi-user-plus':   return Icons.person_add_outlined;
      case 'pi pi-user-minus':  return Icons.person_remove_outlined;
      case 'pi pi-user-edit':   return Icons.manage_accounts_outlined;
      case 'pi pi-id-card':     return Icons.badge_outlined;
      case 'pi pi-address-book':return Icons.contacts_outlined;

      // Academic
      case 'pi pi-graduation-cap': return Icons.school_outlined;
      case 'pi pi-book':            return Icons.menu_book_outlined;
      case 'pi pi-pencil':          return Icons.edit_outlined;
      case 'pi pi-file-edit':       return Icons.edit_note_outlined;
      case 'pi pi-list-check':      return Icons.checklist_outlined;

      // Files & Docs
      case 'pi pi-file':         return Icons.description_outlined;
      case 'pi pi-file-pdf':     return Icons.picture_as_pdf_outlined;
      case 'pi pi-file-excel':   return Icons.table_view_outlined;
      case 'pi pi-folder':       return Icons.folder_outlined;
      case 'pi pi-folder-open':  return Icons.folder_open_outlined;
      case 'pi pi-paperclip':    return Icons.attach_file;
      case 'pi pi-download':     return Icons.download_outlined;
      case 'pi pi-upload':       return Icons.upload_outlined;
      case 'pi pi-print':        return Icons.print_outlined;

      // Charts & Data
      case 'pi pi-chart-bar':    return Icons.bar_chart;
      case 'pi pi-chart-line':   return Icons.show_chart;
      case 'pi pi-chart-pie':    return Icons.pie_chart_outline;
      case 'pi pi-table':        return Icons.table_chart_outlined;
      case 'pi pi-database':     return Icons.storage_outlined;

      // Finance
      case 'pi pi-money-bill':   return Icons.payments_outlined;
      case 'pi pi-wallet':       return Icons.account_balance_wallet_outlined;
      case 'pi pi-credit-card':  return Icons.credit_card_outlined;
      case 'pi pi-percentage':   return Icons.percent;

      // Communication
      case 'pi pi-bell':         return Icons.notifications_outlined;
      case 'pi pi-envelope':     return Icons.email_outlined;
      case 'pi pi-send':         return Icons.send_outlined;
      case 'pi pi-inbox':        return Icons.inbox_outlined;
      case 'pi pi-comments':     return Icons.chat_outlined;
      case 'pi pi-comment':      return Icons.chat_bubble_outline;
      case 'pi pi-phone':        return Icons.phone_outlined;

      // Settings & Tools
      case 'pi pi-cog':          return Icons.settings_outlined;
      case 'pi pi-wrench':       return Icons.build_outlined;
      case 'pi pi-sliders-h':    return Icons.tune;
      case 'pi pi-filter':       return Icons.filter_list;
      case 'pi pi-sort':         return Icons.sort;
      case 'pi pi-search':       return Icons.search;
      case 'pi pi-refresh':      return Icons.refresh;

      // Security
      case 'pi pi-key':          return Icons.vpn_key_outlined;
      case 'pi pi-lock':         return Icons.lock_outlined;
      case 'pi pi-unlock':       return Icons.lock_open_outlined;
      case 'pi pi-shield':       return Icons.security;
      case 'pi pi-eye':          return Icons.visibility_outlined;
      case 'pi pi-eye-slash':    return Icons.visibility_off_outlined;

      // Media
      case 'pi pi-image':        return Icons.image_outlined;
      case 'pi pi-images':       return Icons.photo_library_outlined;
      case 'pi pi-camera':       return Icons.camera_alt_outlined;
      case 'pi pi-video':        return Icons.videocam_outlined;
      case 'pi pi-qrcode':       return Icons.qr_code;

      // Status & Actions
      case 'pi pi-check':        return Icons.check_circle_outline;
      case 'pi pi-check-square': return Icons.check_box_outlined;
      case 'pi pi-times':        return Icons.close;
      case 'pi pi-plus':         return Icons.add_circle_outline;
      case 'pi pi-minus':        return Icons.remove_circle_outline;
      case 'pi pi-trash':        return Icons.delete_outlined;
      case 'pi pi-copy':         return Icons.copy_outlined;
      case 'pi pi-link':         return Icons.link;
      case 'pi pi-external-link':return Icons.open_in_new;
      case 'pi pi-history':      return Icons.history;
      case 'pi pi-undo':         return Icons.undo;
      case 'pi pi-bolt':         return Icons.flash_on;
      case 'pi pi-star':         return Icons.star_outline;
      case 'pi pi-heart':        return Icons.favorite_outline;
      case 'pi pi-flag':         return Icons.flag_outlined;
      case 'pi pi-thumbs-up':    return Icons.thumb_up_outlined;

      // Transport & Location
      case 'pi pi-truck':        return Icons.local_shipping_outlined;
      case 'pi pi-map-marker':   return Icons.location_on_outlined;
      case 'pi pi-globe':        return Icons.language;
      case 'pi pi-wifi':         return Icons.wifi;

      // Calendar & Time
      case 'pi pi-calendar':     return Icons.calendar_today_outlined;
      case 'pi pi-clock':        return Icons.access_time;
      case 'pi pi-ticket':       return Icons.confirmation_number_outlined;

      // Lists
      case 'pi pi-list':         return Icons.list;
      case 'pi pi-align-left':   return Icons.notes;

      // Buildings
      case 'pi pi-building':     return Icons.business_outlined;
      case 'pi pi-briefcase':    return Icons.work_outline;

      default:
        // keyword fallbacks
        if (iconString.contains('user') || iconString.contains('student')) return Icons.person_outline;
        if (iconString.contains('home') || iconString.contains('dashboard')) return Icons.home_outlined;
        if (iconString.contains('setting') || iconString.contains('cog')) return Icons.settings_outlined;
        if (iconString.contains('file') || iconString.contains('doc')) return Icons.description_outlined;
        if (iconString.contains('calendar') || iconString.contains('date')) return Icons.calendar_today_outlined;
        if (iconString.contains('chart') || iconString.contains('report')) return Icons.bar_chart;
        if (iconString.contains('money') || iconString.contains('fee') || iconString.contains('pay')) return Icons.payments_outlined;
        if (iconString.contains('book') || iconString.contains('exam')) return Icons.menu_book_outlined;
        if (iconString.contains('bus') || iconString.contains('transport') || iconString.contains('truck')) return Icons.directions_bus_outlined;
        if (iconString.contains('bell') || iconString.contains('notif')) return Icons.notifications_outlined;
        if (iconString.contains('image') || iconString.contains('photo')) return Icons.image_outlined;
        if (iconString.contains('list')) return Icons.list;
        if (iconString.contains('add') || iconString.contains('plus')) return Icons.add_circle_outline;
        return Icons.widgets_outlined;
    }
  }

  bool isNetworkIcon(String? iconString) {
    if (iconString == null || iconString.isEmpty) return false;
    return iconString.startsWith('http') ||
        iconString.contains('/') ||
        iconString.contains('.');
  }

  String getFullIconUrl(String iconString) {
    if (iconString.startsWith('http')) return iconString;
    final base = Endpoints.baseUrl;
    if (iconString.startsWith('/')) return '$base$iconString';
    return '$base/$iconString';
  }
}
