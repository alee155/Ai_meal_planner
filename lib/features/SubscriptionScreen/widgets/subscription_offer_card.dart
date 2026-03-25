import 'package:ai_meal_planner/core/constants/app_colors.dart';
import 'package:ai_meal_planner/core/theme/app_text_styles.dart';
import 'package:ai_meal_planner/features/SubscriptionScreen/models/subscription_models.dart';
import 'package:ai_meal_planner/shared/widgets/app_filled_button.dart';
import 'package:ai_meal_planner/shared/widgets/app_outlined_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SubscriptionOfferCard extends StatelessWidget {
  const SubscriptionOfferCard({
    super.key,
    required this.plan,
    required this.isActive,
    required this.onPrimaryTap,
    required this.primaryLabel,
    this.onSecondaryTap,
    this.secondaryLabel,
  });

  final SubscriptionPlan plan;
  final bool isActive;
  final VoidCallback onPrimaryTap;
  final String primaryLabel;
  final VoidCallback? onSecondaryTap;
  final String? secondaryLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28.r),
        gradient: const LinearGradient(
          colors: [Color(0xFF67C36D), Color(0xFF2E7D32)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGreenDark.withValues(alpha: 0.25),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28.r),
        child: Stack(
          children: [
            const _SubscriptionOfferDecor(),
            Padding(
              padding: EdgeInsets.all(22.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 7.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(999.r),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.14),
                          ),
                        ),
                        child: Text(
                          isActive ? 'PREMIUM ACTIVE' : 'PREMIUM',
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1,
                            color: Colors.white.withValues(alpha: 0.96),
                          ),
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.workspace_premium_rounded,
                        size: 26.sp,
                        color: Colors.white.withValues(alpha: 0.92),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    plan.title,
                    style: AppTextStyles.display(
                      context,
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    plan.priceLabel,
                    style: AppTextStyles.title(
                      context,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    plan.billingLabel,
                    style: AppTextStyles.caption(
                      context,
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.82),
                    ),
                  ),
                  SizedBox(height: 14.h),
                  Text(
                    plan.description,
                    style: AppTextStyles.body(
                      context,
                      fontSize: 13,
                      height: 1.5,
                      color: Colors.white.withValues(alpha: 0.88),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    children: plan.highlights
                        .map(
                          (highlight) => Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10.w,
                              vertical: 7.h,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.16),
                              borderRadius: BorderRadius.circular(999.r),
                            ),
                            child: Text(
                              highlight,
                              style: AppTextStyles.caption(
                                context,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  SizedBox(height: 20.h),
                  AppFilledButton(
                    label: primaryLabel,
                    onPressed: onPrimaryTap,
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primaryGreenDark,
                    borderRadius: 18,
                    paddingVertical: 15,
                  ),
                  if (secondaryLabel != null && onSecondaryTap != null) ...[
                    SizedBox(height: 10.h),
                    AppOutlinedButton(
                      label: secondaryLabel,
                      onPressed: onSecondaryTap,
                      foregroundColor: Colors.white,
                      borderColor: Colors.white.withValues(alpha: 0.32),
                      borderRadius: 18,
                      paddingVertical: 14,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SubscriptionOfferDecor extends StatelessWidget {
  const _SubscriptionOfferDecor();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: Stack(
          children: [
            Positioned(
              top: -42.h,
              right: -14.w,
              child: Container(
                width: 150.w,
                height: 150.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.10),
                ),
              ),
            ),
            Positioned(
              top: 18.h,
              right: 28.w,
              child: Container(
                width: 88.w,
                height: 88.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.16),
                    width: 1.4,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -24.h,
              left: -10.w,
              child: Transform.rotate(
                angle: -0.35,
                child: Container(
                  width: 150.w,
                  height: 72.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999.r),
                    color: Colors.white.withValues(alpha: 0.08),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
