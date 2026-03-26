import 'package:ai_meal_planner/core/constants/app_colors.dart';
import 'package:ai_meal_planner/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfileSetupHeader extends StatelessWidget {
  const ProfileSetupHeader({
    super.key,
    required this.title,
    required this.subtitle,
    required this.stepLabel,
    required this.skipLabel,
    required this.onSkipTap,
  });

  final String title;
  final String subtitle;
  final String stepLabel;
  final String skipLabel;
  final VoidCallback onSkipTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 14.h, 20.w, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 8.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.chipBackgroundOf(context),
                    borderRadius: BorderRadius.circular(999.r),
                  ),
                  child: Text(
                    stepLabel,
                    style: AppTextStyles.caption(
                      context,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryGreenDark,
                    ),
                  ),
                ),
              ),
              TextButton(
                onPressed: onSkipTap,
                child: Text(
                  skipLabel,
                  style: AppTextStyles.button(
                    context,
                    fontSize: 13,
                    color: AppColors.textSecondaryOf(context),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          Text(
            title,
            style: AppTextStyles.headline(
              context,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            subtitle,
            style: AppTextStyles.body(context, fontSize: 14, height: 1.5),
          ),
        ],
      ),
    );
  }
}
