import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppFilledButton extends StatelessWidget {
  const AppFilledButton({
    super.key,
    required this.label,
    required this.onPressed,
    required this.backgroundColor,
    required this.foregroundColor,
    this.isLoading = false,
    this.borderRadius = 18,
    this.disabledBackgroundColor,
    this.fontSize = 15,
    this.paddingVertical = 16,
  });

  final String label;
  final VoidCallback? onPressed;
  final Color backgroundColor;
  final Color foregroundColor;
  final bool isLoading;
  final double borderRadius;
  final Color? disabledBackgroundColor;
  final double fontSize;
  final double paddingVertical;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          disabledBackgroundColor:
              disabledBackgroundColor ?? backgroundColor.withValues(alpha: 0.5),
          elevation: 0,
          padding: EdgeInsets.symmetric(vertical: paddingVertical.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius.r),
          ),
        ),
        child: isLoading
            ? SizedBox(
                width: 22.w,
                height: 22.w,
                child: CircularProgressIndicator(
                  strokeWidth: 2.4,
                  valueColor: AlwaysStoppedAnimation<Color>(foregroundColor),
                ),
              )
            : Text(
                label,
                style: TextStyle(
                  fontSize: fontSize.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
      ),
    );
  }
}
