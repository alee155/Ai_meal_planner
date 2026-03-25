import 'package:ai_meal_planner/core/animations/app_animations.dart';
import 'package:ai_meal_planner/core/constants/app_colors.dart';
import 'package:ai_meal_planner/core/theme/app_text_styles.dart';
import 'package:ai_meal_planner/core/utils/app_snackbar.dart';
import 'package:ai_meal_planner/features/SubscriptionScreen/controller/subscription_controller.dart';
import 'package:ai_meal_planner/features/SubscriptionScreen/models/subscription_models.dart';
import 'package:ai_meal_planner/features/SubscriptionScreen/widgets/subscription_feature_tile.dart';
import 'package:ai_meal_planner/features/SubscriptionScreen/widgets/subscription_header.dart';
import 'package:ai_meal_planner/features/SubscriptionScreen/widgets/subscription_offer_card.dart';
import 'package:ai_meal_planner/features/SubscriptionScreen/widgets/subscription_status_card.dart';
import 'package:ai_meal_planner/l10n/app_localizations.dart';
import 'package:ai_meal_planner/l10n/l10n.dart';
import 'package:ai_meal_planner/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class SubscriptionScreen extends StatelessWidget {
  const SubscriptionScreen({super.key, this.playEntranceAnimation = true});

  final bool playEntranceAnimation;

  @override
  Widget build(BuildContext context) {
    final subscriptionController = SubscriptionController.ensureRegistered();
    final l10n = context.l10n;
    final plan = _localizedPlan(l10n);

    return Scaffold(
      backgroundColor: AppColors.backgroundSecondaryOf(context),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(20.w, 14.h, 20.w, 24.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SubscriptionHeader(
                onBackTap: Get.back,
              ).animatePlanHeader(enabled: playEntranceAnimation),
              SizedBox(height: 18.h),
              Expanded(
                child: Obx(
                  () => SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        subscriptionController.hasPremium
                            ? SubscriptionStatusCard(
                                subscription: subscriptionController
                                    .activeSubscription
                                    .value!,
                                primaryLabel: l10n.managePlan,
                                onPrimaryTap: _handleManagePlan,
                                secondaryLabel: l10n.openSettings,
                                onSecondaryTap: () =>
                                    Get.toNamed(AppRoutes.settings),
                              )
                            : SubscriptionOfferCard(
                                plan: plan,
                                isActive: false,
                                primaryLabel: l10n.activatePremium,
                                onPrimaryTap: () => _activatePremium(context),
                                secondaryLabel: l10n.maybeLater,
                                onSecondaryTap: Get.back,
                              ),
                        SizedBox(height: 18.h),
                        Text(
                          l10n.premiumBenefits,
                          style: AppTextStyles.title(
                            context,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(height: 6.h),
                        Text(
                          l10n.premiumBenefitsDescription,
                          style: AppTextStyles.body(context, fontSize: 13),
                        ),
                        SizedBox(height: 14.h),
                        ...plan.features.asMap().entries.map((entry) {
                          final index = entry.key;
                          final feature = entry.value;

                          return Padding(
                            padding: EdgeInsets.only(bottom: 12.h),
                            child: SubscriptionFeatureTile(feature: feature)
                                .animatePlanMeal(
                                  enabled: playEntranceAnimation,
                                  delay: AppMotion.stagger(
                                    index + 2,
                                    initialMs: 140,
                                  ),
                                  fromLeft: index.isEven,
                                ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _activatePremium(BuildContext context) {
    final subscriptionController = SubscriptionController.ensureRegistered();

    if (subscriptionController.hasPremium) {
      AppSnackbar.info(
        context.l10n.premiumAlreadyActiveTitle,
        context.l10n.premiumAlreadyActiveMessage,
      );
      return;
    }

    subscriptionController.activatePremium();
    AppSnackbar.success(
      context.l10n.premiumActivatedTitle,
      context.l10n.premiumActivatedMessage,
    );
  }

  void _handleManagePlan() {
    final subscriptionController = SubscriptionController.ensureRegistered();
    final activeSubscription = subscriptionController.activeSubscription.value;
    final context = Get.context;

    if (activeSubscription == null || context == null) {
      return;
    }

    AppSnackbar.info(
      context.l10n.manageSubscriptionTitle,
      context.l10n.manageSubscriptionMessage(
        subscriptionController.formatDate(activeSubscription.nextBillingDate),
      ),
    );
  }

  SubscriptionPlan _localizedPlan(AppLocalizations l10n) {
    return SubscriptionPlan(
      title: l10n.premiumPlan,
      priceLabel: '\$9.99/mo',
      billingLabel: l10n.monthlyBilling,
      description: l10n.premiumDescription,
      highlights: [
        l10n.highlightUnlimitedAiChat,
        l10n.highlightDietitianConsults,
        l10n.highlightPrioritySupport,
      ],
      features: [
        SubscriptionFeature(
          title: l10n.professionalDietitianConsultations,
          description: l10n.professionalDietitianConsultationsDescription,
        ),
        SubscriptionFeature(
          title: l10n.advancedAiOptimization,
          description: l10n.advancedAiOptimizationDescription,
        ),
        SubscriptionFeature(
          title: l10n.personalizedLongTermPlans,
          description: l10n.personalizedLongTermPlansDescription,
        ),
        SubscriptionFeature(
          title: l10n.unlimitedAiChatbotAccess,
          description: l10n.unlimitedAiChatbotAccessDescription,
        ),
        SubscriptionFeature(
          title: l10n.prioritySupport,
          description: l10n.prioritySupportDescription,
        ),
        SubscriptionFeature(
          title: l10n.enhancedAnalyticsInsights,
          description: l10n.enhancedAnalyticsInsightsDescription,
        ),
      ],
    );
  }
}
