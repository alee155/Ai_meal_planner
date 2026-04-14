import 'package:ai_meal_planner/core/network/api_client.dart';
import 'package:ai_meal_planner/core/network/api_endpoints.dart';
import 'package:ai_meal_planner/features/Auth/login/models/login_request_model.dart';
import 'package:ai_meal_planner/features/Auth/login/models/login_response_model.dart';
import 'package:get/get.dart';

class LoginService {
  LoginService({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient.ensureRegistered();

  final ApiClient _apiClient;

  static LoginService ensureRegistered() {
    if (Get.isRegistered<LoginService>()) {
      return Get.find<LoginService>();
    }

    return Get.put(LoginService(), permanent: true);
  }

  Future<LoginResponseModel> loginUser(LoginRequestModel request) async {
    final response = await _apiClient.post(
      ApiEndpoints.auth.login,
      body: request.toJson(),
    );

    return LoginResponseModel.fromApiResponse(response);
  }
}
