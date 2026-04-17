import 'package:ai_meal_planner/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppTextFormField extends StatelessWidget {
  const AppTextFormField({
    super.key,
    required this.controller,
    required this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.autofillHints,
    this.validator,
    this.textCapitalization = TextCapitalization.none,
    this.fillColor,
    this.focusedBorderColor,
    this.borderRadius = 18,
    this.horizontalPadding = 18,
    this.verticalPadding = 18,
  });

  final TextEditingController controller;
  final String hintText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final Iterable<String>? autofillHints;
  final String? Function(String?)? validator;
  final TextCapitalization textCapitalization;
  final Color? fillColor;
  final Color? focusedBorderColor;
  final double borderRadius;
  final double horizontalPadding;
  final double verticalPadding;

  @override
  Widget build(BuildContext context) {
    final resolvedBorderRadius = BorderRadius.circular(borderRadius.r);
    final resolvedBorderColor = AppColors.inputBorderOf(context);
    final resolvedFocusedColor =
        focusedBorderColor ?? AppColors.inputFocusedBorder;

    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      autofillHints: autofillHints,
      validator: validator,
      textCapitalization: textCapitalization,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          color: AppColors.textHintOf(context),
          fontSize: 14.sp,
        ),
        filled: true,
        fillColor: fillColor ?? AppColors.inputBackgroundOf(context),
        prefixIcon: prefixIcon == null
            ? null
            : Icon(prefixIcon, color: AppColors.primaryGreenDark, size: 22.sp),
        suffixIcon: suffixIcon,
        contentPadding: EdgeInsets.symmetric(
          horizontal: horizontalPadding.w,
          vertical: verticalPadding.h,
        ),
        border: OutlineInputBorder(
          borderRadius: resolvedBorderRadius,
          borderSide: BorderSide(color: resolvedBorderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: resolvedBorderRadius,
          borderSide: BorderSide(color: resolvedBorderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: resolvedBorderRadius,
          borderSide: BorderSide(color: resolvedFocusedColor, width: 1.4),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: resolvedBorderRadius,
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: resolvedBorderRadius,
          borderSide: const BorderSide(color: AppColors.error, width: 1.4),
        ),
      ),
    );
  }
}
