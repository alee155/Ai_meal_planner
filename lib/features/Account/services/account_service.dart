import 'package:ai_meal_planner/core/network/api_client.dart';
import 'package:ai_meal_planner/core/network/api_endpoints.dart';
import 'package:ai_meal_planner/core/network/models/api_message_response_model.dart';
import 'package:ai_meal_planner/features/Account/models/password_reset_confirm_request_model.dart';
import 'package:ai_meal_planner/features/Account/models/password_reset_request_model.dart';
import 'package:ai_meal_planner/features/Account/models/update_password_request_model.dart';
import 'package:ai_meal_planner/features/Account/models/update_profile_request_model.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart' hide FormData, MultipartFile;

class AccountService {
  AccountService({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient.ensureRegistered();

  final ApiClient _apiClient;

  static AccountService ensureRegistered() {
    if (Get.isRegistered<AccountService>()) {
      return Get.find<AccountService>();
    }

    return Get.put(AccountService(), permanent: true);
  }

  Future<ApiMessageResponseModel> updatePassword(
    UpdatePasswordRequestModel request,
  ) async {
    final response = await _apiClient.putRequest(
      ApiEndpoints.auth.password.update,
      body: request.toJson(),
    );

    return ApiMessageResponseModel.fromJson(response);
  }

  Future<ApiMessageResponseModel> requestPasswordReset(
    PasswordResetRequestModel request,
  ) async {
    final response = await _apiClient.postRequest(
      ApiEndpoints.auth.password.resetRequest,
      body: request.toJson(),
    );

    return ApiMessageResponseModel.fromJson(response);
  }

  Future<ApiMessageResponseModel> confirmPasswordReset(
    PasswordResetConfirmRequestModel request,
  ) async {
    final response = await _apiClient.postRequest(
      ApiEndpoints.auth.password.resetConfirm,
      body: request.toJson(),
    );

    return ApiMessageResponseModel.fromJson(response);
  }

  Future<ApiMessageResponseModel> updateProfile(
    UpdateProfileRequestModel request,
  ) async {
    final formData = FormData.fromMap({
      'name': request.name.trim(),
      if ((request.profileImagePath ?? '').trim().isNotEmpty)
        'profileImage': MultipartFile.fromFileSync(
          request.profileImagePath!.trim(),
          filename: request.profileImagePath!.split('/').last,
        ),
    });

    final response = await _apiClient.putMultipartRequest(
      ApiEndpoints.users.me,
      body: formData,
    );

    return ApiMessageResponseModel.fromJson(response);
  }

  Future<ApiMessageResponseModel> deleteAccount() async {
    final response = await _apiClient.deleteRequest(
      ApiEndpoints.users.account.delete,
    );

    return ApiMessageResponseModel.fromJson(response);
  }

  Future<ApiMessageResponseModel> deactivateAccount() async {
    final response = await _apiClient.deleteRequest(
      ApiEndpoints.users.account.deactivate,
    );

    return ApiMessageResponseModel.fromJson(response);
  }
}
