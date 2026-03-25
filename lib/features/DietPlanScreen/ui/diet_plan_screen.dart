import 'package:ai_meal_planner/core/animations/app_animations.dart';
import 'package:ai_meal_planner/core/constants/app_colors.dart';
import 'package:ai_meal_planner/core/utils/app_snackbar.dart';
import 'package:ai_meal_planner/features/DietPlanScreen/models/diet_plan_models.dart';
import 'package:ai_meal_planner/features/DietPlanScreen/widgets/diet_plan_action_panel.dart';
import 'package:ai_meal_planner/features/DietPlanScreen/widgets/diet_plan_header.dart';
import 'package:ai_meal_planner/features/DietPlanScreen/widgets/diet_plan_meal_card.dart';
import 'package:ai_meal_planner/features/DietPlanScreen/widgets/diet_plan_summary_card.dart';
import 'package:ai_meal_planner/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class DietPlanScreen extends StatelessWidget {
  const DietPlanScreen({super.key, this.playEntranceAnimation = true});

  final bool playEntranceAnimation;

  static const int _dailyTarget = 1700;
  static const List<DietMacroTarget> _macros = [
    DietMacroTarget(
      title: 'Protein',
      percentage: 0.30,
      gramsLabel: '85g',
      color: AppColors.info,
    ),
    DietMacroTarget(
      title: 'Carbs',
      percentage: 0.45,
      gramsLabel: '180g',
      color: AppColors.warning,
    ),
    DietMacroTarget(
      title: 'Fats',
      percentage: 0.25,
      gramsLabel: '48g',
      color: AppColors.primaryGreenLight,
    ),
  ];

  static const List<DietPlanMeal> _meals = [
    DietPlanMeal(
      title: 'Breakfast',
      calories: 420,
      timeWindow: '7:00 - 9:00 AM',
      items: [
        'Oatmeal with berries - 1 cup',
        'Greek yogurt - 150g',
        'Almonds - 15 pieces',
      ],
      summary:
          'High protein, rich in fiber, and balanced for a steady morning energy curve.',
    ),
    DietPlanMeal(
      title: 'Lunch',
      calories: 580,
      timeWindow: '12:00 - 2:00 PM',
      items: [
        'Grilled chicken breast - 150g',
        'Quinoa salad - 200g',
        'Steamed broccoli - 100g',
        'Olive oil - 1 tbsp',
      ],
      summary:
          'Complete protein and complex carbs to keep energy stable through the afternoon.',
    ),
    DietPlanMeal(
      title: 'Snack',
      calories: 180,
      timeWindow: '4:00 - 5:00 PM',
      items: ['Apple - 1 medium', 'Protein shake - 250ml'],
      summary:
          'A light recovery snack that supports satiety without pushing calories too high.',
    ),
    DietPlanMeal(
      title: 'Dinner',
      calories: 520,
      timeWindow: '7:00 - 9:00 PM',
      items: [
        'Baked salmon - 180g',
        'Sweet potato - 150g',
        'Mixed vegetables - 150g',
      ],
      summary:
          'Omega-3 fats and micronutrients to round out the day without a heavy finish.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final dateLabel = _formatTodayLabel(DateTime.now());

    return Scaffold(
      backgroundColor: AppColors.backgroundSecondaryOf(context),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(20.w, 14.h, 20.w, 18.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DietPlanHeader(
                dateLabel: dateLabel,
                onBackTap: () => _handleBack(context),
              ).animatePlanHeader(enabled: playEntranceAnimation),
              SizedBox(height: 18.h),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      DietPlanSummaryCard(
                        dailyTarget: _dailyTarget,
                        macros: _macros,
                      ).animatePlanSummary(
                        enabled: playEntranceAnimation,
                        delay: AppMotion.stagger(1, initialMs: 120),
                      ),
                      SizedBox(height: 14.h),
                      ..._meals.asMap().entries.map((entry) {
                        final index = entry.key;
                        final meal = entry.value;

                        return Padding(
                          padding: EdgeInsets.only(bottom: 14.h),
                          child:
                              DietPlanMealCard(
                                meal: meal,
                                onDetailsTap: () =>
                                    _showMealDetails(meal.title),
                              ).animatePlanMeal(
                                enabled: playEntranceAnimation,
                                delay: AppMotion.stagger(
                                  index + 2,
                                  initialMs: 140,
                                ),
                                fromLeft: index.isEven,
                              ),
                        );
                      }),
                      DietPlanActionPanel(
                        onGenerateShoppingList: _generateShoppingList,
                        onRefreshPlan: _refreshPlan,
                      ).animatePlanAction(
                        enabled: playEntranceAnimation,
                        delay: AppMotion.stagger(
                          _meals.length + 2,
                          initialMs: 160,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
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

  void _showMealDetails(String mealTitle) {
    AppSnackbar.info(
      '$mealTitle details',
      'Nutrition breakdown, ingredients, and substitutions can be connected here.',
    );
  }

  void _generateShoppingList() {
    AppSnackbar.success(
      'Shopping list ready',
      'Connect this action to your shopping-list flow next.',
    );
  }

  void _refreshPlan() {
    AppSnackbar.info(
      'Plan refresh requested',
      'Swap this placeholder with your AI meal-generation flow.',
    );
  }

  String _formatTodayLabel(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return 'Today • ${months[date.month - 1]} ${date.day}';
  }
}
