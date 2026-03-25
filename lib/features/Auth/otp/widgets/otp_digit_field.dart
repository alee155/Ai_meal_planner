import 'package:ai_meal_planner/core/constants/app_colors.dart';
import 'package:ai_meal_planner/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class OtpDigitField extends StatelessWidget {
  const OtpDigitField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    this.autofocus = false,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final isActive = focusNode.hasFocus || controller.text.isNotEmpty;

    return SizedBox(
      width: 64.w,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        autofocus: autofocus,
        onChanged: onChanged,
        keyboardType: TextInputType.number,
        textInputAction: TextInputAction.next,
        textAlign: TextAlign.center,
        cursorColor: AppColors.primaryGreenDark,
        style: AppTextStyles.headline(
          context,
          fontSize: 24,
          fontWeight: FontWeight.w800,
        ),
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(4),
        ],
        decoration: InputDecoration(
          filled: true,
          fillColor: AppColors.surfaceOf(context).withValues(alpha: 0.95),
          contentPadding: EdgeInsets.symmetric(vertical: 18.h),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20.r),
            borderSide: BorderSide(
              color: isActive
                  ? AppColors.primaryGreenDark
                  : AppColors.borderOf(context),
              width: isActive ? 1.6 : 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20.r),
            borderSide: const BorderSide(
              color: AppColors.primaryGreenDark,
              width: 1.8,
            ),
          ),
        ),
      ),
    );
  }
}
