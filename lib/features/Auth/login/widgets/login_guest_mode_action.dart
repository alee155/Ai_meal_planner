import 'package:ai_meal_planner/core/animations/app_animations.dart';
import 'package:ai_meal_planner/core/constants/app_colors.dart';
import 'package:ai_meal_planner/core/theme/app_text_styles.dart';
import 'package:ai_meal_planner/l10n/l10n.dart';
import 'package:flutter/material.dart';

class LoginGuestModeAction extends StatelessWidget {
  const LoginGuestModeAction({
    super.key,
    required this.onPressed,
    required this.isSubmitting,
  });

  final VoidCallback onPressed;
  final bool isSubmitting;

  @override
  Widget build(BuildContext context) {
    return Align(
      child: TextButton(
        onPressed: isSubmitting ? null : onPressed,
        child: Text(
          context.l10n.continueGuestMode,
          style: AppTextStyles.button(
            context,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.primaryGreenDark,
          ),
        ),
      ).animateAuthAction(delay: AppMotion.stagger(7, initialMs: 90)),
    );
  }
}
