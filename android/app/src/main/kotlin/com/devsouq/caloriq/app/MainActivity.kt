package com.devsouq.caloriq.app

import android.media.RingtoneManager
import java.util.TimeZone
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val alarmChannelName = "com.devsouq.caloriq.app/alarm"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            alarmChannelName,
        ).setMethodCallHandler { call, result ->
            when (call.method) {

                // ── Legacy single-alarm API ─────────────────────────────────
                "scheduleAlarm" -> {
                    val hour        = call.argument<Int>("hour")
                    val minute      = call.argument<Int>("minute")
                    val title       = call.argument<String>("title")
                    val instruction = call.argument<String>("instruction")
                    if (hour == null || minute == null || title == null || instruction == null) {
                        result.error("invalid_args", "Missing alarm arguments", null); return@setMethodCallHandler
                    }
                    AlarmScheduler.scheduleDaily(applicationContext, hour, minute, title, instruction)
                    result.success(null)
                }

                // ── Schedule one alarm (called per window slot) ─────────────
                "scheduleMealAlarm" -> {
                    val alarmId     = call.argument<Int>("alarmId")
                    val hour        = call.argument<Int>("hour")
                    val minute      = call.argument<Int>("minute")
                    val title       = call.argument<String>("title")
                    val instruction = call.argument<String>("instruction")
                    val mealKey     = call.argument<String>("mealKey")
                    val enabled     = call.argument<Boolean>("enabled") ?: true
                    val windowSlot  = call.argument<Int>("windowSlot") ?: -1
                    if (alarmId == null || hour == null || minute == null || title == null || instruction == null) {
                        result.error("invalid_args", "Missing alarm arguments", null); return@setMethodCallHandler
                    }
                    val endHour   = call.argument<Int>("endHour")   ?: -1
                    val endMinute = call.argument<Int>("endMinute") ?: -1
                    val kcal      = call.argument<Int>("kcal")      ?: -1
                    val proteinG  = call.argument<Int>("proteinG")  ?: -1
                    val carbsG    = call.argument<Int>("carbsG")    ?: -1
                    val fatG      = call.argument<Int>("fatG")      ?: -1
                    AlarmScheduler.scheduleMealAlarm(
                        applicationContext,
                        AlarmConfig(
                            id = alarmId, mealKey = mealKey,
                            title = title, instruction = instruction,
                            hour = hour, minute = minute,
                            enabled = enabled, windowSlot = windowSlot,
                            endHour = endHour, endMinute = endMinute,
                            kcal = kcal, proteinG = proteinG,
                            carbsG = carbsG, fatG = fatG,
                        ),
                    )
                    result.success(null)
                }

                // ── Cancel one alarm by ID ──────────────────────────────────
                "cancelMealAlarm" -> {
                    val alarmId = call.argument<Int>("alarmId")
                    if (alarmId == null) {
                        result.error("invalid_args", "Missing alarmId", null); return@setMethodCallHandler
                    }
                    AlarmScheduler.cancelMealAlarm(applicationContext, alarmId)
                    result.success(null)
                }

                // ── Cancel every alarm for one meal window by mealKey ───────
                "cancelMealWindowAlarms" -> {
                    val mealKey = call.argument<String>("mealKey")
                    if (mealKey.isNullOrBlank()) {
                        result.error("invalid_args", "Missing mealKey", null); return@setMethodCallHandler
                    }
                    AlarmScheduler.cancelMealWindowAlarms(applicationContext, mealKey)
                    result.success(null)
                }

                // ── Cancel everything ───────────────────────────────────────
                "cancelAllMealAlarms" -> {
                    AlarmScheduler.cancelAllMealAlarms(applicationContext)
                    result.success(null)
                }

                // ── Stop / snooze ───────────────────────────────────────────
                "stopAlarm" -> {
                    val alarmId = call.argument<Int>("alarmId") ?: 1
                    AlarmScheduler.stopAlarm(applicationContext, alarmId)
                    result.success(null)
                }
                "snoozeAlarm" -> {
                    val alarmId = call.argument<Int>("alarmId") ?: 1
                    AlarmScheduler.snoozeAlarm(applicationContext, alarmId, showToast = false)
                    result.success(null)
                }

                // ── Device info ─────────────────────────────────────────────
                "getAlarmUri" -> {
                    result.success(RingtoneManager.getDefaultUri(RingtoneManager.TYPE_ALARM)?.toString())
                }
                "getLocalTimezone" -> {
                    result.success(TimeZone.getDefault().id)
                }

                else -> result.notImplemented()
            }
        }
    }
}