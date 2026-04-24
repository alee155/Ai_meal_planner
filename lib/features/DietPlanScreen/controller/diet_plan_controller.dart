import 'dart:async';

import 'package:ai_meal_planner/core/network/api_exception.dart';
import 'package:ai_meal_planner/core/auth/services/auth_session_storage_service.dart';
import 'package:ai_meal_planner/features/DietPlanScreen/models/latest_meal_plan_response_model.dart';
import 'package:ai_meal_planner/features/DietPlanScreen/services/meal_plan_service.dart';
import 'package:get/get.dart';

class DietPlanController extends GetxController {
  DietPlanController({
    MealPlanService? mealPlanService,
    AuthSessionStorageService? authStorageService,
  }) : _mealPlanService = mealPlanService ?? MealPlanService.ensureRegistered(),
       _authStorageService =
           authStorageService ?? AuthSessionStorageService.ensureRegistered();

  final MealPlanService _mealPlanService;
  final AuthSessionStorageService _authStorageService;

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
      final token = await _authStorageService.readToken();
      final hasToken = token != null && token.trim().isNotEmpty;
      if (!hasToken) {
        latest.value = null;
        lastFetchedAt.value = null;
        return;
      }

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

  // Old meal-detail helpers removed; the latest API now returns structured
  // `plan.meals`, `swapSuggestions`, and `flags` directly.
}
