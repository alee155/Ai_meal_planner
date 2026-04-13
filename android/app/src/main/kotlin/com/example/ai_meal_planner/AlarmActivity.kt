package com.example.ai_meal_planner

import android.app.Activity
import android.app.KeyguardManager
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.view.WindowManager
import android.widget.Button
import android.widget.TextView
import java.lang.ref.WeakReference
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

class AlarmActivity : Activity() {
    private val handler = Handler(Looper.getMainLooper())
    private lateinit var timeView: TextView
    private lateinit var dateView: TextView
    private lateinit var titleView: TextView
    private lateinit var instructionView: TextView
    private lateinit var scheduledTimeView: TextView

    private val clockUpdater = object : Runnable {
        override fun run() {
            bindCurrentTime()
            handler.postDelayed(this, 1000L)
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        currentActivityRef = WeakReference(this)
        configureWindow()
        setContentView(R.layout.activity_alarm)
        setFinishOnTouchOutside(false)

        timeView = findViewById(R.id.alarmCurrentTime)
        dateView = findViewById(R.id.alarmCurrentDate)
        titleView = findViewById(R.id.alarmTitle)
        instructionView = findViewById(R.id.alarmInstruction)
        scheduledTimeView = findViewById(R.id.alarmScheduledTime)

        findViewById<Button>(R.id.alarmStopButton).setOnClickListener {
            AlarmScheduler.stopAlarm(this)
        }
        findViewById<Button>(R.id.alarmSnoozeButton).setOnClickListener {
            AlarmScheduler.snoozeAlarm(this)
        }

        bindAlarmData(intent)
        handler.post(clockUpdater)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        bindAlarmData(intent)
    }

    override fun onDestroy() {
        handler.removeCallbacks(clockUpdater)
        if (currentActivityRef?.get() === this) {
            currentActivityRef = null
        }
        super.onDestroy()
    }

    override fun onBackPressed() {
        // Ignore back press while alarm is visible.
    }

    private fun configureWindow() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
            setShowWhenLocked(true)
            setTurnScreenOn(true)
            val keyguardManager = getSystemService(Context.KEYGUARD_SERVICE) as KeyguardManager
            keyguardManager.requestDismissKeyguard(this, null)
        } else {
            @Suppress("DEPRECATION")
            window.addFlags(
                WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED or
                    WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON or
                    WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON or
                    WindowManager.LayoutParams.FLAG_DISMISS_KEYGUARD,
            )
        }
        window.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
    }

    private fun bindAlarmData(intent: Intent) {
        val title = intent.getStringExtra(AlarmScheduler.extraTitle)
            ?: "Meal Reminder"
        val instruction = intent.getStringExtra(AlarmScheduler.extraInstruction)
            ?: "Time to complete your meal."
        val hour = intent.getIntExtra(AlarmScheduler.extraHour, 0)
        val minute = intent.getIntExtra(AlarmScheduler.extraMinute, 0)

        titleView.text = title
        instructionView.text = instruction
        scheduledTimeView.text = String.format(Locale.getDefault(), "%02d:%02d", hour, minute)
        bindCurrentTime()
    }

    private fun bindCurrentTime() {
        val now = Date()
        timeView.text = SimpleDateFormat("hh:mm", Locale.getDefault()).format(now)
        dateView.text = SimpleDateFormat("EEEE, MMMM d", Locale.getDefault()).format(now)
        findViewById<TextView>(R.id.alarmCurrentPeriod).text =
            SimpleDateFormat("a", Locale.getDefault()).format(now)
    }

    companion object {
        private var currentActivityRef: WeakReference<AlarmActivity>? = null

        fun createIntent(context: Context, config: AlarmConfig): Intent {
            return Intent(context, AlarmActivity::class.java).apply {
                putExtra(AlarmScheduler.extraTitle, config.title)
                putExtra(AlarmScheduler.extraInstruction, config.instruction)
                putExtra(AlarmScheduler.extraHour, config.hour)
                putExtra(AlarmScheduler.extraMinute, config.minute)
            }
        }

        fun finishIfShowing() {
            currentActivityRef?.get()?.let { activity ->
                activity.runOnUiThread {
                    activity.finishAndRemoveTask()
                }
            }
        }
    }
}
