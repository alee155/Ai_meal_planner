import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends GetxController {
  ThemeController();

  static const _themeModeKey = 'theme_mode';

  final Rx<ThemeMode> themeMode = ThemeMode.light.obs;
  late SharedPreferences _preferences;

  bool get isDarkMode => themeMode.value == ThemeMode.dark;

  static ThemeController ensureRegistered() {
    if (Get.isRegistered<ThemeController>()) {
      return Get.find<ThemeController>();
    }

    return Get.put(ThemeController());
  }

  Future<void> init() async {
    _preferences = await SharedPreferences.getInstance();
    themeMode.value = _readThemeMode();
    Get.changeThemeMode(themeMode.value);
  }

  void toggleTheme(bool isDark) {
    themeMode.value = isDark ? ThemeMode.dark : ThemeMode.light;
    Get.changeThemeMode(themeMode.value);
    _persistThemeMode();
  }

  ThemeMode _readThemeMode() {
    final storedMode = _preferences.getString(_themeModeKey);

    switch (storedMode) {
      case 'dark':
        return ThemeMode.dark;
      case 'light':
      default:
        return ThemeMode.light;
    }
  }

  Future<void> _persistThemeMode() {
    return _preferences.setString(_themeModeKey, isDarkMode ? 'dark' : 'light');
  }
}
