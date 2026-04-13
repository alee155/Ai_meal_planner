import 'package:ai_meal_planner/core/constants/app_colors.dart';
import 'package:ai_meal_planner/core/utils/app_snackbar.dart';
import 'package:ai_meal_planner/features/Auth/login/controller/login_controller.dart';
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
  final LoginController _loginController = LoginController.ensureRegistered();

  bool _obscurePassword = true;

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

    final result = await _loginController.loginUser(
      email: _emailController.text,
      password: _passwordController.text,
    );

    if (!mounted) {
      return;
    }

    if (result.isSuccess) {
      Get.offAllNamed(AppRoutes.bottomNav);
      AppSnackbar.success(context.l10n.welcomeBackTitle, result.message);
      return;
    }

    AppSnackbar.error('Login failed', result.message);
  }

  Future<void> _handleGoogleLogin() async {
    FocusScope.of(context).unfocus();

    _loginController.isSubmitting.value = true;
    await Future<void>.delayed(const Duration(milliseconds: 500));

    if (!mounted) {
      _loginController.isSubmitting.value = false;
      return;
    }

    _loginController.isSubmitting.value = false;
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
    return Obx(() {
      final isSubmitting = _loginController.isSubmitting.value;

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
                          isSubmitting: isSubmitting,
                          onTogglePasswordVisibility: () {
                            setState(
                              () => _obscurePassword = !_obscurePassword,
                            );
                          },
                          onEmailLogin: _handleEmailLogin,
                          onGoogleLogin: _handleGoogleLogin,
                          onSignup: _signup,
                        ),
                        5.h.verticalSpace,
                        LoginGuestModeAction(
                          onPressed: _continueAsGuest,
                          isSubmitting: isSubmitting,
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
    });
  }
}
