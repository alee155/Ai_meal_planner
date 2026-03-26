import 'package:ai_meal_planner/core/animations/app_animations.dart';
import 'package:ai_meal_planner/core/constants/app_colors.dart';
import 'package:ai_meal_planner/features/HomeScreen/widgets/home_calorie_chart_panel.dart';
import 'package:ai_meal_planner/features/HomeScreen/widgets/home_calories_card.dart';
import 'package:ai_meal_planner/features/HomeScreen/widgets/home_header.dart';
import 'package:ai_meal_planner/features/SubscriptionScreen/controller/subscription_controller.dart';
import 'package:ai_meal_planner/l10n/l10n.dart';
import 'package:ai_meal_planner/routes/app_routes.dart';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.playEntranceAnimation = true});

  final bool playEntranceAnimation;

  static const List<double> _weeklyCalories = [
    1360,
    1480,
    1410,
    1325,
    1560,
    1680,
    1510,
  ];
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  HomeCalorieChartType _selectedChartType = HomeCalorieChartType.spline;

  @override
  Widget build(BuildContext context) {
    final subscriptionController = SubscriptionController.ensureRegistered();
    const calorieGoal = 1700;
    const consumedCalories = 1360;
    const remainingCalories = calorieGoal - consumedCalories;
    final days = [
      context.l10n.mondayShort,
      context.l10n.tuesdayShort,
      context.l10n.wednesdayShort,
      context.l10n.thursdayShort,
      context.l10n.fridayShort,
      context.l10n.saturdayShort,
      context.l10n.sundayShort,
    ];

    return Scaffold(
      backgroundColor: AppColors.backgroundSecondaryOf(context),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(20.w, 0.h, 20.w, 0.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Obx(
                () => HomeHeader(
                  onNotificationsTap: () =>
                      Get.toNamed(AppRoutes.notifications),
                ),
              ).animateDashboardHeader(enabled: widget.playEntranceAnimation),
              SizedBox(height: 18.h),
              Obx(
                () => HomeCaloriesCard(
                  consumedCalories: consumedCalories,
                  calorieGoal: calorieGoal,
                  remainingCalories: remainingCalories,
                  planLabel: subscriptionController.hasPremium
                      ? context.l10n.premium
                      : context.l10n.freePlan,
                  isPremium: subscriptionController.hasPremium,
                ),
              ).animateDashboardCard(
                enabled: widget.playEntranceAnimation,
                delay: AppMotion.stagger(1, initialMs: 140),
              ),
              SizedBox(height: 18.h),
              Expanded(
                child: HomeCalorieChartPanel(
                  values: HomeScreen._weeklyCalories,
                  days: days,
                  selectedChartType: _selectedChartType,
                  onChartTypeChanged: (chartType) {
                    setState(() => _selectedChartType = chartType);
                  },
                ),
              ).animateDashboardPanel(
                enabled: widget.playEntranceAnimation,
                delay: AppMotion.stagger(2, initialMs: 180),
              ),
              SizedBox(height: 18.h),
            ],
          ),
        ),
      ),
    );
  }
}
