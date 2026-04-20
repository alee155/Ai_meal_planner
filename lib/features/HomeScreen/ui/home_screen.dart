import 'dart:async';

import 'package:ai_meal_planner/core/animations/app_animations.dart';
import 'package:ai_meal_planner/core/auth/controller/auth_session_controller.dart';
import 'package:ai_meal_planner/core/constants/app_colors.dart';
import 'package:ai_meal_planner/features/DietPlanScreen/controller/diet_plan_controller.dart';
import 'package:ai_meal_planner/features/HomeScreen/widgets/home_calorie_chart_panel.dart';
import 'package:ai_meal_planner/features/HomeScreen/widgets/home_calories_card.dart';
import 'package:ai_meal_planner/features/HomeScreen/widgets/home_header.dart';
import 'package:ai_meal_planner/features/NotificationsScreen/controller/notifications_inbox_controller.dart';
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
  late final DietPlanController _dietPlanController;

  @override
  void initState() {
    super.initState();
    _dietPlanController = DietPlanController.ensureRegistered();
    unawaited(_dietPlanController.ensureFresh());
  }

  @override
  Widget build(BuildContext context) {
    final subscriptionController = SubscriptionController.ensureRegistered();
    final authSessionController = AuthSessionController.ensureRegistered();
    final inboxController = NotificationsInboxController.ensureRegistered();
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
          padding: EdgeInsets.fromLTRB(20.w, 14.h, 20.w, 18.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Obx(
                () => HomeHeader(
                  onNotificationsTap: () =>
                      Get.toNamed(AppRoutes.notifications),
                  badgeCount: inboxController.unreadCount.value == 0
                      ? null
                      : inboxController.unreadCount.value,
                  userName:
                      authSessionController.currentUser.value?.name
                              .trim()
                              .isNotEmpty ==
                          true
                      ? authSessionController.currentUser.value!.name.trim()
                      : 'Guest User',
                  avatarImageUrl: authSessionController
                      .currentUser
                      .value
                      ?.resolvedProfileImageUrl,
                ),
              ).animateDashboardHeader(enabled: widget.playEntranceAnimation),
              SizedBox(height: 18.h),
              Obx(() {
                final goal =
                    (_dietPlanController
                                .latest
                                .value
                                ?.plan
                                .nutrition
                                .targetCalories ??
                            1700)
                        .round();
                const consumed = 1360;
                final remaining = (goal - consumed).clamp(0, goal).toInt();

                return HomeCaloriesCard(
                  consumedCalories: consumed,
                  calorieGoal: goal,
                  remainingCalories: remaining,
                  planLabel: subscriptionController.hasPremium
                      ? context.l10n.premium
                      : context.l10n.freePlan,
                  isPremium: subscriptionController.hasPremium,
                );
              }).animateDashboardCard(
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
