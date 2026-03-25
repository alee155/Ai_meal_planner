import 'package:ai_meal_planner/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AuthBackgroundDecor extends StatelessWidget {
  const AuthBackgroundDecor({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.isDark(context)
                      ? const Color(0xFF173123)
                      : AppColors.primarylightGreen.withValues(alpha: 0.45),
                  AppColors.backgroundMainOf(context),
                  AppColors.isDark(context)
                      ? const Color(0xFF111914)
                      : const Color(0xFFF2F8F2),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: -70.h,
          right: -50.w,
          child: Container(
            width: 220.w,
            height: 220.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primaryGreenLight.withValues(
                alpha: AppColors.isDark(context) ? 0.12 : 0.22,
              ),
            ),
          ),
        ),
        Positioned(
          top: 140.h,
          left: -90.w,
          child: Container(
            width: 210.w,
            height: 210.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.isDark(context)
                  ? AppColors.darkChipBackground.withValues(alpha: 0.8)
                  : AppColors.primarylightGreen.withValues(alpha: 0.95),
            ),
          ),
        ),
      ],
    );
  }
}
