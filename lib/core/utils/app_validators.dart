import 'package:get/get.dart';

class AppValidators {
  AppValidators._();

  static String? requiredEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) {
      return 'Email is required';
    }
    if (!GetUtils.isEmail(email)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  static String? requiredPassword(String? value) {
    final password = value?.trim() ?? '';
    if (password.isEmpty) {
      return 'Password is required';
    }
    if (password.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  static String? requiredFullName(String? value) {
    final name = value?.trim() ?? '';
    if (name.isEmpty) {
      return 'Full name is required';
    }
    if (name.length < 3) {
      return 'Enter your full name';
    }
    return null;
  }

  static String? confirmPassword(
    String? value, {
    required String originalPassword,
  }) {
    final confirmPassword = value?.trim() ?? '';
    if (confirmPassword.isEmpty) {
      return 'Please confirm your password';
    }
    if (confirmPassword != originalPassword.trim()) {
      return 'Passwords do not match';
    }
    return null;
  }

  static bool isValidPassword(String? value) {
    return requiredPassword(value) == null;
  }
}
