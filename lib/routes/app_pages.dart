import 'package:ai_meal_planner/alram.dart';
import 'package:ai_meal_planner/core/auth/widgets/auth_gate.dart';
import 'package:ai_meal_planner/core/auth/widgets/guest_restricted_view.dart';
import 'package:ai_meal_planner/core/constants/app_colors.dart';
import 'package:ai_meal_planner/features/Account/ui/password_reset_confirm_screen.dart';
import 'package:ai_meal_planner/features/Account/ui/password_reset_request_screen.dart';
import 'package:ai_meal_planner/features/AlarmRingScreen/ui/alarm_ring_screen.dart';
import 'package:ai_meal_planner/features/Auth/login/ui/login_screen.dart';
import 'package:ai_meal_planner/features/Auth/otp/ui/otp_screen.dart';
import 'package:ai_meal_planner/features/Auth/signup/ui/signup_screen.dart';
import 'package:ai_meal_planner/features/AIChatScreen/ui/ai_chat_screen.dart';
import 'package:ai_meal_planner/features/BottomNavScreen/ui/bottom_nav_screen.dart';
import 'package:ai_meal_planner/features/DeleteAccountScreen/ui/delete_account_screen.dart';
import 'package:ai_meal_planner/features/DietPlanScreen/ui/diet_plan_screen.dart';
import 'package:ai_meal_planner/features/HomeScreen/ui/home_screen.dart';
import 'package:ai_meal_planner/features/MealRemindersScreen/ui/meal_reminders_screen.dart';
import 'package:ai_meal_planner/features/NotificationsScreen/ui/notification_screen.dart';
import 'package:ai_meal_planner/features/PersonalDetailsScreen/ui/personal_details_screen.dart';
import 'package:ai_meal_planner/features/ProfileSetupScreen/ui/profile_setup_screen.dart';
import 'package:ai_meal_planner/features/SettingScreen/ui/settings_screen.dart';
import 'package:ai_meal_planner/features/SplashScreen/ui/splash_screen.dart';
import 'package:ai_meal_planner/features/SubscriptionScreen/ui/subscription_screen.dart';

import 'package:ai_meal_planner/features/user_profile/ui/user_profile.dart';

import 'package:ai_meal_planner/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'app_routes.dart';

class AppPages {
  const AppPages._();

  static final routes = <GetPage<dynamic>>[
    GetPage(name: AppRoutes.splash, page: () => const SplashScreen()),
    GetPage(name: AppRoutes.login, page: () => const LoginScreen()),
    GetPage(name: AppRoutes.signup, page: () => const SignupScreen()),
    GetPage(name: AppRoutes.otp, page: () => const OtpScreen()),
    GetPage(
      name: AppRoutes.forgotPassword,
      page: () => const PasswordResetRequestScreen(),
    ),
    GetPage(
      name: AppRoutes.resetPasswordConfirm,
      page: () => const PasswordResetConfirmScreen(),
    ),
    GetPage(
      name: AppRoutes.profileSetup,
      page: () => const ProfileSetupScreen(),
    ),
    GetPage(name: AppRoutes.bottomNav, page: () => const BottomNavScreen()),
    GetPage(name: AppRoutes.home, page: () => const HomeScreen()),
    GetPage(
      name: AppRoutes.dietPlan,
      page: () => AuthGate(
        authenticatedBuilder: (_) => const DietPlanScreen(),
        guestBuilder: (context) => Scaffold(
          backgroundColor: AppColors.backgroundSecondaryOf(context),
          body: SafeArea(
            child: GuestRestrictedView(
              icon: Icons.restaurant_menu_rounded,
              title: context.l10n.dietPlanGuestTitle,
              description: context.l10n.dietPlanGuestDescription,
              primaryLabel: context.l10n.guestModeButtonSignIn,
              onPrimary: () => Get.toNamed(AppRoutes.login),
              secondaryLabel: context.l10n.openSettings,
              onSecondary: () => Get.toNamed(AppRoutes.settings),
            ),
          ),
        ),
      ),
    ),
    GetPage(name: AppRoutes.aiChat, page: () => const AiChatScreen()),
    GetPage(
      name: AppRoutes.profile,
      page: () => AuthGate(
        authenticatedBuilder: (_) => const UserProfileScreen(),
        guestBuilder: (context) => Scaffold(
          backgroundColor: AppColors.backgroundMainOf(context),
          appBar: AppBar(
            backgroundColor: AppColors.backgroundMainOf(context),
            surfaceTintColor: AppColors.backgroundMainOf(context),
            scrolledUnderElevation: 0,
            elevation: 0,
            automaticallyImplyLeading: true,
            titleSpacing: 0,
            centerTitle: false,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.navProfile,
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimaryOf(context),
                  ),
                ),
                Text(
                  context.l10n.profileIntroDescription,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondaryOf(context),
                  ),
                ),
              ],
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 14),
                child: InkWell(
                  onTap: () => Get.toNamed(AppRoutes.settings),
                  borderRadius: BorderRadius.circular(18),
                  child: Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceOf(context),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppColors.borderOf(context)),
                    ),
                    child: Icon(
                      Icons.settings_outlined,
                      color: AppColors.textPrimaryOf(context),
                    ),
                  ),
                ),
              ),
            ],
          ),
          body: SafeArea(
            child: GuestRestrictedView(
              icon: Icons.person_outline_rounded,
              title: context.l10n.guestModeTitle,
              description: context.l10n.guestModeDescription,
              primaryLabel: context.l10n.guestModeButtonSignIn,
              onPrimary: () => Get.toNamed(AppRoutes.login),
              secondaryLabel: context.l10n.openSettings,
              onSecondary: () => Get.toNamed(AppRoutes.settings),
            ),
          ),
        ),
      ),
    ),
    GetPage(
      name: AppRoutes.personalDetails,
      page: () => const PersonalDetailsScreen(),
    ),
    GetPage(name: AppRoutes.settings, page: () => const SettingsScreen()),
    GetPage(
      name: AppRoutes.subscription,
      page: () => const SubscriptionScreen(),
    ),
    GetPage(
      name: AppRoutes.notifications,
      page: () => const NotificationScreen(),
    ),
    GetPage(
      name: AppRoutes.mealReminders,
      page: () => const MealRemindersScreen(),
    ),
    GetPage(
      name: AppRoutes.deleteAccount,
      page: () => const DeleteAccountScreen(),
    ),
    GetPage(
      name: AppRoutes.multicolorloader,
      page: () => const TimePickerScreen(),
    ),
    GetPage(name: AppRoutes.alarmRinging, page: () => const AlarmRingScreen()),
  ];
}
