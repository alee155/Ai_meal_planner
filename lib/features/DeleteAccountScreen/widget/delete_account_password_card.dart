import 'package:ai_meal_planner/core/constants/app_colors.dart';
import 'package:ai_meal_planner/core/theme/app_text_styles.dart';
import 'package:ai_meal_planner/shared/widgets/app_text_form_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DeleteAccountPasswordCard extends StatelessWidget {
  const DeleteAccountPasswordCard({
    super.key,
    required this.controller,
    required this.obscurePassword,
    required this.onToggleVisibility,
  });

  final TextEditingController controller;
  final bool obscurePassword;
  final VoidCallback onToggleVisibility;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: AppColors.surfaceOf(context),
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(color: AppColors.borderOf(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Confirm with password',
            style: AppTextStyles.title(context, fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 8.h),
          Text(
            'Enter your current password to confirm account deletion.',
            style: AppTextStyles.body(context, fontSize: 13, height: 1.5),
          ),
          SizedBox(height: 14.h),
          AppTextFormField(
            controller: controller,
            hintText: 'Enter your password',
            obscureText: obscurePassword,
            suffixIcon: IconButton(
              onPressed: onToggleVisibility,
              icon: Icon(
                obscurePassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: AppColors.textSecondaryOf(context),
              ),
            ),
            borderRadius: 16,
            horizontalPadding: 16,
            verticalPadding: 16,
            focusedBorderColor: AppColors.error,
          ),
        ],
      ),
    );
  }
}
