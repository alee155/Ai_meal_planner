import 'package:ai_meal_planner/core/network/api_client.dart';
import 'package:ai_meal_planner/core/network/api_endpoints.dart';
import 'package:ai_meal_planner/core/network/api_exception.dart';
import 'package:ai_meal_planner/features/DietPlanScreen/models/latest_meal_plan_response_model.dart';
import 'package:get/get.dart';

class MealPlanService {
  MealPlanService({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient.ensureRegistered();

  final ApiClient _apiClient;

  static MealPlanService ensureRegistered() {
    if (Get.isRegistered<MealPlanService>()) {
      return Get.find<MealPlanService>();
    }
    return Get.put(MealPlanService(), permanent: true);
  }

  Future<LatestMealPlanResponseModel> fetchLatestMealPlan() async {
    final response = await _apiClient.getRequest(ApiEndpoints.meals.latest);
    return LatestMealPlanResponseModel.fromJson(response);
  }

  /// POST /meals/complete
  Future<MealCompleteResponseModel> completeMeal({
    required String mealType,
    required DateTime completedAt,
  }) async {
    final body = {
      'mealType': mealType,
      'completedAt': completedAt.toUtc().toIso8601String(),
    };
    final apiResponse = await _apiClient.post(
      ApiEndpoints.meals.complete,
      body: body,
    );
    final statusCode = apiResponse.statusCode;
    final data = apiResponse.data;

    switch (statusCode) {
      case 200:
        return MealCompleteResponseModel.fromJson(data);
      case 400:
        throw ApiException(
          message:
              _msg(data) ?? 'Invalid request. Please check the meal details.',
          statusCode: 400,
          data: data,
        );
      case 401:
        throw ApiException(
          message: 'Your session has expired. Please log in again.',
          statusCode: 401,
          data: data,
        );
      case 404:
        throw ApiException(
          message: 'Meal not found. It may have been removed or updated.',
          statusCode: 404,
          data: data,
        );
      default:
        throw ApiException(
          message: _msg(data) ?? 'Something went wrong. Please try again.',
          statusCode: statusCode,
          data: data,
        );
    }
  }

  /// PATCH /meals/time-windows
  ///
  /// Updates a meal time window on the server. The API always expects UTC time
  /// regardless of what is displayed in the UI (PKT). mealIndex is always 1.
  ///
  /// [startUtc] and [endUtc] are HH:mm strings in UTC (e.g. "03:00").
  Future<void> updateMealTimeWindow({
    required String mealType,
    required String startUtc,
    required String endUtc,
  }) async {
    final body = {
      'mealType': mealType,
      'mealIndex': 1,
      'start': startUtc,
      'end': endUtc,
      'timezone': 'UTC',
    };
    final apiResponse = await _apiClient.post(
      ApiEndpoints.meals.timeWindows,
      body: body,
    );
    final statusCode = apiResponse.statusCode;
    final data = apiResponse.data;

    if (statusCode == 200 || statusCode == 204) return;

    throw ApiException(
      message: _msg(data) ?? _statusMessage(statusCode),
      statusCode: statusCode,
      data: data,
    );
  }

  static String? _msg(Map<String, dynamic> data) {
    final v = data['message']?.toString().trim();
    return (v != null && v.isNotEmpty) ? v : null;
  }

  static String _statusMessage(int code) {
    switch (code) {
      case 400:
        return 'Invalid request.';
      case 401:
        return 'Session expired. Please log in again.';
      case 404:
        return 'Meal not found.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }
}
