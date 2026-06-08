package com.devsouq.caloriq.app

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

class AlarmActionReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val alarmId = intent.getIntExtra(AlarmScheduler.extraAlarmId, 1)
        when (intent.action) {
            AlarmScheduler.actionStop  -> AlarmScheduler.stopAlarm(context, alarmId)
            AlarmScheduler.actionSnooze -> AlarmScheduler.snoozeAlarm(context, alarmId)
            AlarmScheduler.actionMealDone -> {
                // User tapped "✓ Done" on a midpoint or pre-close notification.
                // Cancel all remaining window alarms for this meal silently —
                // no alarm screen, no sound, just silent cancellation.
                val mealKey = intent.getStringExtra(AlarmScheduler.extraMealKey)
                AlarmScheduler.stopAlarm(context, alarmId)
                if (!mealKey.isNullOrBlank()) {
                    AlarmScheduler.cancelMealWindowAlarms(context, mealKey)
                }
            }
        }
    }

    companion object {
        fun createIntent(context: Context, action: String, alarmId: Int, mealKey: String? = null): Intent {
            return Intent(context, AlarmActionReceiver::class.java).apply {
                this.action = action
                putExtra(AlarmScheduler.extraAlarmId, alarmId)
                if (mealKey != null) putExtra(AlarmScheduler.extraMealKey, mealKey)
            }
        }
    }
}