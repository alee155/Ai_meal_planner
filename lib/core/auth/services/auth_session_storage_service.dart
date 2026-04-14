// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:ai_meal_planner/core/auth/models/auth_user.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

class AuthSessionStorageService {
  AuthSessionStorageService({FlutterSecureStorage? secureStorage})
    : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  static const _tokenKey = 'auth_token';
  static const _legacyUserKey = 'auth_user';
  static const _authCacheBoxName = 'auth_cache';
  static const _userCacheKey = 'auth_user';

  final FlutterSecureStorage _secureStorage;

  static AuthSessionStorageService ensureRegistered() {
    if (Get.isRegistered<AuthSessionStorageService>()) {
      return Get.find<AuthSessionStorageService>();
    }

    return Get.put(AuthSessionStorageService(), permanent: true);
  }

  Future<void> saveToken(String token) async {
    print('******** AUTH TOKEN SAVE START ********');
    print('token length: ${token.length}');
    await _secureStorage.write(key: _tokenKey, value: token);
    print('******** AUTH TOKEN SAVE END ********');
  }

  Future<void> saveUser(AuthUser user) async {
    print('******** AUTH USER SAVE START ********');
    print('user email: ${user.email}');
    await _authCacheBox.put(_userCacheKey, jsonEncode(user.toJson()));
    await _secureStorage.delete(key: _legacyUserKey);
    print('******** AUTH USER SAVE END ********');
  }

  Future<void> saveSession({
    required String token,
    required AuthUser user,
  }) async {
    print('******** AUTH SESSION SAVE START ********');
    print('token length: ${token.length}');
    print('user email: ${user.email}');
    await saveToken(token);
    await saveUser(user);
    print('******** AUTH SESSION SAVE END ********');
  }

  Future<String?> readToken() async {
    final token = await _secureStorage.read(key: _tokenKey);
    print('******** AUTH TOKEN READ ********');
    print('token exists: ${token != null && token.isNotEmpty}');
    return token;
  }

  Future<AuthUser?> readUser() async {
    final cachedUser = _authCacheBox.get(_userCacheKey);
    final rawUser = cachedUser ?? await _readLegacyUserAndMigrate();
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
    await _secureStorage.delete(key: _legacyUserKey);
    await _authCacheBox.delete(_userCacheKey);
    print('******** AUTH SESSION CLEAR END ********');
  }

  Box<String> get _authCacheBox => Hive.box<String>(_authCacheBoxName);

  Future<String?> _readLegacyUserAndMigrate() async {
    final legacyUser = await _secureStorage.read(key: _legacyUserKey);
    if (legacyUser == null || legacyUser.isEmpty) {
      return null;
    }

    await _authCacheBox.put(_userCacheKey, legacyUser);
    await _secureStorage.delete(key: _legacyUserKey);
    return legacyUser;
  }
}
