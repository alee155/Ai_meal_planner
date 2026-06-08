import 'dart:async';

import 'package:ai_meal_planner/features/DietPlanScreen/controller/diet_plan_controller.dart';
import 'package:ai_meal_planner/features/DietPlanScreen/models/latest_meal_plan_response_model.dart';
import 'package:ai_meal_planner/features/DietPlanScreen/services/meal_plan_service.dart';
import 'package:ai_meal_planner/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum MealRemindersMode { defaultSchedule, custom }

/// One entry in the default schedule list, augmented with per-meal end time
/// and a loading/error state for inline PATCH updates.
class DefaultScheduleEntry {
  DefaultScheduleEntry({
    required this.mealKey,
    required this.startPkt,
    required this.endPkt,
    this.originalTz,
    this.utcStart,
    this.utcEnd,
  });

  final String mealKey;

  /// Displayed PKT start time (mutable — user may update it).
  TimeOfDay startPkt;

  /// Displayed PKT end time (nullable when API did not provide one).
  TimeOfDay? endPkt;

  /// The IANA timezone string from the API, shown in the secondary row.
  final String? originalTz;

  /// Raw UTC start time from the API (for the original-tz display row).
  final ({int hour, int minute})? utcStart;

  /// Raw UTC end time from the API (for the original-tz display row).
  final ({int hour, int minute})? utcEnd;

  bool isUpdatingStart = false;
  bool isUpdatingEnd = false;
  String? updateError;
}

class MealRemindersController extends GetxController {
  MealRemindersController({MealPlanService? mealPlanService})
    : _mealPlanService = mealPlanService ?? MealPlanService.ensureRegistered();

  final MealPlanService _mealPlanService;

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

  /// All scheduled alarms (default window slots + custom).
  final RxList<MealAlarmConfig> alarms = <MealAlarmConfig>[].obs;

  /// Only alarms the user manually created in the Custom tab.
  /// Default-schedule window alarms are never added here.
  final RxList<MealAlarmConfig> customAlarms = <MealAlarmConfig>[].obs;

  static const _prefsCustomAlarmIdsKey = 'meal_reminders_custom_alarm_ids_v1';

  /// Reactive list backing the Default tab rows.
  final RxList<DefaultScheduleEntry> scheduleEntries =
      <DefaultScheduleEntry>[].obs;

  @override
  void onInit() {
    super.onInit();
    unawaited(init());
  }

  /// Called once [init] completes. Attaches a silent stream listener on the
  /// meal plan so [scheduleEntries] stays in sync with any background refresh.
  void _bindMealPlanStream() {
    final dietCtrl = _safeDietController();
    if (dietCtrl == null) return;

    // `ever` fires every time `dietCtrl.latest` emits a new value.
    // `debounce` would also work if you want to wait for rapid emissions to settle.
    ever<LatestMealPlanDataModel?>(
      dietCtrl.latest,
      (_) => _rebuildScheduleEntries(),
    );
  }

  Future<void> init() async {
    isLoading.value = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      isEnabled.value = prefs.getBool(_prefsEnabledKey) ?? false;
      mode.value = _decodeMode(prefs.getString(_prefsModeKey));
      final all = await NotificationService.getSavedMealAlarmConfigs();
      alarms.assignAll(all);
      _rebuildCustomAlarms(all, prefs);
      _rebuildScheduleEntries();
    } finally {
      isLoading.value = false;
    }
    if (isEnabled.value) await _applySchedules();

    // Bind after init — DietPlanController is guaranteed to be registered by now.
    _bindMealPlanStream();
  }

  // ─── Schedule entries ──────────────────────────────────────────────────────

  void _rebuildScheduleEntries() {
    final dietCtrl = _safeDietController();
    final meals = dietCtrl?.latest.value?.plan.meals ?? [];

    // Build entries ONLY from API meals that have timeWindow data.
    // No hardcoded fallback meals — if API gives 3 meals, we show 3.
    final entries = <DefaultScheduleEntry>[];
    for (final meal in meals) {
      if (meal.startPkt == null) continue; // skip meals with no time data
      final key =
          _normaliseMealKey(meal.mealName) ??
          meal.mealName.trim().toLowerCase();
      final s = meal.startPkt!;
      final e = meal.endPkt;
      entries.add(
        DefaultScheduleEntry(
          mealKey: key,
          startPkt: TimeOfDay(hour: s.hour, minute: s.minute),
          endPkt: e != null ? TimeOfDay(hour: e.hour, minute: e.minute) : null,
          originalTz: meal.timezone,
          utcStart: meal.startUtc,
          utcEnd: meal.endUtc,
        ),
      );
    }
    scheduleEntries.assignAll(entries);
  }

  bool get defaultScheduleHasApiData {
    final dietCtrl = _safeDietController();
    final meals = dietCtrl?.latest.value?.plan.meals ?? [];
    return meals.any((m) => m.startPkt != null);
  }

  // ─── Update a single time via PATCH /meals/time-windows ───────────────────

  /// Called when the user taps the edit pen for the start time on an entry.
  Future<void> updateEntryStartTime(
    DefaultScheduleEntry entry,
    TimeOfDay newPktTime,
  ) async {
    // Convert PKT → UTC for the API (subtract 5 hours)
    final utcHour = (newPktTime.hour - 5 + 24) % 24;
    final utcMinute = newPktTime.minute;
    final startUtc = _padHHmm(utcHour, utcMinute);

    // Use existing end time (PKT) converted to UTC for the companion field
    final existingEndPkt = entry.endPkt ?? _addHour(newPktTime);
    final endUtcH = (existingEndPkt.hour - 5 + 24) % 24;
    final endUtc = _padHHmm(endUtcH, existingEndPkt.minute);

    final idx = scheduleEntries.indexOf(entry);
    if (idx == -1) return;

    scheduleEntries[idx].isUpdatingStart = true;
    scheduleEntries[idx].updateError = null;
    scheduleEntries.refresh();

    try {
      await _mealPlanService.updateMealTimeWindow(
        mealType: entry.mealKey,
        startUtc: startUtc,
        endUtc: endUtc,
      );
      scheduleEntries[idx].startPkt = newPktTime;
    } catch (e) {
      scheduleEntries[idx].updateError = e is Exception
          ? e.toString().replaceFirst('Exception: ', '')
          : 'Update failed';
    } finally {
      scheduleEntries[idx].isUpdatingStart = false;
      scheduleEntries.refresh();
    }
  }

  /// Called when the user taps the edit pen for the end time on an entry.
  Future<void> updateEntryEndTime(
    DefaultScheduleEntry entry,
    TimeOfDay newPktTime,
  ) async {
    final existingStartPkt = entry.startPkt;
    final startUtcH = (existingStartPkt.hour - 5 + 24) % 24;
    final startUtc = _padHHmm(startUtcH, existingStartPkt.minute);

    final endUtcH = (newPktTime.hour - 5 + 24) % 24;
    final endUtc = _padHHmm(endUtcH, newPktTime.minute);

    final idx = scheduleEntries.indexOf(entry);
    if (idx == -1) return;

    scheduleEntries[idx].isUpdatingEnd = true;
    scheduleEntries[idx].updateError = null;
    scheduleEntries.refresh();

    try {
      await _mealPlanService.updateMealTimeWindow(
        mealType: entry.mealKey,
        startUtc: startUtc,
        endUtc: endUtc,
      );
      scheduleEntries[idx].endPkt = newPktTime;
    } catch (e) {
      scheduleEntries[idx].updateError = e is Exception
          ? e.toString().replaceFirst('Exception: ', '')
          : 'Update failed';
    } finally {
      scheduleEntries[idx].isUpdatingEnd = false;
      scheduleEntries.refresh();
    }
  }

  // ─── Enable / mode / custom alarms ────────────────────────────────────────

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
    customAlarms.add(config);
    await NotificationService.upsertMealAlarmConfig(config);
    await _saveCustomAlarmIds();
    if (isEnabled.value) await NotificationService.scheduleMealAlarm(config);
  }

  Future<void> toggleAlarm(MealAlarmConfig config, bool enabled) async {
    final updated = config.copyWith(enabled: enabled);
    final idx = alarms.indexWhere((a) => a.id == config.id);
    if (idx != -1) alarms[idx] = updated;
    final cidx = customAlarms.indexWhere((a) => a.id == config.id);
    if (cidx != -1) customAlarms[cidx] = updated;
    await NotificationService.upsertMealAlarmConfig(updated);
    if (!isEnabled.value) return;
    if (enabled) {
      await NotificationService.scheduleMealAlarm(updated);
    } else {
      await NotificationService.cancelMealAlarm(updated.id);
    }
  }

  Future<void> deleteAlarm(MealAlarmConfig config) async {
    alarms.removeWhere((a) => a.id == config.id);
    customAlarms.removeWhere((a) => a.id == config.id);
    await NotificationService.deleteMealAlarmConfig(config.id);
    await NotificationService.cancelMealAlarm(config.id);
    await _saveCustomAlarmIds();
  }

  /// Rebuilds [customAlarms] from [all] by filtering to only IDs that were
  /// manually added by the user (tracked in prefs), not window slot alarms.
  void _rebuildCustomAlarms(
    List<MealAlarmConfig> all,
    SharedPreferences prefs,
  ) {
    final raw = prefs.getStringList(_prefsCustomAlarmIdsKey) ?? [];
    final ids = raw.map((s) => int.tryParse(s)).whereType<int>().toSet();
    customAlarms.assignAll(all.where((c) => ids.contains(c.id)));
  }

  Future<void> _saveCustomAlarmIds() async {
    final prefs = await SharedPreferences.getInstance();
    final ids = customAlarms.map((c) => c.id.toString()).toList();
    await prefs.setStringList(_prefsCustomAlarmIdsKey, ids);
  }

  /// True while [applyDefaultSchedule] is running — drives the button loading state.
  final RxBool isApplyingDefault = false.obs;

  Future<void> applyDefaultSchedule() async {
    if (isApplyingDefault.value) return;
    isApplyingDefault.value = true;

    try {
      await setMode(MealRemindersMode.defaultSchedule);
      await NotificationService.clearAllMealAlarms();

      // Fetch meal plan data for macro population
      final dietCtrl = _safeDietController();
      final meals = dietCtrl?.latest.value?.plan.meals ?? [];

      for (final entry in scheduleEntries) {
        if (entry.endPkt == null) continue;

        final meal = meals.firstWhereOrNull(
          (m) =>
              (_normaliseMealKey(m.mealName) ?? m.mealName.toLowerCase()) ==
              entry.mealKey.toLowerCase(),
        );

        final baseId = await NotificationService.allocateMealWindowBaseId();
        final window = MealWindowConfig(
          mealKey: entry.mealKey,
          baseAlarmId: baseId,
          startHour: entry.startPkt.hour,
          startMinute: entry.startPkt.minute,
          endHour: entry.endPkt!.hour,
          endMinute: entry.endPkt!.minute,
          enabled: isEnabled.value,
          kcal: meal?.actualCalories ?? -1,
          proteinG: meal != null ? meal.subtotal.protein.round() : -1,
          carbsG: meal != null ? meal.subtotal.carbs.round() : -1,
          fatG: meal != null ? meal.subtotal.fats.round() : -1,
        );
        await NotificationService.scheduleMealWindowAlarms(window);
      }

      alarms.assignAll(await NotificationService.getSavedMealAlarmConfigs());

      // ── Success toast ────────────────────────────────────────────────────
      final count = scheduleEntries.where((e) => e.endPkt != null).length;
      final mealWord = count == 1 ? 'meal' : 'meals';
      Get.closeCurrentSnackbar();
      Get.showSnackbar(
        GetSnackBar(
          titleText: const Text(
            'Alarms set!',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 14,
            ),
          ),
          messageText: Text(
            'Reminders scheduled for $count $mealWord. You\'ll be notified at start, midpoint, and 30 min before each window closes.',
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
          icon: const Icon(
            Icons.alarm_on_rounded,
            color: Colors.white,
            size: 24,
          ),
          backgroundColor: const Color(0xFF2E7D32),
          duration: const Duration(seconds: 4),
          borderRadius: 14,
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          snackPosition: SnackPosition.BOTTOM,
        ),
      );
    } catch (_) {
      Get.closeCurrentSnackbar();
      Get.showSnackbar(
        GetSnackBar(
          titleText: const Text(
            'Could not set alarms',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 14,
            ),
          ),
          messageText: const Text(
            'Something went wrong while scheduling. Please try again.',
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
          icon: const Icon(
            Icons.error_outline_rounded,
            color: Colors.white,
            size: 24,
          ),
          backgroundColor: const Color(0xFFA32D2D),
          duration: const Duration(seconds: 3),
          borderRadius: 14,
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          snackPosition: SnackPosition.BOTTOM,
        ),
      );
    } finally {
      isApplyingDefault.value = false;
    }
  }

  Future<void> _applySchedules() async {
    // Re-schedule every saved config individually (used on toggle / boot).
    final configs = await NotificationService.getSavedMealAlarmConfigs();
    alarms.assignAll(configs);
    await NotificationService.scheduleMealAlarms(
      configs.where((c) => c.enabled),
    );
  }

  // ─── Static helpers ────────────────────────────────────────────────────────

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
        return mealKey.isNotEmpty
            ? mealKey[0].toUpperCase() + mealKey.substring(1)
            : mealKey;
    }
  }

  static String? _normaliseMealKey(String mealName) {
    final n = mealName.trim().toLowerCase();
    if (n.contains('breakfast')) return 'breakfast';
    if (n.contains('lunch')) return 'lunch';
    if (n.contains('snack')) return 'snacks';
    if (n.contains('dinner')) return 'dinner';
    return null;
  }

  static String _titleForMeal(String mealKey) =>
      '${displayMealName(mealKey)} reminder';

  static DietPlanController? _safeDietController() {
    if (Get.isRegistered<DietPlanController>()) {
      return Get.find<DietPlanController>();
    }
    return null;
  }

  static MealRemindersMode _decodeMode(String? raw) {
    return raw == 'default'
        ? MealRemindersMode.defaultSchedule
        : MealRemindersMode.custom;
  }

  static String _encodeMode(MealRemindersMode m) =>
      m == MealRemindersMode.defaultSchedule ? 'default' : 'custom';

  /// Pads hours and minutes to HH:mm format expected by the API.
  static String _padHHmm(int hour, int minute) =>
      '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';

  /// Returns [time] shifted forward by 1 hour (for a default end time).
  static TimeOfDay _addHour(TimeOfDay t) =>
      TimeOfDay(hour: (t.hour + 1) % 24, minute: t.minute);
}
