import 'package:ai_meal_planner/core/animations/app_animations.dart';
import 'package:ai_meal_planner/core/constants/app_colors.dart';
import 'package:ai_meal_planner/core/theme/app_text_styles.dart';
import 'package:ai_meal_planner/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SplashBrandPanel extends StatelessWidget {
  const SplashBrandPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: AppColors.primarylightGreen,
            borderRadius: BorderRadius.circular(999.r),
            border: Border.all(
              color: AppColors.primaryGreenLight.withValues(alpha: 0.32),
            ),
          ),
          child: Text(
            context.l10n.aiDietPlanner,
            style: AppTextStyles.label(
              context,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryGreenDark,
            ),
          ),
        ).animateAuthChip(delay: AppMotion.stagger(0, initialMs: 80)),
        26.h.verticalSpace,
        Container(
          width: 132.w,
          height: 132.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primaryGreenLight, AppColors.primaryGreenDark],
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryGreenDark.withValues(alpha: 0.2),
                blurRadius: 30,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: Center(
            child: Container(
              width: 94.w,
              height: 94.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.18),
                border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
              ),
              child: Icon(
                Icons.restaurant_menu_rounded,
                size: 44.sp,
                color: Colors.white,
              ),
            ),
          ),
        ).animateAuthCard(delay: AppMotion.stagger(1, initialMs: 120)),
        28.h.verticalSpace,
        Text(
          context.l10n.splashHeadline,
          textAlign: TextAlign.center,
          style: AppTextStyles.display(context, fontSize: 30, height: 1.12),
        ).animateAuthContent(
          delay: AppMotion.stagger(2, initialMs: 140),
          begin: 0.08,
        ),
        12.h.verticalSpace,
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 300.w),
          child: Text(
            context.l10n.splashDescription,
            textAlign: TextAlign.center,
            style: AppTextStyles.body(
              context,
              fontSize: 15,
              height: 1.6,
              color: AppColors.textSecondaryOf(context),
            ),
          ),
        ).animateAuthContent(
          delay: AppMotion.stagger(3, initialMs: 160),
          begin: 0.06,
        ),
      ],
    );
  }
}
