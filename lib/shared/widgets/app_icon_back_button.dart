import 'package:ai_meal_planner/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppIconBackButton extends StatelessWidget {
  const AppIconBackButton({
    super.key,
    required this.onTap,
    this.size = 44,
    this.borderRadius = 14,
    this.iconSize = 18,
    this.backgroundColor,
    this.borderColor,
    this.iconColor,
  });

  final VoidCallback onTap;
  final double size;
  final double borderRadius;
  final double iconSize;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(borderRadius.r),
      child: Container(
        width: size.w,
        height: size.w,
        decoration: BoxDecoration(
          color: backgroundColor ?? AppColors.surfaceOf(context),
          borderRadius: BorderRadius.circular(borderRadius.r),
          border: Border.all(color: borderColor ?? AppColors.borderOf(context)),
        ),
        child: Icon(
          Icons.arrow_back_ios_new_rounded,
          size: iconSize.sp,
          color: iconColor ?? AppColors.textPrimaryOf(context),
        ),
      ),
    );
  }
}
