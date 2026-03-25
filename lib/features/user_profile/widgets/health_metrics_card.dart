import 'package:ai_meal_planner/core/constants/app_colors.dart';
import 'package:ai_meal_planner/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HealthMetricsCard extends StatelessWidget {
  const HealthMetricsCard({
    super.key,
    required this.title,
    required this.bmiLabel,
    required this.activityLevelLabel,
    required this.selectActivityLevelLabel,
    required this.bmiValueLabel,
    required this.bmiCategory,
    required this.hasBmiData,
    required this.selectedActivityLevel,
    required this.activityOptions,
    required this.onActivityChanged,
  });

  final String title;
  final String bmiLabel;
  final String activityLevelLabel;
  final String selectActivityLevelLabel;
  final String bmiValueLabel;
  final String bmiCategory;
  final bool hasBmiData;
  final String? selectedActivityLevel;
  final List<String> activityOptions;
  final ValueChanged<String?> onActivityChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.cardBackgroundOf(context),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowOf(context),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.title(
              context,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          16.h.verticalSpace,
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: AppColors.primarylightGreen,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  bmiLabel,
                  style: AppTextStyles.label(
                    context,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimaryOf(context),
                  ),
                ),
                4.h.verticalSpace,
                Text(
                  bmiValueLabel,
                  style: AppTextStyles.headline(
                    context,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: hasBmiData
                        ? AppColors.primaryGreen
                        : AppColors.textSecondaryOf(context),
                  ),
                ),
                8.h.verticalSpace,
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: hasBmiData
                        ? AppColors.surfaceOf(context)
                        : AppColors.backgroundSecondaryOf(context),
                    borderRadius: BorderRadius.circular(50.r),
                  ),
                  child: Text(
                    bmiCategory,
                    style: AppTextStyles.caption(
                      context,
                      fontSize: 10,
                      color: hasBmiData
                          ? AppColors.primaryGreen
                          : AppColors.textSecondaryOf(context),
                    ),
                  ),
                ),
              ],
            ),
          ),
          16.h.verticalSpace,
          Text(
            activityLevelLabel,
            style: AppTextStyles.label(
              context,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimaryOf(context),
            ),
          ),
          6.h.verticalSpace,
          DropdownButtonFormField<String>(
            initialValue: selectedActivityLevel,
            items: activityOptions
                .map(
                  (option) => DropdownMenuItem<String>(
                    value: option,
                    child: Text(
                      option,
                      style: AppTextStyles.body(
                        context,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimaryOf(context),
                      ),
                    ),
                  ),
                )
                .toList(),
            onChanged: onActivityChanged,
            style: AppTextStyles.body(
              context,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimaryOf(context),
            ),
            icon: Icon(
              Icons.arrow_drop_down,
              color: AppColors.textSecondaryOf(context),
            ),
            decoration: InputDecoration(
              isDense: true,
              filled: true,
              fillColor: AppColors.surfaceOf(context),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12.w,
                vertical: 12.h,
              ),
              hintText: selectActivityLevelLabel,
              hintStyle: TextStyle(
                fontSize: 14.sp,
                color: AppColors.textHintOf(context),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: AppColors.borderOf(context)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: AppColors.borderOf(context)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: const BorderSide(color: AppColors.primaryGreenDark),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
