// ignore_for_file: avoid_print

import 'package:ai_meal_planner/core/network/api_exception.dart';
import 'package:ai_meal_planner/features/Auth/signup/models/signup_action_result.dart';
import 'package:ai_meal_planner/features/Auth/signup/models/signup_request_model.dart';
import 'package:ai_meal_planner/features/Auth/signup/services/signup_service.dart';
import 'package:get/get.dart';

class SignupController extends GetxController {
  SignupController({SignupService? signupService})
    : _signupService = signupService ?? SignupService.ensureRegistered();

  final SignupService _signupService;

  final RxBool isSubmitting = false.obs;
  final RxnString successMessage = RxnString();
  final RxnString errorMessage = RxnString();

  static SignupController ensureRegistered() {
    if (Get.isRegistered<SignupController>()) {
      return Get.find<SignupController>();
    }

    return Get.put(SignupController(), permanent: true);
  }

  Future<SignupActionResult> registerUser({
    required String name,
    required String email,
    required String password,
  }) async {
    print('******** SIGNUP FLOW START ********');
    print('name: ${name.trim()}');
    print('email: ${email.trim()}');

    if (isSubmitting.value) {
      print('signup skipped: request already in progress');
      print('******** SIGNUP FLOW END ********');
      return const SignupActionResult(
        isSuccess: false,
        message: 'Signup is already in progress.',
      );
    }

    isSubmitting.value = true;
    successMessage.value = null;
    errorMessage.value = null;

    try {
      final response = await _signupService.registerUser(
        SignupRequestModel(name: name, email: email, password: password),
      );

      final resolvedMessage = response.message.trim().isEmpty
          ? 'User registered successfully'
          : response.message.trim();

      successMessage.value = resolvedMessage;
      print('signup success message: $resolvedMessage');
      print('signup userId: ${response.data?.userId ?? 'N/A'}');
      print('******** SIGNUP FLOW END ********');

      return SignupActionResult(
        isSuccess: true,
        message: resolvedMessage,
        userId: response.data?.userId,
      );
    } on ApiException catch (error) {
      errorMessage.value = error.message;
      print('signup api exception: ${error.message}');
      print('******** SIGNUP FLOW END ********');

      return SignupActionResult(isSuccess: false, message: error.message);
    } catch (_) {
      const fallbackMessage = 'Something went wrong. Please try again.';
      errorMessage.value = fallbackMessage;
      print('signup unexpected exception: $fallbackMessage');
      print('******** SIGNUP FLOW END ********');

      return const SignupActionResult(
        isSuccess: false,
        message: fallbackMessage,
      );
    } finally {
      isSubmitting.value = false;
    }
  }
}
