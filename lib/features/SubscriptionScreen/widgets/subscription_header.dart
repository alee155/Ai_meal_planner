import 'package:ai_meal_planner/core/constants/app_colors.dart';
import 'package:ai_meal_planner/core/theme/app_text_styles.dart';
import 'package:ai_meal_planner/l10n/l10n.dart';
import 'package:ai_meal_planner/shared/widgets/app_icon_back_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SubscriptionHeader extends StatelessWidget {
  const SubscriptionHeader({super.key, required this.onBackTap});

  final VoidCallback onBackTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppIconBackButton(
          onTap: onBackTap,
          size: 46,
          borderRadius: 16,
          backgroundColor: AppColors.surfaceOf(context),
          borderColor: AppColors.borderOf(context),
          iconColor: AppColors.textPrimaryOf(context),
        ),
        SizedBox(width: 14.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.availableSubscriptionTitle,
                style: AppTextStyles.headline(
                  context,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 3.h),
              Text(
                context.l10n.availableSubscriptionDescription,
                style: AppTextStyles.body(context, fontSize: 13, height: 1.45),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
