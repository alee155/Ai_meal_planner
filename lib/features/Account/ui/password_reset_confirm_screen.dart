import 'package:ai_meal_planner/core/constants/app_colors.dart';
import 'package:ai_meal_planner/core/theme/app_text_styles.dart';
import 'package:ai_meal_planner/core/utils/app_snackbar.dart';
import 'package:ai_meal_planner/core/utils/app_validators.dart';
import 'package:ai_meal_planner/features/Account/controller/account_controller.dart';
import 'package:ai_meal_planner/features/Account/models/reset_password_confirm_arguments.dart';
import 'package:ai_meal_planner/features/Auth/otp/widgets/otp_digit_field.dart';
import 'package:ai_meal_planner/routes/app_routes.dart';
import 'package:ai_meal_planner/shared/widgets/app_filled_button.dart';
import 'package:ai_meal_planner/shared/widgets/app_icon_back_button.dart';
import 'package:ai_meal_planner/shared/widgets/app_text_form_field.dart';
import 'package:ai_meal_planner/shared/widgets/auth_background_decor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class PasswordResetConfirmScreen extends StatefulWidget {
  const PasswordResetConfirmScreen({super.key});

  @override
  State<PasswordResetConfirmScreen> createState() =>
      _PasswordResetConfirmScreenState();
}

class _PasswordResetConfirmScreenState
    extends State<PasswordResetConfirmScreen> {
  static const int _otpLength = 6;

  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final AccountController _accountController =
      AccountController.ensureRegistered();

  late final List<TextEditingController> _otpControllers;
  late final List<FocusNode> _focusNodes;
  late final String _email;

  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final argument = Get.arguments;
    _email = argument is ResetPasswordConfirmArguments ? argument.email : '';
    _otpControllers = List.generate(_otpLength, (_) => TextEditingController());
    _focusNodes = List.generate(_otpLength, (_) => FocusNode());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _focusNodes.first.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    for (final controller in _otpControllers) {
      controller.dispose();
    }
    for (final node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  bool get _isCodeComplete =>
      _otpControllers.every((controller) => controller.text.isNotEmpty);

  String get _otpCode =>
      _otpControllers.map((controller) => controller.text).join();

  void _onCodeChanged(int index, String value) {
    final digits = _normalizeDigits(value);
    if (digits.isEmpty) {
      _otpControllers[index].clear();
      if (index > 0) {
        _focusNodes[index - 1].requestFocus();
      }
      setState(() {});
      return;
    }

    if (digits.length > 1) {
      var targetIndex = index;
      for (final digit in digits.split('')) {
        if (targetIndex >= _otpLength) {
          break;
        }
        _otpControllers[targetIndex].text = digit;
        _otpControllers[targetIndex].selection = const TextSelection.collapsed(
          offset: 1,
        );
        targetIndex++;
      }

      if (targetIndex < _otpLength) {
        _focusNodes[targetIndex].requestFocus();
      } else {
        _focusNodes.last.unfocus();
      }
      setState(() {});
      return;
    }

    _otpControllers[index].text = digits;
    _otpControllers[index].selection = const TextSelection.collapsed(offset: 1);

    if (index < _otpLength - 1) {
      _focusNodes[index + 1].requestFocus();
    } else {
      _focusNodes[index].unfocus();
    }

    setState(() {});
  }

  String _normalizeDigits(String value) {
    const easternArabicDigits = '٠١٢٣٤٥٦٧٨٩';
    const persianDigits = '۰۱۲۳۴۵۶۷۸۹';
    final buffer = StringBuffer();

    for (final char in value.split('')) {
      final easternArabicIndex = easternArabicDigits.indexOf(char);
      if (easternArabicIndex >= 0) {
        buffer.write(easternArabicIndex);
        continue;
      }

      final persianIndex = persianDigits.indexOf(char);
      if (persianIndex >= 0) {
        buffer.write(persianIndex);
        continue;
      }

      if (RegExp(r'[0-9]').hasMatch(char)) {
        buffer.write(char);
      }
    }

    return buffer.toString();
  }

  Future<void> _resetPassword() async {
    FocusScope.of(context).unfocus();

    if (_email.trim().isEmpty) {
      AppSnackbar.error('Missing email', 'Please request a reset code again.');
      return;
    }

    if (!_isCodeComplete) {
      AppSnackbar.warning(
        'Enter complete code',
        'Please enter the full 6-digit reset code.',
      );
      return;
    }

    final newPasswordError = AppValidators.requiredPassword(
      _newPasswordController.text,
    );
    final confirmPasswordError = AppValidators.confirmPassword(
      _confirmPasswordController.text,
      originalPassword: _newPasswordController.text,
    );

    if (newPasswordError != null || confirmPasswordError != null) {
      AppSnackbar.error(
        'Check your password',
        newPasswordError ?? confirmPasswordError!,
      );
      return;
    }

    setState(() => _isSubmitting = true);
    final result = await _accountController.confirmPasswordReset(
      email: _email,
      otp: _otpCode,
      newPassword: _newPasswordController.text,
    );
    if (!mounted) {
      return;
    }

    setState(() => _isSubmitting = false);
    if (result.isSuccess) {
      Get.offAllNamed(AppRoutes.login, arguments: _email);
      AppSnackbar.success('Password reset', result.message);
      return;
    }

    AppSnackbar.error('Unable to reset password', result.message);
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
                    'Set a new password',
                    style: AppTextStyles.display(context, fontSize: 30),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Enter the reset code sent to $_email and choose a new password.',
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Verify and update',
                          style: AppTextStyles.headline(context, fontSize: 22),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'Paste the 6-digit code or type it manually.',
                          style: AppTextStyles.body(context),
                        ),
                        SizedBox(height: 20.h),
                        Row(
                          children: List.generate(_otpLength * 2 - 1, (
                            itemIndex,
                          ) {
                            if (itemIndex.isOdd) {
                              return SizedBox(width: 8.w);
                            }

                            final index = itemIndex ~/ 2;
                            return Expanded(
                              child: OtpDigitField(
                                controller: _otpControllers[index],
                                focusNode: _focusNodes[index],
                                autofocus: index == 0,
                                onChanged: (value) =>
                                    _onCodeChanged(index, value),
                              ),
                            );
                          }),
                        ),
                        SizedBox(height: 18.h),
                        AppTextFormField(
                          controller: _newPasswordController,
                          hintText: 'New password',
                          prefixIcon: Icons.lock_outline_rounded,
                          obscureText: _obscureNewPassword,
                          suffixIcon: IconButton(
                            onPressed: () => setState(
                              () => _obscureNewPassword = !_obscureNewPassword,
                            ),
                            icon: Icon(
                              _obscureNewPassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: AppColors.textSecondaryOf(context),
                            ),
                          ),
                        ),
                        SizedBox(height: 12.h),
                        AppTextFormField(
                          controller: _confirmPasswordController,
                          hintText: 'Confirm new password',
                          prefixIcon: Icons.lock_outline_rounded,
                          obscureText: _obscureConfirmPassword,
                          suffixIcon: IconButton(
                            onPressed: () => setState(
                              () => _obscureConfirmPassword =
                                  !_obscureConfirmPassword,
                            ),
                            icon: Icon(
                              _obscureConfirmPassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: AppColors.textSecondaryOf(context),
                            ),
                          ),
                        ),
                        SizedBox(height: 22.h),
                        AppFilledButton(
                          label: 'Reset password',
                          onPressed: _resetPassword,
                          backgroundColor: AppColors.primaryGreenDark,
                          foregroundColor: AppColors.textWhite,
                          isLoading: _isSubmitting,
                        ),
                      ],
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
