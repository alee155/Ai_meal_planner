import 'package:ai_meal_planner/core/constants/app_colors.dart';
import 'package:ai_meal_planner/features/BottomNavScreen/widget/bottom_nav_item.dart';
import 'package:ai_meal_planner/features/BottomNavScreen/widget/bottom_nav_item_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onItemTap,
  });

  final List<BottomNavItemData> items;
  final int currentIndex;
  final ValueChanged<int> onItemTap;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      minimum: EdgeInsets.fromLTRB(16.w, 0, 16.w, 12.h),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: AppColors.surfaceOf(context).withValues(alpha: 0.96),
          borderRadius: BorderRadius.circular(24.r),
          border: Border.all(color: AppColors.borderOf(context)),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowOf(context).withValues(alpha: 0.16),
              blurRadius: 22,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: List.generate(
            items.length,
            (index) => Expanded(
              child: BottomNavItem(
                item: items[index],
                isSelected: currentIndex == index,
                onTap: () => onItemTap(index),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
