import 'dart:async';

import 'package:ai_meal_planner/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum MealRemindersMode { defaultSchedule, custom }

class MealRemindersController extends GetxController {
  static MealRemindersController ensureRegistered() {
    if (Get.isRegistered<MealRemindersController>()) {
      return Get.find<MealRemindersController>();
    }

    return Get.put(MealRemindersController(), permanent: true);
  }

  static const _prefsEnabledKey = 'meal_reminders_enabled_v1';
  static const _prefsModeKey = 'meal_reminders_mode_v1';

  final RxBool isLoading = true.obs;
  final RxBool isEnabled = false.obs;
  final Rx<MealRemindersMode> mode = MealRemindersMode.custom.obs;
  final RxList<MealAlarmConfig> alarms = <MealAlarmConfig>[].obs;

  @override
  void onInit() {
    super.onInit();
    unawaited(init());
  }

  Future<void> init() async {
    isLoading.value = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      isEnabled.value = prefs.getBool(_prefsEnabledKey) ?? false;
      mode.value = _decodeMode(prefs.getString(_prefsModeKey));
      alarms.assignAll(await NotificationService.getSavedMealAlarmConfigs());
    } finally {
      isLoading.value = false;
    }

    if (isEnabled.value) {
      await _applySchedules();
    }
  }

  Future<void> setEnabled(bool enabled) async {
    isEnabled.value = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefsEnabledKey, enabled);

    if (!enabled) {
      await NotificationService.cancelAllMealAlarms();
      return;
    }

    await _applySchedules();
  }

  Future<void> setMode(MealRemindersMode nextMode) async {
    if (mode.value == nextMode) return;
    mode.value = nextMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsModeKey, _encodeMode(nextMode));
  }

  Future<void> addAlarm({
    required String mealKey,
    required TimeOfDay time,
  }) async {
    final id = await NotificationService.allocateMealAlarmId();
    final config = MealAlarmConfig(
      id: id,
      mealKey: mealKey,
      title: _titleForMeal(mealKey),
      instruction: NotificationService.defaultInstruction,
      hour: time.hour,
      minute: time.minute,
      enabled: true,
    );

    alarms.add(config);
    await NotificationService.upsertMealAlarmConfig(config);

    if (isEnabled.value) {
      await NotificationService.scheduleMealAlarm(config);
    }
  }

  Future<void> toggleAlarm(MealAlarmConfig config, bool enabled) async {
    final updated = config.copyWith(enabled: enabled);
    final index = alarms.indexWhere((item) => item.id == config.id);
    if (index != -1) {
      alarms[index] = updated;
    }

    await NotificationService.upsertMealAlarmConfig(updated);

    if (!isEnabled.value) {
      return;
    }

    if (enabled) {
      await NotificationService.scheduleMealAlarm(updated);
    } else {
      await NotificationService.cancelMealAlarm(updated.id);
    }
  }

  Future<void> deleteAlarm(MealAlarmConfig config) async {
    alarms.removeWhere((item) => item.id == config.id);
    await NotificationService.deleteMealAlarmConfig(config.id);
    await NotificationService.cancelMealAlarm(config.id);
  }

  /// Placeholder until the backend "Get Time" API lands.
  /// Replace this list with API-provided defaults when ready.
  List<({String mealKey, TimeOfDay time})> get defaultSchedule => const [
    (mealKey: 'breakfast', time: TimeOfDay(hour: 8, minute: 0)),
    (mealKey: 'lunch', time: TimeOfDay(hour: 13, minute: 0)),
    (mealKey: 'snacks', time: TimeOfDay(hour: 16, minute: 30)),
    (mealKey: 'dinner', time: TimeOfDay(hour: 20, minute: 0)),
  ];

  Future<void> applyDefaultSchedule() async {
    await setMode(MealRemindersMode.defaultSchedule);

    // Default schedule should be deterministic: replace any existing alarms.
    final previous = await NotificationService.getSavedMealAlarmConfigs();
    for (final alarm in previous) {
      await NotificationService.cancelMealAlarm(alarm.id);
    }
    await NotificationService.clearAllMealAlarms();

    final defaults = <MealAlarmConfig>[];
    for (final entry in defaultSchedule) {
      final id = await NotificationService.allocateMealAlarmId();
      defaults.add(
        MealAlarmConfig(
          id: id,
          mealKey: entry.mealKey,
          title: _titleForMeal(entry.mealKey),
          instruction: NotificationService.defaultInstruction,
          hour: entry.time.hour,
          minute: entry.time.minute,
          enabled: true,
        ),
      );
    }

    alarms.assignAll(defaults);
    for (final alarm in defaults) {
      await NotificationService.upsertMealAlarmConfig(alarm);
    }

    if (isEnabled.value) {
      await _applySchedules();
    }
  }

  Future<void> _applySchedules() async {
    final configs = await NotificationService.getSavedMealAlarmConfigs();
    alarms.assignAll(configs);
    await NotificationService.scheduleMealAlarms(
      configs.where((config) => config.enabled),
    );
  }

  static String displayMealName(String mealKey) {
    switch (mealKey) {
      case 'breakfast':
        return 'Breakfast';
      case 'lunch':
        return 'Lunch';
      case 'snacks':
        return 'Snacks';
      case 'dinner':
        return 'Dinner';
      default:
        return mealKey;
    }
  }

  static String _titleForMeal(String mealKey) {
    return '${displayMealName(mealKey)} reminder';
  }

  static MealRemindersMode _decodeMode(String? raw) {
    switch (raw) {
      case 'default':
        return MealRemindersMode.defaultSchedule;
      case 'custom':
      default:
        return MealRemindersMode.custom;
    }
  }

  static String _encodeMode(MealRemindersMode mode) {
    switch (mode) {
      case MealRemindersMode.defaultSchedule:
        return 'default';
      case MealRemindersMode.custom:
        return 'custom';
    }
  }
}
