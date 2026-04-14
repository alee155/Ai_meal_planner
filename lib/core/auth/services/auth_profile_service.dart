import 'package:ai_meal_planner/core/auth/models/auth_profile_response_model.dart';
import 'package:ai_meal_planner/core/network/api_client.dart';
import 'package:ai_meal_planner/core/network/api_endpoints.dart';
import 'package:get/get.dart';

class AuthProfileService {
  AuthProfileService({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient.ensureRegistered();

  final ApiClient _apiClient;

  static AuthProfileService ensureRegistered() {
    if (Get.isRegistered<AuthProfileService>()) {
      return Get.find<AuthProfileService>();
    }

    return Get.put(AuthProfileService(), permanent: true);
  }

  Future<AuthProfileResponseModel> fetchCurrentUserProfile() async {
    final response = await _apiClient.getRequest(ApiEndpoints.users.me);
    return AuthProfileResponseModel.fromJson(response);
  }
}
