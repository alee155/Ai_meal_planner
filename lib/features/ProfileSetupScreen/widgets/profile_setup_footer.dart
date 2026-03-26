import 'package:ai_meal_planner/core/constants/app_colors.dart';
import 'package:ai_meal_planner/shared/widgets/app_filled_button.dart';
import 'package:ai_meal_planner/shared/widgets/app_outlined_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfileSetupFooter extends StatelessWidget {
  const ProfileSetupFooter({
    super.key,
    required this.primaryLabel,
    required this.onPrimaryTap,
    required this.isSaving,
    this.secondaryLabel,
    this.onSecondaryTap,
  });

  final String primaryLabel;
  final VoidCallback? onPrimaryTap;
  final bool isSaving;
  final String? secondaryLabel;
  final VoidCallback? onSecondaryTap;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 16.h),
        decoration: BoxDecoration(
          color: AppColors.backgroundMainOf(context),
          border: Border(top: BorderSide(color: AppColors.borderOf(context))),
        ),
        child: Row(
          children: [
            if (secondaryLabel != null) ...[
              Expanded(
                child: AppOutlinedButton(
                  label: secondaryLabel,
                  onPressed: isSaving ? null : onSecondaryTap,
                  foregroundColor: AppColors.textPrimaryOf(context),
                  borderColor: AppColors.borderOf(context),
                  borderRadius: 16,
                  paddingVertical: 14,
                ),
              ),
              SizedBox(width: 12.w),
            ],
            Expanded(
              child: AppFilledButton(
                label: primaryLabel,
                onPressed: onPrimaryTap,
                backgroundColor: AppColors.buttonPrimary,
                foregroundColor: AppColors.textWhite,
                isLoading: isSaving,
                borderRadius: 16,
                paddingVertical: 14,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
