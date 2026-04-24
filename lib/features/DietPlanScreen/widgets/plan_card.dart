import 'package:ai_meal_planner/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PlanCard extends StatelessWidget {
  const PlanCard({super.key, required this.child, this.padding});

  final Widget child;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surfaceOf(context),
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: AppColors.borderOf(context)),
      ),
      child: Padding(padding: padding ?? EdgeInsets.all(18.w), child: child),
    );
  }
}
