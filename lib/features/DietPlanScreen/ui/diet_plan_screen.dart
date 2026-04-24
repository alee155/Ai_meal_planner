import 'package:ai_meal_planner/core/animations/app_animations.dart';
import 'package:ai_meal_planner/core/constants/app_colors.dart';
import 'package:ai_meal_planner/features/DietPlanScreen/controller/diet_plan_controller.dart';
import 'package:ai_meal_planner/features/DietPlanScreen/widgets/diet_plan_header.dart';
import 'package:ai_meal_planner/features/DietPlanScreen/widgets/daily_nutrition_card.dart';
import 'package:ai_meal_planner/features/DietPlanScreen/widgets/macro_ring_card.dart';
import 'package:ai_meal_planner/features/DietPlanScreen/widgets/meal_expandable_card.dart';
import 'package:ai_meal_planner/features/DietPlanScreen/widgets/plan_flags_card.dart';
import 'package:ai_meal_planner/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class DietPlanScreen extends StatefulWidget {
  const DietPlanScreen({super.key, this.playEntranceAnimation = true});

  final bool playEntranceAnimation;

  @override
  State<DietPlanScreen> createState() => _DietPlanScreenState();
}

class _DietPlanScreenState extends State<DietPlanScreen> {
  late final DietPlanController _controller;

  @override
  void initState() {
    super.initState();
    _controller = DietPlanController.ensureRegistered();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundSecondaryOf(context),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(20.w, 14.h, 20.w, 18.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DietPlanHeader(
                onBackTap: () => _handleBack(context),
              ).animatePlanHeader(enabled: widget.playEntranceAnimation),
              SizedBox(height: 18.h),
              Expanded(child: Obx(() => _buildBody(context))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    final latest = _controller.latest.value;
    final isLoading = _controller.isLoading.value;
    final error = _controller.errorMessage.value.trim();

    if (isLoading && latest == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (latest == null) {
      return _EmptyState(
        message: error.isEmpty ? 'No meal plan found.' : error,
        onRetry: () => _controller.fetchLatest(showLoader: true),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _controller.fetchLatest(showLoader: false),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            if (error.isNotEmpty)
              Padding(
                padding: EdgeInsets.only(bottom: 12.h),
                child: _InlineWarning(message: error),
              ),
            DailyNutritionCard(
              targets: latest.plan.dailyNutritionTargets,
              actualTotals: latest.plan.actualDailyTotals,
            ).animatePlanSummary(
              enabled: widget.playEntranceAnimation,
              delay: AppMotion.stagger(1, initialMs: 120),
            ),
            SizedBox(height: 14.h),
            MacroRingCard(
              percentages: latest.plan.actualDailyTotals.macroPercentages,
            ).animatePlanMeal(
              enabled: widget.playEntranceAnimation,
              delay: AppMotion.stagger(2, initialMs: 140),
              fromLeft: true,
            ),
            SizedBox(height: 14.h),
            ...latest.plan.meals.asMap().entries.map((entry) {
              final index = entry.key;
              final meal = entry.value;

              return Padding(
                padding: EdgeInsets.only(bottom: 14.h),
                child:
                    MealExpandableCard(
                      meal: meal,
                      swapSuggestions: latest.plan.swapSuggestions,
                    ).animatePlanMeal(
                      enabled: widget.playEntranceAnimation,
                      delay: AppMotion.stagger(index + 3, initialMs: 160),
                      fromLeft: index.isEven,
                    ),
              );
            }),
            PlanFlagsCard(flags: latest.plan.flags).animatePlanAction(
              enabled: widget.playEntranceAnimation,
              delay: AppMotion.stagger(
                latest.plan.meals.length + 4,
                initialMs: 180,
              ),
            ),
            if (isLoading) ...[
              SizedBox(height: 12.h),
              const Center(child: CircularProgressIndicator()),
              SizedBox(height: 6.h),
              Text(
                'Loading...',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondaryOf(context),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _handleBack(BuildContext context) {
    if (Navigator.of(context).canPop()) {
      Get.back();
      return;
    }

    Get.offAllNamed(AppRoutes.bottomNav);
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.restaurant_menu_rounded,
              size: 52.sp,
              color: AppColors.textHintOf(context),
            ),
            SizedBox(height: 10.h),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondaryOf(context),
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 14.h),
            FilledButton.icon(
              onPressed: onRetry,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primaryGreenDark,
                foregroundColor: AppColors.textWhite,
              ),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}

class _InlineWarning extends StatelessWidget {
  const _InlineWarning({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.24)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: AppColors.warning,
            size: 18.sp,
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textPrimaryOf(context),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
