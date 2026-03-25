import 'package:ai_meal_planner/core/constants/app_colors.dart';
import 'package:ai_meal_planner/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class FitnessGoalsCard extends StatelessWidget {
  const FitnessGoalsCard({
    super.key,
    required this.title,
    required this.selectedGoal,
    required this.goalOptions,
    required this.onGoalChanged,
  });

  final String title;
  final String selectedGoal;
  final List<String> goalOptions;
  final ValueChanged<String> onGoalChanged;

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
          ...goalOptions.map(
            (goal) => Padding(
              padding: EdgeInsets.only(
                bottom: goal == goalOptions.last ? 0 : 12.h,
              ),
              child: _FitnessGoalButton(
                label: goal,
                isSelected: selectedGoal == goal,
                onTap: () => onGoalChanged(goal),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FitnessGoalButton extends StatelessWidget {
  const _FitnessGoalButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 16.w),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryGreen
              : AppColors.surfaceOf(context),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryGreen
                : AppColors.borderOf(context),
          ),
        ),
        child: Row(
          children: [
            Icon(
              _iconFor(label),
              color: isSelected
                  ? Colors.white
                  : AppColors.textSecondaryOf(context),
              size: 20.sp,
            ),
            12.w.horizontalSpace,
            Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? Colors.white
                    : AppColors.textSecondaryOf(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _iconFor(String label) {
    final normalized = label.toLowerCase();
    if (normalized.contains('lose') || normalized.contains('کم')) {
      return Icons.trending_down_rounded;
    }
    if (normalized.contains('maintain') || normalized.contains('برقرار')) {
      return Icons.flag_rounded;
    }
    return Icons.fitness_center_rounded;
  }
}
