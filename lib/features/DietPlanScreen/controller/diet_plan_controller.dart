import 'dart:async';

import 'package:ai_meal_planner/core/network/api_exception.dart';
import 'package:ai_meal_planner/features/DietPlanScreen/models/latest_meal_plan_response_model.dart';
import 'package:ai_meal_planner/features/DietPlanScreen/services/meal_plan_service.dart';
import 'package:get/get.dart';

class DietPlanMealDetails {
  const DietPlanMealDetails({
    required this.items,
    required this.alternatives,
    required this.totals,
  });

  final List<String> items;
  final List<String> alternatives;
  final MealPlanTotalsModel totals;

  bool get hasAnything =>
      items.isNotEmpty || alternatives.isNotEmpty || totals.calories > 0;
}

class DietPlanController extends GetxController {
  DietPlanController({MealPlanService? mealPlanService})
    : _mealPlanService = mealPlanService ?? MealPlanService.ensureRegistered();

  final MealPlanService _mealPlanService;

  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;
  final Rxn<LatestMealPlanDataModel> latest = Rxn<LatestMealPlanDataModel>();
  final Rxn<DateTime> lastFetchedAt = Rxn<DateTime>();

  bool _isFetching = false;

  static DietPlanController ensureRegistered() {
    if (Get.isRegistered<DietPlanController>()) {
      return Get.find<DietPlanController>();
    }

    return Get.put(DietPlanController(), permanent: true);
  }

  @override
  void onInit() {
    super.onInit();
    unawaited(ensureFresh(showLoaderIfEmpty: true));
  }

  Future<void> ensureFresh({
    Duration maxAge = const Duration(minutes: 15),
    bool showLoaderIfEmpty = false,
  }) async {
    final last = lastFetchedAt.value;
    final now = DateTime.now();
    final isStale = last == null ? true : now.difference(last) > maxAge;

    if (!isStale) return;
    await fetchLatest(showLoader: showLoaderIfEmpty && latest.value == null);
  }

  Future<void> fetchLatest({
    bool showLoader = false,
    bool force = false,
  }) async {
    if (_isFetching && !force) return;
    _isFetching = true;
    if (showLoader) {
      isLoading.value = true;
    }
    errorMessage.value = '';

    try {
      final response = await _mealPlanService.fetchLatestMealPlan();
      latest.value = response.data;
      lastFetchedAt.value = DateTime.now();

      if (!response.success) {
        errorMessage.value = response.message?.trim().isNotEmpty == true
            ? response.message!.trim()
            : 'Unable to load meal plan.';
      } else if (response.data == null) {
        errorMessage.value = 'No meal plan found.';
      }
    } on ApiException catch (error) {
      latest.value = null;
      errorMessage.value = error.message.trim().isEmpty
          ? 'Unable to load meal plan.'
          : error.message;
    } catch (_) {
      latest.value = null;
      errorMessage.value = 'Something went wrong. Please try again.';
    } finally {
      isLoading.value = false;
      _isFetching = false;
    }
  }

  DietPlanMealDetails breakfastDetails() {
    final plan = latest.value?.plan;
    final meal = plan?.breakfast;
    final alternatives = plan?.alternatives?.breakfast ?? const [];
    return DietPlanMealDetails(
      items: _normalizeItemList(meal?.items ?? const []),
      alternatives: _normalizeItemList(alternatives),
      totals:
          meal?.totals ??
          const MealPlanTotalsModel(calories: 0, protein: 0, carbs: 0, fats: 0),
    );
  }

  DietPlanMealDetails lunchDetails() {
    final plan = latest.value?.plan;
    final meal = plan?.lunch;
    final alternatives = plan?.alternatives?.lunch ?? const [];
    return DietPlanMealDetails(
      items: _normalizeItemList(meal?.items ?? const []),
      alternatives: _normalizeItemList(alternatives),
      totals:
          meal?.totals ??
          const MealPlanTotalsModel(calories: 0, protein: 0, carbs: 0, fats: 0),
    );
  }

  DietPlanMealDetails dinnerDetails() {
    final plan = latest.value?.plan;
    final meal = plan?.dinner;
    final alternatives = plan?.alternatives?.dinner ?? const [];
    return DietPlanMealDetails(
      items: _normalizeItemList(meal?.items ?? const []),
      alternatives: _normalizeItemList(alternatives),
      totals:
          meal?.totals ??
          const MealPlanTotalsModel(calories: 0, protein: 0, carbs: 0, fats: 0),
    );
  }

  DietPlanMealDetails snacksDetails() {
    final plan = latest.value?.plan;
    final snacks = plan?.snacks ?? const <MealPlanMealModel>[];
    final alternatives = plan?.alternatives?.snacks ?? const [];

    final items = <String>[];
    var totals = const MealPlanTotalsModel(
      calories: 0,
      protein: 0,
      carbs: 0,
      fats: 0,
    );

    for (final snack in snacks) {
      items.addAll(_normalizeItemList(snack.items));
      totals = MealPlanTotalsModel(
        calories: totals.calories + snack.totals.calories,
        protein: totals.protein + snack.totals.protein,
        carbs: totals.carbs + snack.totals.carbs,
        fats: totals.fats + snack.totals.fats,
      );
    }

    return DietPlanMealDetails(
      items: items,
      alternatives: _normalizeItemList(alternatives),
      totals: totals,
    );
  }
}

List<String> _normalizeItemList(List<dynamic> raw) {
  return raw
      .map(_describeMealItem)
      .map((value) => value.trim())
      .where((value) => value.isNotEmpty)
      .toList();
}

String _describeMealItem(dynamic item) {
  if (item == null) return '';
  if (item is String) return item;
  if (item is num) return item.toString();
  if (item is Map) {
    final map = item.map((k, v) => MapEntry(k.toString(), v));
    final name =
        (map['name'] ??
                map['title'] ??
                map['label'] ??
                map['foodName'] ??
                map['recipeName'] ??
                map['itemName'] ??
                map['food'] ??
                map['recipe'])
            ?.toString()
            .trim();
    final quantity =
        (map['quantity'] ??
                map['qty'] ??
                map['amount'] ??
                map['servings'] ??
                map['serving'] ??
                map['portion'] ??
                map['servingSize'])
            ?.toString()
            .trim();
    final unit = (map['unit'] ?? map['uom'])?.toString().trim();
    final calories = (map['calories'] ?? map['kcal'])?.toString().trim();

    final parts = <String>[
      if ((name ?? '').isNotEmpty) name!,
      if ((quantity ?? '').isNotEmpty && (unit ?? '').isNotEmpty)
        '$quantity $unit'
      else if ((quantity ?? '').isNotEmpty)
        quantity!,
      if ((calories ?? '').isNotEmpty) '$calories kcal',
    ];

    if (parts.isNotEmpty) return parts.join(' - ');
    return map.values.whereType<String>().join(' ');
  }

  return item.toString();
}
