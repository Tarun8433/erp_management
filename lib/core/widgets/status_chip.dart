import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:marquee/marquee.dart';
import '../constants/app_colors.dart';

class StatusChip extends StatelessWidget {
  final String label;
  final String count;
  final bool isSelected;
  final VoidCallback onTap;
  final double maxWidth;

  const StatusChip({
    super.key,
    required this.label,
    required this.count,
    required this.isSelected,
    required this.onTap,
    this.maxWidth = 150.0, // Default max width for label
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = context.isDarkMode;
    
    final selectedBgColor = theme.primaryColor;
    final unselectedBgColor = isDark ? AppColors.grey800 : AppColors.white;
    final selectedTextColor = AppColors.white;
    final unselectedTextColor = isDark ? AppColors.grey400 : AppColors.grey800;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? selectedBgColor : unselectedBgColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? selectedBgColor : (isDark ? AppColors.grey700 : AppColors.grey300),
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: selectedBgColor.withValues(alpha: 0.3),
              blurRadius: 4,
              offset: const Offset(0, 2),
            )
          ] : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: _buildLabel(selectedTextColor, unselectedTextColor),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white.withValues(alpha: 0.2) : (isDark ? AppColors.grey700 : AppColors.grey100),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                count,
                style: TextStyle(
                  color: isSelected ? selectedTextColor : unselectedTextColor,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(Color selectedTextColor, Color unselectedTextColor) {
    final style = TextStyle(
      color: isSelected ? selectedTextColor : unselectedTextColor,
      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
      fontSize: 13,
    );

    // Use Marquee if label is long enough to potentially overflow or just long
    // A length check is simple and efficient.
    if (label.length > 20) {
      return SizedBox(
        height: 20, // Fixed height for Marquee
        width: maxWidth, // Ensure it takes up space for Marquee to scroll within
        child: Marquee(
          text: label,
          style: style,
          scrollAxis: Axis.horizontal,
          crossAxisAlignment: CrossAxisAlignment.center,
          blankSpace: 20.0,
          velocity: 30.0,
          pauseAfterRound: const Duration(seconds: 1),
          startPadding: 0.0,
          accelerationDuration: const Duration(seconds: 1),
          accelerationCurve: Curves.linear,
          decelerationDuration: const Duration(milliseconds: 500),
          decelerationCurve: Curves.easeOut,
        ),
      );
    } else {
      return Text(
        label,
        style: style,
        overflow: TextOverflow.ellipsis,
      );
    }
  }
}