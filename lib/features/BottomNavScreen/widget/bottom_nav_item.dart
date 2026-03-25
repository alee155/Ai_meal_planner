import 'package:ai_meal_planner/core/constants/app_colors.dart';
import 'package:ai_meal_planner/features/BottomNavScreen/widget/bottom_nav_item_data.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BottomNavItem extends StatelessWidget {
  const BottomNavItem({
    super.key,
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  final BottomNavItemData item;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18.r),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 8.w),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.chipBackgroundOf(context)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(18.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FaIcon(
              item.icon,
              size: 18.sp,
              color: isSelected
                  ? AppColors.primaryGreenDark
                  : AppColors.textSecondaryOf(context),
            ),
            SizedBox(height: 6.h),
            Text(
              item.label,
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                color: isSelected
                    ? AppColors.primaryGreenDark
                    : AppColors.textSecondaryOf(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
