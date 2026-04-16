import 'package:ai_meal_planner/core/constants/app_colors.dart';
import 'package:ai_meal_planner/core/theme/app_text_styles.dart';
import 'package:ai_meal_planner/core/utils/app_validators.dart';
import 'package:ai_meal_planner/l10n/l10n.dart';
import 'package:ai_meal_planner/shared/widgets/app_filled_button.dart';
import 'package:ai_meal_planner/shared/widgets/app_text_form_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SignupAuthCard extends StatelessWidget {
  const SignupAuthCard({
    super.key,
    required this.formKey,
    required this.nameController,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.obscurePassword,
    required this.obscureConfirmPassword,
    required this.isSubmitting,
    required this.onTogglePasswordVisibility,
    required this.onToggleConfirmPasswordVisibility,
    required this.onSignup,
    required this.onGoogleSignup,
    required this.onSignIn,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final bool obscurePassword;
  final bool obscureConfirmPassword;
  final bool isSubmitting;
  final VoidCallback onTogglePasswordVisibility;
  final VoidCallback onToggleConfirmPasswordVisibility;
  final VoidCallback onSignup;
  final VoidCallback onGoogleSignup;
  final VoidCallback onSignIn;

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
              l10n.createAccountTitle,
              style: AppTextStyles.headline(context, fontSize: 22),
            ),
            3.h.verticalSpace,
            Text(
              l10n.signupDescription,
              style: AppTextStyles.body(context, height: 1.5),
            ),
            10.h.verticalSpace,
            _SignupSectionLabel(label: l10n.fullNameLabel),
            3.h.verticalSpace,
            AppTextFormField(
              controller: nameController,
              textCapitalization: TextCapitalization.words,
              autofillHints: const [AutofillHints.name],
              hintText: l10n.enterFullNameHint,
              prefixIcon: Icons.person_outline_rounded,
              validator: (value) => AppValidators.requiredFullName(
                value,
                requiredMessage: l10n.fullNameRequired,
                invalidMessage: l10n.enterFullName,
              ),
            ),
            10.h.verticalSpace,
            _SignupSectionLabel(label: l10n.emailLabel),
            3.h.verticalSpace,
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
            _SignupSectionLabel(label: l10n.passwordLabel),
            3.h.verticalSpace,
            AppTextFormField(
              controller: passwordController,
              obscureText: obscurePassword,
              autofillHints: const [AutofillHints.newPassword],
              hintText: l10n.createPasswordHint,
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
            10.h.verticalSpace,
            _SignupSectionLabel(label: l10n.confirmPasswordLabel),
            3.h.verticalSpace,
            AppTextFormField(
              controller: confirmPasswordController,
              obscureText: obscureConfirmPassword,
              autofillHints: const [AutofillHints.newPassword],
              hintText: l10n.confirmPasswordHint,
              prefixIcon: Icons.verified_user_outlined,
              suffixIcon: IconButton(
                onPressed: onToggleConfirmPasswordVisibility,
                icon: Icon(
                  obscureConfirmPassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: AppColors.textSecondaryOf(context),
                ),
              ),
              validator: (value) => AppValidators.confirmPassword(
                value,
                originalPassword: passwordController.text,
                requiredMessage: l10n.confirmYourPassword,
                mismatchMessage: l10n.passwordsDoNotMatch,
              ),
            ),
            15.h.verticalSpace,
            AppFilledButton(
              label: l10n.createAccountButton,
              onPressed: onSignup,
              backgroundColor: AppColors.buttonPrimary,
              foregroundColor: AppColors.textWhite,
              isLoading: isSubmitting,
              fontSize: 16,
            ),
          ],
        ),
      ),
    );
  }
}

class _SignupSectionLabel extends StatelessWidget {
  const _SignupSectionLabel({required this.label});

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
