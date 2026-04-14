import 'package:ai_meal_planner/core/auth/controller/auth_session_controller.dart';
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
  final AuthSessionController _authSessionController =
      AuthSessionController.ensureRegistered();

  @override
  void initState() {
    super.initState();
    _bootstrapSession();
  }

  Future<void> _bootstrapSession() async {
    await Future.wait<void>([
      _authSessionController.bootstrapSession(),
      Future<void>.delayed(const Duration(milliseconds: 1800)),
    ]);

    if (!mounted) {
      return;
    }

    Get.offAllNamed(_resolveNextRoute());
  }

  String _resolveNextRoute() {
    return _authSessionController.isLoggedIn
        ? AppRoutes.bottomNav
        : AppRoutes.login;
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
