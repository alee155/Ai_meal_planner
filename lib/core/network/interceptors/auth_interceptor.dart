// ignore_for_file: avoid_print

import 'package:ai_meal_planner/core/auth/controller/auth_session_controller.dart';
import 'package:ai_meal_planner/core/auth/services/auth_session_storage_service.dart';
import 'package:ai_meal_planner/core/network/api_endpoints.dart';
import 'package:ai_meal_planner/routes/app_routes.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';

class AuthInterceptor extends Interceptor {
  AuthInterceptor({AuthSessionStorageService? storageService})
    : _storageService =
          storageService ?? AuthSessionStorageService.ensureRegistered();

  final AuthSessionStorageService _storageService;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (_isPublicEndpoint(options.path)) {
      handler.next(options);
      return;
    }

    final token = await _storageService.readToken();
    if (token != null && token.trim().isNotEmpty) {
      options.headers['Authorization'] = 'Bearer ${token.trim()}';
    }

    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final statusCode = err.response?.statusCode ?? 0;
    final requestPath = err.requestOptions.path;

    final storedToken = await _storageService.readToken();
    final hadSession = storedToken != null && storedToken.trim().isNotEmpty;

    if (statusCode == 401 && hadSession && !_isPublicEndpoint(requestPath)) {
      print('******** AUTH INTERCEPTOR UNAUTHORIZED ********');
      print('path: $requestPath');

      if (Get.isRegistered<AuthSessionController>()) {
        await Get.find<AuthSessionController>().clearSession();
      } else {
        await _storageService.clearSession();
      }

      final currentRoute = Get.currentRoute;
      final isOnAuthRoute =
          currentRoute == AppRoutes.login ||
          currentRoute == AppRoutes.signup ||
          currentRoute == AppRoutes.otp;

      if (!isOnAuthRoute) {
        Get.offAllNamed(AppRoutes.login);
      }
    }

    handler.next(err);
  }

  bool _isPublicEndpoint(String path) {
    return path == ApiEndpoints.auth.register ||
        path == ApiEndpoints.auth.verifyOtp ||
        path == ApiEndpoints.auth.resendOtp ||
        path == ApiEndpoints.auth.login ||
        path == ApiEndpoints.auth.password.resetRequest ||
        path == ApiEndpoints.auth.password.resetConfirm;
  }
}
