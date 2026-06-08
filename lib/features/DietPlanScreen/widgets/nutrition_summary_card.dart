import 'dart:math' as math;

import 'package:ai_meal_planner/core/constants/app_colors.dart';
import 'package:ai_meal_planner/core/theme/app_text_styles.dart';
import 'package:ai_meal_planner/features/DietPlanScreen/models/latest_meal_plan_response_model.dart';
import 'package:ai_meal_planner/features/DietPlanScreen/widgets/plan_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// ─── Public widget ────────────────────────────────────────────────────────────

class NutritionSummaryCard extends StatelessWidget {
  const NutritionSummaryCard({
    super.key,
    required this.targets,
    required this.actualTotals,
  });

  final MealPlanDailyNutritionTargetsModel targets;
  final MealPlanActualDailyTotalsModel actualTotals;

  @override
  Widget build(BuildContext context) {
    final calorieTarget = targets.calories <= 0 ? 1 : targets.calories;
    final calorieProgress = (actualTotals.calories / calorieTarget).clamp(
      0.0,
      1.0,
    );

    final proteinTarget = targets.macros.protein <= 0
        ? 1
        : targets.macros.protein;
    final carbsTarget = targets.macros.carbs <= 0 ? 1 : targets.macros.carbs;
    final fatsTarget = targets.macros.fats <= 0 ? 1 : targets.macros.fats;

    final proteinProgress = (actualTotals.macros.protein / proteinTarget).clamp(
      0.0,
      1.0,
    );
    final carbsProgress = (actualTotals.macros.carbs / carbsTarget).clamp(
      0.0,
      1.0,
    );
    final fatsProgress = (actualTotals.macros.fats / fatsTarget).clamp(
      0.0,
      1.0,
    );

    final pct = actualTotals.macroPercentages;
    final segments = <_Segment>[
      _Segment('Protein', pct.protein, const Color(0xFF4D9FFF)),
      _Segment('Carbs', pct.carbs, const Color(0xFFFFB84D)),
      _Segment('Fats', pct.fats, const Color(0xFFFF6B6B)),
    ];

    // Badge label
    final onTrack = actualTotals.calories <= targets.calories * 1.05;
    final over = actualTotals.calories > targets.calories * 1.05;

    return PlanCard(
      padding: EdgeInsets.all(18.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Top row: calorie count + badge ─────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Today's nutrition",
                      style: AppTextStyles.caption(
                        context,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textSecondaryOf(context),
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${actualTotals.calories}',
                          style: TextStyle(
                            fontSize: 36.sp,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primaryGreenDark,
                            height: 1,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(bottom: 5.h, left: 5.w),
                          child: Text(
                            'kcal',
                            style: AppTextStyles.body(
                              context,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textSecondaryOf(context),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'of ${targets.calories} kcal target',
                      style: AppTextStyles.caption(
                        context,
                        fontSize: 12,
                        color: AppColors.textSecondaryOf(context),
                      ),
                    ),
                  ],
                ),
              ),
              // Status badge
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                decoration: BoxDecoration(
                  color: over
                      ? AppColors.error.withValues(alpha: 0.10)
                      : AppColors.primaryGreenDark.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(999.r),
                  border: Border.all(
                    color: over
                        ? AppColors.error.withValues(alpha: 0.28)
                        : AppColors.primaryGreenDark.withValues(alpha: 0.28),
                  ),
                ),
                child: Text(
                  over
                      ? 'Over target'
                      : (onTrack ? 'On track' : 'Under target'),
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w800,
                    color: over ? AppColors.error : AppColors.primaryGreenDark,
                  ),
                ),
              ),
            ],
          ),

          // ── Calorie progress bar ────────────────────────────────────────
          SizedBox(height: 14.h),
          _CalorieBar(progress: calorieProgress),

          // ── Divider ─────────────────────────────────────────────────────
          Padding(
            padding: EdgeInsets.symmetric(vertical: 14.h),
            child: Divider(
              height: 1,
              thickness: 1,
              color: AppColors.borderOf(context).withValues(alpha: 0.50),
            ),
          ),

          // ── Macro donut + bars ──────────────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Donut chart
              SizedBox(
                width: 96.w,
                height: 96.w,
                child: CustomPaint(
                  painter: _DonutPainter(
                    segments: segments,
                    trackColor: AppColors.borderOf(
                      context,
                    ).withValues(alpha: 0.35),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${_fmtPct(_sumPct(segments))}%',
                          style: AppTextStyles.title(
                            context,
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text(
                          'macros',
                          style: AppTextStyles.caption(
                            context,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondaryOf(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(width: 16.w),
              // Macro progress bars
              Expanded(
                child: Column(
                  children: [
                    _MacroBar(
                      label: 'Protein',
                      actual: actualTotals.macros.protein,
                      target: targets.macros.protein.toDouble(),
                      progress: proteinProgress,
                      color: const Color(0xFF4D9FFF),
                    ),
                    SizedBox(height: 10.h),
                    _MacroBar(
                      label: 'Carbs',
                      actual: actualTotals.macros.carbs,
                      target: targets.macros.carbs.toDouble(),
                      progress: carbsProgress,
                      color: const Color(0xFFFFB84D),
                    ),
                    SizedBox(height: 10.h),
                    _MacroBar(
                      label: 'Fats',
                      actual: actualTotals.macros.fats,
                      target: targets.macros.fats.toDouble(),
                      progress: fatsProgress,
                      color: const Color(0xFFFF6B6B),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // ── Macro stat row ──────────────────────────────────────────────
          SizedBox(height: 14.h),
          Row(
            children: [
              Expanded(
                child: _StatBox(
                  label: 'Protein',
                  value: _fmt1(actualTotals.macros.protein),
                  sub: 'of ${targets.macros.protein}g',
                  color: const Color(0xFF4D9FFF),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: _StatBox(
                  label: 'Carbs',
                  value: _fmt1(actualTotals.macros.carbs),
                  sub: 'of ${targets.macros.carbs}g',
                  color: const Color(0xFFFFB84D),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: _StatBox(
                  label: 'Fats',
                  value: _fmt1(actualTotals.macros.fats),
                  sub: 'of ${targets.macros.fats}g',
                  color: const Color(0xFFFF6B6B),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Sub-widgets ──────────────────────────────────────────────────────────────

class _CalorieBar extends StatelessWidget {
  const _CalorieBar({required this.progress});
  final double progress;

  @override
  Widget build(BuildContext context) {
    final safe = progress.isNaN ? 0.0 : progress.clamp(0.0, 1.0);
    final overflowing = progress > 1.0;
    return ClipRRect(
      borderRadius: BorderRadius.circular(999.r),
      child: LinearProgressIndicator(
        minHeight: 8.h,
        value: safe,
        backgroundColor: AppColors.borderOf(context).withValues(alpha: 0.45),
        valueColor: AlwaysStoppedAnimation<Color>(
          overflowing ? AppColors.error : AppColors.primaryGreenDark,
        ),
      ),
    );
  }
}

class _MacroBar extends StatelessWidget {
  const _MacroBar({
    required this.label,
    required this.actual,
    required this.target,
    required this.progress,
    required this.color,
  });

  final String label;
  final double actual;
  final double target;
  final double progress;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final safe = progress.isNaN ? 0.0 : progress.clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 7.w,
              height: 7.w,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            SizedBox(width: 6.w),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.caption(
                  context,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Text(
              '${_fmtPct(progress * 100)}%',
              style: AppTextStyles.caption(
                context,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
        SizedBox(height: 5.h),
        ClipRRect(
          borderRadius: BorderRadius.circular(999.r),
          child: LinearProgressIndicator(
            minHeight: 5.h,
            value: safe,
            backgroundColor: AppColors.borderOf(
              context,
            ).withValues(alpha: 0.45),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}

class _StatBox extends StatelessWidget {
  const _StatBox({
    required this.label,
    required this.value,
    required this.sub,
    required this.color,
  });

  final String label;
  final String value;
  final String sub;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 9.h),
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondaryOf(context),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: AppColors.borderOf(context).withValues(alpha: 0.60),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 6.w,
                height: 6.w,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              SizedBox(width: 5.w),
              Text(
                label,
                style: AppTextStyles.caption(
                  context,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondaryOf(context),
                ),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimaryOf(context),
              height: 1,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            sub,
            style: AppTextStyles.caption(
              context,
              fontSize: 10,
              color: AppColors.textSecondaryOf(context),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Donut painter ────────────────────────────────────────────────────────────

class _Segment {
  const _Segment(this.label, this.percentage, this.color);
  final String label;
  final double percentage;
  final Color color;
}

class _DonutPainter extends CustomPainter {
  const _DonutPainter({required this.segments, required this.trackColor});

  final List<_Segment> segments;
  final Color trackColor;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final radius = math.min(size.width, size.height) / 2;
    final stroke = radius * 0.20;
    final rect = Rect.fromCircle(
      center: Offset(cx, cy),
      radius: radius - stroke / 2,
    );

    canvas.drawArc(
      rect,
      0,
      math.pi * 2,
      false,
      Paint()
        ..color = trackColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke,
    );

    final total = _sumPct(segments);
    if (total <= 0) return;

    var startAngle = -math.pi / 2;
    for (final seg in segments) {
      final pct = seg.percentage.isNaN ? 0.0 : seg.percentage;
      if (pct <= 0) continue;
      final sweep = (pct / total) * math.pi * 2;
      canvas.drawArc(
        rect,
        startAngle,
        sweep,
        false,
        Paint()
          ..color = seg.color
          ..style = PaintingStyle.stroke
          ..strokeWidth = stroke - 2
          ..strokeCap = StrokeCap.round,
      );
      startAngle += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter old) {
    if (old.trackColor != trackColor) return true;
    if (old.segments.length != segments.length) return true;
    for (var i = 0; i < segments.length; i++) {
      if (old.segments[i].percentage != segments[i].percentage) return true;
      if (old.segments[i].color != segments[i].color) return true;
    }
    return false;
  }
}

// ─── Helpers ──────────────────────────────────────────────────────────────────

double _sumPct(List<_Segment> segs) =>
    segs.fold<double>(0, (t, s) => t + (s.percentage.isNaN ? 0 : s.percentage));

String _fmtPct(double v) {
  final safe = v.isNaN ? 0.0 : v;
  return safe.round().clamp(0, 999).toString();
}

String _fmt1(double v) {
  final s = v.toStringAsFixed(1);
  return s.endsWith('.0') ? '${v.round()}g' : '${s}g';
}
