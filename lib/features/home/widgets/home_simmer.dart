import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/context_extensions.dart';
import 'package:shimmer/shimmer.dart';
import 'package:erp_management/core/constants/app_colors.dart';

class HomeSimmerWidget extends StatelessWidget {
  const HomeSimmerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.1,
        mainAxisExtent: 110,
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: context.isDarkMode ? AppColors.grey800 : AppColors.grey300,
          highlightColor: context.isDarkMode
              ? AppColors.grey700
              : AppColors.grey100,
          child: Container(
            decoration: BoxDecoration(
              color: context.isDarkMode
                  ? AppColors.darkSurface
                  : AppColors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: AppColors.white,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  width: 60,
                  height: 10,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
