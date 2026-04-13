package com.example.ai_meal_planner

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

class AlarmActionReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        when (intent.action) {
            AlarmScheduler.actionStop -> AlarmScheduler.stopAlarm(context)
            AlarmScheduler.actionSnooze -> AlarmScheduler.snoozeAlarm(context)
        }
    }

    companion object {
        fun createIntent(context: Context, action: String): Intent {
            return Intent(context, AlarmActionReceiver::class.java).apply {
                this.action = action
            }
        }
    }
}
