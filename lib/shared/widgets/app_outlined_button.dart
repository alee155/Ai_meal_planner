import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppOutlinedButton extends StatelessWidget {
  const AppOutlinedButton({
    super.key,
    this.label,
    this.child,
    required this.onPressed,
    required this.foregroundColor,
    required this.borderColor,
    this.borderRadius = 18,
    this.paddingVertical = 15,
    this.fontSize = 14,
    this.fontWeight = FontWeight.w600,
  }) : assert(label != null || child != null);

  final String? label;
  final Widget? child;
  final VoidCallback? onPressed;
  final Color foregroundColor;
  final Color borderColor;
  final double borderRadius;
  final double paddingVertical;
  final double fontSize;
  final FontWeight fontWeight;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: foregroundColor,
          side: BorderSide(color: borderColor),
          padding: EdgeInsets.symmetric(vertical: paddingVertical.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius.r),
          ),
        ),
        child:
            child ??
            Text(
              label!,
              style: TextStyle(fontSize: fontSize.sp, fontWeight: fontWeight),
            ),
      ),
    );
  }
}
