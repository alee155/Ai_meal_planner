import 'package:ai_meal_planner/core/network/api_client.dart';
import 'package:ai_meal_planner/core/network/api_endpoints.dart';
import 'package:ai_meal_planner/core/network/models/api_message_response_model.dart';
import 'package:ai_meal_planner/features/Auth/otp/models/resend_otp_request_model.dart';
import 'package:ai_meal_planner/features/Auth/otp/models/verify_otp_request_model.dart';
import 'package:get/get.dart';

class OtpService {
  OtpService({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient.ensureRegistered();

  final ApiClient _apiClient;

  static OtpService ensureRegistered() {
    if (Get.isRegistered<OtpService>()) {
      return Get.find<OtpService>();
    }

    return Get.put(OtpService(), permanent: true);
  }

  Future<ApiMessageResponseModel> verifyOtp(
    VerifyOtpRequestModel request,
  ) async {
    final response = await _apiClient.postRequest(
      ApiEndpoints.auth.verifyOtp,
      body: request.toJson(),
    );

    return ApiMessageResponseModel.fromJson(response);
  }

  Future<ApiMessageResponseModel> resendOtp(
    ResendOtpRequestModel request,
  ) async {
    final response = await _apiClient.postRequest(
      ApiEndpoints.auth.resendOtp,
      body: request.toJson(),
    );

    return ApiMessageResponseModel.fromJson(response);
  }
}
