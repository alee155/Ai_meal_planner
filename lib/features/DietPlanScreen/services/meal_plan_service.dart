import 'package:ai_meal_planner/core/network/api_client.dart';
import 'package:ai_meal_planner/core/network/api_endpoints.dart';
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
}
