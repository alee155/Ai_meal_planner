import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'core/notifications/in_app_inbox_store.dart';
import 'features/NotificationsScreen/controller/notifications_inbox_controller.dart';
import 'routes/app_routes.dart';

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  NotificationService.handleNotificationResponse(notificationResponse);
}

// ─── MealAlarmConfig ─────────────────────────────────────────────────────────

class MealAlarmConfig {
  const MealAlarmConfig({
    required this.id,
    required this.mealKey,
    required this.title,
    required this.instruction,
    required this.hour,
    required this.minute,
    required this.enabled,
    this.endHour = -1,
    this.endMinute = -1,
    this.kcal = -1,
    this.proteinG = -1,
    this.carbsG = -1,
    this.fatG = -1,
  });

  final int id;
  final String mealKey;
  final String title;
  final String instruction;
  final int hour;
  final int minute;
  final bool enabled;
  // Window end time — forwarded to the native alarm screen for display.
  final int endHour;
  final int endMinute;
  // Macro data — shown on the alarm card.
  final int kcal;
  final int proteinG;
  final int carbsG;
  final int fatG;

  MealAlarmConfig copyWith({
    int? id,
    String? mealKey,
    String? title,
    String? instruction,
    int? hour,
    int? minute,
    bool? enabled,
    int? endHour,
    int? endMinute,
    int? kcal,
    int? proteinG,
    int? carbsG,
    int? fatG,
  }) {
    return MealAlarmConfig(
      id: id ?? this.id,
      mealKey: mealKey ?? this.mealKey,
      title: title ?? this.title,
      instruction: instruction ?? this.instruction,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
      enabled: enabled ?? this.enabled,
      endHour: endHour ?? this.endHour,
      endMinute: endMinute ?? this.endMinute,
      kcal: kcal ?? this.kcal,
      proteinG: proteinG ?? this.proteinG,
      carbsG: carbsG ?? this.carbsG,
      fatG: fatG ?? this.fatG,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'mealKey': mealKey,
    'title': title,
    'instruction': instruction,
    'hour': hour,
    'minute': minute,
    'enabled': enabled,
    'endHour': endHour,
    'endMinute': endMinute,
    'kcal': kcal,
    'proteinG': proteinG,
    'carbsG': carbsG,
    'fatG': fatG,
  };

  static MealAlarmConfig? fromJson(Object? json) {
    if (json is! Map) return null;
    final map = Map<String, dynamic>.from(json);
    final id = map['id'];
    final mealKey = map['mealKey'];
    final title = map['title'];
    final instruction = map['instruction'];
    final hour = map['hour'];
    final minute = map['minute'];
    if (id is! int ||
        mealKey is! String ||
        title is! String ||
        instruction is! String ||
        hour is! int ||
        minute is! int)
      return null;
    return MealAlarmConfig(
      id: id,
      mealKey: mealKey,
      title: title,
      instruction: instruction,
      hour: hour,
      minute: minute,
      enabled: map['enabled'] is bool ? map['enabled'] as bool : true,
      endHour: map['endHour'] is int ? map['endHour'] as int : -1,
      endMinute: map['endMinute'] is int ? map['endMinute'] as int : -1,
      kcal: map['kcal'] is int ? map['kcal'] as int : -1,
      proteinG: map['proteinG'] is int ? map['proteinG'] as int : -1,
      carbsG: map['carbsG'] is int ? map['carbsG'] as int : -1,
      fatG: map['fatG'] is int ? map['fatG'] as int : -1,
    );
  }
}

// ─── MealWindowConfig ─────────────────────────────────────────────────────────
// Represents the full time window for one meal — holds start + end so the
// service can derive the 3 alarm fire times internally.

class MealWindowConfig {
  const MealWindowConfig({
    required this.mealKey,
    required this.baseAlarmId,
    required this.startHour,
    required this.startMinute,
    required this.endHour,
    required this.endMinute,
    required this.enabled,
    this.kcal = -1,
    this.proteinG = -1,
    this.carbsG = -1,
    this.fatG = -1,
  });

  final String mealKey;

  /// The base ID from which all 3 slot IDs are derived:
  ///   slot 0 (start)     = baseAlarmId
  ///   slot 1 (midpoint)  = baseAlarmId + 1
  ///   slot 2 (pre-close) = baseAlarmId + 2
  final int baseAlarmId;

  final int startHour;
  final int startMinute;
  final int endHour;
  final int endMinute;
  final bool enabled;

  /// Meal macro data — displayed on the alarm screen card.
  final int kcal;
  final int proteinG;
  final int carbsG;
  final int fatG;

  /// Total window length in minutes.
  int get windowMinutes {
    final startTotal = startHour * 60 + startMinute;
    final endTotal = endHour * 60 + endMinute;
    // Handle windows that cross midnight
    return endTotal >= startTotal
        ? endTotal - startTotal
        : (24 * 60 - startTotal) + endTotal;
  }
}

// ─── AlarmLaunchData ──────────────────────────────────────────────────────────

class AlarmLaunchData {
  const AlarmLaunchData({
    required this.title,
    required this.instruction,
    required this.hour,
    required this.minute,
    this.alarmId,
    this.mealKey,
  });

  final String title;
  final String instruction;
  final int hour;
  final int minute;
  final int? alarmId;
  final String? mealKey;

  String toPayload() => jsonEncode({
    'type': 'meal_alarm',
    'alarmId': alarmId,
    'mealKey': mealKey,
    'title': title,
    'instruction': instruction,
    'hour': hour,
    'minute': minute,
  });

  static AlarmLaunchData? fromPayload(String? payload) {
    if (payload == null || payload.isEmpty) return null;
    try {
      final decoded = jsonDecode(payload);
      if (decoded is! Map) return null;
      final m = Map<String, dynamic>.from(decoded);
      if (m['type'] != 'meal_alarm') return null;
      return AlarmLaunchData(
        title: m['title'] as String? ?? NotificationService.defaultTitle,
        instruction:
            m['instruction'] as String? ??
            NotificationService.defaultInstruction,
        hour: m['hour'] as int? ?? 0,
        minute: m['minute'] as int? ?? 0,
        alarmId: m['alarmId'] as int?,
        mealKey: m['mealKey'] as String?,
      );
    } catch (_) {
      return null;
    }
  }
}

// ─── NotificationService ──────────────────────────────────────────────────────

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  static const MethodChannel _alarmChannel = MethodChannel(
    'com.devsouq.caloriq.app/alarm',
  );

  static const String defaultTitle = 'Meal Reminder';
  static const String defaultInstruction =
      'Time to complete your meal and follow your nutrition plan.';
  static const String? _customAlarmSoundName = null;
  static const int _dailyAlarmId = 1;
  static const int _snoozeAlarmId = 2;
  static const int _statusNotificationId = 3;
  static const String _alarmChannelId = 'meal_alarm_channel_v3';
  static const String _alarmChannelName = 'Meal Alarms';
  static const String _statusChannelId = 'meal_alarm_status_channel';
  static const String _statusChannelName = 'Meal Alarm Status';
  static const String _stopActionId = 'stop_alarm';
  static const String _snoozeActionId = 'snooze_alarm';
  static const String _prefsHourKey = 'meal_alarm_hour';
  static const String _prefsMinuteKey = 'meal_alarm_minute';
  static const String _prefsTimezoneKey = 'meal_alarm_timezone';
  static const String _prefsAlarmUriKey = 'meal_alarm_sound_uri';
  static const String _prefsTitleKey = 'meal_alarm_title';
  static const String _prefsInstructionKey = 'meal_alarm_instruction';
  static const String _prefsMealAlarmsKey = 'meal_alarm_items_v1';
  static const String _prefsMealAlarmsNextIdKey = 'meal_alarm_next_id_v1';
  static const int _multiAlarmIdStart = 1000;
  static const int _multiSnoozeIdOffset = 900000;
  static const int _multiStatusIdOffset = 950000;

  // ── Init ──────────────────────────────────────────────────────────────────

  static Future<void> init() async {
    await _ensureTimezoneInitialized();

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      defaultPresentAlert: true,
      defaultPresentBadge: true,
      defaultPresentSound: true,
    );

    await _plugin.initialize(
      settings: const InitializationSettings(
        android: androidInit,
        iOS: darwinInit,
        macOS: darwinInit,
      ),
      onDidReceiveNotificationResponse: _onNotificationResponse,
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );

    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await androidPlugin?.requestNotificationsPermission();
    await androidPlugin?.requestExactAlarmsPermission();
    await androidPlugin?.requestFullScreenIntentPermission();

    await _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);
    await _plugin
        .resolvePlatformSpecificImplementation<
          MacOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }

  static void _onNotificationResponse(NotificationResponse response) {
    unawaited(handleNotificationResponse(response));
  }

  static Future<void> handleNotificationResponse(
    NotificationResponse response,
  ) async {
    final payloadData = AlarmLaunchData.fromPayload(response.payload);
    final resolvedAlarmId = payloadData?.alarmId ?? response.id;
    switch (response.actionId) {
      case _stopActionId:
        await stopAlarm(alarmId: resolvedAlarmId);
        break;
      case _snoozeActionId:
        await snoozeAlarm(alarmId: resolvedAlarmId);
        break;
      default:
        await _openAlarmScreen(alarmData: payloadData);
        break;
    }
  }

  static Future<AlarmLaunchData?> getLaunchAlarmData() async {
    final details = await _plugin.getNotificationAppLaunchDetails();
    return AlarmLaunchData.fromPayload(details?.notificationResponse?.payload);
  }

  static Future<void> _openAlarmScreen({AlarmLaunchData? alarmData}) async {
    final resolvedAlarmData = alarmData ?? await getSavedAlarmData();
    if (resolvedAlarmData == null || Get.key.currentContext == null) return;

    try {
      await InAppInboxStore.add(
        InAppInboxItem(
          id: 0,
          type: 'meal_alarm',
          title: resolvedAlarmData.title,
          message: resolvedAlarmData.instruction,
          createdAtMs: DateTime.now().millisecondsSinceEpoch,
          isRead: false,
          mealKey: resolvedAlarmData.mealKey,
          hour: resolvedAlarmData.hour,
          minute: resolvedAlarmData.minute,
        ),
      );
      if (Get.isRegistered<NotificationsInboxController>()) {
        unawaited(Get.find<NotificationsInboxController>().reload());
      }
    } catch (_) {}

    if (Get.currentRoute == AppRoutes.alarmRinging) {
      await Get.offNamed(AppRoutes.alarmRinging, arguments: resolvedAlarmData);
      return;
    }
    await Get.toNamed(
      AppRoutes.alarmRinging,
      arguments: resolvedAlarmData,
      preventDuplicates: false,
    );
  }

  // ── Timezone ──────────────────────────────────────────────────────────────

  static Future<void> _ensureTimezoneInitialized() async {
    tz.initializeTimeZones();
    final prefs = await SharedPreferences.getInstance();
    String? timezoneName = prefs.getString(_prefsTimezoneKey);
    if (timezoneName == null || timezoneName.isEmpty) {
      try {
        timezoneName = await _alarmChannel.invokeMethod<String>(
          'getLocalTimezone',
        );
      } catch (_) {
        timezoneName = null;
      }
    }
    if (timezoneName != null && timezoneName.isNotEmpty) {
      try {
        tz.setLocalLocation(tz.getLocation(timezoneName));
        await prefs.setString(_prefsTimezoneKey, timezoneName);
        return;
      } catch (_) {}
    }
    tz.setLocalLocation(tz.UTC);
  }

  // ── Sound ─────────────────────────────────────────────────────────────────

  static Future<AndroidNotificationSound?> _resolveAlarmSound() async {
    if (!Platform.isAndroid) return null;
    if (_customAlarmSoundName != null) {
      return RawResourceAndroidNotificationSound(_customAlarmSoundName!);
    }
    final prefs = await SharedPreferences.getInstance();
    try {
      final alarmUri = await _alarmChannel.invokeMethod<String>('getAlarmUri');
      if (alarmUri == null || alarmUri.isEmpty) {
        final cached = prefs.getString(_prefsAlarmUriKey);
        if (cached == null || cached.isEmpty) return null;
        return UriAndroidNotificationSound(cached);
      }
      await prefs.setString(_prefsAlarmUriKey, alarmUri);
      return UriAndroidNotificationSound(alarmUri);
    } catch (_) {
      final cached = prefs.getString(_prefsAlarmUriKey);
      if (cached == null || cached.isEmpty) return null;
      return UriAndroidNotificationSound(cached);
    }
  }

  // ── Legacy single-reminder API ────────────────────────────────────────────

  static Future<void> scheduleReminder({
    required int hour,
    required int minute,
    String? title,
    String? instruction,
  }) async {
    final t = (title == null || title.trim().isEmpty)
        ? defaultTitle
        : title.trim();
    final i = (instruction == null || instruction.trim().isEmpty)
        ? defaultInstruction
        : instruction.trim();
    if (Platform.isAndroid) {
      await _cancelActiveAlarmNotifications();
      await _plugin.cancel(id: _statusNotificationId);
      await _alarmChannel.invokeMethod<void>('scheduleAlarm', {
        'hour': hour,
        'minute': minute,
        'title': t,
        'instruction': i,
      });
      return;
    }
    await _ensureTimezoneInitialized();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_prefsHourKey, hour);
    await prefs.setInt(_prefsMinuteKey, minute);
    await prefs.setString(_prefsTitleKey, t);
    await prefs.setString(_prefsInstructionKey, i);
    await _cancelActiveAlarmNotifications();
    await _scheduleDailyAlarm(
      hour: hour,
      minute: minute,
      title: t,
      instruction: i,
    );
  }

  // ── Window-alarm API (3 notifications per meal) ───────────────────────────

  /// Schedules up to 3 alarms for [window], spaced across the meal time window.
  ///
  ///   Slot 0 — start time        → "Time for <Meal>!"
  ///   Slot 1 — midpoint          → "Still time — have you eaten?" (skipped if window ≤ 60 min)
  ///   Slot 2 — end minus 30 min  → "30 minutes left!" (skipped if window ≤ 30 min)
  ///
  /// Each slot uses ID = [window.baseAlarmId] + slotIndex so cancellation
  /// by mealKey works on both Android (native) and iOS (plugin).
  static Future<void> scheduleMealWindowAlarms(MealWindowConfig window) async {
    if (!window.enabled) {
      await cancelMealWindowAlarms(window.mealKey);
      return;
    }

    final slots = _deriveWindowSlots(window);
    for (final slot in slots) {
      await scheduleMealAlarm(slot);
    }
  }

  /// Cancels all 3 slot alarms for the given [mealKey].
  /// Called immediately when the user marks a meal as complete.
  static Future<void> cancelMealWindowAlarms(String mealKey) async {
    // Android — one native call cancels by mealKey across all stored configs.
    if (Platform.isAndroid) {
      await _alarmChannel.invokeMethod<void>('cancelMealWindowAlarms', {
        'mealKey': mealKey,
      });
    }

    // Fallback / iOS — cancel by iterating saved configs filtered by mealKey.
    final all = await getSavedMealAlarmConfigs();
    final toCancel = all.where(
      (c) => c.mealKey.trim().toLowerCase() == mealKey.trim().toLowerCase(),
    );
    for (final config in toCancel) {
      await _plugin.cancel(id: config.id);
      await _plugin.cancel(id: _multiSnoozeIdOffset + config.id);
      await _plugin.cancel(id: _multiStatusIdOffset + config.id);
      await deleteMealAlarmConfig(config.id);
    }
  }

  /// Derives the MealAlarmConfig list for each slot of [window].
  static List<MealAlarmConfig> _deriveWindowSlots(MealWindowConfig window) {
    final mealLabel = _capitalize(window.mealKey);
    final windowMin = window.windowMinutes;

    final slots = <MealAlarmConfig>[];

    // Helper — builds a config with all shared window fields pre-filled.
    MealAlarmConfig slot({
      required int id,
      required int hour,
      required int minute,
      required String title,
      required String instruction,
    }) => MealAlarmConfig(
      id: id,
      mealKey: window.mealKey,
      hour: hour,
      minute: minute,
      title: title,
      instruction: instruction,
      enabled: true,
      endHour: window.endHour,
      endMinute: window.endMinute,
      kcal: window.kcal,
      proteinG: window.proteinG,
      carbsG: window.carbsG,
      fatG: window.fatG,
    );

    // Slot 0 — always: start time
    slots.add(
      slot(
        id: window.baseAlarmId,
        hour: window.startHour,
        minute: window.startMinute,
        title: '$mealLabel Time!',
        instruction: 'Your $mealLabel window is open. Time to eat!',
      ),
    );

    // Slot 1 — midpoint (only if window > 60 minutes)
    if (windowMin > 60) {
      final midTotalMin =
          (window.startHour * 60 + window.startMinute) + windowMin ~/ 2;
      slots.add(
        slot(
          id: window.baseAlarmId + 1,
          hour: (midTotalMin ~/ 60) % 24,
          minute: midTotalMin % 60,
          title: '$mealLabel Reminder',
          instruction:
              'Halfway through your $mealLabel window. Have you eaten yet?',
        ),
      );
    }

    // Slot 2 — 30 min before end (only if window > 30 minutes)
    if (windowMin > 30) {
      final endTotalMin = window.endHour * 60 + window.endMinute;
      final startTotalMin = window.startHour * 60 + window.startMinute;
      final preCloseTotalMin = endTotalMin - 30;
      if (preCloseTotalMin > startTotalMin) {
        slots.add(
          slot(
            id: window.baseAlarmId + 2,
            hour: (preCloseTotalMin ~/ 60) % 24,
            minute: preCloseTotalMin % 60,
            title: '$mealLabel Window Closing',
            instruction:
                '30 minutes left to complete your $mealLabel. Don\'t miss it!',
          ),
        );
      }
    }

    return slots;
  }

  // ── Single-alarm CRUD (unchanged — used by custom alarm tab) ─────────────

  static Future<List<MealAlarmConfig>> getSavedMealAlarmConfigs() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsMealAlarmsKey);
    if (raw == null || raw.isEmpty) return const <MealAlarmConfig>[];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return const <MealAlarmConfig>[];
      return decoded
          .map((item) => MealAlarmConfig.fromJson(item))
          .whereType<MealAlarmConfig>()
          .toList(growable: false);
    } catch (_) {
      return const <MealAlarmConfig>[];
    }
  }

  static Future<MealAlarmConfig?> getSavedMealAlarmConfig(int id) async {
    final items = await getSavedMealAlarmConfigs();
    for (final item in items) {
      if (item.id == id) return item;
    }
    return null;
  }

  static Future<int> allocateMealAlarmId() async {
    final prefs = await SharedPreferences.getInstance();
    final nextId = prefs.getInt(_prefsMealAlarmsNextIdKey);
    if (nextId == null || nextId < _multiAlarmIdStart) {
      await prefs.setInt(_prefsMealAlarmsNextIdKey, _multiAlarmIdStart + 1);
      return _multiAlarmIdStart;
    }
    await prefs.setInt(_prefsMealAlarmsNextIdKey, nextId + 1);
    return nextId;
  }

  /// Allocates 3 consecutive IDs for a meal window's slots.
  static Future<int> allocateMealWindowBaseId() async {
    final prefs = await SharedPreferences.getInstance();
    final nextId = prefs.getInt(_prefsMealAlarmsNextIdKey);
    final base = (nextId == null || nextId < _multiAlarmIdStart)
        ? _multiAlarmIdStart
        : nextId;
    // Reserve base, base+1, base+2
    await prefs.setInt(_prefsMealAlarmsNextIdKey, base + 3);
    return base;
  }

  static Future<void> upsertMealAlarmConfig(MealAlarmConfig config) async {
    final prefs = await SharedPreferences.getInstance();
    final items = (await getSavedMealAlarmConfigs()).toList(growable: true);
    final idx = items.indexWhere((item) => item.id == config.id);
    if (idx == -1)
      items.add(config);
    else
      items[idx] = config;
    await prefs.setString(
      _prefsMealAlarmsKey,
      jsonEncode(items.map((e) => e.toJson()).toList()),
    );
  }

  static Future<void> deleteMealAlarmConfig(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final items = (await getSavedMealAlarmConfigs())
        .where((item) => item.id != id)
        .toList(growable: false);
    await prefs.setString(
      _prefsMealAlarmsKey,
      jsonEncode(items.map((e) => e.toJson()).toList()),
    );
  }

  static Future<void> scheduleMealAlarm(MealAlarmConfig config) async {
    await upsertMealAlarmConfig(config);
    await _plugin.cancel(id: config.id);
    await _plugin.cancel(id: _multiSnoozeIdOffset + config.id);
    await _plugin.cancel(id: _multiStatusIdOffset + config.id);

    if (Platform.isAndroid) {
      if (!config.enabled) {
        await _alarmChannel.invokeMethod<void>('cancelMealAlarm', {
          'alarmId': config.id,
        });
        return;
      }
      await _alarmChannel.invokeMethod<void>('scheduleMealAlarm', {
        'alarmId': config.id,
        'mealKey': config.mealKey,
        'hour': config.hour,
        'minute': config.minute,
        'title': config.title,
        'instruction': config.instruction,
        'enabled': config.enabled,
        'windowSlot': -1, // custom alarms have no window slot
        'endHour': config.endHour,
        'endMinute': config.endMinute,
        'kcal': config.kcal,
        'proteinG': config.proteinG,
        'carbsG': config.carbsG,
        'fatG': config.fatG,
      });
      return;
    }

    await _ensureTimezoneInitialized();
    if (!config.enabled) return;

    final now = DateTime.now();
    final scheduled = DateTime(
      now.year,
      now.month,
      now.day,
      config.hour,
      config.minute,
    );
    final next = scheduled.isBefore(now)
        ? scheduled.add(const Duration(days: 1))
        : scheduled;

    await _scheduleOneTimeAlarm(
      id: config.id,
      scheduledDate: tz.TZDateTime.from(next, tz.local),
      alarmData: AlarmLaunchData(
        title: config.title,
        instruction: config.instruction,
        hour: config.hour,
        minute: config.minute,
        alarmId: config.id,
        mealKey: config.mealKey,
      ),
      notificationBody: config.instruction,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  /// Schedules a window-slot alarm. Unlike [scheduleMealAlarm], this passes
  /// the slot index to Android so the "✓ Done" action is shown on slots 1 & 2.
  static Future<void> _scheduleMealWindowSlot({
    required MealAlarmConfig config,
    required int windowSlot,
  }) async {
    await upsertMealAlarmConfig(config);
    await _plugin.cancel(id: config.id);
    await _plugin.cancel(id: _multiSnoozeIdOffset + config.id);
    await _plugin.cancel(id: _multiStatusIdOffset + config.id);

    if (Platform.isAndroid) {
      if (!config.enabled) {
        await _alarmChannel.invokeMethod<void>('cancelMealAlarm', {
          'alarmId': config.id,
        });
        return;
      }
      await _alarmChannel.invokeMethod<void>('scheduleMealAlarm', {
        'alarmId': config.id,
        'mealKey': config.mealKey,
        'hour': config.hour,
        'minute': config.minute,
        'title': config.title,
        'instruction': config.instruction,
        'enabled': config.enabled,
        'windowSlot': windowSlot,
        'endHour': config.endHour,
        'endMinute': config.endMinute,
        'kcal': config.kcal,
        'proteinG': config.proteinG,
        'carbsG': config.carbsG,
        'fatG': config.fatG,
      });
      return;
    }

    // iOS — same as scheduleMealAlarm (no native Done action on iOS)
    await _ensureTimezoneInitialized();
    if (!config.enabled) return;

    final now = DateTime.now();
    final scheduled = DateTime(
      now.year,
      now.month,
      now.day,
      config.hour,
      config.minute,
    );
    final next = scheduled.isBefore(now)
        ? scheduled.add(const Duration(days: 1))
        : scheduled;

    await _scheduleOneTimeAlarm(
      id: config.id,
      scheduledDate: tz.TZDateTime.from(next, tz.local),
      alarmData: AlarmLaunchData(
        title: config.title,
        instruction: config.instruction,
        hour: config.hour,
        minute: config.minute,
        alarmId: config.id,
        mealKey: config.mealKey,
      ),
      notificationBody: config.instruction,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  static Future<void> scheduleMealAlarms(
    Iterable<MealAlarmConfig> configs,
  ) async {
    for (final config in configs) {
      await scheduleMealAlarm(config);
    }
  }

  static Future<void> cancelMealAlarm(int id) async {
    await _plugin.cancel(id: id);
    await _plugin.cancel(id: _multiSnoozeIdOffset + id);
    await _plugin.cancel(id: _multiStatusIdOffset + id);
    if (Platform.isAndroid) {
      await _alarmChannel.invokeMethod<void>('cancelMealAlarm', {
        'alarmId': id,
      });
    }
  }

  static Future<void> cancelAllMealAlarms() async {
    final configs = await getSavedMealAlarmConfigs();
    if (Platform.isAndroid) {
      await _alarmChannel.invokeMethod<void>('cancelAllMealAlarms');
      for (final config in configs) {
        await _plugin.cancel(id: config.id);
        await _plugin.cancel(id: _multiSnoozeIdOffset + config.id);
        await _plugin.cancel(id: _multiStatusIdOffset + config.id);
      }
      return;
    }
    for (final config in configs) {
      await cancelMealAlarm(config.id);
    }
  }

  static Future<void> clearAllMealAlarms() async {
    await cancelAllMealAlarms();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefsMealAlarmsKey);
  }

  static Future<void> _restoreMealAlarmSchedule(int alarmId) async {
    final config = await getSavedMealAlarmConfig(alarmId);
    if (config == null || !config.enabled) return;
    await scheduleMealAlarm(config);
  }

  // ── Stop / snooze ──────────────────────────────────────────────────────────

  static Future<void> stopAlarm({int? alarmId}) async {
    if (alarmId == null ||
        alarmId == _dailyAlarmId ||
        alarmId == _snoozeAlarmId) {
      if (Platform.isAndroid) {
        await _alarmChannel.invokeMethod<void>('stopAlarm');
        return;
      }
      await _cancelActiveAlarmNotifications();
      await _restoreDailyAlarmSchedule();
      return;
    }
    await cancelMealAlarm(alarmId);
    await _restoreMealAlarmSchedule(alarmId);
  }

  static Future<void> snoozeAlarm({int? alarmId}) async {
    if (alarmId == null ||
        alarmId == _dailyAlarmId ||
        alarmId == _snoozeAlarmId) {
      if (Platform.isAndroid) {
        await _alarmChannel.invokeMethod<void>('snoozeAlarm');
        return;
      }
      const snoozeDuration = Duration(seconds: 30);
      await _ensureTimezoneInitialized();
      final alarmData = await getSavedAlarmData();
      await _cancelActiveAlarmNotifications();
      await _restoreDailyAlarmSchedule();
      await _scheduleOneTimeAlarm(
        id: _snoozeAlarmId,
        scheduledDate: tz.TZDateTime.now(tz.local).add(snoozeDuration),
        alarmData:
            alarmData ??
            const AlarmLaunchData(
              title: defaultTitle,
              instruction: defaultInstruction,
              hour: 0,
              minute: 0,
            ),
        notificationBody: 'Snoozed meal alarm is ringing',
      );
      await _showSnoozeMessage(snoozeDuration);
      return;
    }

    const snoozeDuration = Duration(seconds: 30);
    await _ensureTimezoneInitialized();
    final config = await getSavedMealAlarmConfig(alarmId);
    if (config == null) {
      await cancelMealAlarm(alarmId);
      return;
    }
    await cancelMealAlarm(alarmId);
    await _restoreMealAlarmSchedule(alarmId);
    await _scheduleOneTimeAlarm(
      id: _multiSnoozeIdOffset + alarmId,
      scheduledDate: tz.TZDateTime.now(tz.local).add(snoozeDuration),
      alarmData: AlarmLaunchData(
        title: config.title,
        instruction: config.instruction,
        hour: config.hour,
        minute: config.minute,
        alarmId: config.id,
        mealKey: config.mealKey,
      ),
      notificationBody: 'Snoozed meal alarm is ringing',
    );
    await _showSnoozeMessage(
      snoozeDuration,
      id: _multiStatusIdOffset + alarmId,
    );
  }

  // ── Daily alarm (legacy) ───────────────────────────────────────────────────

  static Future<void> _restoreDailyAlarmSchedule() async {
    final prefs = await SharedPreferences.getInstance();
    final hour = prefs.getInt(_prefsHourKey);
    final minute = prefs.getInt(_prefsMinuteKey);
    final title = prefs.getString(_prefsTitleKey) ?? defaultTitle;
    final instruction =
        prefs.getString(_prefsInstructionKey) ?? defaultInstruction;
    if (hour == null || minute == null) return;
    await _scheduleDailyAlarm(
      hour: hour,
      minute: minute,
      title: title,
      instruction: instruction,
    );
  }

  static Future<AlarmLaunchData?> getSavedAlarmData() async {
    final prefs = await SharedPreferences.getInstance();
    final hour = prefs.getInt(_prefsHourKey);
    final minute = prefs.getInt(_prefsMinuteKey);
    if (hour == null || minute == null) return null;
    return AlarmLaunchData(
      title: prefs.getString(_prefsTitleKey) ?? defaultTitle,
      instruction: prefs.getString(_prefsInstructionKey) ?? defaultInstruction,
      hour: hour,
      minute: minute,
    );
  }

  static Future<void> _scheduleDailyAlarm({
    required int hour,
    required int minute,
    required String title,
    required String instruction,
  }) async {
    await _ensureTimezoneInitialized();
    final now = DateTime.now();
    final scheduled = DateTime(now.year, now.month, now.day, hour, minute);
    final next = scheduled.isBefore(now)
        ? scheduled.add(const Duration(days: 1))
        : scheduled;
    await _scheduleOneTimeAlarm(
      id: _dailyAlarmId,
      scheduledDate: tz.TZDateTime.from(next, tz.local),
      alarmData: AlarmLaunchData(
        title: title,
        instruction: instruction,
        hour: hour,
        minute: minute,
      ),
      notificationBody: instruction,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  static Future<void> _scheduleOneTimeAlarm({
    required int id,
    required tz.TZDateTime scheduledDate,
    required AlarmLaunchData alarmData,
    required String notificationBody,
    DateTimeComponents? matchDateTimeComponents,
  }) async {
    final alarmSound = await _resolveAlarmSound();
    const int insistentFlag = 4;
    await _plugin.zonedSchedule(
      id: id,
      title: alarmData.title,
      body: notificationBody,
      scheduledDate: scheduledDate,
      payload: alarmData.toPayload(),
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _alarmChannelId,
          _alarmChannelName,
          channelDescription: 'Reminders for meal tracking',
          importance: Importance.max,
          priority: Priority.high,
          category: AndroidNotificationCategory.alarm,
          sound: alarmSound,
          audioAttributesUsage: AudioAttributesUsage.alarm,
          fullScreenIntent: true,
          ongoing: true,
          autoCancel: false,
          additionalFlags: Int32List.fromList(<int>[insistentFlag]),
          actions: const <AndroidNotificationAction>[
            AndroidNotificationAction(_snoozeActionId, 'Snooze'),
            AndroidNotificationAction(_stopActionId, 'Stop'),
          ],
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.alarmClock,
      matchDateTimeComponents: matchDateTimeComponents,
    );
  }

  static Future<void> _cancelActiveAlarmNotifications() async {
    await _plugin.cancel(id: _dailyAlarmId);
    await _plugin.cancel(id: _snoozeAlarmId);
  }

  static Future<void> _showSnoozeMessage(
    Duration duration, {
    int id = _statusNotificationId,
  }) async {
    await _plugin.show(
      id: id,
      title: 'Alarm Snoozed',
      body: 'Alarm will ring again after ${duration.inSeconds} seconds.',
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          _statusChannelId,
          _statusChannelName,
          channelDescription: 'Status messages for meal alarms',
          importance: Importance.low,
          priority: Priority.low,
          playSound: false,
          enableVibration: false,
        ),
        iOS: DarwinNotificationDetails(presentSound: false),
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  static String _capitalize(String value) =>
      value.isEmpty ? value : value[0].toUpperCase() + value.substring(1);
}
