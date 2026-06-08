package com.devsouq.caloriq.app

import android.animation.ObjectAnimator
import android.app.Activity
import android.app.KeyguardManager
import android.content.Context
import android.content.Intent
import android.graphics.drawable.Drawable
import android.os.Build
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.view.HapticFeedbackConstants
import android.view.View
import android.view.ViewGroup
import android.view.WindowManager
import android.widget.FrameLayout
import android.widget.LinearLayout
import android.widget.TextView
import androidx.core.content.ContextCompat
import java.lang.ref.WeakReference
import java.text.SimpleDateFormat
import java.util.Calendar
import java.util.Date
import java.util.Locale

// ─── Slot theme ───────────────────────────────────────────────────────────────

private enum class SlotTheme(
    val accentHex: String,
    val statusLabel: String,
    val bellBgHex: String,
) {
    START(
        accentHex   = "#388E3C",
        statusLabel = "Alarm ringing",
        bellBgHex   = "#388E3C",
    ),
    MIDPOINT(
        accentHex   = "#E65100",
        statusLabel = "Alarm ringing",
        bellBgHex   = "#E65100",
    ),
    PRECLOSE(
        accentHex   = "#A32D2D",
        statusLabel  = "Final reminder",
        bellBgHex   = "#A32D2D",
    ),
}

private fun slotThemeFor(windowSlot: Int): SlotTheme = when (windowSlot) {
    1    -> SlotTheme.MIDPOINT
    2    -> SlotTheme.PRECLOSE
    else -> SlotTheme.START
}

private fun parseColor(hex: String): Int = android.graphics.Color.parseColor(hex)

// ─── AlarmActivity ────────────────────────────────────────────────────────────

class AlarmActivity : Activity() {

    private val handler = Handler(Looper.getMainLooper())
    private var alarmId: Int = 1
    private var mealKey: String? = null
    private var windowSlot: Int = -1
    private var handlingAction = false

    // Views
    private lateinit var statusLabel: TextView
    private lateinit var pulseDot: View
    private lateinit var pulseRing: View
    private lateinit var bellCircle: FrameLayout
    private lateinit var timeView: TextView
    private lateinit var dateView: TextView
    private lateinit var windowPill: TextView
    private lateinit var slotBadge: TextView
    private lateinit var stepperSection: LinearLayout
    private lateinit var slotDot1: FrameLayout
    private lateinit var slotDot2: FrameLayout
    private lateinit var slotDot3: FrameLayout
    private lateinit var slotDot1Text: TextView
    private lateinit var slotDot2Text: TextView
    private lateinit var slotDot3Text: TextView
    private lateinit var slotLine1: View
    private lateinit var slotLine2: View
    private lateinit var slotLabel1: TextView
    private lateinit var slotLabel2: TextView
    private lateinit var slotLabel3: TextView
    private lateinit var mealCard: LinearLayout
    private lateinit var alarmTitle: TextView
    private lateinit var alarmInstruction: TextView
    private lateinit var macroRow: LinearLayout
    private lateinit var macroKcal: TextView
    private lateinit var macroProtein: TextView
    private lateinit var macroCarbs: TextView
    private lateinit var macroFat: TextView
    private lateinit var hintText: TextView
    private lateinit var doneButton: TextView
    private lateinit var snoozeButton: TextView
    private lateinit var stopButton: TextView

    private val clockUpdater = object : Runnable {
        override fun run() {
            bindCurrentTime()
            handler.postDelayed(this, 1000L)
        }
    }

    // ── Lifecycle ─────────────────────────────────────────────────────────────

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        currentActivityRef = WeakReference(this)
        configureWindow()
        setContentView(R.layout.activity_alarm)
        setFinishOnTouchOutside(false)
        bindViews()
        bindAlarmData(intent)
        configureActions()
        startPulseAnimation()
        handler.post(clockUpdater)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        bindAlarmData(intent)
    }

    override fun onDestroy() {
        handler.removeCallbacks(clockUpdater)
        if (currentActivityRef?.get() === this) currentActivityRef = null
        super.onDestroy()
    }

    @Deprecated("Deprecated in Android 13.0 (API 33)")
    override fun onBackPressed() {
        // Block back press while alarm is active.
    }

    // ── Window configuration ──────────────────────────────────────────────────

    private fun configureWindow() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
            setShowWhenLocked(true)
            setTurnScreenOn(true)
            (getSystemService(Context.KEYGUARD_SERVICE) as KeyguardManager)
                .requestDismissKeyguard(this, null)
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

    // ── View binding ──────────────────────────────────────────────────────────

    private fun bindViews() {
        statusLabel      = findViewById(R.id.statusLabel)
        pulseDot         = findViewById(R.id.pulseDot)
        pulseRing        = findViewById(R.id.pulseRing)
        bellCircle       = findViewById(R.id.bellCircle)
        timeView         = findViewById(R.id.alarmCurrentTime)
        dateView         = findViewById(R.id.alarmCurrentDateCenter)
        windowPill       = findViewById(R.id.alarmWindowPill)
        slotBadge        = findViewById(R.id.alarmSlotBadge)
        stepperSection   = findViewById(R.id.stepperSection)
        slotDot1         = findViewById(R.id.slotDot1)
        slotDot2         = findViewById(R.id.slotDot2)
        slotDot3         = findViewById(R.id.slotDot3)
        slotDot1Text     = findViewById(R.id.slotDot1Text)
        slotDot2Text     = findViewById(R.id.slotDot2Text)
        slotDot3Text     = findViewById(R.id.slotDot3Text)
        slotLine1        = findViewById(R.id.slotLine1)
        slotLine2        = findViewById(R.id.slotLine2)
        slotLabel1       = findViewById(R.id.slotLabel1)
        slotLabel2       = findViewById(R.id.slotLabel2)
        slotLabel3       = findViewById(R.id.slotLabel3)
        mealCard         = findViewById(R.id.mealCard)
        alarmTitle       = findViewById(R.id.alarmTitle)
        alarmInstruction = findViewById(R.id.alarmInstruction)
        macroRow         = findViewById(R.id.macroRow)
        macroKcal        = findViewById(R.id.macroKcal)
        macroProtein     = findViewById(R.id.macroProtein)
        macroCarbs       = findViewById(R.id.macroCarbs)
        macroFat         = findViewById(R.id.macroFat)
        hintText         = findViewById(R.id.hintText)
        doneButton       = findViewById(R.id.alarmDoneButton)
        snoozeButton     = findViewById(R.id.alarmSnoozeButton)
        stopButton       = findViewById(R.id.alarmStopButton)
    }

    // ── Data binding ──────────────────────────────────────────────────────────

    private fun bindAlarmData(intent: Intent) {
        alarmId     = intent.getIntExtra(AlarmScheduler.extraAlarmId, 1)
        mealKey     = intent.getStringExtra(AlarmScheduler.extraMealKey)
        windowSlot  = intent.getIntExtra(AlarmScheduler.extraWindowSlot, -1)

        val title       = intent.getStringExtra(AlarmScheduler.extraTitle) ?: "Meal Reminder"
        val instruction = intent.getStringExtra(AlarmScheduler.extraInstruction)
            ?: "Time to complete your meal."
        val startHour   = intent.getIntExtra(AlarmScheduler.extraHour, 0)
        val startMinute = intent.getIntExtra(AlarmScheduler.extraMinute, 0)
        val endHour     = intent.getIntExtra(extraEndHour, -1)
        val endMinute   = intent.getIntExtra(extraEndMinute, -1)

        val kcal        = intent.getIntExtra(extraKcal, -1)
        val proteinG    = intent.getIntExtra(extraProteinG, -1)
        val carbsG      = intent.getIntExtra(extraCarbsG, -1)
        val fatG        = intent.getIntExtra(extraFatG, -1)

        val theme = slotThemeFor(windowSlot)

        // Text content
        alarmTitle.text       = title
        alarmInstruction.text = instruction

        // Window pill text
        val startFmt = formatHourMinute(startHour, startMinute)
        if (endHour >= 0) {
            val endFmt = formatHourMinute(endHour, endMinute)
            windowPill.text = "Window: $startFmt – $endFmt PKT"
        } else {
            windowPill.text = "Scheduled for $startFmt PKT"
        }

        // Macro badges
        if (kcal > 0) {
            macroRow.visibility = View.VISIBLE
            macroKcal.text    = "$kcal kcal"
            macroProtein.text = if (proteinG >= 0) "P ${proteinG}g" else ""
            macroCarbs.text   = if (carbsG   >= 0) "C ${carbsG}g"   else ""
            macroFat.text     = if (fatG     >= 0) "F ${fatG}g"     else ""
            macroProtein.visibility = if (proteinG >= 0) View.VISIBLE else View.GONE
            macroCarbs.visibility   = if (carbsG   >= 0) View.VISIBLE else View.GONE
            macroFat.visibility     = if (fatG     >= 0) View.VISIBLE else View.GONE
        } else {
            macroRow.visibility = View.GONE
        }

        // Apply theme colours
        applyTheme(theme, windowSlot, startHour, startMinute, endHour, endMinute)
        bindCurrentTime()
    }

    // ── Theme application ─────────────────────────────────────────────────────

    private fun applyTheme(
        theme: SlotTheme,
        slot: Int,
        startHour: Int, startMinute: Int,
        endHour: Int, endMinute: Int,
    ) {
        val accentColor = parseColor(theme.accentHex)

        // Status pill
        statusLabel.text = theme.statusLabel

        // Bell circle colour
        setOvalColor(bellCircle, accentColor)

        // Stepper — only show for window alarms (slot 0, 1, 2)
        if (slot in 0..2 && endHour >= 0) {
            stepperSection.visibility = View.VISIBLE
            slotBadge.visibility      = View.VISIBLE
            slotBadge.text            = "Reminder ${slot + 1} of 3"

            val startFmt = formatHourMinute(startHour, startMinute)
            val midHour  = (startHour * 60 + startMinute + (endHour * 60 + endMinute - startHour * 60 - startMinute) / 2) / 60 % 24
            val midMin   = (startHour * 60 + startMinute + (endHour * 60 + endMinute - startHour * 60 - startMinute) / 2) % 60
            val midFmt   = formatHourMinute(midHour, midMin)
            val preH     = ((endHour * 60 + endMinute) - 30) / 60 % 24
            val preM     = ((endHour * 60 + endMinute) - 30) % 60
            val preFmt   = formatHourMinute(preH.coerceAtLeast(0), preM.coerceAtLeast(0))

            slotLabel1.text = "Start · $startFmt"
            slotLabel2.text = "Mid · $midFmt"
            slotLabel3.text = "Close · $preFmt"

            renderStepper(slot, accentColor)
        } else {
            stepperSection.visibility = View.GONE
            slotBadge.visibility      = View.GONE
        }

        // Hint text per slot
        hintText.text = when (slot) {
            0    -> "Snooze pauses for 30 s. Mark as done when you finish eating — all remaining reminders will be cancelled."
            1    -> "One more reminder before your window closes. Mark done to cancel all remaining alerts."
            2    -> "This is your final reminder. Mark done now — no more alerts will be sent."
            else -> "Snooze pauses for 30 s. Stop silences the alarm."
        }

        // Done button — always visible for window alarms (slots 0-2)
        if (slot in 0..2) {
            doneButton.visibility = View.VISIBLE
            if (slot == 2) {
                // Pre-close: make done the TOP button (primary visual weight)
                val parent = doneButton.parent as LinearLayout
                parent.removeView(doneButton)
                parent.addView(doneButton, 0)
            }
        } else {
            doneButton.visibility = View.GONE
        }

        // Snooze button colour
        setRoundedColor(snoozeButton, accentColor, 22)
    }

    private fun renderStepper(currentSlot: Int, accentColor: Int) {
        val dotViews   = listOf(slotDot1,     slotDot2,     slotDot3)
        val dotTexts   = listOf(slotDot1Text, slotDot2Text, slotDot3Text)
        val lineViews  = listOf(slotLine1,    slotLine2)

        for (i in dotViews.indices) {
            val dot  = dotViews[i]
            val text = dotTexts[i]
            when {
                i < currentSlot -> {
                    // Done
                    setOvalColor(dot, accentColor)
                    text.text      = "✓"
                    text.textSize  = 9f
                    text.setTextColor(parseColor("#FFFFFF"))
                }
                i == currentSlot -> {
                    // Active
                    setOvalColorStroke(dot, parseColor("#FFFFFF"), accentColor)
                    text.text = (i + 1).toString()
                    text.setTextColor(accentColor)
                }
                else -> {
                    // Pending
                    setOvalColorStroke(dot, parseColor("#C8DEC8"), parseColor("#B0CFAC"))
                    text.text = (i + 1).toString()
                    text.setTextColor(parseColor("#7A9A87"))
                }
            }
        }

        for (i in lineViews.indices) {
            lineViews[i].setBackgroundColor(
                if (i < currentSlot) accentColor else parseColor("#C4DEC8")
            )
        }
    }

    // ── Clock ─────────────────────────────────────────────────────────────────

    private fun bindCurrentTime() {
        val now = Date()
        timeView.text = SimpleDateFormat("h:mm a", Locale.getDefault()).format(now)
        dateView.text = SimpleDateFormat("EEEE, MMMM d", Locale.getDefault()).format(now)
    }

    // ── Actions ───────────────────────────────────────────────────────────────

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

        doneButton.setOnClickListener {
            if (handlingAction) return@setOnClickListener
            handlingAction = true
            it.performHapticFeedback(HapticFeedbackConstants.CONFIRM)
            // Stop the current alarm UI
            AlarmScheduler.stopAlarm(this, alarmId)
            // Cancel all remaining window alarms for this meal
            val key = mealKey
            if (!key.isNullOrBlank()) {
                AlarmScheduler.cancelMealWindowAlarms(this, key)
            }
        }
    }

    // ── Pulse animation ───────────────────────────────────────────────────────

    private fun startPulseAnimation() {
        listOf(View.SCALE_X, View.SCALE_Y).forEach { prop ->
            ObjectAnimator.ofFloat(pulseRing, prop, 1f, 1.6f).apply {
                duration = 1200L
                repeatCount = ObjectAnimator.INFINITE
                repeatMode  = ObjectAnimator.RESTART
                start()
            }
        }
        ObjectAnimator.ofFloat(pulseRing, View.ALPHA, 0.5f, 0f).apply {
            duration = 1200L
            repeatCount = ObjectAnimator.INFINITE
            repeatMode  = ObjectAnimator.RESTART
            start()
        }
        ObjectAnimator.ofFloat(pulseDot, View.ALPHA, 0.5f, 1f).apply {
            duration = 900L
            repeatCount = ObjectAnimator.INFINITE
            repeatMode  = ObjectAnimator.REVERSE
            start()
        }
    }

    // ── Drawable helpers ──────────────────────────────────────────────────────

    private fun setOvalColor(view: View, color: Int) {
        val d = android.graphics.drawable.GradientDrawable()
        d.shape = android.graphics.drawable.GradientDrawable.OVAL
        d.setColor(color)
        view.background = d
    }

    private fun setOvalColorStroke(view: View, fillColor: Int, strokeColor: Int) {
        val d = android.graphics.drawable.GradientDrawable()
        d.shape = android.graphics.drawable.GradientDrawable.OVAL
        d.setColor(fillColor)
        d.setStroke(dpToPx(2), strokeColor)
        view.background = d
    }

    private fun setRoundedColor(view: View, color: Int, radiusDp: Int) {
        val d = android.graphics.drawable.GradientDrawable()
        d.cornerRadius = dpToPx(radiusDp).toFloat()
        d.setColor(color)
        view.background = d
    }

    private fun dpToPx(dp: Int): Int =
        (dp * resources.displayMetrics.density + 0.5f).toInt()

    // ── Formatting ────────────────────────────────────────────────────────────

    private fun formatHourMinute(hour: Int, minute: Int): String {
        val cal = Calendar.getInstance().apply {
            set(Calendar.HOUR_OF_DAY, hour)
            set(Calendar.MINUTE, minute)
        }
        return SimpleDateFormat("h:mm a", Locale.getDefault()).format(cal.time)
    }

    // ── Companion ─────────────────────────────────────────────────────────────

    companion object {
        private var currentActivityRef: WeakReference<AlarmActivity>? = null

        // Extra keys for window end time and macro data
        const val extraEndHour   = "extra_alarm_end_hour"
        const val extraEndMinute = "extra_alarm_end_minute"
        const val extraKcal      = "extra_alarm_kcal"
        const val extraProteinG  = "extra_alarm_protein_g"
        const val extraCarbsG    = "extra_alarm_carbs_g"
        const val extraFatG      = "extra_alarm_fat_g"

        fun createIntent(context: Context, config: AlarmConfig): Intent =
            Intent(context, AlarmActivity::class.java).apply {
                putExtra(AlarmScheduler.extraAlarmId,    config.id)
                putExtra(AlarmScheduler.extraMealKey,    config.mealKey)
                putExtra(AlarmScheduler.extraTitle,      config.title)
                putExtra(AlarmScheduler.extraInstruction, config.instruction)
                putExtra(AlarmScheduler.extraHour,       config.hour)
                putExtra(AlarmScheduler.extraMinute,     config.minute)
                putExtra(AlarmScheduler.extraWindowSlot, config.windowSlot)
                putExtra(extraEndHour,   config.endHour)
                putExtra(extraEndMinute, config.endMinute)
                putExtra(extraKcal,      config.kcal)
                putExtra(extraProteinG,  config.proteinG)
                putExtra(extraCarbsG,    config.carbsG)
                putExtra(extraFatG,      config.fatG)
            }

        fun finishIfShowing() {
            currentActivityRef?.get()?.runOnUiThread {
                currentActivityRef?.get()?.finishAndRemoveTask()
            }
        }
    }
}