// ignore_for_file: avoid_print

import 'package:ai_meal_planner/core/auth/models/auth_user.dart';
import 'package:ai_meal_planner/core/auth/services/auth_session_storage_service.dart';
import 'package:get/get.dart';

class AuthSessionController extends GetxController {
  AuthSessionController({AuthSessionStorageService? storageService})
    : _storageService =
          storageService ?? AuthSessionStorageService.ensureRegistered();

  final AuthSessionStorageService _storageService;

  final RxnString token = RxnString();
  final Rxn<AuthUser> currentUser = Rxn<AuthUser>();
  final RxBool isLoaded = false.obs;

  bool get isLoggedIn => (token.value ?? '').trim().isNotEmpty;

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
    print('currentUserEmail: ${currentUser.value?.email ?? 'N/A'}');
    print('******** AUTH SESSION INIT END ********');
  }

  Future<void> saveSession({
    required String token,
    required AuthUser user,
  }) async {
    await _storageService.saveSession(token: token, user: user);
    this.token.value = token;
    currentUser.value = user;
    isLoaded.value = true;
  }

  Future<void> clearSession() async {
    await _storageService.clearSession();
    token.value = null;
    currentUser.value = null;
    isLoaded.value = true;
  }
}
