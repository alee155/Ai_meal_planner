import 'package:ai_meal_planner/core/constants/app_colors.dart';
import 'package:ai_meal_planner/core/theme/app_text_styles.dart';
import 'package:ai_meal_planner/features/SubscriptionScreen/controller/subscription_controller.dart';
import 'package:ai_meal_planner/features/SubscriptionScreen/models/subscription_models.dart';
import 'package:ai_meal_planner/l10n/l10n.dart';
import 'package:ai_meal_planner/shared/widgets/app_filled_button.dart';
import 'package:ai_meal_planner/shared/widgets/app_outlined_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SubscriptionStatusCard extends StatelessWidget {
  const SubscriptionStatusCard({
    super.key,
    required this.subscription,
    this.primaryLabel,
    this.onPrimaryTap,
    this.secondaryLabel,
    this.onSecondaryTap,
  });

  final ActiveSubscription subscription;
  final String? primaryLabel;
  final VoidCallback? onPrimaryTap;
  final String? secondaryLabel;
  final VoidCallback? onSecondaryTap;

  @override
  Widget build(BuildContext context) {
    final controller = SubscriptionController.ensureRegistered();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: AppColors.surfaceOf(context),
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: AppColors.borderOf(context)),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowOf(context).withValues(alpha: 0.14),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48.w,
                height: 48.w,
                decoration: BoxDecoration(
                  color: AppColors.chipBackgroundOf(context),
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: const Icon(
                  Icons.workspace_premium_rounded,
                  color: AppColors.primaryGreenDark,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.premiumPlan,
                      style: AppTextStyles.title(
                        context,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      context.l10n.nextBillingDate(
                        controller.formatDate(subscription.nextBillingDate),
                      ),
                      style: AppTextStyles.body(context, fontSize: 13),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 7.h),
                decoration: BoxDecoration(
                  color: AppColors.chipBackgroundOf(context),
                  borderRadius: BorderRadius.circular(999.r),
                ),
                child: Text(
                  subscription.plan.priceLabel,
                  style: AppTextStyles.caption(
                    context,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryGreenDark,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: _SubscriptionStat(
                  title: context.l10n.profileSubscriptionAiAccess,
                  value: context.l10n.subscriptionUnlimited,
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: _SubscriptionStat(
                  title: context.l10n.profileSubscriptionDietitian,
                  value: context.l10n.subscriptionIncluded,
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: _SubscriptionStat(
                  title: context.l10n.profileSubscriptionSupport,
                  value: context.l10n.subscriptionPriority,
                ),
              ),
            ],
          ),
          if (primaryLabel != null || secondaryLabel != null) ...[
            SizedBox(height: 16.h),
            Row(
              children: [
                if (secondaryLabel != null && onSecondaryTap != null)
                  Expanded(
                    child: AppOutlinedButton(
                      label: secondaryLabel,
                      onPressed: onSecondaryTap,
                      foregroundColor: AppColors.textPrimaryOf(context),
                      borderColor: AppColors.borderOf(context),
                      borderRadius: 16,
                      paddingVertical: 14,
                    ),
                  ),
                if (secondaryLabel != null && onSecondaryTap != null)
                  SizedBox(width: 10.w),
                if (primaryLabel != null && onPrimaryTap != null)
                  Expanded(
                    child: AppFilledButton(
                      label: primaryLabel!,
                      onPressed: onPrimaryTap,
                      backgroundColor: AppColors.primaryGreenDark,
                      foregroundColor: AppColors.textWhite,
                      borderRadius: 16,
                      paddingVertical: 14,
                      fontSize: 14,
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _SubscriptionStat extends StatelessWidget {
  const _SubscriptionStat({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondaryOf(context),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.borderOf(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.caption(context, fontSize: 11)),
          SizedBox(height: 4.h),
          Text(
            value,
            style: AppTextStyles.title(
              context,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
