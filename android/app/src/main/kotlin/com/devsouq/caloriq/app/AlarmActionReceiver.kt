package com.devsouq.caloriq.app

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

class AlarmActionReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val alarmId = intent.getIntExtra(AlarmScheduler.extraAlarmId, 1)
        when (intent.action) {
            AlarmScheduler.actionStop -> AlarmScheduler.stopAlarm(context, alarmId)
            AlarmScheduler.actionSnooze -> AlarmScheduler.snoozeAlarm(context, alarmId)
        }
    }

    companion object {
        fun createIntent(context: Context, action: String, alarmId: Int): Intent {
            return Intent(context, AlarmActionReceiver::class.java).apply {
                this.action = action
                putExtra(AlarmScheduler.extraAlarmId, alarmId)
            }
        }
    }
}
