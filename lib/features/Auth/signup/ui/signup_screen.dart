import 'package:ai_meal_planner/core/constants/app_colors.dart';
import 'package:ai_meal_planner/core/utils/app_snackbar.dart';
import 'package:ai_meal_planner/features/Auth/otp/models/otp_screen_arguments.dart';
import 'package:ai_meal_planner/features/Auth/signup/controller/signup_controller.dart';
import 'package:ai_meal_planner/features/Auth/signup/widgets/signup_auth_card.dart';

import 'package:ai_meal_planner/features/Auth/signup/widgets/signup_hero_section.dart';
import 'package:ai_meal_planner/features/Auth/signup/widgets/signup_top_bar.dart';
import 'package:ai_meal_planner/l10n/l10n.dart';
import 'package:ai_meal_planner/routes/app_routes.dart';
import 'package:ai_meal_planner/shared/widgets/auth_background_decor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final SignupController _signupController =
      SignupController.ensureRegistered();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    final l10n = context.l10n;
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final result = await _signupController.registerUser(
      name: _nameController.text,
      email: _emailController.text,
      password: _passwordController.text,
    );

    if (!mounted) {
      return;
    }

    if (result.isSuccess) {
      Get.toNamed(
        AppRoutes.otp,
        arguments: OtpScreenArguments(
          email: result.email ?? _emailController.text.trim(),
        ),
      );
      AppSnackbar.success(l10n.accountCreatedTitle, result.message);
      return;
    }

    AppSnackbar.error('Signup failed', result.message);
  }

  Future<void> _handleGoogleSignup() async {
    final l10n = context.l10n;
    FocusScope.of(context).unfocus();

    _signupController.isSubmitting.value = true;
    await Future<void>.delayed(const Duration(milliseconds: 500));

    if (!mounted) {
      _signupController.isSubmitting.value = false;
      return;
    }

    _signupController.isSubmitting.value = false;
    Get.offAllNamed(AppRoutes.login);
    AppSnackbar.info(l10n.googleSignUpTitle, l10n.googleSignUpMessage);
  }

  void _goBack() {
    FocusScope.of(context).unfocus();
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isSubmitting = _signupController.isSubmitting.value;

      return Scaffold(
        backgroundColor: AppColors.backgroundMainOf(context),
        body: Stack(
          children: [
            const AuthBackgroundDecor(),
            SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 0.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SignupTopBar(
                      onBackTap: _goBack,
                      isSubmitting: isSubmitting,
                    ),
                    10.h.verticalSpace,
                    const SignupHeroSection(),
                    10.h.verticalSpace,
                    SignupAuthCard(
                      formKey: _formKey,
                      nameController: _nameController,
                      emailController: _emailController,
                      passwordController: _passwordController,
                      confirmPasswordController: _confirmPasswordController,
                      obscurePassword: _obscurePassword,
                      obscureConfirmPassword: _obscureConfirmPassword,
                      isSubmitting: isSubmitting,
                      onTogglePasswordVisibility: () {
                        setState(() => _obscurePassword = !_obscurePassword);
                      },
                      onToggleConfirmPasswordVisibility: () {
                        setState(
                          () => _obscureConfirmPassword =
                              !_obscureConfirmPassword,
                        );
                      },
                      onSignup: _handleSignup,
                      onGoogleSignup: _handleGoogleSignup,
                      onSignIn: _goBack,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}
