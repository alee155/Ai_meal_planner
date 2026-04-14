import 'package:ai_meal_planner/core/constants/app_colors.dart';
import 'package:ai_meal_planner/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DeleteAccountWarningCard extends StatelessWidget {
  const DeleteAccountWarningCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColors.isDark(context)
            ? AppColors.error.withValues(alpha: 0.16)
            : const Color(0xFFFFF4F4),
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48.w,
            height: 48.w,
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: const Icon(
              Icons.warning_amber_rounded,
              color: AppColors.error,
            ),
          ),
          SizedBox(height: 14.h),
          Text(
            'This action cannot be undone.',
            style: AppTextStyles.headline(
              context,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 10.h),
          const _WarningRow(
            text:
                'Your meal plans, nutrition history, and progress will be removed.',
          ),
          const _WarningRow(
            text: 'You will be signed out immediately after deletion.',
          ),
          const _WarningRow(
            text:
                'If you only need a break, deactivate instead of deleting permanently.',
          ),
        ],
      ),
    );
  }
}

class _WarningRow extends StatelessWidget {
  const _WarningRow({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 10.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 6.h),
            child: Container(
              width: 7.w,
              height: 7.w,
              decoration: const BoxDecoration(
                color: AppColors.error,
                shape: BoxShape.circle,
              ),
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.body(
                context,
                fontSize: 13,
                height: 1.5,
                color: AppColors.textPrimaryOf(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
