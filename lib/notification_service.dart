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

class MealAlarmConfig {
  const MealAlarmConfig({
    required this.id,
    required this.mealKey,
    required this.title,
    required this.instruction,
    required this.hour,
    required this.minute,
    required this.enabled,
  });

  final int id;
  final String mealKey;
  final String title;
  final String instruction;
  final int hour;
  final int minute;
  final bool enabled;

  MealAlarmConfig copyWith({
    int? id,
    String? mealKey,
    String? title,
    String? instruction,
    int? hour,
    int? minute,
    bool? enabled,
  }) {
    return MealAlarmConfig(
      id: id ?? this.id,
      mealKey: mealKey ?? this.mealKey,
      title: title ?? this.title,
      instruction: instruction ?? this.instruction,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
      enabled: enabled ?? this.enabled,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'mealKey': mealKey,
      'title': title,
      'instruction': instruction,
      'hour': hour,
      'minute': minute,
      'enabled': enabled,
    };
  }

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
        minute is! int) {
      return null;
    }

    return MealAlarmConfig(
      id: id,
      mealKey: mealKey,
      title: title,
      instruction: instruction,
      hour: hour,
      minute: minute,
      enabled: map['enabled'] is bool ? map['enabled'] as bool : true,
    );
  }
}

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

  String toPayload() {
    return jsonEncode({
      'type': 'meal_alarm',
      'alarmId': alarmId,
      'mealKey': mealKey,
      'title': title,
      'instruction': instruction,
      'hour': hour,
      'minute': minute,
    });
  }

  static AlarmLaunchData? fromPayload(String? payload) {
    if (payload == null || payload.isEmpty) {
      return null;
    }

    try {
      final decoded = jsonDecode(payload);
      if (decoded is! Map) {
        return null;
      }
      final payloadMap = Map<String, dynamic>.from(decoded);
      if (payloadMap['type'] != 'meal_alarm') {
        return null;
      }

      return AlarmLaunchData(
        title:
            payloadMap['title'] as String? ?? NotificationService.defaultTitle,
        instruction:
            payloadMap['instruction'] as String? ??
            NotificationService.defaultInstruction,
        hour: payloadMap['hour'] as int? ?? 0,
        minute: payloadMap['minute'] as int? ?? 0,
        alarmId: payloadMap['alarmId'] as int?,
        mealKey: payloadMap['mealKey'] as String?,
      );
    } catch (_) {
      return null;
    }
  }
}

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  static const MethodChannel _alarmChannel = MethodChannel(
    'com.example.ai_meal_planner/alarm',
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

    const settings = InitializationSettings(
      android: androidInit,
      iOS: darwinInit,
      macOS: darwinInit,
    );

    await _plugin.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: _onNotificationResponse,
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );

    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    // Android 13+ notifications permission.
    await androidPlugin?.requestNotificationsPermission();

    // Android 14+ exact alarm permission for exactAllowWhileIdle schedules.
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
    if (resolvedAlarmData == null || Get.key.currentContext == null) {
      return;
    }

    // Log an in-app "notification inbox" item when an alarm is opened/rings.
    // This is what powers the bell badge + Notifications screen.
    try {
      await InAppInboxStore.add(
        InAppInboxItem(
          id: 0, // overwritten by store
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

      // Keep the bell badge in sync if the controller is alive.
      if (Get.isRegistered<NotificationsInboxController>()) {
        unawaited(Get.find<NotificationsInboxController>().reload());
      }
    } catch (_) {
      // Ignore logging failures; never block the alarm UI.
    }

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
      } catch (_) {
        // Fall back to UTC below if the device timezone isn't in the tz db.
      }
    }

    tz.setLocalLocation(tz.UTC);
  }

  static Future<AndroidNotificationSound?> _resolveAlarmSound() async {
    if (!Platform.isAndroid) {
      return null;
    }

    if (_customAlarmSoundName != null) {
      return RawResourceAndroidNotificationSound(_customAlarmSoundName!);
    }

    final prefs = await SharedPreferences.getInstance();

    try {
      final alarmUri = await _alarmChannel.invokeMethod<String>('getAlarmUri');
      if (alarmUri == null || alarmUri.isEmpty) {
        final cachedAlarmUri = prefs.getString(_prefsAlarmUriKey);
        if (cachedAlarmUri == null || cachedAlarmUri.isEmpty) {
          return null;
        }
        return UriAndroidNotificationSound(cachedAlarmUri);
      }
      await prefs.setString(_prefsAlarmUriKey, alarmUri);
      return UriAndroidNotificationSound(alarmUri);
    } catch (_) {
      final cachedAlarmUri = prefs.getString(_prefsAlarmUriKey);
      if (cachedAlarmUri == null || cachedAlarmUri.isEmpty) {
        return null;
      }
      return UriAndroidNotificationSound(cachedAlarmUri);
    }
  }

  static Future<void> scheduleReminder({
    required int hour,
    required int minute,
    String? title,
    String? instruction,
  }) async {
    final normalizedTitle = (title == null || title.trim().isEmpty)
        ? defaultTitle
        : title.trim();
    final normalizedInstruction =
        (instruction == null || instruction.trim().isEmpty)
        ? defaultInstruction
        : instruction.trim();

    if (Platform.isAndroid) {
      await _cancelActiveAlarmNotifications();
      await _plugin.cancel(id: _statusNotificationId);
      await _alarmChannel.invokeMethod<void>('scheduleAlarm', {
        'hour': hour,
        'minute': minute,
        'title': normalizedTitle,
        'instruction': normalizedInstruction,
      });
      return;
    }

    await _ensureTimezoneInitialized();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_prefsHourKey, hour);
    await prefs.setInt(_prefsMinuteKey, minute);
    await prefs.setString(_prefsTitleKey, normalizedTitle);
    await prefs.setString(_prefsInstructionKey, normalizedInstruction);

    await _cancelActiveAlarmNotifications();
    await _scheduleDailyAlarm(
      hour: hour,
      minute: minute,
      title: normalizedTitle,
      instruction: normalizedInstruction,
    );
  }

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

  static Future<void> upsertMealAlarmConfig(MealAlarmConfig config) async {
    final prefs = await SharedPreferences.getInstance();
    final items = (await getSavedMealAlarmConfigs()).toList(growable: true);
    final existingIndex = items.indexWhere((item) => item.id == config.id);
    if (existingIndex == -1) {
      items.add(config);
    } else {
      items[existingIndex] = config;
    }
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
      });
      return;
    }

    await _ensureTimezoneInitialized();

    if (!config.enabled) {
      return;
    }

    final now = DateTime.now();
    final scheduled = DateTime(
      now.year,
      now.month,
      now.day,
      config.hour,
      config.minute,
    );
    final nextOccurrence = scheduled.isBefore(now)
        ? scheduled.add(const Duration(days: 1))
        : scheduled;

    await _scheduleOneTimeAlarm(
      id: config.id,
      scheduledDate: tz.TZDateTime.from(nextOccurrence, tz.local),
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

  static Future<void> stopAlarm({int? alarmId}) async {
    // Backwards compatible: "single alarm" flow.
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

    // Multi-alarm flow (Flutter Local Notifications on all platforms).
    await cancelMealAlarm(alarmId);
    await _restoreMealAlarmSchedule(alarmId);
  }

  static Future<void> snoozeAlarm({int? alarmId}) async {
    // Backwards compatible: "single alarm" flow.
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

  static Future<void> _restoreDailyAlarmSchedule() async {
    final prefs = await SharedPreferences.getInstance();
    final hour = prefs.getInt(_prefsHourKey);
    final minute = prefs.getInt(_prefsMinuteKey);
    final title = prefs.getString(_prefsTitleKey) ?? defaultTitle;
    final instruction =
        prefs.getString(_prefsInstructionKey) ?? defaultInstruction;

    if (hour == null || minute == null) {
      return;
    }

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

    if (hour == null || minute == null) {
      return null;
    }

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
    final nextOccurrence = scheduled.isBefore(now)
        ? scheduled.add(const Duration(days: 1))
        : scheduled;

    await _scheduleOneTimeAlarm(
      id: _dailyAlarmId,
      scheduledDate: tz.TZDateTime.from(nextOccurrence, tz.local),
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

    // This makes Android keep alerting until the user acknowledges it.
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
    final seconds = duration.inSeconds;
    await _plugin.show(
      id: id,
      title: 'Alarm Snoozed',
      body: 'Alarm will ring again after $seconds seconds.',
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
}
