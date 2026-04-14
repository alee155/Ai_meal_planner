// ignore_for_file: avoid_print

import 'package:ai_meal_planner/core/network/api_exception.dart';
import 'package:ai_meal_planner/features/Auth/otp/models/otp_action_result.dart';
import 'package:ai_meal_planner/features/Auth/otp/models/resend_otp_request_model.dart';
import 'package:ai_meal_planner/features/Auth/otp/models/verify_otp_request_model.dart';
import 'package:ai_meal_planner/features/Auth/otp/services/otp_service.dart';
import 'package:get/get.dart';

class OtpController extends GetxController {
  OtpController({OtpService? otpService})
    : _otpService = otpService ?? OtpService.ensureRegistered();

  final OtpService _otpService;

  final RxBool isVerifying = false.obs;
  final RxBool isResending = false.obs;
  final RxnString successMessage = RxnString();
  final RxnString errorMessage = RxnString();

  static OtpController ensureRegistered() {
    if (Get.isRegistered<OtpController>()) {
      return Get.find<OtpController>();
    }

    return Get.put(OtpController(), permanent: true);
  }

  Future<OtpActionResult> verifyOtp({
    required String email,
    required String otp,
  }) async {
    print('******** VERIFY OTP FLOW START ********');
    print('email: ${email.trim()}');

    if (isVerifying.value) {
      print('verify otp skipped: request already in progress');
      print('******** VERIFY OTP FLOW END ********');
      return const OtpActionResult(
        isSuccess: false,
        message: 'OTP verification is already in progress.',
      );
    }

    isVerifying.value = true;
    successMessage.value = null;
    errorMessage.value = null;

    try {
      final response = await _otpService.verifyOtp(
        VerifyOtpRequestModel(email: email, otp: otp),
      );

      final resolvedMessage = response.message.trim().isEmpty
          ? 'Account verified successfully.'
          : response.message.trim();

      successMessage.value = resolvedMessage;
      print('verify otp success message: $resolvedMessage');
      print('******** VERIFY OTP FLOW END ********');

      return OtpActionResult(isSuccess: true, message: resolvedMessage);
    } on ApiException catch (error) {
      errorMessage.value = error.message;
      print('verify otp api exception: ${error.message}');
      print('******** VERIFY OTP FLOW END ********');
      return OtpActionResult(isSuccess: false, message: error.message);
    } catch (_) {
      const fallbackMessage = 'Something went wrong. Please try again.';
      errorMessage.value = fallbackMessage;
      print('verify otp unexpected exception: $fallbackMessage');
      print('******** VERIFY OTP FLOW END ********');
      return const OtpActionResult(isSuccess: false, message: fallbackMessage);
    } finally {
      isVerifying.value = false;
    }
  }

  Future<OtpActionResult> resendOtp({required String email}) async {
    print('******** RESEND OTP FLOW START ********');
    print('email: ${email.trim()}');

    if (isResending.value) {
      print('resend otp skipped: request already in progress');
      print('******** RESEND OTP FLOW END ********');
      return const OtpActionResult(
        isSuccess: false,
        message: 'OTP resend is already in progress.',
      );
    }

    isResending.value = true;
    successMessage.value = null;
    errorMessage.value = null;

    try {
      final response = await _otpService.resendOtp(
        ResendOtpRequestModel(email: email),
      );

      final resolvedMessage = response.message.trim().isEmpty
          ? 'Verification code sent successfully.'
          : response.message.trim();

      successMessage.value = resolvedMessage;
      print('resend otp success message: $resolvedMessage');
      print('******** RESEND OTP FLOW END ********');

      return OtpActionResult(isSuccess: true, message: resolvedMessage);
    } on ApiException catch (error) {
      errorMessage.value = error.message;
      print('resend otp api exception: ${error.message}');
      print('******** RESEND OTP FLOW END ********');
      return OtpActionResult(isSuccess: false, message: error.message);
    } catch (_) {
      const fallbackMessage = 'Something went wrong. Please try again.';
      errorMessage.value = fallbackMessage;
      print('resend otp unexpected exception: $fallbackMessage');
      print('******** RESEND OTP FLOW END ********');
      return const OtpActionResult(isSuccess: false, message: fallbackMessage);
    } finally {
      isResending.value = false;
    }
  }
}
