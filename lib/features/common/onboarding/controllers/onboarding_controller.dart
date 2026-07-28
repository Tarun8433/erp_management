import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../routes/app_routes.dart';
import '../../../../core/utils/local_storage/storage_helper.dart';

class OnboardingModel {
  final String title;
  final String description;
  final IconData icon;

  OnboardingModel({
    required this.title,
    required this.description,
    required this.icon,
  });
}

class OnboardingController extends GetxController {
  var pageIndex = 0.obs;
  final pageController = PageController();

  final List<OnboardingModel> pages = [
    OnboardingModel(
      title: 'onboarding_title_1'.tr,
      description: 'onboarding_desc_1'.tr,
      icon: Icons.location_on_outlined,
    ),
    OnboardingModel(
      title: 'onboarding_title_2'.tr,
      description: 'onboarding_desc_2'.tr,
      icon: Icons.verified_user_outlined,
    ),
    OnboardingModel(
      title: 'onboarding_title_3'.tr,
      description: 'onboarding_desc_3'.tr,
      icon: Icons.public_outlined,
    ),
  ];

  void onPageChanged(int index) {
    pageIndex.value = index;
  }

  void onNext() {
    if (pageIndex.value < pages.length - 1) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    } else {
      _finishOnboarding();
    }
  }

  void onSkip() {
    _finishOnboarding();
  }

  void _finishOnboarding() async {
    await StorageHelper.saveIntroSeen();
    Get.offAllNamed(AppRoutes.auth);
  }
}
