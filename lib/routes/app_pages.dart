import 'package:ai_meal_planner/alram.dart';
import 'package:ai_meal_planner/features/AlarmRingScreen/ui/alarm_ring_screen.dart';
import 'package:ai_meal_planner/features/Auth/login/ui/login_screen.dart';
import 'package:ai_meal_planner/features/Auth/otp/ui/otp_screen.dart';
import 'package:ai_meal_planner/features/Auth/signup/ui/signup_screen.dart';
import 'package:ai_meal_planner/features/AIChatScreen/ui/ai_chat_screen.dart';
import 'package:ai_meal_planner/features/BottomNavScreen/ui/bottom_nav_screen.dart';
import 'package:ai_meal_planner/features/DeleteAccountScreen/ui/delete_account_screen.dart';
import 'package:ai_meal_planner/features/DietPlanScreen/ui/diet_plan_screen.dart';
import 'package:ai_meal_planner/features/HomeScreen/ui/home_screen.dart';
import 'package:ai_meal_planner/features/NotificationsScreen/ui/notification_screen.dart';
import 'package:ai_meal_planner/features/PersonalDetailsScreen/ui/personal_details_screen.dart';
import 'package:ai_meal_planner/features/ProfileSetupScreen/ui/profile_setup_screen.dart';
import 'package:ai_meal_planner/features/SettingScreen/ui/settings_screen.dart';
import 'package:ai_meal_planner/features/SplashScreen/ui/splash_screen.dart';
import 'package:ai_meal_planner/features/SubscriptionScreen/ui/subscription_screen.dart';

import 'package:ai_meal_planner/features/user_profile/ui/user_profile.dart';

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
      name: AppRoutes.profileSetup,
      page: () => const ProfileSetupScreen(),
    ),
    GetPage(name: AppRoutes.bottomNav, page: () => const BottomNavScreen()),
    GetPage(name: AppRoutes.home, page: () => const HomeScreen()),
    GetPage(name: AppRoutes.dietPlan, page: () => const DietPlanScreen()),
    GetPage(name: AppRoutes.aiChat, page: () => const AiChatScreen()),
    GetPage(name: AppRoutes.profile, page: () => const UserProfileScreen()),
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
