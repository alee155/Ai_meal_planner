import 'package:ai_meal_planner/core/animations/app_animations.dart';
import 'package:ai_meal_planner/core/constants/app_colors.dart';
import 'package:ai_meal_planner/core/utils/app_snackbar.dart';
import 'package:ai_meal_planner/features/DietPlanScreen/controller/diet_plan_controller.dart';
import 'package:ai_meal_planner/features/DietPlanScreen/models/diet_plan_models.dart';
import 'package:ai_meal_planner/features/DietPlanScreen/models/latest_meal_plan_response_model.dart';
import 'package:ai_meal_planner/features/DietPlanScreen/widgets/diet_plan_action_panel.dart';
import 'package:ai_meal_planner/features/DietPlanScreen/widgets/diet_plan_header.dart';
import 'package:ai_meal_planner/features/DietPlanScreen/widgets/diet_plan_meal_card.dart';
import 'package:ai_meal_planner/features/DietPlanScreen/widgets/diet_plan_summary_card.dart';
import 'package:ai_meal_planner/l10n/l10n.dart';
import 'package:ai_meal_planner/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class DietPlanScreen extends StatefulWidget {
  const DietPlanScreen({super.key, this.playEntranceAnimation = true});

  final bool playEntranceAnimation;

  static const int _dailyTarget = 1700;

  @override
  State<DietPlanScreen> createState() => _DietPlanScreenState();
}

class _DietPlanScreenState extends State<DietPlanScreen> {
  final Map<DietMealType, DietMealProgress> _mealProgress = {};
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
    final l10n = context.l10n;
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

    final dailyTarget = latest.plan.nutrition.targetCalories > 0
        ? latest.plan.nutrition.targetCalories.round()
        : DietPlanScreen._dailyTarget;
    final macros = _macroTargetsFrom(latest, context);
    final meals = _buildMeals(context, latest);
    final completedMeals = meals.where((meal) => meal.isCompleted).length;
    final consumedCalories = meals
        .where((meal) => meal.isCompleted)
        .fold<int>(0, (total, meal) => total + meal.calories);

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
            DietPlanSummaryCard(
              dailyTarget: dailyTarget,
              macros: macros,
              completedMeals: completedMeals,
              totalMeals: meals.length,
              consumedCalories: consumedCalories,
            ).animatePlanSummary(
              enabled: widget.playEntranceAnimation,
              delay: AppMotion.stagger(1, initialMs: 120),
            ),
            SizedBox(height: 14.h),
            ...meals.asMap().entries.map((entry) {
              final index = entry.key;
              final meal = entry.value;

              return Padding(
                padding: EdgeInsets.only(bottom: 14.h),
                child:
                    DietPlanMealCard(
                      meal: meal,
                      onCompleteTap: () => _markMealCompleted(meal),
                      onSkipTap: () => _skipMeal(meal),
                    ).animatePlanMeal(
                      enabled: widget.playEntranceAnimation,
                      delay: AppMotion.stagger(index + 2, initialMs: 140),
                      fromLeft: index.isEven,
                    ),
              );
            }),
            DietPlanActionPanel(
              onGenerateShoppingList: () => _generateShoppingList(context),
              onRefreshPlan: () => _refreshPlan(context),
            ).animatePlanAction(
              enabled: widget.playEntranceAnimation,
              delay: AppMotion.stagger(meals.length + 2, initialMs: 160),
            ),
            if (isLoading) ...[
              SizedBox(height: 12.h),
              const Center(child: CircularProgressIndicator()),
              SizedBox(height: 6.h),
              Text(
                l10n.splashLoading,
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

  List<DietPlanMeal> _buildMeals(
    BuildContext context,
    LatestMealPlanDataModel latest,
  ) {
    final l10n = context.l10n;

    final meals = <DietPlanMeal>[];
    final breakfast = _controller.breakfastDetails();
    final lunch = _controller.lunchDetails();
    final dinner = _controller.dinnerDetails();
    final snacks = _controller.snacksDetails();

    if (breakfast.items.isNotEmpty || breakfast.totals.calories > 0) {
      meals.add(
        DietPlanMeal(
          type: DietMealType.breakfast,
          title: l10n.breakfast,
          calories: breakfast.totals.calories,
          timeWindow: '7:00 - 9:00 AM',
          items: _previewItems(breakfast.items),
          summary: l10n.breakfastSummary,
          proteinGrams: breakfast.totals.protein,
          carbsGrams: breakfast.totals.carbs,
          fatsGrams: breakfast.totals.fats,
          alternatives: breakfast.alternatives,
        ),
      );
    }

    if (lunch.items.isNotEmpty || lunch.totals.calories > 0) {
      meals.add(
        DietPlanMeal(
          type: DietMealType.lunch,
          title: l10n.lunch,
          calories: lunch.totals.calories,
          timeWindow: '12:00 - 2:00 PM',
          items: _previewItems(lunch.items),
          summary: l10n.lunchSummary,
          proteinGrams: lunch.totals.protein,
          carbsGrams: lunch.totals.carbs,
          fatsGrams: lunch.totals.fats,
          alternatives: lunch.alternatives,
        ),
      );
    }

    if (snacks.items.isNotEmpty || snacks.totals.calories > 0) {
      meals.add(
        DietPlanMeal(
          type: DietMealType.snack,
          title: l10n.snack,
          calories: snacks.totals.calories,
          timeWindow: '4:00 - 5:00 PM',
          items: _previewItems(snacks.items),
          summary: l10n.snackSummary,
          proteinGrams: snacks.totals.protein,
          carbsGrams: snacks.totals.carbs,
          fatsGrams: snacks.totals.fats,
          alternatives: snacks.alternatives,
        ),
      );
    }

    if (dinner.items.isNotEmpty || dinner.totals.calories > 0) {
      meals.add(
        DietPlanMeal(
          type: DietMealType.dinner,
          title: l10n.dinner,
          calories: dinner.totals.calories,
          timeWindow: '7:00 - 9:00 PM',
          items: _previewItems(dinner.items),
          summary: l10n.dinnerSummary,
          proteinGrams: dinner.totals.protein,
          carbsGrams: dinner.totals.carbs,
          fatsGrams: dinner.totals.fats,
          alternatives: dinner.alternatives,
        ),
      );
    }

    return meals.map(_applyMealProgress).toList();
  }

  List<DietMacroTarget> _macroTargetsFrom(
    LatestMealPlanDataModel latest,
    BuildContext context,
  ) {
    final l10n = context.l10n;
    final macros = latest.plan.nutrition.macros;

    final proteinCalories = macros.protein * 4;
    final carbsCalories = macros.carbs * 4;
    final fatsCalories = macros.fats * 9;
    final total = proteinCalories + carbsCalories + fatsCalories;

    double pct(int cals) => total == 0 ? 0 : cals / total;

    return [
      DietMacroTarget(
        title: l10n.protein,
        percentage: pct(proteinCalories),
        gramsLabel: '${macros.protein}g',
        color: AppColors.info,
      ),
      DietMacroTarget(
        title: l10n.carbs,
        percentage: pct(carbsCalories),
        gramsLabel: '${macros.carbs}g',
        color: AppColors.warning,
      ),
      DietMacroTarget(
        title: l10n.fats,
        percentage: pct(fatsCalories),
        gramsLabel: '${macros.fats}g',
        color: AppColors.primaryGreenLight,
      ),
    ];
  }

  List<String> _previewItems(List<String> items) {
    const maxItems = 4;
    if (items.length <= maxItems) return items;
    final preview = items.take(maxItems).toList();
    preview.add('+${items.length - maxItems} more');
    return preview;
  }

  DietPlanMeal _applyMealProgress(DietPlanMeal meal) {
    final progress = _mealProgress[meal.type] ?? const DietMealProgress();

    return meal.copyWith(
      status: progress.status,
      completedAt: progress.completedAt,
      clearCompletedAt: progress.completedAt == null,
    );
  }

  void _handleBack(BuildContext context) {
    if (Navigator.of(context).canPop()) {
      Get.back();
      return;
    }

    Get.offAllNamed(AppRoutes.bottomNav);
  }

  void _markMealCompleted(DietPlanMeal meal) {
    final next = DietMealProgress(
      status: DietMealStatus.completed,
      completedAt: DateTime.now(),
    );

    setState(() => _mealProgress[meal.type] = next);
    AppSnackbar.success(
      meal.title,
      context.l10n.mealCompletedMessage(meal.title),
    );
  }

  void _skipMeal(DietPlanMeal meal) {
    const next = DietMealProgress(status: DietMealStatus.skipped);

    setState(() => _mealProgress[meal.type] = next);
    AppSnackbar.warning(
      meal.title,
      context.l10n.mealSkippedMessage(meal.title),
    );
  }

  // Alternatives + nutrition are displayed inline inside `DietPlanMealCard`.

  void _generateShoppingList(BuildContext context) {
    AppSnackbar.success(
      context.l10n.shoppingListReadyTitle,
      context.l10n.shoppingListReadyMessage,
    );
  }

  void _refreshPlan(BuildContext context) {
    _controller.fetchLatest(showLoader: true);
    AppSnackbar.info(
      context.l10n.planRefreshRequestedTitle,
      context.l10n.planRefreshRequestedMessage,
    );
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
