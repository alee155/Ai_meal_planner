import 'package:ai_meal_planner/core/constants/app_colors.dart';
import 'package:ai_meal_planner/core/theme/app_text_styles.dart';
import 'package:ai_meal_planner/core/utils/app_snackbar.dart';
import 'package:ai_meal_planner/core/utils/app_validators.dart';
import 'package:ai_meal_planner/features/Account/controller/account_controller.dart';
import 'package:ai_meal_planner/features/Account/models/reset_password_confirm_arguments.dart';
import 'package:ai_meal_planner/routes/app_routes.dart';
import 'package:ai_meal_planner/shared/widgets/app_filled_button.dart';
import 'package:ai_meal_planner/shared/widgets/app_icon_back_button.dart';
import 'package:ai_meal_planner/shared/widgets/app_text_form_field.dart';
import 'package:ai_meal_planner/shared/widgets/auth_background_decor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class PasswordResetRequestScreen extends StatefulWidget {
  const PasswordResetRequestScreen({super.key});

  @override
  State<PasswordResetRequestScreen> createState() =>
      _PasswordResetRequestScreenState();
}

class _PasswordResetRequestScreenState
    extends State<PasswordResetRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final AccountController _accountController =
      AccountController.ensureRegistered();

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final argument = Get.arguments;
    if (argument is String && argument.trim().isNotEmpty) {
      _emailController.text = argument.trim();
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _requestResetCode() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSubmitting = true);
    final result = await _accountController.requestPasswordReset(
      email: _emailController.text,
    );
    if (!mounted) {
      return;
    }

    setState(() => _isSubmitting = false);
    if (result.isSuccess) {
      Get.toNamed(
        AppRoutes.resetPasswordConfirm,
        arguments: ResetPasswordConfirmArguments(
          email: _emailController.text.trim(),
        ),
      );
      AppSnackbar.success('Reset code sent', result.message);
      return;
    }

    AppSnackbar.error('Unable to send code', result.message);
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
              padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 28.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [AppIconBackButton(onTap: Get.back)]),
                  SizedBox(height: 24.h),
                  Text(
                    'Forgot your password?',
                    style: AppTextStyles.display(context, fontSize: 30),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Enter your account email and we will send a 6-digit reset code.',
                    style: AppTextStyles.body(
                      context,
                      fontSize: 15,
                      height: 1.6,
                    ),
                  ),
                  SizedBox(height: 22.h),
                  Container(
                    padding: EdgeInsets.all(22.w),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceOf(
                        context,
                      ).withValues(alpha: 0.95),
                      borderRadius: BorderRadius.circular(28.r),
                      border: Border.all(color: AppColors.borderOf(context)),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.shadowOf(context),
                          blurRadius: 30,
                          offset: const Offset(0, 14),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Reset request',
                            style: AppTextStyles.headline(
                              context,
                              fontSize: 22,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            'We will send a one-time code to your email address.',
                            style: AppTextStyles.body(context),
                          ),
                          SizedBox(height: 18.h),
                          Text(
                            'Email address',
                            style: AppTextStyles.title(context, fontSize: 14),
                          ),
                          SizedBox(height: 6.h),
                          AppTextFormField(
                            controller: _emailController,
                            hintText: 'Enter your email',
                            keyboardType: TextInputType.emailAddress,
                            prefixIcon: Icons.email_outlined,
                            validator: (value) =>
                                AppValidators.requiredEmail(value),
                          ),
                          SizedBox(height: 22.h),
                          AppFilledButton(
                            label: 'Send reset code',
                            onPressed: _requestResetCode,
                            backgroundColor: AppColors.primaryGreenDark,
                            foregroundColor: AppColors.textWhite,
                            isLoading: _isSubmitting,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
