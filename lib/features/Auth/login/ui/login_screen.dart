import 'package:ai_meal_planner/core/constants/app_colors.dart';
import 'package:ai_meal_planner/core/utils/app_snackbar.dart';
import 'package:ai_meal_planner/features/Auth/login/widgets/login_auth_card.dart';
import 'package:ai_meal_planner/features/Auth/login/widgets/login_guest_mode_action.dart';
import 'package:ai_meal_planner/features/Auth/login/widgets/login_hero_section.dart';
import 'package:ai_meal_planner/l10n/l10n.dart';
import 'package:ai_meal_planner/shared/widgets/auth_background_decor.dart';
import 'package:ai_meal_planner/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleEmailLogin() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSubmitting = true);
    await Future<void>.delayed(const Duration(milliseconds: 600));

    if (!mounted) {
      return;
    }

    setState(() => _isSubmitting = false);
    Get.offAllNamed(AppRoutes.bottomNav);
    AppSnackbar.success(
      context.l10n.welcomeBackTitle,
      context.l10n.mealPlannerReadyMessage,
    );
  }

  Future<void> _handleGoogleLogin() async {
    FocusScope.of(context).unfocus();

    setState(() => _isSubmitting = true);
    await Future<void>.delayed(const Duration(milliseconds: 500));

    if (!mounted) {
      return;
    }

    setState(() => _isSubmitting = false);
    Get.offAllNamed(AppRoutes.bottomNav);
    AppSnackbar.info(
      context.l10n.googleSignInTitle,
      context.l10n.googleSignInMessage,
    );
  }

  void _continueAsGuest() {
    FocusScope.of(context).unfocus();
    Get.offAllNamed(AppRoutes.bottomNav);
  }

  void _signup() {
    FocusScope.of(context).unfocus();
    Get.toNamed(AppRoutes.signup);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundMainOf(context),
      body: Stack(
        children: [
          const AuthBackgroundDecor(),
          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 0.h),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: 1.sh - 40.h),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const LoginHeroSection(),
                      5.h.verticalSpace,
                      LoginAuthCard(
                        formKey: _formKey,
                        emailController: _emailController,
                        passwordController: _passwordController,
                        obscurePassword: _obscurePassword,
                        isSubmitting: _isSubmitting,
                        onTogglePasswordVisibility: () {
                          setState(() => _obscurePassword = !_obscurePassword);
                        },
                        onEmailLogin: _handleEmailLogin,
                        onGoogleLogin: _handleGoogleLogin,
                        onSignup: _signup,
                      ),
                      5.h.verticalSpace,
                      LoginGuestModeAction(
                        onPressed: _continueAsGuest,
                        isSubmitting: _isSubmitting,
                      ),
                      const Spacer(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
