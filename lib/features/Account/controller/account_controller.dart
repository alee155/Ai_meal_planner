// ignore_for_file: avoid_print

import 'package:ai_meal_planner/core/auth/controller/auth_session_controller.dart';
import 'package:ai_meal_planner/core/network/api_exception.dart';
import 'package:ai_meal_planner/features/Account/models/account_action_result.dart';
import 'package:ai_meal_planner/features/Account/models/password_reset_confirm_request_model.dart';
import 'package:ai_meal_planner/features/Account/models/password_reset_request_model.dart';
import 'package:ai_meal_planner/features/Account/models/update_password_request_model.dart';
import 'package:ai_meal_planner/features/Account/models/update_profile_request_model.dart';
import 'package:ai_meal_planner/features/Account/services/account_service.dart';
import 'package:get/get.dart';

class AccountController extends GetxController {
  AccountController({
    AccountService? accountService,
    AuthSessionController? authSessionController,
  }) : _accountService = accountService ?? AccountService.ensureRegistered(),
       _authSessionController =
           authSessionController ?? AuthSessionController.ensureRegistered();

  final AccountService _accountService;
  final AuthSessionController _authSessionController;

  static AccountController ensureRegistered() {
    if (Get.isRegistered<AccountController>()) {
      return Get.find<AccountController>();
    }

    return Get.put(AccountController(), permanent: true);
  }

  Future<AccountActionResult> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final response = await _accountService.updatePassword(
        UpdatePasswordRequestModel(
          currentPassword: currentPassword,
          newPassword: newPassword,
        ),
      );

      return AccountActionResult(
        isSuccess: true,
        message: response.message.trim().isEmpty
            ? 'Password updated successfully.'
            : response.message.trim(),
      );
    } on ApiException catch (error) {
      return AccountActionResult(isSuccess: false, message: error.message);
    } catch (_) {
      return const AccountActionResult(
        isSuccess: false,
        message: 'Something went wrong. Please try again.',
      );
    }
  }

  Future<AccountActionResult> requestPasswordReset({
    required String email,
  }) async {
    try {
      final response = await _accountService.requestPasswordReset(
        PasswordResetRequestModel(email: email),
      );

      return AccountActionResult(
        isSuccess: true,
        message: response.message.trim().isEmpty
            ? 'Reset code sent successfully.'
            : response.message.trim(),
      );
    } on ApiException catch (error) {
      return AccountActionResult(isSuccess: false, message: error.message);
    } catch (_) {
      return const AccountActionResult(
        isSuccess: false,
        message: 'Something went wrong. Please try again.',
      );
    }
  }

  Future<AccountActionResult> confirmPasswordReset({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    try {
      final response = await _accountService.confirmPasswordReset(
        PasswordResetConfirmRequestModel(
          email: email,
          otp: otp,
          newPassword: newPassword,
        ),
      );

      return AccountActionResult(
        isSuccess: true,
        message: response.message.trim().isEmpty
            ? 'Password reset successfully.'
            : response.message.trim(),
      );
    } on ApiException catch (error) {
      return AccountActionResult(isSuccess: false, message: error.message);
    } catch (_) {
      return const AccountActionResult(
        isSuccess: false,
        message: 'Something went wrong. Please try again.',
      );
    }
  }

  Future<AccountActionResult> updateProfile({
    required String name,
    String? profileImagePath,
  }) async {
    try {
      final response = await _accountService.updateProfile(
        UpdateProfileRequestModel(
          name: name,
          profileImagePath: profileImagePath,
        ),
      );
      await _authSessionController.fetchAndStoreCurrentUser();

      return AccountActionResult(
        isSuccess: true,
        message: response.message.trim().isEmpty
            ? 'Profile updated successfully.'
            : response.message.trim(),
      );
    } on ApiException catch (error) {
      return AccountActionResult(isSuccess: false, message: error.message);
    } catch (_) {
      return const AccountActionResult(
        isSuccess: false,
        message: 'Something went wrong. Please try again.',
      );
    }
  }

  Future<AccountActionResult> deleteAccount() async {
    try {
      final response = await _accountService.deleteAccount();
      await _authSessionController.clearSession();

      return AccountActionResult(
        isSuccess: true,
        message: response.message.trim().isEmpty
            ? 'Account deleted successfully.'
            : response.message.trim(),
      );
    } on ApiException catch (error) {
      return AccountActionResult(isSuccess: false, message: error.message);
    } catch (_) {
      return const AccountActionResult(
        isSuccess: false,
        message: 'Something went wrong. Please try again.',
      );
    }
  }

  Future<AccountActionResult> deactivateAccount() async {
    try {
      final response = await _accountService.deactivateAccount();
      await _authSessionController.clearSession();

      return AccountActionResult(
        isSuccess: true,
        message: response.message.trim().isEmpty
            ? 'Account deactivated successfully.'
            : response.message.trim(),
      );
    } on ApiException catch (error) {
      return AccountActionResult(isSuccess: false, message: error.message);
    } catch (_) {
      return const AccountActionResult(
        isSuccess: false,
        message: 'Something went wrong. Please try again.',
      );
    }
  }
}
