import 'package:ai_meal_planner/core/constants/app_colors.dart';
import 'package:ai_meal_planner/core/theme/app_text_styles.dart';
import 'package:ai_meal_planner/features/DietPlanScreen/controller/diet_plan_controller.dart';
import 'package:ai_meal_planner/features/DietPlanScreen/models/latest_meal_plan_response_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

// ─── Public card ──────────────────────────────────────────────────────────────

class MealExpandableCard extends StatefulWidget {
  const MealExpandableCard({
    super.key,
    required this.meal,
    required this.swapSuggestions,
  });

  final MealPlanMealModel meal;
  final List<MealPlanSwapSuggestionModel> swapSuggestions;

  @override
  State<MealExpandableCard> createState() => _MealExpandableCardState();
}

class _MealExpandableCardState extends State<MealExpandableCard>
    with SingleTickerProviderStateMixin {
  late List<MealPlanFoodItemModel> _items;
  late AnimationController _completionAnim;
  late Animation<double> _completionFade;

  @override
  void initState() {
    super.initState();
    _items = List<MealPlanFoodItemModel>.from(widget.meal.items);
    _completionAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _completionFade = CurvedAnimation(
      parent: _completionAnim,
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _completionAnim.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant MealExpandableCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.meal != widget.meal) {
      _items = List<MealPlanFoodItemModel>.from(widget.meal.items);
    }
  }

  @override
  Widget build(BuildContext context) {
    final meal = widget.meal;
    final controller = DietPlanController.ensureRegistered();

    return Obx(() {
      final isCompleted = controller.isMealCompleted(meal.mealName);
      final isCompleting = controller.isMealCompleting(meal.mealName);
      final visuals = _mealVisuals(meal.mealName);

      // Kick off the fade-in animation when completion state first arrives
      if (isCompleted && _completionAnim.status == AnimationStatus.dismissed) {
        _completionAnim.forward();
      }

      final cardBg = isCompleted
          ? visuals.accent.withValues(alpha: 0.08)
          : AppColors.surfaceOf(context);
      final cardBorder = isCompleted
          ? visuals.accent.withValues(alpha: 0.35)
          : AppColors.borderOf(context);

      return AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: cardBorder, width: isCompleted ? 1.5 : 1),
          boxShadow: isCompleted
              ? [
                  BoxShadow(
                    color: visuals.accent.withValues(alpha: 0.12),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ]
              : [
                  BoxShadow(
                    color: AppColors.shadowOf(context),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20.r),
          child: Column(
            children: [
              // ── Header ──────────────────────────────────────────────────
              _CardHeader(
                meal: meal,
                visuals: visuals,
                items: _items,
                isCompleted: isCompleted,
                isCompleting: isCompleting,
                completionFade: _completionFade,
                onMarkComplete: () => controller.markMealComplete(
                  mealName: meal.mealName.trim().toLowerCase(),
                  completedAt: DateTime.now().toUtc(),
                ),
              ),
              // ── Divider ──────────────────────────────────────────────────
              Divider(
                height: 1,
                thickness: 1,
                color: isCompleted
                    ? visuals.accent.withValues(alpha: 0.20)
                    : AppColors.borderOf(context).withValues(alpha: 0.40),
              ),
              // ── Food items ───────────────────────────────────────────────
              if (_items.isEmpty)
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 18.w,
                    vertical: 14.h,
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'No items available',
                      style: AppTextStyles.caption(
                        context,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textSecondaryOf(context),
                      ),
                    ),
                  ),
                )
              else
                ..._items.map(
                  (item) => _MealItemRow(
                    item: item,
                    accent: visuals.accent,
                    isCompleted: isCompleted,
                    onSwapTap: _swapHandlerFor(
                      mealName: meal.mealName,
                      item: item,
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    });
  }

  VoidCallback? _swapHandlerFor({
    required String mealName,
    required MealPlanFoodItemModel item,
  }) {
    final suggestion = widget.swapSuggestions.where((s) {
      return s.meal.trim().toLowerCase() == mealName.trim().toLowerCase() &&
          s.currentItem.name.trim().toLowerCase() ==
              item.name.trim().toLowerCase();
    }).firstOrNull;
    if (suggestion == null) return null;
    final safeAlts = suggestion.alternatives.where((a) => a.isSafeSwap).toList()
      ..sort((a, b) => b.matchScore.compareTo(a.matchScore));
    if (safeAlts.isEmpty) return null;
    final best = safeAlts.first;
    return () => setState(() {
      final idx = _items.indexWhere(
        (e) =>
            e.name.trim().toLowerCase() == item.name.trim().toLowerCase() &&
            e.calories == item.calories,
      );
      if (idx != -1) {
        _items[idx] = MealPlanFoodItemModel(
          name: best.name,
          calories: best.calories,
          protein: best.protein,
          carbs: best.carbs,
          fats: best.fats,
          weightGrams: 0,
        );
      }
    });
  }
}

// ─── Card header (icon + name + time window + complete action) ────────────────

class _CardHeader extends StatelessWidget {
  const _CardHeader({
    required this.meal,
    required this.visuals,
    required this.items,
    required this.isCompleted,
    required this.isCompleting,
    required this.completionFade,
    required this.onMarkComplete,
  });

  final MealPlanMealModel meal;
  final _MealVisuals visuals;
  final List<MealPlanFoodItemModel> items;
  final bool isCompleted;
  final bool isCompleting;
  final Animation<double> completionFade;
  final VoidCallback onMarkComplete;

  int get _totalCalories => items.fold(0, (t, i) => t + i.calories);

  @override
  Widget build(BuildContext context) {
    final startPkt = meal.startPkt;
    final endPkt = meal.endPkt;
    final hasTime = startPkt != null;

    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Top row: icon / name / kcal badge / complete button ─────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Meal icon
              AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                width: 48.w,
                height: 48.w,
                decoration: BoxDecoration(
                  color: isCompleted
                      ? visuals.accent.withValues(alpha: 0.18)
                      : visuals.accent.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(visuals.icon, color: visuals.accent, size: 22.sp),
                    if (isCompleted)
                      FadeTransition(
                        opacity: completionFade,
                        child: Container(
                          decoration: BoxDecoration(
                            color: visuals.accent,
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                          child: Icon(
                            Icons.check_rounded,
                            color: Colors.white,
                            size: 22.sp,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              SizedBox(width: 12.w),
              // Name + subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            meal.mealName.trim().isEmpty
                                ? 'Meal'
                                : meal.mealName.trim(),
                            style: AppTextStyles.title(
                              context,
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        if (isCompleted) ...[
                          SizedBox(width: 8.w),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 3.h,
                            ),
                            decoration: BoxDecoration(
                              color: visuals.accent,
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.check_circle_rounded,
                                  color: Colors.white,
                                  size: 11.sp,
                                ),
                                SizedBox(width: 4.w),
                                Text(
                                  'Done',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10.sp,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      '${items.length} items · $_totalCalories kcal',
                      style: AppTextStyles.caption(
                        context,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondaryOf(
                          context,
                        ).withValues(alpha: 0.80),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // ── Time window pill ─────────────────────────────────────────────
          if (hasTime) ...[
            SizedBox(height: 12.h),
            _TimeWindowPill(
              meal: meal,
              accent: visuals.accent,
              startPkt: startPkt,
              endPkt: endPkt,
            ),
          ],
          // ── Mark-complete action — only visible after meal window starts ────
          if (_isMealWindowOpen(meal)) ...[
            SizedBox(height: 12.h),
            _CompleteAction(
              accent: visuals.accent,
              isCompleted: isCompleted,
              isCompleting: isCompleting,
              completionFade: completionFade,
              onTap: onMarkComplete,
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Time window pill ─────────────────────────────────────────────────────────

class _TimeWindowPill extends StatelessWidget {
  const _TimeWindowPill({
    required this.meal,
    required this.accent,
    required this.startPkt,
    this.endPkt,
  });

  final MealPlanMealModel meal;
  final Color accent;
  final ({int hour, int minute}) startPkt;
  final ({int hour, int minute})? endPkt;

  @override
  Widget build(BuildContext context) {
    final pktStart = _fmt(startPkt.hour, startPkt.minute);
    final pktEnd = endPkt != null ? _fmt(endPkt!.hour, endPkt!.minute) : null;

    // Original UTC times — read from startUtc/endUtc on the model
    final utcStart = meal.startUtc;
    final utcEnd = meal.endUtc;
    final tz = meal.timezone;
    String? originalLine;
    if (utcStart != null && tz != null && tz.isNotEmpty) {
      final utcStartStr = _fmt(utcStart.hour, utcStart.minute);
      final utcEndStr = utcEnd != null
          ? _fmt(utcEnd.hour, utcEnd.minute)
          : null;
      originalLine = utcEndStr != null
          ? '$utcStartStr – $utcEndStr UTC · $tz'
          : '$utcStartStr UTC · $tz';
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 9.h),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: accent.withValues(alpha: 0.20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // PKT row — primary display
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Text(
                  'PKT',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 9.sp,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Icon(Icons.schedule_rounded, size: 13.sp, color: accent),
              SizedBox(width: 4.w),
              Text(
                pktEnd != null ? '$pktStart  –  $pktEnd' : pktStart,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimaryOf(context),
                ),
              ),
              if (meal.editable == true) ...[
                const Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.edit_rounded, size: 10.sp, color: accent),
                      SizedBox(width: 3.w),
                      Text(
                        'Editable',
                        style: TextStyle(
                          fontSize: 9.sp,
                          fontWeight: FontWeight.w700,
                          color: accent,
                        ),
                      ),
                    ],
                  ),
                ),
              ] else if (meal.editable == false) ...[
                const Spacer(),
                Icon(
                  Icons.lock_outline_rounded,
                  size: 13.sp,
                  color: AppColors.textSecondaryOf(
                    context,
                  ).withValues(alpha: 0.50),
                ),
              ],
            ],
          ),
          // UTC / original tz row — secondary
          if (originalLine != null) ...[
            SizedBox(height: 5.h),
            Row(
              children: [
                Icon(
                  Icons.language_rounded,
                  size: 11.sp,
                  color: AppColors.textSecondaryOf(
                    context,
                  ).withValues(alpha: 0.70),
                ),
                SizedBox(width: 5.w),
                Expanded(
                  child: Text(
                    originalLine,
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: AppColors.textSecondaryOf(
                        context,
                      ).withValues(alpha: 0.70),
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  static String _fmt(int hour, int minute) {
    final period = hour < 12 ? 'AM' : 'PM';
    final h = hour % 12 == 0 ? 12 : hour % 12;
    final m = minute.toString().padLeft(2, '0');
    return '$h:$m $period';
  }
}

// ─── Complete action ──────────────────────────────────────────────────────────

class _CompleteAction extends StatelessWidget {
  const _CompleteAction({
    required this.accent,
    required this.isCompleted,
    required this.isCompleting,
    required this.completionFade,
    required this.onTap,
  });

  final Color accent;
  final bool isCompleted;
  final bool isCompleting;
  final Animation<double> completionFade;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    if (isCompleted) {
      return FadeTransition(
        opacity: completionFade,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 11.h),
          decoration: BoxDecoration(
            color: accent,
            borderRadius: BorderRadius.circular(14.r),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.check_circle_rounded,
                color: Colors.white,
                size: 17.sp,
              ),
              SizedBox(width: 8.w),
              Text(
                'Meal Completed!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: isCompleting ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 11.h),
        decoration: BoxDecoration(
          color: isCompleting ? accent.withValues(alpha: 0.60) : accent,
          borderRadius: BorderRadius.circular(14.r),
          boxShadow: [
            BoxShadow(
              color: accent.withValues(alpha: 0.30),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isCompleting)
              SizedBox(
                width: 15.w,
                height: 15.w,
                child: const CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            else
              Icon(Icons.check_rounded, color: Colors.white, size: 17.sp),
            SizedBox(width: 8.w),
            Text(
              isCompleting ? 'Logging meal…' : 'Mark as Complete',
              style: TextStyle(
                color: Colors.white,
                fontSize: 13.sp,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Food item row ────────────────────────────────────────────────────────────

class _MealItemRow extends StatelessWidget {
  const _MealItemRow({
    required this.item,
    required this.accent,
    required this.isCompleted,
    required this.onSwapTap,
  });

  final MealPlanFoodItemModel item;
  final Color accent;
  final bool isCompleted;
  final VoidCallback? onSwapTap;

  @override
  Widget build(BuildContext context) {
    final dimmed = isCompleted ? 0.55 : 1.0;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      child: Row(
        children: [
          Container(
            width: 6.w,
            height: 6.w,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: isCompleted ? 0.35 : 0.70),
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name.trim().isEmpty ? 'Item' : item.name.trim(),
                  style: AppTextStyles.body(
                    context,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimaryOf(
                      context,
                    ).withValues(alpha: 0.95 * dimmed),
                  ),
                ),
                SizedBox(height: 5.h),
                Wrap(
                  spacing: 5.w,
                  runSpacing: 5.h,
                  children: [
                    if (item.weightGrams > 0)
                      _badge('${item.weightGrams}g', accent, dimmed: dimmed),
                    _badge(
                      'P ${_fmt1(item.protein)}',
                      AppColors.info,
                      dimmed: dimmed,
                    ),
                    _badge(
                      'C ${_fmt1(item.carbs)}',
                      AppColors.warning,
                      dimmed: dimmed,
                    ),
                    _badge(
                      'F ${_fmt1(item.fats)}',
                      AppColors.error,
                      dimmed: dimmed,
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          if (onSwapTap != null && !isCompleted) ...[
            InkWell(
              onTap: onSwapTap,
              borderRadius: BorderRadius.circular(10.r),
              child: Container(
                padding: EdgeInsets.all(6.w),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  Icons.swap_horiz_rounded,
                  color: accent,
                  size: 18.sp,
                ),
              ),
            ),
            SizedBox(width: 10.w),
          ],
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${item.calories}',
                style: AppTextStyles.title(
                  context,
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                'kcal',
                style: AppTextStyles.caption(
                  context,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondaryOf(
                    context,
                  ).withValues(alpha: 0.65 * dimmed),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _badge(String label, Color color, {required double dimmed}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10 * dimmed + 0.02),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10.sp,
          fontWeight: FontWeight.w700,
          color: color.withValues(alpha: dimmed),
        ),
      ),
    );
  }
}

// ─── Window open check ────────────────────────────────────────────────────────

/// Returns true when the current PKT time is at or after the meal's start time.
/// If no start time is known (API didn't provide one) we default to showing the
/// button so users can always log their meal.
bool _isMealWindowOpen(MealPlanMealModel meal) {
  final start = meal.startPkt;
  if (start == null) return true; // no time data — always show
  final now = DateTime.now();
  final nowMinutes = now.hour * 60 + now.minute;
  final startMinutes = start.hour * 60 + start.minute;
  return nowMinutes >= startMinutes;
}

// ─── Visuals helper ───────────────────────────────────────────────────────────

class _MealVisuals {
  const _MealVisuals(this.icon, this.accent);
  final IconData icon;
  final Color accent;
}

_MealVisuals _mealVisuals(String mealName) {
  final n = mealName.trim().toLowerCase();
  if (n.contains('breakfast'))
    return const _MealVisuals(Icons.wb_sunny_rounded, Color(0xFFFFB300));
  if (n.contains('lunch'))
    return const _MealVisuals(Icons.lunch_dining_rounded, Color(0xFF4CAF50));
  if (n.contains('dinner'))
    return const _MealVisuals(Icons.nightlight_round, Color(0xFF7C4DFF));
  return const _MealVisuals(Icons.restaurant_menu_rounded, Color(0xFF388E3C));
}

/// Formats hour (0-23) and minute as "H:mm AM/PM".
String _fmtHM(int hour, int minute) {
  final period = hour < 12 ? 'AM' : 'PM';
  final h = hour % 12 == 0 ? 12 : hour % 12;
  final m = minute.toString().padLeft(2, '0');
  return '$h:$m $period';
}

String _fmt1(double v) {
  final s = v.toStringAsFixed(1);
  return s.endsWith('.0') ? '${v.round()}g' : '${s}g';
}
