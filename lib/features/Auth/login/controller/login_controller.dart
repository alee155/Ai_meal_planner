// ignore_for_file: avoid_print

import 'package:ai_meal_planner/core/auth/controller/auth_session_controller.dart';
import 'package:ai_meal_planner/core/network/api_exception.dart';
import 'package:ai_meal_planner/features/Auth/login/models/login_action_result.dart';
import 'package:ai_meal_planner/features/Auth/login/models/login_request_model.dart';
import 'package:ai_meal_planner/features/Auth/login/services/login_service.dart';
import 'package:ai_meal_planner/features/user_profile/controller/user_profile_controller.dart';
import 'package:ai_meal_planner/routes/app_routes.dart';
import 'package:get/get.dart';

class LoginController extends GetxController {
  LoginController({
    LoginService? loginService,
    AuthSessionController? authSessionController,
    UserProfileController? userProfileController,
  }) : _loginService = loginService ?? LoginService.ensureRegistered(),
       _authSessionController =
           authSessionController ?? AuthSessionController.ensureRegistered(),
       _userProfileController =
           userProfileController ?? UserProfileController.ensureRegistered();

  final LoginService _loginService;
  final AuthSessionController _authSessionController;
  final UserProfileController _userProfileController;

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
      await _userProfileController.init(refreshRemote: false);
      final hasCompletedProfile = await _userProfileController.refreshProfile(
        suppressErrors: true,
      );
      final nextRoute = hasCompletedProfile
          ? AppRoutes.bottomNav
          : AppRoutes.profileSetup;

      successMessage.value = resolvedMessage;
      print('login success message: $resolvedMessage');
      print('login token: $token');
      print('login token length: ${token.length}');
      print('login next route: $nextRoute');
      print('******** LOGIN FLOW END ********');

      return LoginActionResult(
        isSuccess: true,
        message: resolvedMessage,
        token: token,
        nextRoute: nextRoute,
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
