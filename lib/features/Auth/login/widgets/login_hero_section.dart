import 'package:ai_meal_planner/core/animations/app_animations.dart';
import 'package:ai_meal_planner/core/constants/app_colors.dart';
import 'package:ai_meal_planner/core/theme/app_text_styles.dart';
import 'package:ai_meal_planner/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LoginHeroSection extends StatelessWidget {
  const LoginHeroSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: AppColors.primarylightGreen,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            context.l10n.aiDietPlanner,
            style: AppTextStyles.label(
              context,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryGreenDark,
            ),
          ).animateAuthChip(delay: AppMotion.stagger(0, initialMs: 120)),
        ),
        10.h.verticalSpace,
        Text(
          context.l10n.eatSmarterFeelStronger,
          style: AppTextStyles.display(context, height: 1.1),
        ).animateAuthContent(
          delay: AppMotion.stagger(1, initialMs: 140),
          begin: 0.12,
        ),
        10.h.verticalSpace,
        Text(
          context.l10n.loginHeroDescription,
          style: AppTextStyles.body(context, fontSize: 15, height: 1.6),
        ).animateAuthContent(
          delay: AppMotion.stagger(2, initialMs: 160),
          begin: 0.1,
        ),
      ],
    );
  }
}
