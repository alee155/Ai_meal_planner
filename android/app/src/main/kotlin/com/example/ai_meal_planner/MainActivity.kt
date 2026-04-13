package com.example.ai_meal_planner

import android.media.RingtoneManager
import java.util.TimeZone
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val alarmChannelName = "com.example.ai_meal_planner/alarm"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            alarmChannelName,
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "scheduleAlarm" -> {
                    val hour = call.argument<Int>("hour")
                    val minute = call.argument<Int>("minute")
                    val title = call.argument<String>("title")
                    val instruction = call.argument<String>("instruction")

                    if (hour == null || minute == null || title == null || instruction == null) {
                        result.error("invalid_args", "Missing alarm arguments", null)
                        return@setMethodCallHandler
                    }

                    AlarmScheduler.scheduleDaily(
                        applicationContext,
                        hour,
                        minute,
                        title,
                        instruction,
                    )
                    result.success(null)
                }
                "stopAlarm" -> {
                    AlarmScheduler.stopAlarm(applicationContext)
                    result.success(null)
                }
                "snoozeAlarm" -> {
                    AlarmScheduler.snoozeAlarm(applicationContext, showToast = false)
                    result.success(null)
                }
                "getAlarmUri" -> {
                    result.success(
                        RingtoneManager.getDefaultUri(RingtoneManager.TYPE_ALARM)?.toString(),
                    )
                }
                "getLocalTimezone" -> {
                    result.success(TimeZone.getDefault().id)
                }

                else -> result.notImplemented()
            }
        }
    }
}
