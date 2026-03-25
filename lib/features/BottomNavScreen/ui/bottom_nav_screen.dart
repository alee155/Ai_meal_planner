import 'package:ai_meal_planner/core/constants/app_colors.dart';
import 'package:ai_meal_planner/features/BottomNavScreen/widget/bottom_nav_bar.dart';
import 'package:ai_meal_planner/features/BottomNavScreen/widget/bottom_nav_item_data.dart';
import 'package:ai_meal_planner/features/DietPlanScreen/ui/diet_plan_screen.dart';
import 'package:ai_meal_planner/features/HomeScreen/ui/home_screen.dart';
import 'package:ai_meal_planner/features/SettingScreen/ui/settings_screen.dart';
import 'package:ai_meal_planner/features/user_profile/ui/user_profile.dart';
import 'package:ai_meal_planner/l10n/l10n.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';

class BottomNavScreen extends StatefulWidget {
  const BottomNavScreen({super.key});

  @override
  State<BottomNavScreen> createState() => _BottomNavScreenState();
}

class _BottomNavScreenState extends State<BottomNavScreen> {
  int _currentIndex = 0;
  final Set<int> _animatedTabs = {0};

  List<Widget> get _screens => [
    HomeScreen(playEntranceAnimation: _animatedTabs.contains(0)),
    DietPlanScreen(playEntranceAnimation: _animatedTabs.contains(1)),
    UserProfileScreen(playEntranceAnimation: _animatedTabs.contains(2)),
    SettingsScreen(
      showBackButton: false,
      playEntranceAnimation: _animatedTabs.contains(3),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final items = [
      BottomNavItemData(context.l10n.navHome, FontAwesomeIcons.house),
      BottomNavItemData(context.l10n.navPlan, FontAwesomeIcons.utensils),
      BottomNavItemData(context.l10n.navProfile, FontAwesomeIcons.user),
      BottomNavItemData(context.l10n.navSettings, FontAwesomeIcons.gear),
    ];

    return Scaffold(
      backgroundColor: AppColors.backgroundSecondaryOf(context),
      extendBody: true,
      body: IndexedStack(index: _currentIndex, children: _screens),
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
