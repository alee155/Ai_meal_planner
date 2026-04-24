import 'package:ai_meal_planner/core/constants/app_colors.dart';
import 'package:ai_meal_planner/core/theme/app_text_styles.dart';
import 'package:ai_meal_planner/features/DietPlanScreen/models/latest_meal_plan_response_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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

class _MealExpandableCardState extends State<MealExpandableCard> {
  late List<MealPlanFoodItemModel> _items;

  @override
  void initState() {
    super.initState();
    _items = List<MealPlanFoodItemModel>.from(widget.meal.items);
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
    final visuals = _mealVisuals(meal.mealName, context);
    final subtitle = '${_items.length} items · ${_itemsCalories()} kcal';

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceOf(context),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.borderOf(context)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14.r),
        child: Material(
          color: Colors.transparent,
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.all(18.w),
                child: Row(
                  children: [
                    Container(
                      width: 46.w,
                      height: 46.w,
                      decoration: BoxDecoration(
                        color: visuals.accent.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                      child: Icon(
                        visuals.icon,
                        color: visuals.accent,
                        size: 22.sp,
                      ),
                    ),
                    SizedBox(width: 14.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            meal.mealName.trim().isEmpty
                                ? 'Meal'
                                : meal.mealName.trim(),
                            style: AppTextStyles.title(
                              context,
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          SizedBox(height: 3.h),
                          Text(
                            subtitle,
                            style: AppTextStyles.caption(
                              context,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textSecondaryOf(
                                context,
                              ).withValues(alpha: 0.75),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 6.h,
                      ),
                      decoration: BoxDecoration(
                        color: visuals.accent.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(999.r),
                      ),
                      child: Text(
                        '${_itemsCalories()} kcal',
                        style: AppTextStyles.caption(
                          context,
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          color: visuals.accent,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Divider(
                height: 1,
                thickness: 1,
                color: AppColors.borderOf(context).withValues(alpha: 0.40),
              ),
              ..._items.map(
                (item) => _MealItemRow(
                  item: item,
                  accent: visuals.accent,
                  onSwapTap: _swapHandlerFor(
                    mealName: meal.mealName,
                    item: item,
                  ),
                ),
              ),
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
                ),
            ],
          ),
        ),
      ),
    );
  }

  VoidCallback? _swapHandlerFor({
    required String mealName,
    required MealPlanFoodItemModel item,
  }) {
    final suggestion = _findSuggestionFor(
      mealName: mealName,
      itemName: item.name,
    );
    if (suggestion == null) return null;

    final safeAlternatives = suggestion.alternatives
        .where((alt) => alt.isSafeSwap)
        .toList();
    if (safeAlternatives.isEmpty) return null;

    safeAlternatives.sort((a, b) => b.matchScore.compareTo(a.matchScore));
    final best = safeAlternatives.first;

    return () {
      final next = _toFoodItem(best);
      setState(() {
        final index = _items.indexWhere((e) => _sameItem(e, item));
        if (index == -1) return;
        _items[index] = next;
      });
    };
  }

  MealPlanSwapSuggestionModel? _findSuggestionFor({
    required String mealName,
    required String itemName,
  }) {
    final normalizedMeal = mealName.trim().toLowerCase();
    final normalizedItem = itemName.trim().toLowerCase();

    for (final suggestion in widget.swapSuggestions) {
      if (suggestion.meal.trim().toLowerCase() != normalizedMeal) continue;
      if (suggestion.currentItem.name.trim().toLowerCase() != normalizedItem) {
        continue;
      }
      return suggestion;
    }
    return null;
  }

  bool _sameItem(MealPlanFoodItemModel a, MealPlanFoodItemModel b) {
    return a.name.trim().toLowerCase() == b.name.trim().toLowerCase() &&
        a.calories == b.calories;
  }

  MealPlanFoodItemModel _toFoodItem(MealPlanSwapAlternativeModel alt) {
    return MealPlanFoodItemModel(
      name: alt.name,
      calories: alt.calories,
      protein: alt.protein,
      carbs: alt.carbs,
      fats: alt.fats,
      weightGrams: 0,
    );
  }

  int _itemsCalories() {
    return _items.fold<int>(0, (total, item) => total + item.calories);
  }
}

class _MealItemRow extends StatelessWidget {
  const _MealItemRow({
    required this.item,
    required this.accent,
    required this.onSwapTap,
  });

  final MealPlanFoodItemModel item;
  final Color accent;
  final VoidCallback? onSwapTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 12.h),
      child: Row(
        children: [
          Container(
            width: 6.w,
            height: 6.w,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.70),
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
                    ).withValues(alpha: 0.95),
                  ),
                ),
                SizedBox(height: 4.h),
                Wrap(
                  spacing: 6.w,
                  runSpacing: 6.h,
                  children: [
                    if (item.weightGrams > 0)
                      _MetaBadge(label: '${item.weightGrams}g', accent: accent),
                    _NutriBadge('P ${_fmt1(item.protein)}', AppColors.info),
                    _NutriBadge('C ${_fmt1(item.carbs)}', AppColors.warning),
                    _NutriBadge('F ${_fmt1(item.fats)}', AppColors.error),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: 10.w),
          if (onSwapTap != null) ...[
            IconButton(
              onPressed: onSwapTap,
              icon: const Icon(Icons.swap_horiz_rounded),
              color: accent,
              iconSize: 20.sp,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              tooltip: 'Swap',
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
              SizedBox(height: 2.h),
              Text(
                'kcal',
                style: AppTextStyles.caption(
                  context,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondaryOf(
                    context,
                  ).withValues(alpha: 0.65),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetaBadge extends StatelessWidget {
  const _MetaBadge({required this.label, required this.accent});

  final String label;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: accent.withValues(alpha: 0.22)),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption(
          context,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: accent,
        ),
      ),
    );
  }
}

class _NutriBadge extends StatelessWidget {
  const _NutriBadge(this.label, this.color);

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption(
          context,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

class _MealVisuals {
  const _MealVisuals(this.icon, this.accent);

  final IconData icon;
  final Color accent;
}

_MealVisuals _mealVisuals(String mealName, BuildContext context) {
  final normalized = mealName.trim().toLowerCase();
  if (normalized.contains('breakfast')) {
    return const _MealVisuals(Icons.wb_sunny_rounded, Color(0xFFFFB300));
  }
  if (normalized.contains('lunch')) {
    return const _MealVisuals(Icons.lunch_dining_rounded, Color(0xFF4CAF50));
  }
  if (normalized.contains('dinner')) {
    return const _MealVisuals(Icons.nightlight_round, Color(0xFF7C4DFF));
  }
  return _MealVisuals(
    Icons.restaurant_menu_rounded,
    AppColors.primaryGreenDark,
  );
}

String _fmt1(double value) {
  final trimmed = value.toStringAsFixed(1);
  if (trimmed.endsWith('.0')) {
    return '${value.round()}g';
  }
  return '${trimmed}g';
}
