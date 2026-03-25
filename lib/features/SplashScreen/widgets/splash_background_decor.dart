import 'package:ai_meal_planner/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SplashBackgroundDecor extends StatelessWidget {
  const SplashBackgroundDecor({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);

    return Stack(
      children: [
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  isDark
                      ? const Color(0xFF122018)
                      : AppColors.primarylightGreen.withValues(alpha: 0.72),
                  AppColors.backgroundMainOf(context),
                  isDark ? const Color(0xFF0D1410) : const Color(0xFFF4FAF5),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: -100.h,
          right: -40.w,
          child: Container(
            width: 240.w,
            height: 240.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primaryGreenLight.withValues(
                alpha: isDark ? 0.12 : 0.2,
              ),
            ),
          ),
        ),
        Positioned(
          top: 160.h,
          left: -80.w,
          child: Container(
            width: 210.w,
            height: 210.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark
                  ? AppColors.darkChipBackground.withValues(alpha: 0.82)
                  : AppColors.primarylightGreen.withValues(alpha: 0.94),
            ),
          ),
        ),
        Positioned(
          bottom: -70.h,
          right: -90.w,
          child: Container(
            width: 240.w,
            height: 240.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark
                  ? AppColors.darkSurface.withValues(alpha: 0.88)
                  : const Color(0xFFDCEEDD),
            ),
          ),
        ),
      ],
    );
  }
}
