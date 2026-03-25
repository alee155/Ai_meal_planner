import 'package:ai_meal_planner/core/constants/app_colors.dart';
import 'package:ai_meal_planner/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfileOverviewCard extends StatelessWidget {
  const ProfileOverviewCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.planLabel,
    required this.goalLabel,
    required this.goalValue,
    required this.activityLabel,
    required this.activityValue,
    required this.bmiLabel,
    required this.bmiValue,
    required this.bmiStatus,
    required this.hasPremium,
    required this.hasBmiData,
  });

  final String title;
  final String subtitle;
  final String planLabel;
  final String goalLabel;
  final String goalValue;
  final String activityLabel;
  final String activityValue;
  final String bmiLabel;
  final String bmiValue;
  final String bmiStatus;
  final bool hasPremium;
  final bool hasBmiData;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 0),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28.r),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryGreen, AppColors.primaryGreenDark],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGreenDark.withValues(alpha: 0.22),
            blurRadius: 28,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 68.w,
                height: 68.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.18),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.26),
                    width: 2,
                  ),
                ),
                child: Icon(
                  Icons.person_rounded,
                  size: 34.sp,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.headline(
                        context,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      subtitle,
                      style: AppTextStyles.body(
                        context,
                        fontSize: 13,
                        height: 1.45,
                        color: Colors.white.withValues(alpha: 0.84),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(999.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  hasPremium
                      ? Icons.workspace_premium_rounded
                      : Icons.shield_outlined,
                  size: 14.sp,
                  color: Colors.white,
                ),
                SizedBox(width: 6.w),
                Text(
                  planLabel,
                  style: AppTextStyles.caption(
                    context,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 18.h),
          Row(
            children: [
              Expanded(
                child: _OverviewStatTile(label: goalLabel, value: goalValue),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: _OverviewStatTile(
                  label: activityLabel,
                  value: activityValue,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: _OverviewStatTile(
                  label: bmiLabel,
                  value: bmiValue,
                  helper: bmiStatus,
                  isMuted: !hasBmiData,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OverviewStatTile extends StatelessWidget {
  const _OverviewStatTile({
    required this.label,
    required this.value,
    this.helper,
    this.isMuted = false,
  });

  final String label;
  final String value;
  final String? helper;
  final bool isMuted;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: isMuted ? 0.1 : 0.16),
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.caption(
              context,
              fontSize: 10,
              color: Colors.white.withValues(alpha: 0.76),
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.title(
              context,
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          if (helper != null) ...[
            SizedBox(height: 4.h),
            Text(
              helper!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.caption(
                context,
                fontSize: 10,
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
