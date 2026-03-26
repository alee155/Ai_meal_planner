import 'package:ai_meal_planner/core/constants/app_colors.dart';
import 'package:ai_meal_planner/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfileSetupStepIndicator extends StatelessWidget {
  const ProfileSetupStepIndicator({
    super.key,
    required this.labels,
    required this.currentStep,
  });

  final List<String> labels;
  final int currentStep;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 18.h, 20.w, 0),
      child: Row(
        children: List.generate(labels.length, (index) {
          final isActive = index == currentStep;
          final isCompleted = index < currentStep;

          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                right: index == labels.length - 1 ? 0 : 8.w,
              ),
              child: Column(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: double.infinity,
                    height: 8.h,
                    decoration: BoxDecoration(
                      color: isCompleted || isActive
                          ? AppColors.primaryGreenDark
                          : AppColors.progressBackgroundOf(context),
                      borderRadius: BorderRadius.circular(999.r),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    labels[index],
                    textAlign: TextAlign.center,
                    style: AppTextStyles.caption(
                      context,
                      fontSize: 10,
                      fontWeight: isActive ? FontWeight.w800 : FontWeight.w700,
                      color: isActive
                          ? AppColors.textPrimaryOf(context)
                          : AppColors.textSecondaryOf(context),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
