import 'package:ai_meal_planner/core/constants/app_colors.dart';
import 'package:ai_meal_planner/core/theme/app_text_styles.dart';
import 'package:ai_meal_planner/features/DietPlanScreen/models/latest_meal_plan_response_model.dart';
import 'package:ai_meal_planner/features/DietPlanScreen/widgets/plan_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DailyNutritionCard extends StatelessWidget {
  const DailyNutritionCard({
    super.key,
    required this.targets,
    required this.actualTotals,
  });

  final MealPlanDailyNutritionTargetsModel targets;
  final MealPlanActualDailyTotalsModel actualTotals;

  @override
  Widget build(BuildContext context) {
    final calorieTarget = targets.calories <= 0 ? 1 : targets.calories;
    final caloriesProgress = (actualTotals.calories / calorieTarget).clamp(
      0.0,
      1.0,
    );

    return PlanCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${actualTotals.calories} kcal',
                      style: AppTextStyles.display(
                        context,
                        fontSize: 34,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primaryGreenDark,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'Consumed today',
                      style: AppTextStyles.body(context, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          _ProgressBar(
            value: caloriesProgress,
            label: 'Calories',
            leftValue: '${actualTotals.calories}',
            rightValue: '${targets.calories}',
            color: AppColors.primaryGreenDark,
          ),
          SizedBox(height: 16.h),
          Container(
            padding: EdgeInsets.all(14.w),
            decoration: BoxDecoration(
              color: AppColors.backgroundSecondaryOf(context),
              borderRadius: BorderRadius.circular(18.r),
              border: Border.all(color: AppColors.borderOf(context)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Macros progress',
                  style: AppTextStyles.title(
                    context,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 12.h),
                Row(
                  children: [
                    Expanded(
                      child: _MacroMiniProgress(
                        label: 'Protein',
                        leftValue: _fmt1(actualTotals.macros.protein),
                        value:
                            (actualTotals.macros.protein /
                                    (targets.macros.protein <= 0
                                        ? 1
                                        : targets.macros.protein))
                                .clamp(0.0, 1.0),
                        color: AppColors.info,
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: _MacroMiniProgress(
                        label: 'Carbs',
                        leftValue: _fmt1(actualTotals.macros.carbs),
                        value:
                            (actualTotals.macros.carbs /
                                    (targets.macros.carbs <= 0
                                        ? 1
                                        : targets.macros.carbs))
                                .clamp(0.0, 1.0),
                        color: AppColors.warning,
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: _MacroMiniProgress(
                        label: 'Fats',
                        leftValue: _fmt1(actualTotals.macros.fats),
                        value:
                            (actualTotals.macros.fats /
                                    (targets.macros.fats <= 0
                                        ? 1
                                        : targets.macros.fats))
                                .clamp(0.0, 1.0),
                        color: AppColors.primaryGreenLight,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({
    required this.value,
    required this.label,
    required this.leftValue,
    required this.rightValue,
    required this.color,
  });

  final double value;
  final String label;
  final String leftValue;
  final String rightValue;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final safeValue = value.isNaN ? 0.0 : value;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.body(
                  context,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Text(
              '$leftValue / $rightValue',
              style: AppTextStyles.caption(
                context,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondaryOf(context),
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        ClipRRect(
          borderRadius: BorderRadius.circular(999.r),
          child: LinearProgressIndicator(
            minHeight: 10.h,
            value: safeValue.clamp(0.0, 1.0),
            backgroundColor: AppColors.borderOf(context).withValues(alpha: 0.5),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}

class _MacroMiniProgress extends StatelessWidget {
  const _MacroMiniProgress({
    required this.label,
    required this.leftValue,
    required this.value,
    required this.color,
  });

  final String label;
  final String leftValue;
  final double value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final safeValue = value.isNaN ? 0.0 : value;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.caption(
            context,
            fontSize: 12,
            fontWeight: FontWeight.w900,
          ),
        ),
        SizedBox(height: 6.h),
        Text(
          leftValue,
          style: AppTextStyles.title(
            context,
            fontSize: 14,
            fontWeight: FontWeight.w900,
          ),
        ),
        SizedBox(height: 8.h),
        ClipRRect(
          borderRadius: BorderRadius.circular(999.r),
          child: LinearProgressIndicator(
            minHeight: 8.h,
            value: safeValue.clamp(0.0, 1.0),
            backgroundColor: AppColors.borderOf(context).withValues(alpha: 0.5),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}

String _fmt1(double value) {
  final trimmed = value.toStringAsFixed(1);
  if (trimmed.endsWith('.0')) {
    return '${value.round()}g';
  }
  return '${trimmed}g';
}
