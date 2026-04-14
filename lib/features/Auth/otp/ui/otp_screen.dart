import 'package:ai_meal_planner/core/animations/app_animations.dart';
import 'package:ai_meal_planner/core/constants/app_colors.dart';
import 'package:ai_meal_planner/core/theme/app_text_styles.dart';
import 'package:ai_meal_planner/core/utils/app_snackbar.dart';
import 'package:ai_meal_planner/features/Auth/otp/controller/otp_controller.dart';
import 'package:ai_meal_planner/features/Auth/otp/models/otp_screen_arguments.dart';
import 'package:ai_meal_planner/features/Auth/otp/widgets/otp_digit_field.dart';
import 'package:ai_meal_planner/features/Auth/otp/widgets/otp_info_card.dart';
import 'package:ai_meal_planner/l10n/l10n.dart';
import 'package:ai_meal_planner/routes/app_routes.dart';
import 'package:ai_meal_planner/shared/widgets/app_filled_button.dart';
import 'package:ai_meal_planner/shared/widgets/app_icon_back_button.dart';
import 'package:ai_meal_planner/shared/widgets/auth_background_decor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key, this.arguments});

  final OtpScreenArguments? arguments;

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  static const int _otpLength = 6;

  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;
  late final OtpController _otpController;
  late final OtpScreenArguments _arguments;

  @override
  void initState() {
    super.initState();
    _otpController = OtpController.ensureRegistered();
    final routeArguments = Get.arguments;
    _arguments =
        widget.arguments ??
        (routeArguments is OtpScreenArguments
            ? routeArguments
            : const OtpScreenArguments(email: ''));
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
    final digits = _normalizeDigits(value);

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

    if (_arguments.email.trim().isEmpty) {
      AppSnackbar.error(
        'Missing email',
        'Please register again to verify your account.',
      );
      return;
    }

    if (!_isCodeComplete) {
      AppSnackbar.warning(
        context.l10n.enterCompleteCodeTitle,
        context.l10n.enterCompleteCodeMessage,
      );
      return;
    }

    final result = await _otpController.verifyOtp(
      email: _arguments.email,
      otp: _code,
    );

    if (!mounted) {
      return;
    }

    if (result.isSuccess) {
      Get.offAllNamed(AppRoutes.login, arguments: _arguments.email);
      AppSnackbar.success(context.l10n.codeVerifiedTitle, result.message);
      return;
    }

    AppSnackbar.error('Verification failed', result.message);
  }

  Future<void> _resendCode() async {
    FocusScope.of(context).unfocus();

    if (_arguments.email.trim().isEmpty) {
      AppSnackbar.error(
        'Missing email',
        'Please register again to request a new code.',
      );
      return;
    }

    final result = await _otpController.resendOtp(email: _arguments.email);

    if (!mounted) {
      return;
    }

    if (!result.isSuccess) {
      AppSnackbar.error('Unable to resend code', result.message);
      return;
    }

    _clearCode();
    AppSnackbar.info(context.l10n.codeResentTitle, result.message);
  }

  @override
  Widget build(BuildContext context) {
    final destination = _arguments.email.trim().isEmpty
        ? 'your email address'
        : _arguments.email;

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
                          context.l10n.secureVerification,
                          style: AppTextStyles.label(
                            context,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryGreenDark,
                          ),
                        ),
                      ).animateAuthChip(delay: AppMotion.stagger(1)),
                      SizedBox(height: 14.h),
                      Text(
                        context.l10n.enterOtpCode,
                        style: AppTextStyles.display(context, height: 1.08),
                      ).animateAuthContent(
                        delay: AppMotion.stagger(2, initialMs: 120),
                        begin: 0.12,
                      ),
                      SizedBox(height: 10.h),
                      Text(
                        context.l10n.otpIntroDescription,
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
                        destination: destination,
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
                              context.l10n.verificationCodeTitle,
                              style: AppTextStyles.headline(
                                context,
                                fontSize: 22,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              context.l10n.otpPasteHint,
                              style: AppTextStyles.body(context, height: 1.5),
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
                                    controller: _controllers[index],
                                    focusNode: _focusNodes[index],
                                    autofocus: index == 0,
                                    onChanged: (value) =>
                                        _onCodeChanged(index, value),
                                  ),
                                );
                              }),
                            ),
                            SizedBox(height: 14.h),
                            Center(
                              child: Text(
                                _isCodeComplete
                                    ? context.l10n.otpReadyStatus
                                    : context.l10n.otpPendingStatus,
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
                            Obx(() {
                              final isBusy =
                                  _otpController.isVerifying.value ||
                                  _otpController.isResending.value;

                              return Column(
                                children: [
                                  AppFilledButton(
                                    label: context.l10n.verifyCode,
                                    onPressed: _verifyCode,
                                    backgroundColor: AppColors.buttonPrimary,
                                    foregroundColor: AppColors.textWhite,
                                    isLoading: _otpController.isVerifying.value,
                                    fontSize: 16,
                                  ),
                                  SizedBox(height: 14.h),
                                  Center(
                                    child: Wrap(
                                      crossAxisAlignment:
                                          WrapCrossAlignment.center,
                                      children: [
                                        Text(
                                          context.l10n.didntReceiveIt,
                                          style: AppTextStyles.body(
                                            context,
                                            fontSize: 14,
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: isBusy
                                              ? null
                                              : _resendCode,
                                          style: TextButton.styleFrom(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 6.w,
                                            ),
                                            minimumSize: Size.zero,
                                            tapTargetSize: MaterialTapTargetSize
                                                .shrinkWrap,
                                          ),
                                          child: Text(
                                            context.l10n.resendCode,
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
                              );
                            }),
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
