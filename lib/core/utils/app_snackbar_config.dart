import 'package:ai_meal_planner/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

enum AppSnackbarType { success, error, info, warning }

class AppSnackbarConfig {
  AppSnackbarConfig._();

  static SnackPosition get snackPosition => SnackPosition.BOTTOM;
  static Color get textColor => AppColors.textWhite;
  static EdgeInsets get margin => EdgeInsets.all(16.w);
  static double get borderRadius => 18.r;
  static const Duration defaultDuration = Duration(seconds: 3);

  static Color backgroundColor(AppSnackbarType type) {
    switch (type) {
      case AppSnackbarType.success:
        return AppColors.primaryGreenDark;
      case AppSnackbarType.error:
        return AppColors.error;
      case AppSnackbarType.info:
        return AppColors.info;
      case AppSnackbarType.warning:
        return AppColors.warning;
    }
  }
}
