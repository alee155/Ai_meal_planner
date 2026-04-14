// ignore_for_file: avoid_print

import 'package:ai_meal_planner/core/auth/controller/auth_session_controller.dart';
import 'package:ai_meal_planner/core/network/api_exception.dart';
import 'package:ai_meal_planner/features/Auth/login/models/login_action_result.dart';
import 'package:ai_meal_planner/features/Auth/login/models/login_request_model.dart';
import 'package:ai_meal_planner/features/Auth/login/services/login_service.dart';
import 'package:get/get.dart';

class LoginController extends GetxController {
  LoginController({
    LoginService? loginService,
    AuthSessionController? authSessionController,
  }) : _loginService = loginService ?? LoginService.ensureRegistered(),
       _authSessionController =
           authSessionController ?? AuthSessionController.ensureRegistered();

  final LoginService _loginService;
  final AuthSessionController _authSessionController;

  final RxBool isSubmitting = false.obs;
  final RxnString successMessage = RxnString();
  final RxnString errorMessage = RxnString();

  static LoginController ensureRegistered() {
    if (Get.isRegistered<LoginController>()) {
      return Get.find<LoginController>();
    }

    return Get.put(LoginController(), permanent: true);
  }

  Future<LoginActionResult> loginUser({
    required String email,
    required String password,
  }) async {
    print('******** LOGIN FLOW START ********');
    print('email: ${email.trim()}');

    if (isSubmitting.value) {
      print('login skipped: request already in progress');
      print('******** LOGIN FLOW END ********');
      return const LoginActionResult(
        isSuccess: false,
        message: 'Login is already in progress.',
      );
    }

    isSubmitting.value = true;
    successMessage.value = null;
    errorMessage.value = null;

    try {
      final response = await _loginService.loginUser(
        LoginRequestModel(email: email, password: password),
      );

      final resolvedMessage = response.message.trim().isEmpty
          ? 'Login successful'
          : response.message.trim();
      final token = response.token.trim();

      if (token.isEmpty) {
        throw const ApiException(
          message: 'Login response is missing auth token.',
        );
      }

      await _authSessionController.saveToken(token);
      await _authSessionController.fetchAndStoreCurrentUser();

      successMessage.value = resolvedMessage;
      print('login success message: $resolvedMessage');
      print('login token length: ${token.length}');
      print('******** LOGIN FLOW END ********');

      return LoginActionResult(
        isSuccess: true,
        message: resolvedMessage,
        token: token,
      );
    } on ApiException catch (error) {
      if (_authSessionController.currentUser.value == null) {
        await _authSessionController.clearSession();
      }
      errorMessage.value = error.message;
      print('login api exception: ${error.message}');
      print('******** LOGIN FLOW END ********');

      return LoginActionResult(isSuccess: false, message: error.message);
    } catch (_) {
      if (_authSessionController.currentUser.value == null) {
        await _authSessionController.clearSession();
      }
      const fallbackMessage = 'Something went wrong. Please try again.';
      errorMessage.value = fallbackMessage;
      print('login unexpected exception: $fallbackMessage');
      print('******** LOGIN FLOW END ********');

      return const LoginActionResult(
        isSuccess: false,
        message: fallbackMessage,
      );
    } finally {
      isSubmitting.value = false;
    }
  }
}
