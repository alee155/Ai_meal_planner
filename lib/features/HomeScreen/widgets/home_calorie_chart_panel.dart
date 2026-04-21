import 'dart:math' as math;

import 'package:ai_meal_planner/core/constants/app_colors.dart';
import 'package:ai_meal_planner/core/theme/app_text_styles.dart';
import 'package:ai_meal_planner/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

enum HomeCalorieChartType { spline, bars }

class HomeCalorieChartPanel extends StatelessWidget {
  const HomeCalorieChartPanel({
    super.key,
    required this.values,
    required this.days,
    required this.selectedChartType,
    required this.onChartTypeChanged,
    this.isGuest = false,
  });

  final List<double> values;
  final List<String> days;
  final HomeCalorieChartType selectedChartType;
  final ValueChanged<HomeCalorieChartType> onChartTypeChanged;
  final bool isGuest;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final lowestValue = values.reduce(math.min).round();
    final peakValue = values.reduce(math.max).round();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.surfaceOf(context),
        borderRadius: BorderRadius.circular(28.r),
        border: Border.all(color: AppColors.borderOf(context)),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowOf(context).withValues(alpha: 0.18),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      selectedChartType == HomeCalorieChartType.spline
                          ? l10n.calorieSplineChart
                          : l10n.calorieColumnChart,
                      style: AppTextStyles.headline(
                        context,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      selectedChartType == HomeCalorieChartType.spline
                          ? l10n.weeklyTotalCalorieTrend
                          : l10n.weeklyCalorieComparisonByDay,
                      style: AppTextStyles.label(context),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 12.w),
              _ChartTypeToggle(
                selectedChartType: selectedChartType,
                onChartTypeChanged: onChartTypeChanged,
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              switchInCurve: Curves.easeOut,
              switchOutCurve: Curves.easeIn,
              child: CustomPaint(
                key: ValueKey(selectedChartType),
                painter: selectedChartType == HomeCalorieChartType.spline
                    ? _SplineChartPainter(
                        values: values,
                        gridColor: AppColors.borderOf(context),
                        lineColor: AppColors.isDark(context)
                            ? AppColors.primaryGreenLight
                            : AppColors.primaryGreenDark,
                        fillTopColor: AppColors.isDark(context)
                            ? AppColors.primaryGreenLight.withValues(
                                alpha: 0.28,
                              )
                            : AppColors.primaryGreenDark.withValues(
                                alpha: 0.34,
                              ),
                        fillBottomColor: AppColors.isDark(context)
                            ? AppColors.primaryGreenLight.withValues(
                                alpha: 0.05,
                              )
                            : AppColors.primaryGreenDark.withValues(
                                alpha: 0.08,
                              ),
                        pointCenterColor: AppColors.surfaceOf(context),
                        valueLabelColor: AppColors.textPrimaryOf(context),
                        showValueLabels: !isGuest,
                      )
                    : _ColumnBarChartPainter(
                        values: values,
                        gridColor: AppColors.borderOf(context),
                        barColor: AppColors.isDark(context)
                            ? AppColors.primaryGreenLight
                            : AppColors.primaryGreenDark,
                        highlightedBarColor: AppColors.primaryGreenDark,
                        barShadowColor: AppColors.primaryGreenDark.withValues(
                          alpha: 0.12,
                        ),
                        valueLabelColor: AppColors.textPrimaryOf(context),
                        showValueLabels: !isGuest,
                      ),
                child: const SizedBox.expand(),
              ),
            ),
          ),
          SizedBox(height: 10.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: days
                .map((day) => Text(day, style: AppTextStyles.caption(context)))
                .toList(),
          ),
          SizedBox(height: 10.h),
          Row(
            children: [
              if (!isGuest)
                Text(
                  l10n.lowestKcal(lowestValue),
                  style: AppTextStyles.caption(context, fontSize: 12),
                ),
              if (!isGuest) const Spacer(),
              if (!isGuest)
                Text(
                  l10n.peakKcal(peakValue),
                  style: AppTextStyles.caption(
                    context,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryGreenDark,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ChartTypeToggle extends StatelessWidget {
  const _ChartTypeToggle({
    required this.selectedChartType,
    required this.onChartTypeChanged,
  });

  final HomeCalorieChartType selectedChartType;
  final ValueChanged<HomeCalorieChartType> onChartTypeChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondaryOf(context),
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: AppColors.borderOf(context)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ChartToggleChip(
            label: context.l10n.spline,
            isSelected: selectedChartType == HomeCalorieChartType.spline,
            onTap: () => onChartTypeChanged(HomeCalorieChartType.spline),
          ),
          SizedBox(width: 6.w),
          _ChartToggleChip(
            label: context.l10n.bars,
            isSelected: selectedChartType == HomeCalorieChartType.bars,
            onTap: () => onChartTypeChanged(HomeCalorieChartType.bars),
          ),
        ],
      ),
    );
  }
}

class _ChartToggleChip extends StatelessWidget {
  const _ChartToggleChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final foregroundColor = isSelected
        ? AppColors.textWhite
        : AppColors.textPrimaryOf(context);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryGreenDark : Colors.transparent,
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: Text(
          label,
          style: AppTextStyles.caption(
            context,
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: foregroundColor,
          ),
        ),
      ),
    );
  }
}

class _SplineChartPainter extends CustomPainter {
  _SplineChartPainter({
    required this.values,
    required this.gridColor,
    required this.lineColor,
    required this.fillTopColor,
    required this.fillBottomColor,
    required this.pointCenterColor,
    required this.valueLabelColor,
    this.showValueLabels = true,
  });

  final List<double> values;
  final Color gridColor;
  final Color lineColor;
  final Color fillTopColor;
  final Color fillBottomColor;
  final Color pointCenterColor;
  final Color valueLabelColor;
  final bool showValueLabels;

  @override
  void paint(Canvas canvas, Size size) {
    const horizontalPadding = 8.0;
    const topPadding = 22.0;
    const bottomPadding = 8.0;
    final chartWidth = size.width - (horizontalPadding * 2);
    final chartHeight = size.height - topPadding - bottomPadding;

    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1;

    for (var i = 0; i < 4; i++) {
      final y = topPadding + (chartHeight / 3) * i;
      canvas.drawLine(
        Offset(horizontalPadding, y),
        Offset(size.width - horizontalPadding, y),
        gridPaint,
      );
    }

    final minValue = values.reduce(math.min);
    final maxValue = values.reduce(math.max);
    final normalizedMax = maxValue + 80;
    final normalizedMin = math.max(0.0, minValue - 120);

    final points = _buildPoints(
      values: values,
      maxValue: normalizedMax,
      minValue: normalizedMin,
      horizontalPadding: horizontalPadding,
      topPadding: topPadding,
      chartWidth: chartWidth,
      chartHeight: chartHeight,
    );

    final linePath = Path()..moveTo(points.first.dx, points.first.dy);
    _addSmoothPath(linePath, points);

    final areaPath = Path.from(linePath)
      ..lineTo(points.last.dx, size.height - bottomPadding)
      ..lineTo(points.first.dx, size.height - bottomPadding)
      ..close();

    final areaPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [fillTopColor, fillBottomColor],
      ).createShader(Offset.zero & size);

    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    canvas.drawPath(areaPath, areaPaint);
    canvas.drawPath(linePath, linePaint);

    if (showValueLabels) {
      for (var i = 0; i < points.length; i++) {
        _drawValueLabel(
          canvas: canvas,
          size: size,
          center: points[i],
          value: values[i].round().toString(),
          textColor: valueLabelColor,
          backgroundColor: lineColor.withValues(alpha: 0.14),
        );
      }
    }

    final highlightPoint = points[5];
    final shadowPaint = Paint()..color = lineColor.withValues(alpha: 0.14);
    canvas.drawCircle(highlightPoint, 12, shadowPaint);
    canvas.drawCircle(highlightPoint, 5.5, Paint()..color = lineColor);
    canvas.drawCircle(highlightPoint, 2.4, Paint()..color = pointCenterColor);
  }

  List<Offset> _buildPoints({
    required List<double> values,
    required double maxValue,
    required double minValue,
    required double horizontalPadding,
    required double topPadding,
    required double chartWidth,
    required double chartHeight,
  }) {
    final stepX = chartWidth / math.max(values.length - 1, 1);
    return List<Offset>.generate(values.length, (index) {
      final x = horizontalPadding + (stepX * index);
      final normalizedValue =
          (values[index] - minValue) / (maxValue - minValue);
      final y = topPadding + chartHeight - (normalizedValue * chartHeight);
      return Offset(x, y);
    });
  }

  void _addSmoothPath(Path path, List<Offset> points) {
    for (var i = 0; i < points.length - 1; i++) {
      final current = points[i];
      final next = points[i + 1];
      final controlPoint1 = Offset(
        current.dx + ((next.dx - current.dx) * 0.35),
        current.dy,
      );
      final controlPoint2 = Offset(
        current.dx + ((next.dx - current.dx) * 0.65),
        next.dy,
      );
      path.cubicTo(
        controlPoint1.dx,
        controlPoint1.dy,
        controlPoint2.dx,
        controlPoint2.dy,
        next.dx,
        next.dy,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _SplineChartPainter oldDelegate) {
    return oldDelegate.values != values ||
        oldDelegate.gridColor != gridColor ||
        oldDelegate.lineColor != lineColor ||
        oldDelegate.fillTopColor != fillTopColor ||
        oldDelegate.fillBottomColor != fillBottomColor ||
        oldDelegate.pointCenterColor != pointCenterColor ||
        oldDelegate.valueLabelColor != valueLabelColor ||
        oldDelegate.showValueLabels != showValueLabels;
  }
}

class _ColumnBarChartPainter extends CustomPainter {
  _ColumnBarChartPainter({
    required this.values,
    required this.gridColor,
    required this.barColor,
    required this.highlightedBarColor,
    required this.barShadowColor,
    required this.valueLabelColor,
    this.showValueLabels = true,
  });

  final List<double> values;
  final Color gridColor;
  final Color barColor;
  final Color highlightedBarColor;
  final Color barShadowColor;
  final Color valueLabelColor;
  final bool showValueLabels;

  @override
  void paint(Canvas canvas, Size size) {
    const horizontalPadding = 8.0;
    const topPadding = 22.0;
    const bottomPadding = 8.0;
    final chartWidth = size.width - (horizontalPadding * 2);
    final chartHeight = size.height - topPadding - bottomPadding;

    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1;

    for (var i = 0; i < 4; i++) {
      final y = topPadding + (chartHeight / 3) * i;
      canvas.drawLine(
        Offset(horizontalPadding, y),
        Offset(size.width - horizontalPadding, y),
        gridPaint,
      );
    }

    final minValue = values.reduce(math.min);
    final maxValue = values.reduce(math.max);
    final normalizedMax = maxValue + 80;
    final normalizedMin = math.max(0.0, minValue - 120);
    final slotWidth = chartWidth / values.length;
    final barWidth = math.min(28.0, slotWidth * 0.58);
    final peakIndex = values.indexOf(maxValue);

    for (var i = 0; i < values.length; i++) {
      final normalizedValue =
          (values[i] - normalizedMin) / (normalizedMax - normalizedMin);
      final barHeight = math.max(10.0, normalizedValue * chartHeight);
      final left =
          horizontalPadding + (slotWidth * i) + ((slotWidth - barWidth) / 2);
      final top = topPadding + chartHeight - barHeight;
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(left, top, barWidth, barHeight),
        const Radius.circular(5),
      );

      final currentBarColor = i == peakIndex ? highlightedBarColor : barColor;
      // final shadowRect = rect.shift(const Offset(0, 6));

      // canvas.drawRRect(shadowRect, Paint()..color = barShadowColor);
      canvas.drawRRect(
        rect,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              currentBarColor.withValues(alpha: 0.98),
              currentBarColor.withValues(alpha: 0.68),
            ],
          ).createShader(rect.outerRect),
      );
      //
      if (showValueLabels) {
        _drawValueLabel(
          canvas: canvas,
          size: size,
          center: Offset(rect.outerRect.center.dx, rect.outerRect.top),
          value: values[i].round().toString(),
          textColor: valueLabelColor,
          backgroundColor: currentBarColor.withValues(alpha: 0.14),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _ColumnBarChartPainter oldDelegate) {
    return oldDelegate.values != values ||
        oldDelegate.gridColor != gridColor ||
        oldDelegate.barColor != barColor ||
        oldDelegate.highlightedBarColor != highlightedBarColor ||
        oldDelegate.barShadowColor != barShadowColor ||
        oldDelegate.valueLabelColor != valueLabelColor ||
        oldDelegate.showValueLabels != showValueLabels;
  }
}

void _drawValueLabel({
  required Canvas canvas,
  required Size size,
  required Offset center,
  required String value,
  required Color textColor,
  required Color backgroundColor,
}) {
  final textPainter = TextPainter(
    text: TextSpan(
      text: value,
      style: TextStyle(
        color: textColor,
        fontSize: 10.sp,
        fontWeight: FontWeight.w700,
      ),
    ),
    textDirection: TextDirection.ltr,
    maxLines: 1,
  )..layout();

  const horizontalPadding = 6.0;
  const verticalPadding = 3.0;
  final labelWidth = textPainter.width + (horizontalPadding * 2);
  final labelHeight = textPainter.height + (verticalPadding * 2);
  final left = (center.dx - (labelWidth / 2)).clamp(
    0.0,
    size.width - labelWidth,
  );
  final top = (center.dy - labelHeight - 8).clamp(
    0.0,
    size.height - labelHeight,
  );
  final rect = RRect.fromRectAndRadius(
    Rect.fromLTWH(left, top, labelWidth, labelHeight),
    const Radius.circular(999),
  );

  canvas.drawRRect(rect, Paint()..color = backgroundColor);
  textPainter.paint(
    canvas,
    Offset(left + horizontalPadding, top + verticalPadding),
  );
}
