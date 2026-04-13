// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:ai_meal_planner/core/auth/models/auth_user.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';

class AuthSessionStorageService {
  AuthSessionStorageService({FlutterSecureStorage? secureStorage})
    : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  static const _tokenKey = 'auth_token';
  static const _userKey = 'auth_user';

  final FlutterSecureStorage _secureStorage;

  static AuthSessionStorageService ensureRegistered() {
    if (Get.isRegistered<AuthSessionStorageService>()) {
      return Get.find<AuthSessionStorageService>();
    }

    return Get.put(AuthSessionStorageService(), permanent: true);
  }

  Future<void> saveSession({
    required String token,
    required AuthUser user,
  }) async {
    print('******** AUTH SESSION SAVE START ********');
    print('token length: ${token.length}');
    print('user email: ${user.email}');
    await _secureStorage.write(key: _tokenKey, value: token);
    await _secureStorage.write(key: _userKey, value: jsonEncode(user.toJson()));
    print('******** AUTH SESSION SAVE END ********');
  }

  Future<String?> readToken() async {
    final token = await _secureStorage.read(key: _tokenKey);
    print('******** AUTH TOKEN READ ********');
    print('token exists: ${token != null && token.isNotEmpty}');
    return token;
  }

  Future<AuthUser?> readUser() async {
    final rawUser = await _secureStorage.read(key: _userKey);
    print('******** AUTH USER READ ********');
    print('user exists: ${rawUser != null && rawUser.isNotEmpty}');

    if (rawUser == null || rawUser.isEmpty) {
      return null;
    }

    final decoded = jsonDecode(rawUser) as Map<String, dynamic>;
    return AuthUser.fromJson(decoded);
  }

  Future<void> clearSession() async {
    print('******** AUTH SESSION CLEAR START ********');
    await _secureStorage.delete(key: _tokenKey);
    await _secureStorage.delete(key: _userKey);
    print('******** AUTH SESSION CLEAR END ********');
  }
}
