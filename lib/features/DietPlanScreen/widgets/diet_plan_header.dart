import 'package:ai_meal_planner/core/theme/app_text_styles.dart';
import 'package:ai_meal_planner/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DietPlanHeader extends StatelessWidget {
  const DietPlanHeader({super.key, required this.onBackTap});

  final VoidCallback onBackTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.dietPlanTitle,
                style: AppTextStyles.headline(
                  context,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                context.l10n.dietPlanHeaderDescription,
                style: AppTextStyles.body(context, fontSize: 13, height: 1.45),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
