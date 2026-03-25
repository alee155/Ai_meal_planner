import 'package:ai_meal_planner/core/constants/app_colors.dart';
import 'package:ai_meal_planner/core/theme/app_text_styles.dart';
import 'package:ai_meal_planner/core/utils/app_validators.dart';
import 'package:ai_meal_planner/shared/widgets/app_filled_button.dart';
import 'package:ai_meal_planner/shared/widgets/app_outlined_button.dart';
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
              'Create account',
              style: AppTextStyles.headline(context, fontSize: 22),
            ),
            3.h.verticalSpace,
            Text(
              'Start with a few details and let the app tailor your nutrition journey.',
              style: AppTextStyles.body(context, height: 1.5),
            ),
            10.h.verticalSpace,
            const _SignupSectionLabel(label: 'Full Name'),
            3.h.verticalSpace,
            AppTextFormField(
              controller: nameController,
              textCapitalization: TextCapitalization.words,
              autofillHints: const [AutofillHints.name],
              hintText: 'Enter your full name',
              prefixIcon: Icons.person_outline_rounded,
              validator: AppValidators.requiredFullName,
            ),
            10.h.verticalSpace,
            const _SignupSectionLabel(label: 'Email'),
            3.h.verticalSpace,
            AppTextFormField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              autofillHints: const [AutofillHints.email],
              hintText: 'Enter your email',
              prefixIcon: Icons.mail_outline_rounded,
              validator: AppValidators.requiredEmail,
            ),
            10.h.verticalSpace,
            const _SignupSectionLabel(label: 'Password'),
            3.h.verticalSpace,
            AppTextFormField(
              controller: passwordController,
              obscureText: obscurePassword,
              autofillHints: const [AutofillHints.newPassword],
              hintText: 'Create a password',
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
              validator: AppValidators.requiredPassword,
            ),
            10.h.verticalSpace,
            const _SignupSectionLabel(label: 'Confirm Password'),
            3.h.verticalSpace,
            AppTextFormField(
              controller: confirmPasswordController,
              obscureText: obscureConfirmPassword,
              autofillHints: const [AutofillHints.newPassword],
              hintText: 'Confirm your password',
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
              ),
            ),
            15.h.verticalSpace,
            AppFilledButton(
              label: 'Create Account',
              onPressed: onSignup,
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
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  child: Text(
                    'or',
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
              onPressed: isSubmitting ? null : onGoogleSignup,
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
                    'Sign up with Google',
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            10.h.verticalSpace,
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Already have an account?',
                  style: AppTextStyles.body(context, fontSize: 14),
                ),
                TextButton(
                  onPressed: isSubmitting ? null : onSignIn,
                  child: Text(
                    'Sign In',
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
