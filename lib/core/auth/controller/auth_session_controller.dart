// ignore_for_file: avoid_print

import 'package:ai_meal_planner/core/auth/models/auth_user.dart';
import 'package:ai_meal_planner/core/auth/services/auth_profile_service.dart';
import 'package:ai_meal_planner/core/auth/services/auth_session_storage_service.dart';
import 'package:ai_meal_planner/core/network/api_exception.dart';
import 'package:ai_meal_planner/features/user_profile/controller/user_profile_controller.dart';
import 'package:get/get.dart';

class AuthSessionController extends GetxController {
  AuthSessionController({
    AuthSessionStorageService? storageService,
    AuthProfileService? authProfileService,
  }) : _storageService =
           storageService ?? AuthSessionStorageService.ensureRegistered(),
       _authProfileService =
           authProfileService ?? AuthProfileService.ensureRegistered();

  final AuthSessionStorageService _storageService;
  final AuthProfileService _authProfileService;

  final RxnString token = RxnString();
  final Rxn<AuthUser> currentUser = Rxn<AuthUser>();
  final RxBool isLoaded = false.obs;

  bool get isLoggedIn => (token.value ?? '').trim().isNotEmpty;
  bool get isGuest => !isLoggedIn;

  static AuthSessionController ensureRegistered() {
    if (Get.isRegistered<AuthSessionController>()) {
      return Get.find<AuthSessionController>();
    }

    return Get.put(AuthSessionController(), permanent: true);
  }

  Future<void> init() async {
    if (isLoaded.value) {
      return;
    }

    print('******** AUTH SESSION INIT START ********');
    token.value = await _storageService.readToken();
    currentUser.value = await _storageService.readUser();
    isLoaded.value = true;
    print('isLoggedIn: $isLoggedIn');
    print('storedToken: ${token.value ?? 'N/A'}');
    print('currentUserEmail: ${currentUser.value?.email ?? 'N/A'}');
    print('******** AUTH SESSION INIT END ********');
  }

  Future<void> saveToken(String token) async {
    await _storageService.saveToken(token);
    this.token.value = token;
    isLoaded.value = true;
  }

  Future<void> saveUser(AuthUser user) async {
    await _storageService.saveUser(user);
    currentUser.value = user;
    isLoaded.value = true;
    UserProfileController.ensureRegistered().seedAccountDetails(
      fullName: user.name,
      email: user.email,
    );
  }

  Future<void> saveSession({
    required String token,
    required AuthUser user,
  }) async {
    await saveToken(token);
    await saveUser(user);
  }

  Future<AuthUser?> fetchAndStoreCurrentUser() async {
    if (!isLoggedIn) {
      return null;
    }

    final response = await _authProfileService.fetchCurrentUserProfile();
    final user = response.user;
    if (user == null) {
      throw const ApiException(
        message: 'Profile response is missing user data.',
      );
    }

    await saveUser(user);
    return user;
  }

  Future<bool> bootstrapSession() async {
    await init();
    if (!isLoggedIn) {
      return false;
    }

    try {
      await fetchAndStoreCurrentUser();
      return true;
    } on ApiException catch (_) {
      await clearSession();
      return false;
    } catch (_) {
      await clearSession();
      return false;
    }
  }

  Future<void> clearSession() async {
    await _storageService.clearSession();
    token.value = null;
    currentUser.value = null;
    isLoaded.value = true;
  }
}
