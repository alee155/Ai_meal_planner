import 'dart:math' as math;

import 'package:ai_meal_planner/core/constants/app_colors.dart';
import 'package:ai_meal_planner/core/theme/app_text_styles.dart';
import 'package:ai_meal_planner/features/DietPlanScreen/models/latest_meal_plan_response_model.dart';
import 'package:ai_meal_planner/features/DietPlanScreen/widgets/plan_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MacroRingCard extends StatelessWidget {
  const MacroRingCard({super.key, required this.percentages});

  final MealPlanMacroPercentagesModel percentages;

  @override
  Widget build(BuildContext context) {
    final segments = <_MacroSegment>[
      _MacroSegment('Protein', percentages.protein, AppColors.info),
      _MacroSegment('Carbs', percentages.carbs, AppColors.warning),
      _MacroSegment('Fats', percentages.fats, AppColors.primaryGreenLight),
    ];

    return PlanCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Macro distribution',
                  style: AppTextStyles.title(
                    context,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Text(
                'Today',
                style: AppTextStyles.caption(
                  context,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondaryOf(context),
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          Row(
            children: [
              SizedBox(
                width: 118.w,
                height: 118.w,
                child: CustomPaint(
                  painter: _MacroDonutPainter(
                    segments: segments,
                    trackColor: AppColors.borderOf(
                      context,
                    ).withValues(alpha: 0.45),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Macros',
                          style: AppTextStyles.caption(
                            context,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textSecondaryOf(context),
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          '${_fmtPct(_sumPct(segments))}%',
                          style: AppTextStyles.title(
                            context,
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  children: segments
                      .map((segment) => _LegendRow(segment: segment))
                      .toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LegendRow extends StatelessWidget {
  const _LegendRow({required this.segment});

  final _MacroSegment segment;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Row(
        children: [
          Container(
            width: 10.w,
            height: 10.w,
            decoration: BoxDecoration(
              color: segment.color,
              borderRadius: BorderRadius.circular(3.r),
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              segment.label,
              style: AppTextStyles.body(
                context,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: AppColors.backgroundSecondaryOf(context),
              borderRadius: BorderRadius.circular(999.r),
              border: Border.all(color: AppColors.borderOf(context)),
            ),
            child: Text(
              '${_fmtPct(segment.percentage)}%',
              style: AppTextStyles.caption(
                context,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MacroSegment {
  const _MacroSegment(this.label, this.percentage, this.color);

  final String label;
  final double percentage;
  final Color color;
}

class _MacroDonutPainter extends CustomPainter {
  _MacroDonutPainter({required this.segments, required this.trackColor});

  final List<_MacroSegment> segments;
  final Color trackColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;
    final stroke = radius * 0.22;

    final rect = Rect.fromCircle(center: center, radius: radius - stroke / 2);
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, 0, math.pi * 2, false, trackPaint);

    final total = _sumPct(segments);
    if (total <= 0) return;

    var startAngle = -math.pi / 2;
    for (final segment in segments) {
      final pct = segment.percentage.isNaN ? 0.0 : segment.percentage;
      if (pct <= 0) continue;
      final sweep = (pct / total) * math.pi * 2;
      final paint = Paint()
        ..color = segment.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(rect, startAngle, sweep, false, paint);
      startAngle += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _MacroDonutPainter oldDelegate) {
    if (oldDelegate.trackColor != trackColor) return true;
    if (oldDelegate.segments.length != segments.length) return true;
    for (var i = 0; i < segments.length; i++) {
      if (oldDelegate.segments[i].percentage != segments[i].percentage) {
        return true;
      }
      if (oldDelegate.segments[i].color != segments[i].color) return true;
      if (oldDelegate.segments[i].label != segments[i].label) return true;
    }
    return false;
  }
}

double _sumPct(List<_MacroSegment> segments) {
  return segments.fold<double>(
    0,
    (total, segment) =>
        total + (segment.percentage.isNaN ? 0 : segment.percentage),
  );
}

String _fmtPct(double value) {
  final safe = value.isNaN ? 0.0 : value;
  final rounded = safe.round();
  return rounded.clamp(0, 999).toString();
}
