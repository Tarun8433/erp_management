import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:erp_management/core/services/api/api_service.dart';
import 'package:erp_management/core/services/api/endpoints.dart';
import 'package:erp_management/features/menu/models/menu_response.dart';
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
    _loadCachedMenu();
    fetchAppMenu();
    loadProfileImage();
  }

  Future<void> loadProfileImage() async {
    final path = await StorageHelper.getProfileImage();
    profileImagePath.value = path;
  }

  Future<void> _loadUserInfo() async {
    final userData = await StorageHelper.getUserData();
    if (userData != null) {
      userName.value = userData.name ?? 'User';
      userEmail.value = userData.email ?? '';
    }
    final role = await StorageHelper.getSelectedRole();
    if (role != null && role.isNotEmpty) {
      userRole.value = role;
    }
  }

  Future<void> _loadCachedMenu() async {
    final savedMenu = await StorageHelper.getRoleComponent();
    if (savedMenu.isNotEmpty) {
      menuItems.assignAll(savedMenu);
    }
  }

  Future<void> fetchAppMenu() async {
    try {
      isLoading.value = true;
      final response = await _apiService.getJson(Endpoints.getAppMenu());
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
    if (iconString == null) return Icons.circle_outlined;

    switch (iconString) {
      case 'pi pi-cog':
        return Icons.settings;
      case 'pi pi-bolt':
        return Icons.flash_on;
      case 'pi pi-user':
        return Icons.person;
      case 'pi pi-key':
        return Icons.vpn_key;
      case 'pi pi-id-card':
        return Icons.badge;
      case 'pi pi-list':
        return Icons.list;
      case 'pi pi-ticket':
        return Icons.confirmation_number;
      case 'pi pi-home':
        return Icons.home;
      case 'pi pi-search':
        return Icons.search;
      case 'pi pi-calendar':
        return Icons.calendar_today;
      default:
        if (iconString.contains('user')) return Icons.person;
        if (iconString.contains('cog') || iconString.contains('setting')) {
          return Icons.settings;
        }
        if (iconString.contains('home')) return Icons.home;
        return Icons.circle_outlined;
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
