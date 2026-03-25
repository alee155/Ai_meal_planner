import 'package:ai_meal_planner/core/theme/app_text_styles.dart';
import 'package:ai_meal_planner/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SignupHeroSection extends StatelessWidget {
  const SignupHeroSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.buildHealthyRoutine,
          style: AppTextStyles.display(context, height: 1.08),
        ),
        10.h.verticalSpace,
        Text(
          context.l10n.signupHeroDescription,
          style: AppTextStyles.body(context, fontSize: 15, height: 1.6),
        ),
      ],
    );
  }
}
