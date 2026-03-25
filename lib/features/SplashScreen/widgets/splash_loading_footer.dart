import 'package:ai_meal_planner/core/animations/app_animations.dart';
import 'package:ai_meal_planner/core/constants/app_colors.dart';
import 'package:ai_meal_planner/core/theme/app_text_styles.dart';
import 'package:ai_meal_planner/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SplashLoadingFooter extends StatelessWidget {
  const SplashLoadingFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: AppColors.surfaceOf(context).withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(
          color: AppColors.borderOf(context).withValues(alpha: 0.8),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowOf(context),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          const _PulseLoader(),
          14.w.horizontalSpace,
          Expanded(
            child: Text(
              context.l10n.splashLoading,
              style: AppTextStyles.body(
                context,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimaryOf(context),
              ),
            ),
          ),
        ],
      ),
    ).animateAuthAction(delay: AppMotion.stagger(4, initialMs: 180));
  }
}

class _PulseLoader extends StatelessWidget {
  const _PulseLoader();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        3,
        (index) => Padding(
          padding: EdgeInsets.only(right: index == 2 ? 0 : 6.w),
          child:
              Container(
                    width: 9.w,
                    height: 9.w,
                    decoration: const BoxDecoration(
                      color: AppColors.primaryGreenDark,
                      shape: BoxShape.circle,
                    ),
                  )
                  .animate(onPlay: (controller) => controller.repeat())
                  .fadeIn(
                    delay: Duration(milliseconds: index * 180),
                    duration: const Duration(milliseconds: 420),
                  )
                  .then()
                  .fadeOut(duration: const Duration(milliseconds: 420)),
        ),
      ),
    );
  }
}
