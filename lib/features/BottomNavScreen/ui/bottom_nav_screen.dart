import 'package:ai_meal_planner/features/AIChatScreen/ui/ai_chat_screen.dart';
import 'package:ai_meal_planner/core/constants/app_colors.dart';
import 'package:ai_meal_planner/core/auth/widgets/auth_gate.dart';
import 'package:ai_meal_planner/core/auth/widgets/guest_restricted_view.dart';
import 'package:ai_meal_planner/features/BottomNavScreen/widget/bottom_nav_bar.dart';
import 'package:ai_meal_planner/features/BottomNavScreen/widget/bottom_nav_item_data.dart';
import 'package:ai_meal_planner/features/DietPlanScreen/ui/diet_plan_screen.dart';
import 'package:ai_meal_planner/features/HomeScreen/ui/home_screen.dart';
import 'package:ai_meal_planner/features/user_profile/ui/user_profile.dart';
import 'package:ai_meal_planner/l10n/l10n.dart';
import 'package:ai_meal_planner/routes/app_routes.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BottomNavScreen extends StatefulWidget {
  const BottomNavScreen({super.key});

  @override
  State<BottomNavScreen> createState() => _BottomNavScreenState();
}

class _BottomNavScreenState extends State<BottomNavScreen> {
  int _currentIndex = 0;
  final Set<int> _animatedTabs = {0};

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeScreen(playEntranceAnimation: _animatedTabs.contains(0)),
      AuthGate(
        authenticatedBuilder: (_) =>
            DietPlanScreen(playEntranceAnimation: _animatedTabs.contains(1)),
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
      AiChatScreen(playEntranceAnimation: _animatedTabs.contains(2)),
      AuthGate(
        authenticatedBuilder: (_) =>
            UserProfileScreen(playEntranceAnimation: _animatedTabs.contains(3)),
        guestBuilder: (context) => Scaffold(
          backgroundColor: AppColors.backgroundMainOf(context),
          appBar: AppBar(
            backgroundColor: AppColors.backgroundMainOf(context),
            surfaceTintColor: AppColors.backgroundMainOf(context),
            scrolledUnderElevation: 0,
            elevation: 0,
            automaticallyImplyLeading: false,
            leading: const SizedBox.shrink(),
            titleSpacing: 5,
            centerTitle: false,
            title: Align(
              alignment: Alignment.centerLeft,
              child: Column(
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
    ];

    final items = [
      BottomNavItemData(context.l10n.navHome, FontAwesomeIcons.house),
      BottomNavItemData(context.l10n.navPlan, FontAwesomeIcons.utensils),
      BottomNavItemData('AI Chat', FontAwesomeIcons.commentDots),
      BottomNavItemData(context.l10n.navProfile, FontAwesomeIcons.user),
    ];

    return Scaffold(
      backgroundColor: AppColors.backgroundSecondaryOf(context),
      extendBody: true,
      body: IndexedStack(index: _currentIndex, children: screens),
      bottomNavigationBar: BottomNavBar(
        items: items,
        currentIndex: _currentIndex,
        onItemTap: (index) => setState(() {
          _currentIndex = index;
          _animatedTabs.add(index);
        }),
      ),
    );
  }
}
