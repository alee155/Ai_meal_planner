import 'package:get/get.dart';

class AppValidators {
  AppValidators._();

  static String? requiredEmail(
    String? value, {
    String? requiredMessage,
    String? invalidMessage,
  }) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) {
      return requiredMessage ?? 'Email is required';
    }
    if (!GetUtils.isEmail(email)) {
      return invalidMessage ?? 'Enter a valid email address';
    }
    return null;
  }

  static String? requiredPassword(
    String? value, {
    String? requiredMessage,
    String? minLengthMessage,
  }) {
    final password = value?.trim() ?? '';
    if (password.isEmpty) {
      return requiredMessage ?? 'Password is required';
    }
    if (password.length < 6) {
      return minLengthMessage ?? 'Password must be at least 6 characters';
    }
    return null;
  }

  static String? requiredFullName(
    String? value, {
    String? requiredMessage,
    String? invalidMessage,
  }) {
    final name = value?.trim() ?? '';
    if (name.isEmpty) {
      return requiredMessage ?? 'Full name is required';
    }
    if (name.length < 3) {
      return invalidMessage ?? 'Enter your full name';
    }
    return null;
  }

  static String? confirmPassword(
    String? value, {
    required String originalPassword,
    String? requiredMessage,
    String? mismatchMessage,
  }) {
    final confirmPassword = value?.trim() ?? '';
    if (confirmPassword.isEmpty) {
      return requiredMessage ?? 'Please confirm your password';
    }
    if (confirmPassword != originalPassword.trim()) {
      return mismatchMessage ?? 'Passwords do not match';
    }
    return null;
  }

  static bool isValidPassword(
    String? value, {
    String? requiredMessage,
    String? minLengthMessage,
  }) {
    return requiredPassword(
          value,
          requiredMessage: requiredMessage,
          minLengthMessage: minLengthMessage,
        ) ==
        null;
  }
}
