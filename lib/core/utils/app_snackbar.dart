import 'package:get/get.dart';

import 'app_snackbar_config.dart';

class AppSnackbar {
  AppSnackbar._();

  static void success(
    String title,
    String message, {
    Duration duration = AppSnackbarConfig.defaultDuration,
  }) {
    _show(title, message, type: AppSnackbarType.success, duration: duration);
  }

  static void error(
    String title,
    String message, {
    Duration duration = AppSnackbarConfig.defaultDuration,
  }) {
    _show(title, message, type: AppSnackbarType.error, duration: duration);
  }

  static void info(
    String title,
    String message, {
    Duration duration = AppSnackbarConfig.defaultDuration,
  }) {
    _show(title, message, type: AppSnackbarType.info, duration: duration);
  }

  static void warning(
    String title,
    String message, {
    Duration duration = AppSnackbarConfig.defaultDuration,
  }) {
    _show(title, message, type: AppSnackbarType.warning, duration: duration);
  }

  static void _show(
    String title,
    String message, {
    required AppSnackbarType type,
    Duration duration = AppSnackbarConfig.defaultDuration,
  }) {
    Get.closeCurrentSnackbar();
    Get.snackbar(
      title,
      message,
      snackPosition: AppSnackbarConfig.snackPosition,
      backgroundColor: AppSnackbarConfig.backgroundColor(type),
      colorText: AppSnackbarConfig.textColor,
      margin: AppSnackbarConfig.margin,
      borderRadius: AppSnackbarConfig.borderRadius,
      duration: duration,
    );
  }
}
