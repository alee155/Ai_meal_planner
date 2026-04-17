package com.devsouq.caloriq.app.widgets

import android.content.Context
import android.graphics.drawable.GradientDrawable
import android.os.Handler
import android.os.Looper
import android.util.AttributeSet
import android.view.Gravity
import android.view.MotionEvent
import android.view.View
import android.widget.FrameLayout
import android.widget.ImageView
import android.widget.LinearLayout
import android.widget.TextView
import kotlin.math.max

class SwipeActionView @JvmOverloads constructor(
    context: Context,
    attrs: AttributeSet? = null,
) : FrameLayout(context, attrs) {

    private val trackView = View(context)
    private val fillView = View(context)
    private val labelRow = LinearLayout(context)
    private val labelIcon = ImageView(context)
    private val labelText = TextView(context)
    private val thumbView = FrameLayout(context)
    private val thumbIcon = ImageView(context)
    private val handler = Handler(Looper.getMainLooper())

    private var dragX = 0f
    private var maxDrag = 0f
    private var completed = false
    private var onCompleted: (() -> Unit)? = null

    private val thumbSize = dp(56)
    private val thumbPad = dp(4)
    private var trackColor = 0xFFE1F5EE.toInt()
    private var fillStartColor = 0x809FE1CB.toInt()
    private var fillEndColor = 0xCC5DCAA5.toInt()
    private var labelColor = 0xFF0F6E56.toInt()

    init {
        clipChildren = false
        clipToPadding = false
        elevation = dp(1).toFloat()

        trackView.background = roundedDrawable(trackColor, radius = 32f, strokeColor = 0x22000000)
        addView(trackView, LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.MATCH_PARENT))

        fillView.background = gradientDrawable(fillStartColor, fillEndColor, 32f)
        addView(fillView, LayoutParams(thumbSize + thumbPad * 2, LayoutParams.MATCH_PARENT))

        labelRow.apply {
            orientation = LinearLayout.HORIZONTAL
            gravity = Gravity.CENTER
            setPadding(dp(22), 0, dp(22), 0)
            addView(labelIcon, LinearLayout.LayoutParams(dp(16), dp(16)))
            addView(labelText, LinearLayout.LayoutParams(LayoutParams.WRAP_CONTENT, LayoutParams.WRAP_CONTENT).apply {
                marginStart = dp(8)
            })
        }
        addView(labelRow, LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.MATCH_PARENT))

        thumbView.background = roundedDrawable(0xFFFFFFFF.toInt(), radius = 28f, strokeColor = 0x14000000)
        thumbView.elevation = dp(4).toFloat()
        thumbView.addView(
            thumbIcon,
            LayoutParams(dp(22), dp(22), Gravity.CENTER),
        )
        addView(thumbView, LayoutParams(thumbSize, thumbSize).apply {
            gravity = Gravity.START or Gravity.CENTER_VERTICAL
            leftMargin = thumbPad
        })

        thumbView.setOnTouchListener(::onThumbDragged)
    }

    fun configure(
        label: String,
        labelColor: Int,
        trackColor: Int,
        fillStartColor: Int,
        fillEndColor: Int,
        iconRes: Int,
        thumbIconRes: Int,
        onCompleted: () -> Unit,
    ) {
        this.onCompleted = onCompleted
        completed = false
        dragX = 0f
        this.trackColor = trackColor
        this.fillStartColor = fillStartColor
        this.fillEndColor = fillEndColor
        this.labelColor = labelColor

        trackView.background = roundedDrawable(
            color = trackColor,
            radius = 32f,
            strokeColor = if (labelColor == 0xFFA32D2D.toInt()) 0x22A32D2D else 0x220F6E56,
        )
        fillView.background = gradientDrawable(fillStartColor, fillEndColor, 32f)

        labelIcon.setImageResource(iconRes)
        labelIcon.setColorFilter(labelColor)
        labelText.text = label
        labelText.setTextColor(labelColor)
        labelText.textSize = 15f
        labelText.setTypeface(labelText.typeface, android.graphics.Typeface.BOLD)
        labelText.letterSpacing = 0.01f

        thumbIcon.setImageResource(thumbIconRes)
        thumbIcon.setColorFilter(fillEndColor)

        post {
            updateDragPosition(0f)
        }
    }

    private fun onThumbDragged(view: View, event: MotionEvent): Boolean {
        if (completed) {
            return true
        }

        when (event.actionMasked) {
            MotionEvent.ACTION_DOWN -> {
                parent.requestDisallowInterceptTouchEvent(true)
                return true
            }
            MotionEvent.ACTION_MOVE -> {
                maxDrag = max(0f, width - thumbSize - thumbPad * 2f)
                val next = (view.x + event.x - view.width / 2f - thumbPad).coerceIn(0f, maxDrag)
                updateDragPosition(next)
                if (dragX >= maxDrag * 0.95f) {
                    complete()
                }
                return true
            }
            MotionEvent.ACTION_UP, MotionEvent.ACTION_CANCEL -> {
                if (!completed) {
                    animateThumbBack()
                }
                parent.requestDisallowInterceptTouchEvent(false)
                return true
            }
            else -> return false
        }
    }

    private fun updateDragPosition(value: Float) {
        dragX = value
        thumbView.translationX = dragX
        val fillParams = fillView.layoutParams
        fillParams.width = (dragX + thumbSize + thumbPad * 2).toInt()
        fillView.layoutParams = fillParams
        val pct = if (maxDrag <= 0f) 0f else dragX / maxDrag
        labelRow.alpha = (1f - pct * 2f).coerceIn(0f, 1f)
    }

    private fun complete() {
        if (completed) {
            return
        }

        completed = true
        updateDragPosition(maxDrag)
        handler.postDelayed({
            onCompleted?.invoke()
            completed = false
            animateThumbBack()
        }, 220L)
    }

    private fun animateThumbBack() {
        thumbView.animate()
            .translationX(0f)
            .setDuration(220L)
            .withStartAction {
                labelRow.animate().alpha(1f).setDuration(180L).start()
            }
            .start()

        fillView.animate()
            .setDuration(220L)
            .withEndAction {
                updateDragPosition(0f)
            }
            .start()
    }

    private fun roundedDrawable(color: Int, radius: Float, strokeColor: Int? = null): GradientDrawable {
        return GradientDrawable().apply {
            shape = GradientDrawable.RECTANGLE
            cornerRadius = dp(radius).toFloat()
            setColor(color)
            if (strokeColor != null) {
                setStroke(dp(1), strokeColor)
            }
        }
    }

    private fun gradientDrawable(startColor: Int, endColor: Int, radius: Float): GradientDrawable {
        return GradientDrawable(
            GradientDrawable.Orientation.LEFT_RIGHT,
            intArrayOf(startColor, endColor),
        ).apply {
            cornerRadius = dp(radius).toFloat()
        }
    }

    private fun dp(value: Float): Int {
        return (value * resources.displayMetrics.density).toInt()
    }

    private fun dp(value: Int): Int = dp(value.toFloat())
}
