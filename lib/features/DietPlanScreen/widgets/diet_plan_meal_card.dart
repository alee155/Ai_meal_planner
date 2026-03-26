import 'package:ai_meal_planner/core/constants/app_colors.dart';
import 'package:ai_meal_planner/core/theme/app_text_styles.dart';
import 'package:ai_meal_planner/features/DietPlanScreen/models/diet_plan_models.dart';
import 'package:ai_meal_planner/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DietPlanMealCard extends StatelessWidget {
  const DietPlanMealCard({
    super.key,
    required this.meal,
    required this.onDetailsTap,
    required this.onCompleteTap,
    required this.onSkipTap,
  });

  final DietPlanMeal meal;
  final VoidCallback onDetailsTap;
  final VoidCallback onCompleteTap;
  final VoidCallback onSkipTap;

  @override
  Widget build(BuildContext context) {
    final accentColor = _accentColorFor(meal.type);
    final iconData = _iconFor(meal.type);
    final isCompleted = meal.isCompleted;
    final isSkipped = meal.isSkipped;
    final surfaceColor = AppColors.surfaceOf(context);
    final cardColor = isCompleted
        ? accentColor.withValues(alpha: AppColors.isDark(context) ? 0.16 : 0.10)
        : isSkipped
        ? AppColors.warning.withValues(
            alpha: AppColors.isDark(context) ? 0.14 : 0.08,
          )
        : surfaceColor;
    final borderColor = isCompleted
        ? AppColors.success.withValues(alpha: 0.36)
        : isSkipped
        ? AppColors.warning.withValues(alpha: 0.28)
        : AppColors.borderOf(context);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      width: double.infinity,
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(color: borderColor),
        boxShadow: isCompleted
            ? [
                BoxShadow(
                  color: accentColor.withValues(alpha: 0.10),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ]
            : null,
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 8.h,
                    ),
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
                  SizedBox(height: 8.h),
                  _MealStatusChip(meal: meal),
                ],
              ),
            ],
          ),
          if (meal.completedAt != null) ...[
            SizedBox(height: 14.h),
            Row(
              children: [
                Icon(
                  Icons.check_circle_rounded,
                  size: 16.sp,
                  color: AppColors.success,
                ),
                SizedBox(width: 8.w),
                Text(
                  context.l10n.completedAtLabel(
                    TimeOfDay.fromDateTime(meal.completedAt!).format(context),
                  ),
                  style: AppTextStyles.caption(
                    context,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: AppColors.success,
                  ),
                ),
              ],
            ),
          ],
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
              context.l10n.viewNutritionDetails,
              style: AppTextStyles.button(
                context,
                fontSize: 13,
                color: AppColors.primaryGreenDark,
              ),
            ),
          ),
          SizedBox(height: 10.h),
          Row(
            children: [
              Expanded(
                child: isCompleted
                    ? _CompletedActionPill(accentColor: accentColor)
                    : FilledButton.icon(
                        onPressed: onCompleteTap,
                        style: FilledButton.styleFrom(
                          backgroundColor: accentColor,
                          foregroundColor: AppColors.textWhite,
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14.r),
                          ),
                        ),
                        icon: Icon(Icons.check_rounded, size: 18.sp),
                        label: Text(
                          context.l10n.markMealDone,
                          style: AppTextStyles.button(context, fontSize: 13),
                        ),
                      ),
              ),
              if (!isCompleted) ...[
                SizedBox(width: 10.w),
                TextButton(
                  onPressed: isSkipped ? null : onSkipTap,
                  style: TextButton.styleFrom(
                    foregroundColor: isSkipped
                        ? AppColors.textHintOf(context)
                        : AppColors.textSecondaryOf(context),
                  ),
                  child: Text(
                    isSkipped
                        ? context.l10n.mealStatusSkipped
                        : context.l10n.skipMeal,
                    style: AppTextStyles.button(
                      context,
                      fontSize: 13,
                      color: isSkipped
                          ? AppColors.textHintOf(context)
                          : AppColors.textSecondaryOf(context),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  IconData _iconFor(DietMealType type) {
    switch (type) {
      case DietMealType.breakfast:
        return Icons.breakfast_dining_outlined;
      case DietMealType.lunch:
        return Icons.lunch_dining_outlined;
      case DietMealType.snack:
        return Icons.local_cafe_outlined;
      case DietMealType.dinner:
        return Icons.dinner_dining_outlined;
    }
  }

  Color _accentColorFor(DietMealType type) {
    switch (type) {
      case DietMealType.breakfast:
        return AppColors.warning;
      case DietMealType.lunch:
        return AppColors.primaryGreenDark;
      case DietMealType.snack:
        return AppColors.info;
      case DietMealType.dinner:
        return AppColors.primaryGreen;
    }
  }
}

class _MealStatusChip extends StatelessWidget {
  const _MealStatusChip({required this.meal});

  final DietPlanMeal meal;

  @override
  Widget build(BuildContext context) {
    final statusColor = switch (meal.status) {
      DietMealStatus.completed => AppColors.success,
      DietMealStatus.skipped => AppColors.warning,
      DietMealStatus.pending => AppColors.textSecondaryOf(context),
    };
    final statusLabel = switch (meal.status) {
      DietMealStatus.completed => context.l10n.mealStatusCompleted,
      DietMealStatus.skipped => context.l10n.mealStatusSkipped,
      DietMealStatus.pending => context.l10n.mealStatusPending,
    };
    final statusIcon = switch (meal.status) {
      DietMealStatus.completed => Icons.check_circle_rounded,
      DietMealStatus.skipped => Icons.fastfood_outlined,
      DietMealStatus.pending => Icons.schedule_rounded,
    };

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 7.h),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(statusIcon, size: 14.sp, color: statusColor),
          SizedBox(width: 6.w),
          Text(
            statusLabel,
            style: AppTextStyles.caption(
              context,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: statusColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _CompletedActionPill extends StatelessWidget {
  const _CompletedActionPill({required this.accentColor});

  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: accentColor.withValues(alpha: 0.24)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle_rounded, size: 18.sp, color: accentColor),
          SizedBox(width: 8.w),
          Text(
            context.l10n.mealStatusCompleted,
            style: AppTextStyles.button(
              context,
              fontSize: 13,
              color: accentColor,
            ),
          ),
        ],
      ),
    );
  }
}
