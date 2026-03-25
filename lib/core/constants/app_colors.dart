import 'package:flutter/material.dart';

class AppColors {
  AppColors._(); // Private constructor to prevent instantiation

  // 🌿 Primary Brand Colors
  static const Color primaryGreen = Color(0xFF4CAF50);
  static const Color primaryGreenLight = Color(0xFF81C784);
  static const Color primaryGreenDark = Color(0xFF388E3C);
  static const Color primarylightGreen = Color(0xFFE8F5E9);
  static const Color darkBackgroundMain = Color(0xFF0F1512);
  static const Color darkBackgroundSecondary = Color(0xFF131B17);
  static const Color darkCardBackground = Color(0xFF1B241F);
  static const Color darkSurface = Color(0xFF18211C);
  static const Color darkTextPrimary = Color(0xFFF4F7F4);
  static const Color darkTextSecondary = Color(0xFFA8B5AC);
  static const Color darkTextHint = Color(0xFF78857C);
  static const Color darkBorder = Color(0xFF2D3B33);
  static const Color darkDivider = Color(0xFF243029);
  static const Color darkInputBackground = Color(0xFF111813);
  static const Color darkInputBorder = Color(0xFF34423A);
  static const Color darkChipBackground = Color(0xFF203128);
  static const Color darkProgressBackground = Color(0xFF27342D);
  // 🎨 Background Colors
  static const Color backgroundMain = Color(0xFFFFFFFF); // Pure white
  static const Color backgroundSecondary = Color(0xFFF5F7FA); // Light gray

  // 🧾 Card & Surface Colors
  static const Color cardBackground = Color(0xFFF5F7FA);
  static const Color surfaceWhite = Color(0xFFFFFFFF);

  // 📝 Text Colors
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textHint = Color(0xFF9CA3AF);
  static const Color textWhite = Color(0xFFFFFFFF);

  // 🟢 Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFE53935);
  static const Color warning = Color(0xFFFFB300);
  static const Color info = Color(0xFF2196F3);

  // 🔲 Borders & Dividers
  static const Color borderLight = Color(0xFFE5E7EB);
  static const Color divider = Color(0xFFEEEEEE);

  // 🌫 Shadows (used with opacity)
  static const Color shadowColor = Color(0x1A000000); // Black with low opacity

  // ✨ Input Fields
  static const Color inputBackground = Color(0xFFF9FAFB);
  static const Color inputBorder = Color(0xFFD1D5DB);
  static const Color inputFocusedBorder = primaryGreen;

  // 🎯 Buttons
  static const Color buttonPrimary = primaryGreen;
  static const Color buttonDisabled = Color(0xFFBDBDBD);

  // 🧩 Misc
  static const Color chipBackground = Color(0xFFE8F5E9);
  static const Color progressBackground = Color(0xFFE0E0E0);

  static bool isDark(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  static Color backgroundMainOf(BuildContext context) {
    return isDark(context) ? darkBackgroundMain : backgroundMain;
  }

  static Color backgroundSecondaryOf(BuildContext context) {
    return isDark(context) ? darkBackgroundSecondary : backgroundSecondary;
  }

  static Color cardBackgroundOf(BuildContext context) {
    return isDark(context) ? darkCardBackground : cardBackground;
  }

  static Color surfaceOf(BuildContext context) {
    return isDark(context) ? darkSurface : surfaceWhite;
  }

  static Color textPrimaryOf(BuildContext context) {
    return isDark(context) ? darkTextPrimary : textPrimary;
  }

  static Color textSecondaryOf(BuildContext context) {
    return isDark(context) ? darkTextSecondary : textSecondary;
  }

  static Color textHintOf(BuildContext context) {
    return isDark(context) ? darkTextHint : textHint;
  }

  static Color borderOf(BuildContext context) {
    return isDark(context) ? darkBorder : borderLight;
  }

  static Color dividerOf(BuildContext context) {
    return isDark(context) ? darkDivider : divider;
  }

  static Color shadowOf(BuildContext context) {
    return isDark(context)
        ? const Color(0x33000000)
        : shadowColor.withValues(alpha: 0.12);
  }

  static Color inputBackgroundOf(BuildContext context) {
    return isDark(context) ? darkInputBackground : inputBackground;
  }

  static Color inputBorderOf(BuildContext context) {
    return isDark(context) ? darkInputBorder : inputBorder;
  }

  static Color chipBackgroundOf(BuildContext context) {
    return isDark(context) ? darkChipBackground : chipBackground;
  }

  static Color progressBackgroundOf(BuildContext context) {
    return isDark(context) ? darkProgressBackground : progressBackground;
  }
}
