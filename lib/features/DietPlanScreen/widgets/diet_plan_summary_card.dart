import 'package:ai_meal_planner/core/constants/app_colors.dart';
import 'package:ai_meal_planner/core/theme/app_text_styles.dart';
import 'package:ai_meal_planner/features/DietPlanScreen/models/diet_plan_models.dart';
import 'package:ai_meal_planner/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DietPlanSummaryCard extends StatelessWidget {
  const DietPlanSummaryCard({
    super.key,
    required this.dailyTarget,
    required this.macros,
  });

  final int dailyTarget;
  final List<DietMacroTarget> macros;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surfaceOf(context),
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: AppColors.borderOf(context)),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowOf(context).withValues(alpha: 0.14),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24.r),
        child: Stack(
          children: [
            const _DietPlanSummaryDecor(),
            Padding(
              padding: EdgeInsets.all(20.w),
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
                              '$dailyTarget kcal',
                              style: AppTextStyles.display(
                                context,
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                                color: AppColors.primaryGreenDark,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              context.l10n.dailyCalorieTarget,
                              style: AppTextStyles.body(context, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 8.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.chipBackgroundOf(context),
                          borderRadius: BorderRadius.circular(999.r),
                          border: Border.all(
                            color: AppColors.primaryGreenDark.withValues(
                              alpha: 0.12,
                            ),
                          ),
                        ),
                        child: Text(
                          context.l10n.aiBalanced,
                          style: AppTextStyles.caption(
                            context,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryGreenDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 18.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: macros
                        .map(
                          (macro) => Expanded(
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 4.w),
                              child: _MacroCard(macro: macro),
                            ),
                          ),
                        )
                        .toList(),
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

class _DietPlanSummaryDecor extends StatelessWidget {
  const _DietPlanSummaryDecor();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: Stack(
          children: [
            Positioned(
              top: -34.h,
              right: -10.w,
              child: Container(
                width: 132.w,
                height: 132.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primaryGreenLight.withValues(alpha: 0.14),
                ),
              ),
            ),
            Positioned(
              top: 18.h,
              right: 28.w,
              child: Container(
                width: 76.w,
                height: 76.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primaryGreenDark.withValues(alpha: 0.12),
                    width: 1.2,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -28.h,
              left: -8.w,
              child: Transform.rotate(
                angle: -0.32,
                child: Container(
                  width: 140.w,
                  height: 62.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999.r),
                    color: AppColors.primaryGreen.withValues(alpha: 0.07),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 26.h,
              right: 98.w,
              child: Column(
                children: List.generate(
                  3,
                  (_) => Padding(
                    padding: EdgeInsets.only(bottom: 6.h),
                    child: Container(
                      width: 5.w,
                      height: 5.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primaryGreenDark.withValues(
                          alpha: 0.20,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MacroCard extends StatelessWidget {
  const _MacroCard({required this.macro});

  final DietMacroTarget macro;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 10.w),
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondaryOf(context),
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: AppColors.borderOf(context)),
      ),
      child: Column(
        children: [
          SizedBox(
            width: 52.w,
            height: 52.w,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 52.w,
                  height: 52.w,
                  child: CircularProgressIndicator(
                    value: macro.percentage,
                    strokeWidth: 5,
                    backgroundColor: macro.color.withValues(alpha: 0.12),
                    valueColor: AlwaysStoppedAnimation<Color>(macro.color),
                  ),
                ),
                Text(
                  macro.percentLabel,
                  style: AppTextStyles.caption(
                    context,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: macro.color,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 10.h),
          Text(
            macro.title,
            style: AppTextStyles.title(
              context,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            macro.gramsLabel,
            style: AppTextStyles.caption(context, fontSize: 11),
          ),
        ],
      ),
    );
  }
}
