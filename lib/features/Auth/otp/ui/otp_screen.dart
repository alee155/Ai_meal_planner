import 'package:ai_meal_planner/core/animations/app_animations.dart';
import 'package:ai_meal_planner/core/constants/app_colors.dart';
import 'package:ai_meal_planner/core/theme/app_text_styles.dart';
import 'package:ai_meal_planner/core/utils/app_snackbar.dart';
import 'package:ai_meal_planner/features/Auth/otp/widgets/otp_digit_field.dart';
import 'package:ai_meal_planner/features/Auth/otp/widgets/otp_info_card.dart';

import 'package:ai_meal_planner/shared/widgets/app_filled_button.dart';
import 'package:ai_meal_planner/shared/widgets/app_icon_back_button.dart';
import 'package:ai_meal_planner/shared/widgets/auth_background_decor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key, this.destination = 'demo@aimealplanner.app'});

  final String destination;

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  static const int _otpLength = 4;

  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(_otpLength, (_) => TextEditingController());
    _focusNodes = List.generate(_otpLength, (_) => FocusNode());

    for (final node in _focusNodes) {
      node.addListener(_handleFocusChange);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _focusNodes.first.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final node in _focusNodes) {
      node
        ..removeListener(_handleFocusChange)
        ..dispose();
    }
    super.dispose();
  }

  void _handleFocusChange() {
    if (mounted) {
      setState(() {});
    }
  }

  String get _code => _controllers.map((controller) => controller.text).join();

  bool get _isCodeComplete =>
      _controllers.every((controller) => controller.text.isNotEmpty);

  void _onCodeChanged(int index, String value) {
    final digits = value.replaceAll(RegExp(r'[^0-9]'), '');

    if (digits.isEmpty) {
      _controllers[index].clear();
      if (index > 0) {
        _focusNodes[index - 1].requestFocus();
      }
      setState(() {});
      return;
    }

    if (digits.length > 1) {
      _fillCodeFrom(index, digits);
      return;
    }

    _controllers[index].text = digits;
    _controllers[index].selection = const TextSelection.collapsed(offset: 1);

    if (index < _otpLength - 1) {
      _focusNodes[index + 1].requestFocus();
    } else {
      _focusNodes[index].unfocus();
    }

    setState(() {});
  }

  void _fillCodeFrom(int startIndex, String digits) {
    var targetIndex = startIndex;

    for (final digit in digits.split('')) {
      if (targetIndex >= _otpLength) {
        break;
      }

      _controllers[targetIndex].text = digit;
      _controllers[targetIndex].selection = const TextSelection.collapsed(
        offset: 1,
      );
      targetIndex++;
    }

    if (targetIndex >= _otpLength) {
      _focusNodes.last.unfocus();
    } else {
      _focusNodes[targetIndex].requestFocus();
    }

    setState(() {});
  }

  void _clearCode() {
    for (final controller in _controllers) {
      controller.clear();
    }
    _focusNodes.first.requestFocus();
    setState(() {});
  }

  Future<void> _verifyCode() async {
    FocusScope.of(context).unfocus();

    if (!_isCodeComplete) {
      AppSnackbar.warning(
        'Enter complete code',
        'Please enter the full 4-digit verification code.',
      );
      return;
    }

    setState(() => _isSubmitting = true);
    await Future<void>.delayed(const Duration(milliseconds: 700));

    if (!mounted) {
      return;
    }

    setState(() => _isSubmitting = false);
    AppSnackbar.success(
      'Code verified',
      'OTP $_code verified in this demo screen.',
    );
  }

  void _resendCode() {
    FocusScope.of(context).unfocus();
    _clearCode();
    AppSnackbar.info(
      'Code resent',
      'A new verification code has been sent to ${widget.destination}.',
    );
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
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: 1.sh - 40.h),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [AppIconBackButton(onTap: Get.back)],
                      ).animateAuthAction(
                        delay: AppMotion.stagger(0, initialMs: 80),
                      ),
                      SizedBox(height: 20.h),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 8.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primarylightGreen,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          'Secure Verification',
                          style: AppTextStyles.label(
                            context,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryGreenDark,
                          ),
                        ),
                      ).animateAuthChip(delay: AppMotion.stagger(1)),
                      SizedBox(height: 14.h),
                      Text(
                        'Enter your\nOTP code.',
                        style: AppTextStyles.display(context, height: 1.08),
                      ).animateAuthContent(
                        delay: AppMotion.stagger(2, initialMs: 120),
                        begin: 0.12,
                      ),
                      SizedBox(height: 10.h),
                      Text(
                        'Use the verification code we just sent to confirm access to your account.',
                        style: AppTextStyles.body(
                          context,
                          fontSize: 15,
                          height: 1.6,
                        ),
                      ).animateAuthContent(
                        delay: AppMotion.stagger(3, initialMs: 140),
                        begin: 0.1,
                      ),
                      SizedBox(height: 18.h),
                      OtpInfoCard(
                        destination: widget.destination,
                        onChangeTap: Get.back,
                      ).animateAuthCard(
                        delay: AppMotion.stagger(4, initialMs: 120),
                      ),
                      SizedBox(height: 18.h),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(22.w),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceOf(
                            context,
                          ).withValues(alpha: 0.95),
                          borderRadius: BorderRadius.circular(28.r),
                          border: Border.all(
                            color: AppColors.borderOf(context),
                          ),
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
                              '4-digit verification code',
                              style: AppTextStyles.headline(
                                context,
                                fontSize: 22,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              'Enter the code below. You can also paste it into the first box.',
                              style: AppTextStyles.body(context, height: 1.5),
                            ),
                            SizedBox(height: 20.h),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: List.generate(
                                _otpLength,
                                (index) => OtpDigitField(
                                  controller: _controllers[index],
                                  focusNode: _focusNodes[index],
                                  autofocus: index == 0,
                                  onChanged: (value) =>
                                      _onCodeChanged(index, value),
                                ),
                              ),
                            ),
                            SizedBox(height: 14.h),
                            Center(
                              child: Text(
                                _isCodeComplete
                                    ? 'Code looks good. You can verify now.'
                                    : 'Code expires soon. Enter all 4 digits to continue.',
                                style: AppTextStyles.caption(
                                  context,
                                  fontSize: 12,
                                  color: _isCodeComplete
                                      ? AppColors.primaryGreenDark
                                      : AppColors.textSecondaryOf(context),
                                ),
                              ),
                            ),
                            SizedBox(height: 20.h),
                            AppFilledButton(
                              label: 'Verify code',
                              onPressed: _verifyCode,
                              backgroundColor: AppColors.buttonPrimary,
                              foregroundColor: AppColors.textWhite,
                              isLoading: _isSubmitting,
                              fontSize: 16,
                            ),
                            SizedBox(height: 14.h),
                            Center(
                              child: Wrap(
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  Text(
                                    "Didn't receive it?",
                                    style: AppTextStyles.body(
                                      context,
                                      fontSize: 14,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: _isSubmitting
                                        ? null
                                        : _resendCode,
                                    style: TextButton.styleFrom(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 6.w,
                                      ),
                                      minimumSize: Size.zero,
                                      tapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    child: Text(
                                      'Resend code',
                                      style: AppTextStyles.button(
                                        context,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.primaryGreenDark,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ).animateAuthCard(
                        delay: AppMotion.stagger(5, initialMs: 120),
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
