import 'package:ai_meal_planner/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    final baseTheme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: 'Inter',
      scaffoldBackgroundColor: AppColors.backgroundMain,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryGreenDark,
        brightness: Brightness.light,
        primary: AppColors.primaryGreenDark,
        secondary: AppColors.primaryGreenLight,
        surface: AppColors.surfaceWhite,
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primaryGreenDark;
          }
          return AppColors.surfaceWhite;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primaryGreenLight;
          }
          return AppColors.borderLight;
        }),
      ),
    );

    return baseTheme.copyWith(
      textTheme: baseTheme.textTheme.apply(fontFamily: 'Inter'),
      primaryTextTheme: baseTheme.primaryTextTheme.apply(fontFamily: 'Inter'),
    );
  }

  static ThemeData get darkTheme {
    final baseTheme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: 'Inter',
      scaffoldBackgroundColor: AppColors.darkBackgroundMain,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryGreenLight,
        brightness: Brightness.dark,
        primary: AppColors.primaryGreenLight,
        secondary: AppColors.primaryGreenDark,
        surface: AppColors.darkSurface,
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primaryGreenLight;
          }
          return AppColors.darkSurface;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primaryGreenDark.withValues(alpha: 0.65);
          }
          return AppColors.darkBorder;
        }),
      ),
    );

    return baseTheme.copyWith(
      textTheme: baseTheme.textTheme.apply(fontFamily: 'Inter'),
      primaryTextTheme: baseTheme.primaryTextTheme.apply(fontFamily: 'Inter'),
    );
  }
}
