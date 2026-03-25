import 'dart:async';

import 'package:ai_meal_planner/core/constants/app_colors.dart';
import 'package:ai_meal_planner/features/SplashScreen/widgets/splash_background_decor.dart';
import 'package:ai_meal_planner/features/SplashScreen/widgets/splash_brand_panel.dart';
import 'package:ai_meal_planner/features/SplashScreen/widgets/splash_loading_footer.dart';
import 'package:ai_meal_planner/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();
    _navigationTimer = Timer(
      const Duration(milliseconds: 1850),
      _navigateToInitialRoute,
    );
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    super.dispose();
  }

  void _navigateToInitialRoute() {
    if (!mounted) {
      return;
    }

    Get.offAllNamed(_resolveNextRoute());
  }

  String _resolveNextRoute() {
    return AppRoutes.bottomNav;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundMainOf(context),
      body: Stack(
        children: [
          const SplashBackgroundDecor(),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
              child: Column(
                children: [
                  const Spacer(flex: 2),
                  const SplashBrandPanel(),
                  const Spacer(),
                  const SplashLoadingFooter(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
