import 'package:ai_meal_planner/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

class AppTextStyles {
  AppTextStyles._();

  static TextStyle display(
    BuildContext context, {
    double fontSize = 34,
    FontWeight fontWeight = FontWeight.w800,
    Color? color,
    double? height,
  }) {
    return Theme.of(context).textTheme.displaySmall!.copyWith(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color ?? AppColors.textPrimaryOf(context),
      height: height,
    );
  }

  static TextStyle headline(
    BuildContext context, {
    double fontSize = 24,
    FontWeight fontWeight = FontWeight.w700,
    Color? color,
    double? height,
  }) {
    return Theme.of(context).textTheme.headlineSmall!.copyWith(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color ?? AppColors.textPrimaryOf(context),
      height: height,
    );
  }

  static TextStyle title(
    BuildContext context, {
    double fontSize = 15,
    FontWeight fontWeight = FontWeight.w600,
    Color? color,
    double? height,
  }) {
    return Theme.of(context).textTheme.titleMedium!.copyWith(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color ?? AppColors.textPrimaryOf(context),
      height: height,
    );
  }

  static TextStyle body(
    BuildContext context, {
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.w400,
    Color? color,
    double? height,
  }) {
    return Theme.of(context).textTheme.bodyMedium!.copyWith(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color ?? AppColors.textSecondaryOf(context),
      height: height,
    );
  }

  static TextStyle label(
    BuildContext context, {
    double fontSize = 13,
    FontWeight fontWeight = FontWeight.w600,
    Color? color,
    double? height,
  }) {
    return Theme.of(context).textTheme.labelLarge!.copyWith(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color ?? AppColors.textSecondaryOf(context),
      height: height,
    );
  }

  static TextStyle button(
    BuildContext context, {
    double fontSize = 15,
    FontWeight fontWeight = FontWeight.w700,
    Color? color,
    double? height,
  }) {
    return Theme.of(context).textTheme.labelLarge!.copyWith(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color ?? AppColors.textWhite,
      height: height,
    );
  }

  static TextStyle caption(
    BuildContext context, {
    double fontSize = 11,
    FontWeight fontWeight = FontWeight.w600,
    Color? color,
    double? height,
  }) {
    return Theme.of(context).textTheme.labelSmall!.copyWith(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color ?? AppColors.textSecondaryOf(context),
      height: height,
    );
  }
}
