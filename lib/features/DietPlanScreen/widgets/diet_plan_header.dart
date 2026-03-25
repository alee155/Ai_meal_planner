import 'package:ai_meal_planner/core/constants/app_colors.dart';
import 'package:ai_meal_planner/core/theme/app_text_styles.dart';
import 'package:ai_meal_planner/shared/widgets/app_icon_back_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DietPlanHeader extends StatelessWidget {
  const DietPlanHeader({
    super.key,
    required this.dateLabel,
    required this.onBackTap,
  });

  final String dateLabel;
  final VoidCallback onBackTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Diet Plan',
                style: AppTextStyles.headline(
                  context,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                'Personalized meals aligned with your calorie and macro goals.',
                style: AppTextStyles.body(context, fontSize: 13, height: 1.45),
              ),
              SizedBox(height: 10.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: AppColors.chipBackgroundOf(context),
                  borderRadius: BorderRadius.circular(999.r),
                  border: Border.all(
                    color: AppColors.primaryGreenDark.withValues(alpha: 0.18),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 14.sp,
                      color: AppColors.primaryGreenDark,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      dateLabel,
                      style: AppTextStyles.caption(
                        context,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryGreenDark,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
