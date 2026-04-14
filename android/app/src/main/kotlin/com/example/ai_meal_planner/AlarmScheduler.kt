package com.example.ai_meal_planner

import android.Manifest
import android.app.AlarmManager
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.graphics.BitmapFactory
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.content.pm.PackageManager
import android.os.Build
import android.widget.Toast
import androidx.core.app.NotificationCompat
import androidx.core.content.ContextCompat
import java.util.Calendar

data class AlarmConfig(
    val title: String,
    val instruction: String,
    val hour: Int,
    val minute: Int,
)

object AlarmScheduler {
    private const val preferencesName = "native_alarm_preferences"
    private const val titleKey = "alarm_title"
    private const val instructionKey = "alarm_instruction"
    private const val hourKey = "alarm_hour"
    private const val minuteKey = "alarm_minute"
    private const val enabledKey = "alarm_enabled"

    private const val channelId = "native_meal_alarm_channel"
    private const val channelName = "Native Meal Alarms"
    private const val channelDescription = "Native lock-screen meal alarms"
    private const val notificationId = 42001

    const val actionTriggerDaily = "com.example.ai_meal_planner.ALARM_TRIGGER_DAILY"
    const val actionTriggerSnooze = "com.example.ai_meal_planner.ALARM_TRIGGER_SNOOZE"
    const val actionStop = "com.example.ai_meal_planner.ALARM_STOP"
    const val actionSnooze = "com.example.ai_meal_planner.ALARM_SNOOZE"

    const val extraTitle = "extra_alarm_title"
    const val extraInstruction = "extra_alarm_instruction"
    const val extraHour = "extra_alarm_hour"
    const val extraMinute = "extra_alarm_minute"

    private const val dailyRequestCode = 42002
    private const val snoozeRequestCode = 42003
    private const val fullscreenRequestCode = 42004
    private const val stopRequestCode = 42005
    private const val snoozeActionRequestCode = 42006

    fun scheduleDaily(
        context: Context,
        hour: Int,
        minute: Int,
        title: String,
        instruction: String,
    ) {
        val config = AlarmConfig(
            title = title,
            instruction = instruction,
            hour = hour,
            minute = minute,
        )

        saveAlarmConfig(context, config)
        cancelScheduledAlarm(context, actionTriggerDaily, dailyRequestCode)
        cancelScheduledAlarm(context, actionTriggerSnooze, snoozeRequestCode)
        dismissAlarmUi(context)
        scheduleNextDailyOccurrence(context, config)
    }

    fun stopAlarm(context: Context) {
        cancelScheduledAlarm(context, actionTriggerSnooze, snoozeRequestCode)
        dismissAlarmUi(context)
    }

    fun snoozeAlarm(context: Context, showToast: Boolean = true) {
        val config = getSavedAlarmConfig(context) ?: return
        cancelScheduledAlarm(context, actionTriggerSnooze, snoozeRequestCode)
        dismissAlarmUi(context)
        scheduleSnooze(context, config, delayMillis = 30_000L)

        if (showToast) {
            Toast.makeText(
                context.applicationContext,
                "Alarm will ring again after 30 seconds.",
                Toast.LENGTH_SHORT,
            ).show()
        }
    }

    fun rescheduleSavedAlarm(context: Context) {
        val config = getSavedAlarmConfig(context) ?: return
        cancelScheduledAlarm(context, actionTriggerDaily, dailyRequestCode)
        cancelScheduledAlarm(context, actionTriggerSnooze, snoozeRequestCode)
        scheduleNextDailyOccurrence(context, config)
    }

    fun onAlarmTriggered(context: Context, intent: Intent) {
        val config = alarmConfigFromIntent(intent) ?: getSavedAlarmConfig(context) ?: return
        val isDailyAlarm = intent.action == actionTriggerDaily

        if (isDailyAlarm) {
            scheduleNextDailyOccurrence(context, config)
        }

        showFullScreenNotification(context, config)
        AlarmPlaybackManager.start(context)
        launchAlarmActivity(context, config)
    }

    private fun scheduleNextDailyOccurrence(context: Context, config: AlarmConfig) {
        val triggerAtMillis = nextTriggerTimeMillis(config.hour, config.minute)
        scheduleAlarmAt(
            context = context,
            triggerAtMillis = triggerAtMillis,
            requestCode = dailyRequestCode,
            action = actionTriggerDaily,
            config = config,
            useAlarmClock = true,
        )
    }

    private fun scheduleSnooze(
        context: Context,
        config: AlarmConfig,
        delayMillis: Long,
    ) {
        val triggerAtMillis = System.currentTimeMillis() + delayMillis
        scheduleAlarmAt(
            context = context,
            triggerAtMillis = triggerAtMillis,
            requestCode = snoozeRequestCode,
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
            alarmManager.setExactAndAllowWhileIdle(
                AlarmManager.RTC_WAKEUP,
                triggerAtMillis,
                pendingIntent,
            )
            return
        }

        alarmManager.setExact(AlarmManager.RTC_WAKEUP, triggerAtMillis, pendingIntent)
    }

    private fun showFullScreenNotification(context: Context, config: AlarmConfig) {
        createNotificationChannel(context)

        val activityIntent = AlarmActivity.createIntent(context, config)
        val fullScreenPendingIntent = PendingIntent.getActivity(
            context,
            fullscreenRequestCode,
            activityIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )

        val stopPendingIntent = PendingIntent.getBroadcast(
            context,
            stopRequestCode,
            AlarmActionReceiver.createIntent(context, actionStop),
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )

        val snoozePendingIntent = PendingIntent.getBroadcast(
            context,
            snoozeActionRequestCode,
            AlarmActionReceiver.createIntent(context, actionSnooze),
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )

        val notification = NotificationCompat.Builder(context, channelId)
            .setSmallIcon(R.mipmap.ic_launcher)
            .setLargeIcon(
                BitmapFactory.decodeResource(context.resources, R.mipmap.ic_launcher),
            )
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
            .build()

        val manager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.TIRAMISU ||
            ContextCompat.checkSelfPermission(
                context,
                Manifest.permission.POST_NOTIFICATIONS,
            ) == PackageManager.PERMISSION_GRANTED
        ) {
            manager.notify(notificationId, notification)
        }
    }

    private fun createNotificationChannel(context: Context) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) {
            return
        }

        val manager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        val channel = NotificationChannel(
            channelId,
            channelName,
            NotificationManager.IMPORTANCE_HIGH,
        ).apply {
            description = channelDescription
            lockscreenVisibility = android.app.Notification.VISIBILITY_PUBLIC
            setSound(null, null)
            enableVibration(false)
        }
        manager.createNotificationChannel(channel)
    }

    private fun launchAlarmActivity(context: Context, config: AlarmConfig) {
        val intent = AlarmActivity.createIntent(context, config).addFlags(
            Intent.FLAG_ACTIVITY_NEW_TASK or
                Intent.FLAG_ACTIVITY_SINGLE_TOP or
                Intent.FLAG_ACTIVITY_CLEAR_TOP,
        )
        context.startActivity(intent)
    }

    fun dismissAlarmUi(context: Context) {
        AlarmPlaybackManager.stop(context)
        val manager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        manager.cancel(notificationId)
        AlarmActivity.finishIfShowing()
    }

    private fun createAlarmPendingIntent(
        context: Context,
        action: String,
        requestCode: Int,
        config: AlarmConfig,
    ): PendingIntent {
        val intent = Intent(context, AlarmReceiver::class.java).apply {
            this.action = action
            putAlarmConfig(config)
        }

        return PendingIntent.getBroadcast(
            context,
            requestCode,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
    }

    private fun cancelScheduledAlarm(context: Context, action: String, requestCode: Int) {
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val intent = Intent(context, AlarmReceiver::class.java).apply {
            this.action = action
        }

        val pendingIntent = PendingIntent.getBroadcast(
            context,
            requestCode,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
        alarmManager.cancel(pendingIntent)
        pendingIntent.cancel()
    }

    private fun nextTriggerTimeMillis(hour: Int, minute: Int): Long {
        val now = Calendar.getInstance()
        val trigger = Calendar.getInstance().apply {
            set(Calendar.HOUR_OF_DAY, hour)
            set(Calendar.MINUTE, minute)
            set(Calendar.SECOND, 0)
            set(Calendar.MILLISECOND, 0)
        }

        if (!trigger.after(now)) {
            trigger.add(Calendar.DAY_OF_YEAR, 1)
        }

        return trigger.timeInMillis
    }

    private fun saveAlarmConfig(context: Context, config: AlarmConfig) {
        preferences(context).edit()
            .putString(titleKey, config.title)
            .putString(instructionKey, config.instruction)
            .putInt(hourKey, config.hour)
            .putInt(minuteKey, config.minute)
            .putBoolean(enabledKey, true)
            .apply()
    }

    private fun getSavedAlarmConfig(context: Context): AlarmConfig? {
        val prefs = preferences(context)
        if (!prefs.getBoolean(enabledKey, false)) {
            return null
        }

        val title = prefs.getString(titleKey, null) ?: return null
        val instruction = prefs.getString(instructionKey, null) ?: return null
        if (!prefs.contains(hourKey) || !prefs.contains(minuteKey)) {
            return null
        }

        return AlarmConfig(
            title = title,
            instruction = instruction,
            hour = prefs.getInt(hourKey, 0),
            minute = prefs.getInt(minuteKey, 0),
        )
    }

    private fun preferences(context: Context): SharedPreferences {
        return context.getSharedPreferences(preferencesName, Context.MODE_PRIVATE)
    }

    private fun alarmConfigFromIntent(intent: Intent): AlarmConfig? {
        val title = intent.getStringExtra(extraTitle) ?: return null
        val instruction = intent.getStringExtra(extraInstruction) ?: return null
        val hour = intent.getIntExtra(extraHour, -1)
        val minute = intent.getIntExtra(extraMinute, -1)
        if (hour < 0 || minute < 0) {
            return null
        }

        return AlarmConfig(
            title = title,
            instruction = instruction,
            hour = hour,
            minute = minute,
        )
    }

    private fun Intent.putAlarmConfig(config: AlarmConfig) {
        putExtra(extraTitle, config.title)
        putExtra(extraInstruction, config.instruction)
        putExtra(extraHour, config.hour)
        putExtra(extraMinute, config.minute)
    }
}
