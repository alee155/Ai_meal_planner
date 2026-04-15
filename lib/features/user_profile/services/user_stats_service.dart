import 'package:ai_meal_planner/core/network/api_client.dart';
import 'package:ai_meal_planner/core/network/api_endpoints.dart';
import 'package:ai_meal_planner/features/user_profile/models/user_stats_response_model.dart';
import 'package:get/get.dart';

class UserStatsService {
  UserStatsService({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient.ensureRegistered();

  final ApiClient _apiClient;

  static UserStatsService ensureRegistered() {
    if (Get.isRegistered<UserStatsService>()) {
      return Get.find<UserStatsService>();
    }

    return Get.put(UserStatsService(), permanent: true);
  }

  Future<UserStatsResponseModel> fetchUserStats() async {
    final response = await _apiClient.getRequest(ApiEndpoints.users.stats);
    return UserStatsResponseModel.fromJson(response);
  }

  Future<UserStatsResponseModel> createUserStats(
    Map<String, dynamic> body,
  ) async {
    final response = await _apiClient.postRequest(
      ApiEndpoints.users.stats,
      body: body,
    );
    return UserStatsResponseModel.fromJson(response);
  }

  Future<UserStatsResponseModel> updateUserStats(
    Map<String, dynamic> body,
  ) async {
    final response = await _apiClient.patchRequest(
      ApiEndpoints.users.stats,
      body: body,
    );
    return UserStatsResponseModel.fromJson(response);
  }
}
