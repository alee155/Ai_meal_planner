import 'package:ai_meal_planner/core/constants/app_colors.dart';
import 'package:ai_meal_planner/core/theme/app_text_styles.dart';
import 'package:ai_meal_planner/features/DietPlanScreen/models/latest_meal_plan_response_model.dart';
import 'package:ai_meal_planner/features/DietPlanScreen/widgets/plan_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SwapSuggestionCard extends StatelessWidget {
  const SwapSuggestionCard({super.key, required this.suggestion});

  final MealPlanSwapSuggestionModel suggestion;

  @override
  Widget build(BuildContext context) {
    return PlanCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Swap suggestions',
                  style: AppTextStyles.title(
                    context,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: AppColors.backgroundSecondaryOf(context),
                  borderRadius: BorderRadius.circular(999.r),
                  border: Border.all(color: AppColors.borderOf(context)),
                ),
                child: Text(
                  suggestion.meal.trim().isEmpty
                      ? 'Meal'
                      : suggestion.meal.trim(),
                  style: AppTextStyles.caption(
                    context,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          Text(
            'Current item',
            style: AppTextStyles.caption(
              context,
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: AppColors.textSecondaryOf(context),
            ),
          ),
          SizedBox(height: 8.h),
          _CurrentItemRow(item: suggestion.currentItem),
          SizedBox(height: 14.h),
          Text(
            'Alternatives',
            style: AppTextStyles.caption(
              context,
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: AppColors.textSecondaryOf(context),
            ),
          ),
          SizedBox(height: 10.h),
          if (suggestion.alternatives.isEmpty)
            Text(
              'No alternatives available',
              style: AppTextStyles.body(
                context,
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondaryOf(context),
              ),
            )
          else
            ...suggestion.alternatives.map((alt) => _AlternativeRow(alt: alt)),
        ],
      ),
    );
  }
}

class _CurrentItemRow extends StatelessWidget {
  const _CurrentItemRow({required this.item});

  final MealPlanSwapItemModel item;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.18)),
      ),
      child: Row(
        children: [
          Icon(Icons.close_rounded, color: AppColors.error, size: 18.sp),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              item.name.trim().isEmpty ? 'Current item' : item.name.trim(),
              style: AppTextStyles.body(
                context,
                fontSize: 13,
                fontWeight: FontWeight.w900,
              ).copyWith(decoration: TextDecoration.lineThrough),
            ),
          ),
          SizedBox(width: 10.w),
          _ScoreBadge(
            label: '${item.calories} kcal',
            background: AppColors.surfaceOf(context),
            border: AppColors.borderOf(context),
          ),
        ],
      ),
    );
  }
}

class _AlternativeRow extends StatelessWidget {
  const _AlternativeRow({required this.alt});

  final MealPlanSwapAlternativeModel alt;

  @override
  Widget build(BuildContext context) {
    final scoreLabel = '${(alt.matchScore * 100).round()}% match';
    final isSafe = alt.isSafeSwap;

    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: AppColors.backgroundSecondaryOf(context),
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(color: AppColors.borderOf(context)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 34.w,
              height: 34.w,
              decoration: BoxDecoration(
                color: (isSafe ? AppColors.success : AppColors.warning)
                    .withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: (isSafe ? AppColors.success : AppColors.warning)
                      .withValues(alpha: 0.22),
                ),
              ),
              child: Icon(
                isSafe ? Icons.check_rounded : Icons.info_outline_rounded,
                size: 18.sp,
                color: isSafe ? AppColors.success : AppColors.warning,
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    alt.name.trim().isEmpty ? 'Alternative' : alt.name.trim(),
                    style: AppTextStyles.body(
                      context,
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Wrap(
                    spacing: 6.w,
                    runSpacing: 6.h,
                    children: [
                      _ScoreBadge(
                        label: scoreLabel,
                        background: AppColors.surfaceOf(context),
                        border: AppColors.borderOf(context),
                      ),
                      _ScoreBadge(
                        label: '${alt.calories} kcal',
                        background: AppColors.surfaceOf(context),
                        border: AppColors.borderOf(context),
                      ),
                      if (isSafe)
                        _ScoreBadge(
                          label: 'Safe swap',
                          background: AppColors.success.withValues(alpha: 0.10),
                          border: AppColors.success.withValues(alpha: 0.20),
                          foreground: AppColors.success,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScoreBadge extends StatelessWidget {
  const _ScoreBadge({
    required this.label,
    required this.background,
    required this.border,
    this.foreground,
  });

  final String label;
  final Color background;
  final Color border;
  final Color? foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999.r),
        border: Border.all(color: border),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption(
          context,
          fontSize: 11,
          fontWeight: FontWeight.w900,
          color: foreground ?? AppColors.textPrimaryOf(context),
        ),
      ),
    );
  }
}
