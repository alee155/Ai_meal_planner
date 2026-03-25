import 'package:ai_meal_planner/core/constants/app_colors.dart';
import 'package:ai_meal_planner/core/theme/app_text_styles.dart';
import 'package:ai_meal_planner/l10n/l10n.dart';
import 'package:ai_meal_planner/shared/widgets/app_filled_button.dart';
import 'package:ai_meal_planner/shared/widgets/app_outlined_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DietPlanActionPanel extends StatelessWidget {
  const DietPlanActionPanel({
    super.key,
    required this.onGenerateShoppingList,
    required this.onRefreshPlan,
  });

  final VoidCallback onGenerateShoppingList;
  final VoidCallback onRefreshPlan;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: AppColors.surfaceOf(context),
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: AppColors.borderOf(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.nextStep,
            style: AppTextStyles.title(
              context,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            context.l10n.dietPlanNextStepDescription,
            style: AppTextStyles.body(context, fontSize: 13, height: 1.45),
          ),
          SizedBox(height: 16.h),
          AppFilledButton(
            label: context.l10n.generateShoppingList,
            onPressed: onGenerateShoppingList,
            backgroundColor: AppColors.primaryGreenDark,
            foregroundColor: AppColors.textWhite,
            borderRadius: 18,
            fontSize: 15,
            paddingVertical: 15,
          ),
          SizedBox(height: 10.h),
          AppOutlinedButton(
            label: context.l10n.refreshPlan,
            onPressed: onRefreshPlan,
            foregroundColor: AppColors.primaryGreenDark,
            borderColor: AppColors.primaryGreenDark.withValues(alpha: 0.28),
            borderRadius: 18,
            paddingVertical: 14,
            fontSize: 14,
          ),
        ],
      ),
    );
  }
}
