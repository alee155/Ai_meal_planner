import 'package:ai_meal_planner/core/animations/app_animations.dart';
import 'package:ai_meal_planner/core/constants/app_colors.dart';
import 'package:ai_meal_planner/core/theme/app_text_styles.dart';
import 'package:ai_meal_planner/core/utils/app_validators.dart';
import 'package:ai_meal_planner/l10n/l10n.dart';
import 'package:ai_meal_planner/shared/widgets/app_filled_button.dart';
import 'package:ai_meal_planner/shared/widgets/app_outlined_button.dart';
import 'package:ai_meal_planner/shared/widgets/app_text_form_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LoginAuthCard extends StatelessWidget {
  const LoginAuthCard({
    super.key,
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.obscurePassword,
    required this.isSubmitting,
    required this.onTogglePasswordVisibility,
    required this.onEmailLogin,
    required this.onGoogleLogin,
    required this.onForgotPassword,
    required this.onSignup,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool obscurePassword;
  final bool isSubmitting;
  final VoidCallback onTogglePasswordVisibility;
  final VoidCallback onEmailLogin;
  final VoidCallback onGoogleLogin;
  final VoidCallback onForgotPassword;
  final VoidCallback onSignup;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Container(
      padding: EdgeInsets.all(22.w),
      decoration: BoxDecoration(
        color: AppColors.surfaceOf(context).withValues(alpha: 0.95),
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
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.welcomeBack,
              style: AppTextStyles.headline(context, fontSize: 22),
            ),
            SizedBox(height: 3.h),
            Text(
              l10n.loginRoutineDescription,
              style: AppTextStyles.body(context),
            ),
            15.h.verticalSpace,
            _LoginSectionLabel(label: l10n.emailLabel),
            SizedBox(height: 3.h),
            AppTextFormField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              autofillHints: const [AutofillHints.email],
              hintText: l10n.enterEmailHint,
              prefixIcon: Icons.mail_outline_rounded,
              validator: (value) => AppValidators.requiredEmail(
                value,
                requiredMessage: l10n.emailRequired,
                invalidMessage: l10n.validEmailRequired,
              ),
            ),
            10.h.verticalSpace,
            _LoginSectionLabel(label: l10n.passwordLabel),
            SizedBox(height: 3.h),
            AppTextFormField(
              controller: passwordController,
              obscureText: obscurePassword,
              autofillHints: const [AutofillHints.password],
              hintText: l10n.enterPasswordHint,
              prefixIcon: Icons.lock_outline_rounded,
              suffixIcon: IconButton(
                onPressed: onTogglePasswordVisibility,
                icon: Icon(
                  obscurePassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: AppColors.textSecondaryOf(context),
                ),
              ),
              validator: (value) => AppValidators.requiredPassword(
                value,
                requiredMessage: l10n.passwordRequired,
                minLengthMessage: l10n.passwordMinLength,
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: isSubmitting ? null : onForgotPassword,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 4.h),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'Forgot password?',
                  style: AppTextStyles.button(
                    context,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryGreenDark,
                  ),
                ),
              ),
            ),
            20.h.verticalSpace,
            AppFilledButton(
              label: l10n.signIn,
              onPressed: onEmailLogin,
              backgroundColor: AppColors.buttonPrimary,
              foregroundColor: AppColors.textWhite,
              isLoading: isSubmitting,
              fontSize: 16,
            ),
            10.h.verticalSpace,
            Row(
              children: [
                Expanded(child: Divider(color: AppColors.dividerOf(context))),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Text(
                    l10n.or,
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: AppColors.textHintOf(context),
                    ),
                  ),
                ),
                Expanded(child: Divider(color: AppColors.dividerOf(context))),
              ],
            ),
            10.h.verticalSpace,
            AppOutlinedButton(
              onPressed: isSubmitting ? null : onGoogleLogin,
              foregroundColor: AppColors.textPrimaryOf(context),
              borderColor: AppColors.borderOf(context),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 24.w,
                    height: 24.w,
                    decoration: BoxDecoration(
                      color: AppColors.backgroundMainOf(context),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'G',
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimaryOf(context),
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Text(
                    l10n.signInWithGoogle,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            14.h.verticalSpace,
            Center(
              child: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    l10n.dontHaveAccount,
                    style: AppTextStyles.body(
                      context,
                      fontSize: 14,
                      color: AppColors.textSecondaryOf(context),
                    ),
                  ),
                  TextButton(
                    onPressed: isSubmitting ? null : onSignup,
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 6.w),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      l10n.createAccount,
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
      ),
    ).animateAuthCard(delay: AppMotion.stagger(4, initialMs: 110));
  }
}

class _LoginSectionLabel extends StatelessWidget {
  const _LoginSectionLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: AppTextStyles.title(
        context,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
