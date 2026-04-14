import 'package:ai_meal_planner/core/network/api_client.dart';
import 'package:ai_meal_planner/core/network/api_endpoints.dart';
import 'package:ai_meal_planner/features/Auth/signup/models/signup_request_model.dart';
import 'package:ai_meal_planner/features/Auth/signup/models/signup_response_model.dart';
import 'package:get/get.dart';

class SignupService {
  SignupService({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient.ensureRegistered();

  final ApiClient _apiClient;

  static SignupService ensureRegistered() {
    if (Get.isRegistered<SignupService>()) {
      return Get.find<SignupService>();
    }

    return Get.put(SignupService(), permanent: true);
  }

  Future<SignupResponseModel> registerUser(SignupRequestModel request) async {
    final response = await _apiClient.postRequest(
      ApiEndpoints.auth.register,
      body: request.toJson(),
    );

    return SignupResponseModel.fromJson(response);
  }
}
