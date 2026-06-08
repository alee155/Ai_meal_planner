package com.devsouq.caloriq.app

import android.Manifest
import android.app.AlarmManager
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.graphics.BitmapFactory
import android.os.Build
import android.widget.Toast
import androidx.core.app.NotificationCompat
import androidx.core.content.ContextCompat
import org.json.JSONArray
import org.json.JSONObject
import java.util.Calendar

data class AlarmConfig(
    val id: Int,
    val mealKey: String?,
    val title: String,
    val instruction: String,
    val hour: Int,
    val minute: Int,
    val enabled: Boolean = true,
    // Slot index within a meal window: 0=start, 1=midpoint, 2=pre-close.
    // -1 means a legacy / custom single alarm (no window context).
    val windowSlot: Int = -1,
    // Window end time — passed to AlarmActivity for UI display.
    val endHour: Int = -1,
    val endMinute: Int = -1,
    // Meal macro data — shown on the alarm screen card.
    val kcal: Int = -1,
    val proteinG: Int = -1,
    val carbsG: Int = -1,
    val fatG: Int = -1,
)

object AlarmScheduler {
    private const val preferencesName = "native_alarm_preferences_v2"
    private const val alarmsKey = "alarms_json"

    private const val channelId = "native_meal_alarm_channel"
    private const val channelName = "Native Meal Alarms"
    private const val channelDescription = "Native lock-screen meal alarms"

    const val actionTriggerDaily  = "com.devsouq.caloriq.app.ALARM_TRIGGER_DAILY"
    const val actionTriggerSnooze = "com.devsouq.caloriq.app.ALARM_TRIGGER_SNOOZE"
    const val actionStop          = "com.devsouq.caloriq.app.ALARM_STOP"
    const val actionSnooze        = "com.devsouq.caloriq.app.ALARM_SNOOZE"
    // Fired from the alarm notification "Done" action button — marks meal complete
    // and cancels all remaining window alarms without opening the app.
    const val actionMealDone      = "com.devsouq.caloriq.app.MEAL_DONE"

    const val extraAlarmId    = "extra_alarm_id"
    const val extraMealKey    = "extra_alarm_meal_key"
    const val extraTitle      = "extra_alarm_title"
    const val extraInstruction = "extra_alarm_instruction"
    const val extraHour       = "extra_alarm_hour"
    const val extraMinute     = "extra_alarm_minute"
    const val extraWindowSlot = "extra_alarm_window_slot"

    private const val dailyRequestBase         = 42000
    private const val snoozeRequestBase        = 52000
    private const val fullscreenRequestBase    = 62000
    private const val stopRequestBase          = 72000
    private const val snoozeActionRequestBase  = 82000
    private const val notificationBase         = 92000
    private const val mealDoneRequestBase      = 102000

    // ── Backwards-compatible single-alarm API ────────────────────────────────

    fun scheduleDaily(context: Context, hour: Int, minute: Int, title: String, instruction: String) {
        scheduleMealAlarm(
            context = context,
            config = AlarmConfig(
                id = 1, mealKey = null,
                title = title, instruction = instruction,
                hour = hour, minute = minute, enabled = true,
            ),
        )
    }

    // ── Core single-alarm schedule/cancel ────────────────────────────────────

    fun scheduleMealAlarm(context: Context, config: AlarmConfig) {
        if (config.id <= 0) return
        upsertAlarmConfig(context, config)
        cancelScheduledAlarm(context, actionTriggerDaily, dailyRequestCode(config.id), config.id)
        cancelScheduledAlarm(context, actionTriggerSnooze, snoozeRequestCode(config.id), config.id)
        dismissAlarmUi(context, config.id)
        if (config.enabled) {
            scheduleNextDailyOccurrence(context, config)
        } else {
            val mgr = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            mgr.cancel(notificationIdFor(config.id))
        }
    }

    fun cancelMealAlarm(context: Context, alarmId: Int) {
        if (alarmId <= 0) return
        removeAlarmConfig(context, alarmId)
        cancelScheduledAlarm(context, actionTriggerDaily, dailyRequestCode(alarmId), alarmId)
        cancelScheduledAlarm(context, actionTriggerSnooze, snoozeRequestCode(alarmId), alarmId)
        dismissAlarmUi(context, alarmId)
    }

    fun cancelAllMealAlarms(context: Context) {
        val alarms = loadAlarmConfigs(context)
        for (config in alarms) {
            cancelScheduledAlarm(context, actionTriggerDaily, dailyRequestCode(config.id), config.id)
            cancelScheduledAlarm(context, actionTriggerSnooze, snoozeRequestCode(config.id), config.id)
            dismissAlarmUi(context, config.id)
        }
        saveAlarmConfigs(context, emptyList())
    }

    // ── Window-alarm helpers (called from Flutter via MethodChannel) ──────────

    /**
     * Cancels all saved alarms whose mealKey matches [mealKey].
     * Called when the user marks a meal as complete — silences all remaining
     * reminders for that meal window without touching other meals.
     */
    fun cancelMealWindowAlarms(context: Context, mealKey: String) {
        val normalised = mealKey.trim().lowercase()
        val all = loadAlarmConfigs(context)
        val remaining = mutableListOf<AlarmConfig>()

        for (config in all) {
            if (config.mealKey?.trim()?.lowercase() == normalised) {
                cancelScheduledAlarm(context, actionTriggerDaily, dailyRequestCode(config.id), config.id)
                cancelScheduledAlarm(context, actionTriggerSnooze, snoozeRequestCode(config.id), config.id)
                dismissAlarmUi(context, config.id)
            } else {
                remaining.add(config)
            }
        }
        saveAlarmConfigs(context, remaining)
    }

    // ── Stop / snooze ─────────────────────────────────────────────────────────

    fun stopAlarm(context: Context) = stopAlarm(context, alarmId = 1)

    fun stopAlarm(context: Context, alarmId: Int) {
        cancelScheduledAlarm(context, actionTriggerSnooze, snoozeRequestCode(alarmId), alarmId)
        dismissAlarmUi(context, alarmId)
    }

    fun snoozeAlarm(context: Context, showToast: Boolean = true) =
        snoozeAlarm(context, alarmId = 1, showToast = showToast)

    fun snoozeAlarm(context: Context, alarmId: Int, showToast: Boolean = true) {
        val config = getSavedAlarmConfig(context, alarmId) ?: return
        cancelScheduledAlarm(context, actionTriggerSnooze, snoozeRequestCode(alarmId), alarmId)
        dismissAlarmUi(context, alarmId)
        scheduleSnooze(context, config, delayMillis = 30_000L)
        if (showToast) {
            Toast.makeText(
                context.applicationContext,
                "Alarm will ring again after 30 seconds.",
                Toast.LENGTH_SHORT,
            ).show()
        }
    }

    // ── Boot reschedule ───────────────────────────────────────────────────────

    fun rescheduleSavedAlarm(context: Context) = rescheduleAllSavedAlarms(context)

    fun rescheduleAllSavedAlarms(context: Context) {
        val configs = loadAlarmConfigs(context).filter { it.enabled }
        for (config in configs) {
            cancelScheduledAlarm(context, actionTriggerDaily, dailyRequestCode(config.id), config.id)
            cancelScheduledAlarm(context, actionTriggerSnooze, snoozeRequestCode(config.id), config.id)
            scheduleNextDailyOccurrence(context, config)
        }
    }

    // ── Alarm fire entry point ────────────────────────────────────────────────

    fun onAlarmTriggered(context: Context, intent: Intent) {
        val alarmId = intent.getIntExtra(extraAlarmId, -1)
        val config = alarmConfigFromIntent(intent) ?: getSavedAlarmConfig(context, alarmId) ?: return
        val isDailyAlarm = intent.action == actionTriggerDaily

        if (isDailyAlarm) {
            scheduleNextDailyOccurrence(context, config)
        }

        logFlutterInboxItem(context, config)
        showFullScreenNotification(context, config)
        AlarmPlaybackManager.start(context)
        launchAlarmActivity(context, config)
    }

    // ── Internal scheduling ───────────────────────────────────────────────────

    private fun scheduleNextDailyOccurrence(context: Context, config: AlarmConfig) {
        val triggerAtMillis = nextTriggerTimeMillis(config.hour, config.minute)
        scheduleAlarmAt(
            context = context,
            triggerAtMillis = triggerAtMillis,
            requestCode = dailyRequestCode(config.id),
            action = actionTriggerDaily,
            config = config,
            useAlarmClock = true,
        )
    }

    private fun scheduleSnooze(context: Context, config: AlarmConfig, delayMillis: Long) {
        val triggerAtMillis = System.currentTimeMillis() + delayMillis
        scheduleAlarmAt(
            context = context,
            triggerAtMillis = triggerAtMillis,
            requestCode = snoozeRequestCode(config.id),
            action = actionTriggerSnooze,
            config = config,
            useAlarmClock = false,
        )
    }

    private fun scheduleAlarmAt(
        context: Context,
        triggerAtMillis: Long,
        requestCode: Int,
        action: String,
        config: AlarmConfig,
        useAlarmClock: Boolean,
    ) {
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val pendingIntent = createAlarmPendingIntent(context, action, requestCode, config)

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP && useAlarmClock) {
            val info = AlarmManager.AlarmClockInfo(triggerAtMillis, pendingIntent)
            alarmManager.setAlarmClock(info, pendingIntent)
            return
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            alarmManager.setExactAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, triggerAtMillis, pendingIntent)
            return
        }

        alarmManager.setExact(AlarmManager.RTC_WAKEUP, triggerAtMillis, pendingIntent)
    }

    // ── Notification ──────────────────────────────────────────────────────────

    private fun showFullScreenNotification(context: Context, config: AlarmConfig) {
        createNotificationChannel(context)

        val activityIntent = AlarmActivity.createIntent(context, config)
        val fullScreenPendingIntent = PendingIntent.getActivity(
            context, fullscreenRequestCode(config.id), activityIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )

        val stopPendingIntent = PendingIntent.getBroadcast(
            context, stopRequestCode(config.id),
            AlarmActionReceiver.createIntent(context, actionStop, config.id),
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )

        val snoozePendingIntent = PendingIntent.getBroadcast(
            context, snoozeActionRequestCode(config.id),
            AlarmActionReceiver.createIntent(context, actionSnooze, config.id),
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )

        // "Done" action — only shown on midpoint (slot 1) and pre-close (slot 2) alarms
        // so the user can silently dismiss all remaining reminders from the notification shade.
        val showDoneAction = config.mealKey != null && config.windowSlot >= 1
        val donePendingIntent = if (showDoneAction) {
            PendingIntent.getBroadcast(
                context, mealDoneRequestCode(config.id),
                AlarmActionReceiver.createIntent(context, actionMealDone, config.id, config.mealKey),
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
            )
        } else null

        val builder = NotificationCompat.Builder(context, channelId)
            .setSmallIcon(R.mipmap.ic_launcher)
            .setLargeIcon(BitmapFactory.decodeResource(context.resources, R.mipmap.ic_launcher))
            .setContentTitle(config.title)
            .setContentText(config.instruction)
            .setPriority(NotificationCompat.PRIORITY_MAX)
            .setCategory(NotificationCompat.CATEGORY_ALARM)
            .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
            .setOngoing(true)
            .setAutoCancel(false)
            .setSound(null)
            .setVibrate(longArrayOf(0L))
            .setContentIntent(fullScreenPendingIntent)
            .setFullScreenIntent(fullScreenPendingIntent, true)
            .addAction(0, "Snooze", snoozePendingIntent)
            .addAction(0, "Stop", stopPendingIntent)

        if (donePendingIntent != null) {
            builder.addAction(0, "✓ Done", donePendingIntent)
        }

        val notification = builder.build()
        val mgr = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.TIRAMISU ||
            ContextCompat.checkSelfPermission(context, Manifest.permission.POST_NOTIFICATIONS)
            == PackageManager.PERMISSION_GRANTED
        ) {
            mgr.notify(notificationIdFor(config.id), notification)
        }
    }

    private fun createNotificationChannel(context: Context) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return
        val mgr = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        val channel = NotificationChannel(channelId, channelName, NotificationManager.IMPORTANCE_HIGH).apply {
            description = channelDescription
            lockscreenVisibility = android.app.Notification.VISIBILITY_PUBLIC
            setSound(null, null)
            enableVibration(false)
        }
        mgr.createNotificationChannel(channel)
    }

    private fun launchAlarmActivity(context: Context, config: AlarmConfig) {
        val intent = AlarmActivity.createIntent(context, config).addFlags(
            Intent.FLAG_ACTIVITY_NEW_TASK or
                Intent.FLAG_ACTIVITY_SINGLE_TOP or
                Intent.FLAG_ACTIVITY_CLEAR_TOP,
        )
        context.startActivity(intent)
    }

    fun dismissAlarmUi(context: Context, alarmId: Int) {
        AlarmPlaybackManager.stop(context)
        val mgr = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        mgr.cancel(notificationIdFor(alarmId))
        AlarmActivity.finishIfShowing()
    }

    // ── PendingIntent factories ───────────────────────────────────────────────

    private fun createAlarmPendingIntent(
        context: Context, action: String, requestCode: Int, config: AlarmConfig,
    ): PendingIntent {
        val intent = Intent(context, AlarmReceiver::class.java).apply {
            this.action = action
            putAlarmConfig(config)
        }
        return PendingIntent.getBroadcast(
            context, requestCode, intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
    }

    private fun cancelScheduledAlarm(context: Context, action: String, requestCode: Int, alarmId: Int) {
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val intent = Intent(context, AlarmReceiver::class.java).apply {
            this.action = action
            putExtra(extraAlarmId, alarmId)
        }
        val pendingIntent = PendingIntent.getBroadcast(
            context, requestCode, intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
        alarmManager.cancel(pendingIntent)
        pendingIntent.cancel()
    }

    // ── Persistence ───────────────────────────────────────────────────────────

    private fun nextTriggerTimeMillis(hour: Int, minute: Int): Long {
        val now = Calendar.getInstance()
        val trigger = Calendar.getInstance().apply {
            set(Calendar.HOUR_OF_DAY, hour)
            set(Calendar.MINUTE, minute)
            set(Calendar.SECOND, 0)
            set(Calendar.MILLISECOND, 0)
        }
        if (!trigger.after(now)) trigger.add(Calendar.DAY_OF_YEAR, 1)
        return trigger.timeInMillis
    }

    private fun preferences(context: Context) =
        context.getSharedPreferences(preferencesName, Context.MODE_PRIVATE)

    private fun loadAlarmConfigs(context: Context): List<AlarmConfig> {
        val raw = preferences(context).getString(alarmsKey, null) ?: return emptyList()
        return try {
            val arr = JSONArray(raw)
            (0 until arr.length()).mapNotNull { idx -> arr.optJSONObject(idx)?.toAlarmConfig() }
        } catch (_: Throwable) { emptyList() }
    }

    private fun saveAlarmConfigs(context: Context, configs: List<AlarmConfig>) {
        val arr = JSONArray()
        for (config in configs) arr.put(config.toJson())
        preferences(context).edit().putString(alarmsKey, arr.toString()).apply()
    }

    private fun upsertAlarmConfig(context: Context, config: AlarmConfig) {
        val existing = loadAlarmConfigs(context).toMutableList()
        val idx = existing.indexOfFirst { it.id == config.id }
        if (idx == -1) existing.add(config) else existing[idx] = config
        saveAlarmConfigs(context, existing)
    }

    private fun removeAlarmConfig(context: Context, alarmId: Int) {
        saveAlarmConfigs(context, loadAlarmConfigs(context).filterNot { it.id == alarmId })
    }

    fun getSavedAlarmConfig(context: Context, alarmId: Int): AlarmConfig? {
        if (alarmId <= 0) return null
        return loadAlarmConfigs(context).firstOrNull { it.id == alarmId && it.enabled }
    }

    private fun alarmConfigFromIntent(intent: Intent): AlarmConfig? {
        val id = intent.getIntExtra(extraAlarmId, -1)
        if (id <= 0) return null
        val title = intent.getStringExtra(extraTitle) ?: return null
        val instruction = intent.getStringExtra(extraInstruction) ?: return null
        val hour = intent.getIntExtra(extraHour, -1)
        val minute = intent.getIntExtra(extraMinute, -1)
        if (hour < 0 || minute < 0) return null
        return AlarmConfig(
            id = id,
            mealKey    = intent.getStringExtra(extraMealKey),
            title = title, instruction = instruction,
            hour = hour, minute = minute, enabled = true,
            windowSlot = intent.getIntExtra(extraWindowSlot, -1),
            endHour    = intent.getIntExtra(AlarmActivity.extraEndHour,   -1),
            endMinute  = intent.getIntExtra(AlarmActivity.extraEndMinute, -1),
            kcal       = intent.getIntExtra(AlarmActivity.extraKcal,      -1),
            proteinG   = intent.getIntExtra(AlarmActivity.extraProteinG,  -1),
            carbsG     = intent.getIntExtra(AlarmActivity.extraCarbsG,    -1),
            fatG       = intent.getIntExtra(AlarmActivity.extraFatG,      -1),
        )
    }

    private fun Intent.putAlarmConfig(config: AlarmConfig) {
        putExtra(extraAlarmId, config.id)
        putExtra(extraMealKey, config.mealKey)
        putExtra(extraTitle, config.title)
        putExtra(extraInstruction, config.instruction)
        putExtra(extraHour, config.hour)
        putExtra(extraMinute, config.minute)
        putExtra(extraWindowSlot, config.windowSlot)
        putExtra(AlarmActivity.extraEndHour,   config.endHour)
        putExtra(AlarmActivity.extraEndMinute, config.endMinute)
        putExtra(AlarmActivity.extraKcal,      config.kcal)
        putExtra(AlarmActivity.extraProteinG,  config.proteinG)
        putExtra(AlarmActivity.extraCarbsG,    config.carbsG)
        putExtra(AlarmActivity.extraFatG,      config.fatG)
    }

    private fun AlarmConfig.toJson() = JSONObject().apply {
        put("id", id)
        put("mealKey", mealKey)
        put("title", title)
        put("instruction", instruction)
        put("hour", hour)
        put("minute", minute)
        put("enabled", enabled)
        put("windowSlot", windowSlot)
        put("endHour", endHour)
        put("endMinute", endMinute)
        put("kcal", kcal)
        put("proteinG", proteinG)
        put("carbsG", carbsG)
        put("fatG", fatG)
    }

    private fun JSONObject.toAlarmConfig(): AlarmConfig? {
        val id = optInt("id", -1)
        if (id <= 0) return null
        val title = optString("title", "")
        val instruction = optString("instruction", "")
        val hour = optInt("hour", -1)
        val minute = optInt("minute", -1)
        if (title.isBlank() || instruction.isBlank() || hour < 0 || minute < 0) return null
        return AlarmConfig(
            id = id,
            mealKey = if (has("mealKey") && !isNull("mealKey")) optString("mealKey") else null,
            title = title, instruction = instruction,
            hour = hour, minute = minute,
            enabled = optBoolean("enabled", true),
            windowSlot = optInt("windowSlot", -1),
            endHour    = optInt("endHour",   -1),
            endMinute  = optInt("endMinute", -1),
            kcal       = optInt("kcal",      -1),
            proteinG   = optInt("proteinG",  -1),
            carbsG     = optInt("carbsG",    -1),
            fatG       = optInt("fatG",      -1),
        )
    }

    // ── Request code helpers ──────────────────────────────────────────────────

    private fun dailyRequestCode(id: Int)            = dailyRequestBase + id
    private fun snoozeRequestCode(id: Int)           = snoozeRequestBase + id
    private fun fullscreenRequestCode(id: Int)       = fullscreenRequestBase + id
    private fun stopRequestCode(id: Int)             = stopRequestBase + id
    private fun snoozeActionRequestCode(id: Int)     = snoozeActionRequestBase + id
    private fun notificationIdFor(id: Int)           = notificationBase + id
    private fun mealDoneRequestCode(id: Int)         = mealDoneRequestBase + id

    // ── In-app inbox logging (for Flutter notification bell) ─────────────────

    private fun logFlutterInboxItem(context: Context, config: AlarmConfig) {
        try {
            val prefs = context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
            val key = "flutter.in_app_inbox_items_v1"
            val existing = prefs.getString(key, null)
            val arr = if (existing.isNullOrBlank()) JSONArray() else JSONArray(existing)
            val item = JSONObject().apply {
                put("id", (System.currentTimeMillis() % Int.MAX_VALUE).toInt())
                put("type", "meal_alarm")
                put("title", config.title)
                put("message", config.instruction)
                put("createdAtMs", System.currentTimeMillis())
                put("isRead", false)
                put("mealKey", config.mealKey)
                put("hour", config.hour)
                put("minute", config.minute)
            }
            val next = JSONArray().apply {
                put(item)
                for (i in 0 until minOf(arr.length(), 98)) put(arr.get(i))
            }
            prefs.edit().putString(key, next.toString()).apply()
        } catch (_: Throwable) {}
    }
}