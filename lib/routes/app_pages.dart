import 'package:ai_meal_planner/features/Auth/login/ui/login_screen.dart';
import 'package:ai_meal_planner/features/Auth/otp/ui/otp_screen.dart';
import 'package:ai_meal_planner/features/Auth/signup/ui/signup_screen.dart';
import 'package:ai_meal_planner/features/BottomNavScreen/ui/bottom_nav_screen.dart';
import 'package:ai_meal_planner/features/DeleteAccountScreen/ui/delete_account_screen.dart';
import 'package:ai_meal_planner/features/DietPlanScreen/ui/diet_plan_screen.dart';
import 'package:ai_meal_planner/features/HomeScreen/ui/home_screen.dart';
import 'package:ai_meal_planner/features/NotificationsScreen/ui/notification_screen.dart';
import 'package:ai_meal_planner/features/SettingScreen/ui/settings_screen.dart';
import 'package:ai_meal_planner/features/user_profile/ui/user_profile.dart';
import 'package:get/get.dart';

import 'app_routes.dart';

class AppPages {
  const AppPages._();

  static final routes = <GetPage<dynamic>>[
    GetPage(name: AppRoutes.login, page: () => const LoginScreen()),
    GetPage(name: AppRoutes.signup, page: () => const SignupScreen()),
    GetPage(name: AppRoutes.otp, page: () => const OtpScreen()),
    GetPage(name: AppRoutes.bottomNav, page: () => const BottomNavScreen()),
    GetPage(name: AppRoutes.home, page: () => const HomeScreen()),
    GetPage(name: AppRoutes.dietPlan, page: () => const DietPlanScreen()),
    GetPage(name: AppRoutes.profile, page: () => const UserProfileScreen()),
    GetPage(name: AppRoutes.settings, page: () => const SettingsScreen()),
    GetPage(
      name: AppRoutes.notifications,
      page: () => const NotificationScreen(),
    ),
    GetPage(
      name: AppRoutes.deleteAccount,
      page: () => const DeleteAccountScreen(),
    ),
  ];
}
