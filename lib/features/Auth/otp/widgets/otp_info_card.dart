import 'package:ai_meal_planner/core/constants/app_colors.dart';
import 'package:ai_meal_planner/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class OtpInfoCard extends StatelessWidget {
  const OtpInfoCard({super.key, required this.destination, this.onChangeTap});

  final String destination;
  final VoidCallback? onChangeTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.surfaceOf(context).withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: AppColors.borderOf(context)),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowOf(context),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46.w,
            height: 46.w,
            decoration: BoxDecoration(
              color: AppColors.chipBackgroundOf(context),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: const Icon(
              Icons.mark_email_read_outlined,
              color: AppColors.primaryGreenDark,
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Code sent successfully',
                  style: AppTextStyles.title(
                    context,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'We sent your verification code to:',
                  style: AppTextStyles.body(context, fontSize: 13, height: 1.5),
                ),
                SizedBox(height: 4.h),
                Text(
                  destination,
                  style: AppTextStyles.title(
                    context,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryGreenDark,
                  ),
                ),
              ],
            ),
          ),
          if (onChangeTap != null)
            TextButton(
              onPressed: onChangeTap,
              child: Text(
                'Change',
                style: AppTextStyles.button(
                  context,
                  fontSize: 13,
                  color: AppColors.primaryGreenDark,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
