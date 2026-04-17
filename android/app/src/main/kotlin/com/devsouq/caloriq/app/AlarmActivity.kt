package com.devsouq.caloriq.app

import android.app.Activity
import android.app.KeyguardManager
import android.animation.ObjectAnimator
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.view.HapticFeedbackConstants
import android.view.View
import android.view.WindowManager
import android.widget.TextView
import java.lang.ref.WeakReference
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

class AlarmActivity : Activity() {
    private val handler = Handler(Looper.getMainLooper())
    private lateinit var timeView: TextView
    private lateinit var centerDateView: TextView
    private lateinit var titleView: TextView
    private lateinit var instructionView: TextView
    private lateinit var scheduledTimeView: TextView
    private lateinit var pulseRing: View
    private lateinit var pulseDot: View
    private lateinit var snoozeButton: View
    private lateinit var stopButton: View
    private var handlingAction = false
    private var alarmId: Int = 1

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
        centerDateView = findViewById(R.id.alarmCurrentDateCenter)
        titleView = findViewById(R.id.alarmTitle)
        instructionView = findViewById(R.id.alarmInstruction)
        scheduledTimeView = findViewById(R.id.alarmScheduledTime)
        pulseRing = findViewById(R.id.pulseRing)
        pulseDot = findViewById(R.id.pulseDot)
        snoozeButton = findViewById(R.id.alarmSnoozeButton)
        stopButton = findViewById(R.id.alarmStopButton)

        configureActions()
        startPulseAnimation()

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

    @Deprecated("Deprecated in Android 13.0 (API 33)")
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
        alarmId = intent.getIntExtra(AlarmScheduler.extraAlarmId, 1)
        val title = intent.getStringExtra(AlarmScheduler.extraTitle)
            ?: "Meal Reminder"
        val instruction = intent.getStringExtra(AlarmScheduler.extraInstruction)
            ?: "Time to complete your meal."
        val hour = intent.getIntExtra(AlarmScheduler.extraHour, 0)
        val minute = intent.getIntExtra(AlarmScheduler.extraMinute, 0)

        titleView.text = title
        instructionView.text = instruction
        scheduledTimeView.text = "Scheduled for ${formatTime(hour, minute)}"
        bindCurrentTime()
    }

    private fun bindCurrentTime() {
        val now = Date()
        timeView.text = SimpleDateFormat("h:mm a", Locale.getDefault()).format(now)
        val dateText = SimpleDateFormat("EEEE, MMMM d", Locale.getDefault()).format(now)
        centerDateView.text = dateText
    }

    private fun formatTime(hour: Int, minute: Int): String {
        val calendar = java.util.Calendar.getInstance().apply {
            set(java.util.Calendar.HOUR_OF_DAY, hour)
            set(java.util.Calendar.MINUTE, minute)
        }
        return SimpleDateFormat("h:mm a", Locale.getDefault()).format(calendar.time)
    }

    private fun configureActions() {
        snoozeButton.setOnClickListener {
            if (handlingAction) return@setOnClickListener
            handlingAction = true
            it.performHapticFeedback(HapticFeedbackConstants.CONFIRM)
            AlarmScheduler.snoozeAlarm(this, alarmId)
        }

        stopButton.setOnClickListener {
            if (handlingAction) return@setOnClickListener
            handlingAction = true
            it.performHapticFeedback(HapticFeedbackConstants.REJECT)
            AlarmScheduler.stopAlarm(this, alarmId)
        }
    }

    private fun startPulseAnimation() {
        pulseRing.scaleX = 1f
        pulseRing.scaleY = 1f
        ObjectAnimator.ofFloat(pulseRing, View.SCALE_X, 1f, 1.6f).apply {
            duration = 1200L
            repeatCount = ObjectAnimator.INFINITE
            repeatMode = ObjectAnimator.RESTART
            start()
        }
        ObjectAnimator.ofFloat(pulseRing, View.SCALE_Y, 1f, 1.6f).apply {
            duration = 1200L
            repeatCount = ObjectAnimator.INFINITE
            repeatMode = ObjectAnimator.RESTART
            start()
        }
        ObjectAnimator.ofFloat(pulseRing, View.ALPHA, 0.5f, 0f).apply {
            duration = 1200L
            repeatCount = ObjectAnimator.INFINITE
            repeatMode = ObjectAnimator.RESTART
            start()
        }
        ObjectAnimator.ofFloat(pulseDot, View.ALPHA, 0.5f, 1f).apply {
            duration = 900L
            repeatCount = ObjectAnimator.INFINITE
            repeatMode = ObjectAnimator.REVERSE
            start()
        }
    }

    companion object {
        private var currentActivityRef: WeakReference<AlarmActivity>? = null

        fun createIntent(context: Context, config: AlarmConfig): Intent {
            return Intent(context, AlarmActivity::class.java).apply {
                putExtra(AlarmScheduler.extraAlarmId, config.id)
                putExtra(AlarmScheduler.extraMealKey, config.mealKey)
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
