import 'dart:async';

import 'package:ai_meal_planner/core/network/api_exception.dart';
import 'package:ai_meal_planner/core/auth/services/auth_session_storage_service.dart';
import 'package:ai_meal_planner/features/DietPlanScreen/models/latest_meal_plan_response_model.dart';
import 'package:ai_meal_planner/features/DietPlanScreen/services/meal_plan_service.dart';
import 'package:ai_meal_planner/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DietPlanController extends GetxController {
  DietPlanController({
    MealPlanService? mealPlanService,
    AuthSessionStorageService? authStorageService,
    Duration pollingInterval = const Duration(minutes: 5),
  }) : _mealPlanService = mealPlanService ?? MealPlanService.ensureRegistered(),
       _authStorageService =
           authStorageService ?? AuthSessionStorageService.ensureRegistered(),
       _pollingInterval = pollingInterval;

  final MealPlanService _mealPlanService;
  final AuthSessionStorageService _authStorageService;
  final Duration _pollingInterval;

  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;
  final Rxn<LatestMealPlanDataModel> latest = Rxn<LatestMealPlanDataModel>();
  final Rxn<DateTime> lastFetchedAt = Rxn<DateTime>();

  /// Tracks which meals are currently being marked complete (by mealName).
  final RxSet<String> completingMeals = <String>{}.obs;

  /// Tracks which meals have been successfully completed in this session.
  final RxSet<String> completedMeals = <String>{}.obs;

  bool _isFetching = false;

  /// Silent background polling stream. Fires every [_pollingInterval] and
  /// re-fetches the plan if stale. The UI reacts automatically via [latest].
  StreamSubscription<void>? _pollSubscription;

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
    _startPolling();
  }

  @override
  void onClose() {
    _pollSubscription?.cancel();
    super.onClose();
  }

  /// Starts a periodic stream that silently re-fetches the meal plan in the
  /// background. No loading spinner is shown — [latest] just updates and every
  /// widget listening via [Obx] re-renders automatically.
  void _startPolling() {
    _pollSubscription = Stream<void>.periodic(
      _pollingInterval,
    ).asyncMap((_) => ensureFresh()).listen(null);
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

  /// Marks a meal as complete via POST /meals/complete.
  ///
  /// Shows a snackbar on success or failure. Safe to call multiple times —
  /// duplicate in-flight calls for the same [mealName] are ignored.
  Future<void> markMealComplete({
    required String mealName,
    DateTime? completedAt,
  }) async {
    final key = mealName.trim().toLowerCase();

    if (completingMeals.contains(key)) return;

    completingMeals.add(key);

    try {
      final result = await _mealPlanService.completeMeal(
        mealType: key,
        completedAt: completedAt ?? DateTime.now().toUtc(),
      );

      completedMeals.add(key);

      // Silently cancel all pending window alarms for this meal —
      // the start/midpoint/pre-close notifications are no longer relevant.
      unawaited(NotificationService.cancelMealWindowAlarms(key));

      _showSnackbar(
        title: 'Meal logged!',
        message: result.message?.trim().isNotEmpty == true
            ? result.message!
            : '${_capitalize(mealName)} has been marked as complete.',
        isError: false,
        icon: Icons.check_circle_rounded,
      );
    } on ApiException catch (e) {
      _showSnackbar(
        title: _apiErrorTitle(e.statusCode),
        message: e.message,
        isError: true,
        icon: Icons.error_outline_rounded,
      );
    } catch (_) {
      _showSnackbar(
        title: 'Error',
        message: 'Could not mark meal as complete. Please try again.',
        isError: true,
        icon: Icons.error_outline_rounded,
      );
    } finally {
      completingMeals.remove(key);
    }
  }

  bool isMealCompleting(String mealName) =>
      completingMeals.contains(mealName.trim().toLowerCase());

  bool isMealCompleted(String mealName) =>
      completedMeals.contains(mealName.trim().toLowerCase());

  // ─── Private helpers ──────────────────────────────────────────────────────

  static String _apiErrorTitle(int? statusCode) {
    switch (statusCode) {
      case 400:
        return 'Invalid Request';
      case 401:
        return 'Session Expired';
      case 404:
        return 'Not Found';
      default:
        return 'Error';
    }
  }

  static String _capitalize(String value) {
    if (value.isEmpty) return value;
    return value[0].toUpperCase() + value.substring(1);
  }

  void _showSnackbar({
    required String title,
    required String message,
    required bool isError,
    required IconData icon,
  }) {
    Get.closeCurrentSnackbar();
    Get.showSnackbar(
      GetSnackBar(
        titleText: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 14,
          ),
        ),
        messageText: Text(
          message,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
        icon: Icon(icon, color: Colors.white, size: 24),
        backgroundColor: isError
            ? const Color(0xFFA32D2D)
            : const Color(0xFF2E7D32),
        duration: const Duration(seconds: 3),
        borderRadius: 14,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        snackPosition: SnackPosition.BOTTOM,
      ),
    );
  }
}
