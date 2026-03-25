import 'package:ai_meal_planner/shared/widgets/app_icon_back_button.dart';
import 'package:flutter/material.dart';

class SignupTopBar extends StatelessWidget {
  const SignupTopBar({
    super.key,
    required this.onBackTap,
    required this.isSubmitting,
  });

  final VoidCallback onBackTap;
  final bool isSubmitting;

  @override
  Widget build(BuildContext context) {
    return AppIconBackButton(
      onTap: isSubmitting ? () {} : onBackTap,
      size: 48,
      borderRadius: 16,
    );
  }
}
