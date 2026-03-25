import 'package:ai_meal_planner/core/constants/app_colors.dart';
import 'package:ai_meal_planner/core/theme/app_text_styles.dart';
import 'package:ai_meal_planner/features/DietPlanScreen/models/diet_plan_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DietPlanMealCard extends StatelessWidget {
  const DietPlanMealCard({
    super.key,
    required this.meal,
    required this.onDetailsTap,
  });

  final DietPlanMeal meal;
  final VoidCallback onDetailsTap;

  @override
  Widget build(BuildContext context) {
    final accentColor = _accentColorFor(meal.title);
    final iconData = _iconFor(meal.title);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: AppColors.surfaceOf(context),
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(color: AppColors.borderOf(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48.w,
                height: 48.w,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Icon(iconData, color: accentColor, size: 22.sp),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      meal.title,
                      style: AppTextStyles.title(
                        context,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          size: 14.sp,
                          color: AppColors.textSecondaryOf(context),
                        ),
                        SizedBox(width: 6.w),
                        Flexible(
                          child: Text(
                            meal.timeWindow,
                            style: AppTextStyles.body(context, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(width: 10.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: AppColors.chipBackgroundOf(context),
                  borderRadius: BorderRadius.circular(999.r),
                ),
                child: Text(
                  '${meal.calories} kcal',
                  style: AppTextStyles.caption(
                    context,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryGreenDark,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          ...meal.items.map(
            (item) => Padding(
              padding: EdgeInsets.only(bottom: 8.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 7.w,
                    height: 7.w,
                    margin: EdgeInsets.only(top: 6.h),
                    decoration: BoxDecoration(
                      color: accentColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Text(
                      item,
                      style: AppTextStyles.body(
                        context,
                        fontSize: 14,
                        color: AppColors.textPrimaryOf(context),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 6.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: AppColors.backgroundSecondaryOf(context),
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: AppColors.borderOf(context)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.auto_awesome_rounded,
                  size: 16.sp,
                  color: accentColor,
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    meal.summary,
                    style: AppTextStyles.caption(
                      context,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimaryOf(context),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 10.h),
          TextButton.icon(
            onPressed: onDetailsTap,
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              foregroundColor: AppColors.primaryGreenDark,
            ),
            icon: Icon(Icons.insights_outlined, size: 18.sp),
            label: Text(
              'View nutrition details',
              style: AppTextStyles.button(
                context,
                fontSize: 13,
                color: AppColors.primaryGreenDark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _iconFor(String title) {
    switch (title.toLowerCase()) {
      case 'breakfast':
        return Icons.breakfast_dining_outlined;
      case 'lunch':
        return Icons.lunch_dining_outlined;
      case 'snack':
        return Icons.local_cafe_outlined;
      case 'dinner':
        return Icons.dinner_dining_outlined;
      default:
        return Icons.restaurant_menu_outlined;
    }
  }

  Color _accentColorFor(String title) {
    switch (title.toLowerCase()) {
      case 'breakfast':
        return AppColors.warning;
      case 'lunch':
        return AppColors.primaryGreenDark;
      case 'snack':
        return AppColors.info;
      case 'dinner':
        return AppColors.primaryGreen;
      default:
        return AppColors.primaryGreenDark;
    }
  }
}
