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

import 'routes/app_routes.dart';

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  NotificationService.handleNotificationResponse(notificationResponse);
}

class AlarmLaunchData {
  const AlarmLaunchData({
    required this.title,
    required this.instruction,
    required this.hour,
    required this.minute,
  });

  final String title;
  final String instruction;
  final int hour;
  final int minute;

  String toPayload() {
    return jsonEncode({
      'type': 'meal_alarm',
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
    switch (response.actionId) {
      case _stopActionId:
        await stopAlarm();
        break;
      case _snoozeActionId:
        await snoozeAlarm();
        break;
      default:
        await _openAlarmScreen(
          alarmData: AlarmLaunchData.fromPayload(response.payload),
        );
        break;
    }
  }

  static Future<AlarmLaunchData?> getLaunchAlarmData() async {
    final details = await _plugin.getNotificationAppLaunchDetails();
    return AlarmLaunchData.fromPayload(
      details?.notificationResponse?.payload,
    );
  }

  static Future<void> _openAlarmScreen({AlarmLaunchData? alarmData}) async {
    final resolvedAlarmData = alarmData ?? await getSavedAlarmData();
    if (resolvedAlarmData == null || Get.key.currentContext == null) {
      return;
    }

    if (Get.currentRoute == AppRoutes.alarmRinging) {
      await Get.offNamed(
        AppRoutes.alarmRinging,
        arguments: resolvedAlarmData,
      );
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
    final normalizedTitle =
        (title == null || title.trim().isEmpty) ? defaultTitle : title.trim();
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

  static Future<void> stopAlarm() async {
    if (Platform.isAndroid) {
      await _alarmChannel.invokeMethod<void>('stopAlarm');
      return;
    }

    await _cancelActiveAlarmNotifications();
    await _restoreDailyAlarmSchedule();
  }

  static Future<void> snoozeAlarm() async {
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

  static Future<void> _showSnoozeMessage(Duration duration) async {
    final seconds = duration.inSeconds;
    await _plugin.show(
      id: _statusNotificationId,
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
