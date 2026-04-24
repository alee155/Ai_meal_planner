import 'package:ai_meal_planner/core/constants/app_colors.dart';
import 'package:ai_meal_planner/core/theme/app_text_styles.dart';
import 'package:ai_meal_planner/features/DietPlanScreen/models/latest_meal_plan_response_model.dart';
import 'package:ai_meal_planner/features/DietPlanScreen/widgets/plan_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PlanFlagsCard extends StatelessWidget {
  const PlanFlagsCard({super.key, required this.flags});

  final MealPlanFlagsModel flags;

  @override
  Widget build(BuildContext context) {
    final allergyPassed = _passedFrom(flags.allergiesRespected);
    final dislikesPassed = _passedFrom(flags.dislikesAvoided);
    final calorieGapPassed = _passedFrom(flags.calorieGap);

    return PlanCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Plan flags',
            style: AppTextStyles.title(
              context,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 14.h),
          _FlagStatusRow('Allergy Constraints Respected', allergyPassed),
          SizedBox(height: 10.h),
          _FlagStatusRow('Dislikes Avoided', dislikesPassed),
          SizedBox(height: 10.h),
          _FlagStatusRow('Calorie Gap', calorieGapPassed),
        ],
      ),
    );
  }
}

class _FlagStatusRow extends StatelessWidget {
  const _FlagStatusRow(this.label, this.passed);

  final String label;
  final bool? passed;

  @override
  Widget build(BuildContext context) {
    final Color color = passed == null
        ? AppColors.textSecondaryOf(context).withValues(alpha: 0.55)
        : passed == true
        ? AppColors.success
        : AppColors.error;

    final IconData icon = passed == null
        ? Icons.remove_circle_outline_rounded
        : passed == true
        ? Icons.check_circle_rounded
        : Icons.cancel_rounded;

    final String statusText = passed == null
        ? 'None'
        : passed == true
        ? 'Passed'
        : 'Failed';

    return Row(
      children: [
        Icon(icon, color: color, size: 18.sp),
        SizedBox(width: 10.w),
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.body(
              context,
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimaryOf(context).withValues(alpha: 0.80),
            ),
          ),
        ),
        Text(
          statusText,
          style: AppTextStyles.caption(
            context,
            fontSize: 12,
            fontWeight: FontWeight.w900,
            color: color,
          ),
        ),
      ],
    );
  }
}

bool? _passedFrom(String? message) {
  final raw = (message ?? '').trim();
  if (raw.isEmpty) return null;

  final lower = raw.toLowerCase();
  if (raw.contains('✅') ||
      lower.contains('passed') ||
      lower.contains('respected')) {
    return true;
  }
  if (raw.contains('❌') || lower.contains('failed') || lower.contains('not')) {
    return false;
  }

  return true;
}
