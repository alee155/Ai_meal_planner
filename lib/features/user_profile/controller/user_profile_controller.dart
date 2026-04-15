import 'dart:convert';

import 'package:ai_meal_planner/core/auth/controller/auth_session_controller.dart';
import 'package:ai_meal_planner/core/network/api_exception.dart';
import 'package:ai_meal_planner/features/user_profile/models/user_stats_response_model.dart';
import 'package:ai_meal_planner/features/user_profile/services/user_stats_service.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProfileData {
  const UserProfileData({
    this.fullName = '',
    this.email = '',
    this.weight = '',
    this.height = '',
    this.heightFeet = '',
    this.heightInches = '',
    this.age = '',
    this.genderKey = 'male',
    this.weightUnit = 'kg',
    this.heightUnit = 'cm',
    this.activityKey = 'moderate',
    this.goalKey = 'maintain',
    this.dietPreferenceKey = 'balanced',
    this.allergies = const [],
    this.dislikedFoods = '',
    this.onboardingComplete = false,
  });

  static const double _poundsPerKilogram = 2.20462;

  final String fullName;
  final String email;
  final String weight;
  final String height;
  final String heightFeet;
  final String heightInches;
  final String age;
  final String genderKey;
  final String weightUnit;
  final String heightUnit;
  final String? activityKey;
  final String goalKey;
  final String dietPreferenceKey;
  final List<String> allergies;
  final String dislikedFoods;
  final bool onboardingComplete;

  UserProfileData copyWith({
    String? fullName,
    String? email,
    String? weight,
    String? height,
    String? heightFeet,
    String? heightInches,
    String? age,
    String? genderKey,
    String? weightUnit,
    String? heightUnit,
    String? activityKey,
    bool clearActivityKey = false,
    String? goalKey,
    String? dietPreferenceKey,
    List<String>? allergies,
    String? dislikedFoods,
    bool? onboardingComplete,
  }) {
    return UserProfileData(
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      weight: weight ?? this.weight,
      height: height ?? this.height,
      heightFeet: heightFeet ?? this.heightFeet,
      heightInches: heightInches ?? this.heightInches,
      age: age ?? this.age,
      genderKey: genderKey ?? this.genderKey,
      weightUnit: weightUnit ?? this.weightUnit,
      heightUnit: heightUnit ?? this.heightUnit,
      activityKey: clearActivityKey ? null : activityKey ?? this.activityKey,
      goalKey: goalKey ?? this.goalKey,
      dietPreferenceKey: dietPreferenceKey ?? this.dietPreferenceKey,
      allergies: allergies ?? this.allergies,
      dislikedFoods: dislikedFoods ?? this.dislikedFoods,
      onboardingComplete: onboardingComplete ?? this.onboardingComplete,
    );
  }

  bool hasSameEditableValues(UserProfileData other) {
    return weight.trim() == other.weight.trim() &&
        height.trim() == other.height.trim() &&
        heightFeet.trim() == other.heightFeet.trim() &&
        heightInches.trim() == other.heightInches.trim() &&
        age.trim() == other.age.trim() &&
        genderKey.trim() == other.genderKey.trim() &&
        weightUnit.trim() == other.weightUnit.trim() &&
        heightUnit.trim() == other.heightUnit.trim() &&
        (activityKey?.trim() ?? '') == (other.activityKey?.trim() ?? '') &&
        goalKey.trim() == other.goalKey.trim() &&
        dietPreferenceKey.trim() == other.dietPreferenceKey.trim() &&
        _normalizedAllergies(allergies).join('|') ==
            _normalizedAllergies(other.allergies).join('|') &&
        _normalizedDislikedFoods(dislikedFoods) ==
            _normalizedDislikedFoods(other.dislikedFoods);
  }

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'email': email,
      'weight': weight,
      'height': height,
      'heightFeet': heightFeet,
      'heightInches': heightInches,
      'age': age,
      'genderKey': genderKey,
      'weightUnit': weightUnit,
      'heightUnit': heightUnit,
      'activityKey': activityKey,
      'goalKey': goalKey,
      'dietPreferenceKey': dietPreferenceKey,
      'allergies': allergies,
      'dislikedFoods': dislikedFoods,
      'onboardingComplete': onboardingComplete,
    };
  }

  factory UserProfileData.fromJson(Map<String, dynamic> json) {
    return UserProfileData(
      fullName: json['fullName'] as String? ?? '',
      email: json['email'] as String? ?? '',
      weight: json['weight'] as String? ?? '',
      height: json['height'] as String? ?? '',
      heightFeet: json['heightFeet'] as String? ?? '',
      heightInches: json['heightInches'] as String? ?? '',
      age: json['age'] as String? ?? '',
      genderKey: json['genderKey'] as String? ?? 'male',
      weightUnit: json['weightUnit'] as String? ?? 'kg',
      heightUnit: json['heightUnit'] as String? ?? 'cm',
      activityKey: json['activityKey'] as String? ?? 'moderate',
      goalKey: json['goalKey'] as String? ?? 'maintain',
      dietPreferenceKey: json['dietPreferenceKey'] as String? ?? 'balanced',
      allergies: (json['allergies'] as List<dynamic>? ?? const [])
          .map((item) => item.toString())
          .where((item) => item.isNotEmpty)
          .toList(),
      dislikedFoods: json['dislikedFoods'] as String? ?? '',
      onboardingComplete: json['onboardingComplete'] as bool? ?? false,
    );
  }

  factory UserProfileData.fromStats(
    UserStatsModel stats, {
    required String fullName,
    required String email,
    required String weightUnit,
    required String heightUnit,
    String fallbackAge = '',
    String fallbackGenderKey = 'male',
    String? fallbackActivityKey = 'moderate',
    String fallbackGoalKey = 'maintain',
    String fallbackDietPreferenceKey = 'balanced',
  }) {
    final normalizedWeightUnit = weightUnit == 'lb' ? 'lb' : 'kg';
    final normalizedHeightUnit = heightUnit == 'ft/in' ? 'ft/in' : 'cm';
    final weightValue = normalizedWeightUnit == 'lb'
        ? stats.weightKg * _poundsPerKilogram
        : stats.weightKg;

    var height = '';
    var heightFeet = '';
    var heightInches = '';

    if (normalizedHeightUnit == 'cm') {
      height = _formatValue(stats.heightCm);
    } else {
      final totalInches = stats.heightCm / 2.54;
      var feet = totalInches ~/ 12;
      var inches = (totalInches - (feet * 12)).round();

      if (inches == 12) {
        feet += 1;
        inches = 0;
      }

      heightFeet = feet.toString();
      heightInches = inches.toString();
    }

    return UserProfileData(
      fullName: fullName,
      email: email,
      weight: _formatValue(weightValue, allowDecimal: true),
      height: height,
      heightFeet: heightFeet,
      heightInches: heightInches,
      age: stats.age > 0 ? stats.age.toString() : fallbackAge,
      genderKey: stats.gender.trim().isNotEmpty
          ? UserProfileController.normalizeGenderKey(stats.gender)
          : fallbackGenderKey,
      weightUnit: normalizedWeightUnit,
      heightUnit: normalizedHeightUnit,
      activityKey: stats.activityLevel.trim().isNotEmpty
          ? UserProfileController.normalizeActivityKey(stats.activityLevel)
          : fallbackActivityKey,
      goalKey: stats.goal.trim().isNotEmpty
          ? UserProfileController.normalizeGoalKey(stats.goal)
          : fallbackGoalKey,
      dietPreferenceKey: stats.mealPreferences.isEmpty
          ? fallbackDietPreferenceKey
          : UserProfileController.normalizeDietPreferenceKey(
              stats.mealPreferences.first,
            ),
      allergies:
          stats.mealAllergies
              .map(UserProfileController.normalizeAllergyKey)
              .toSet()
              .where((item) => item.isNotEmpty)
              .toList()
            ..sort(),
      dislikedFoods: stats.mealDislikes.join(', '),
      onboardingComplete: true,
    );
  }

  static String _formatValue(double value, {bool allowDecimal = false}) {
    if (!allowDecimal || value == value.roundToDouble()) {
      return value.round().toString();
    }

    return value.toStringAsFixed(1);
  }

  static List<String> _normalizedAllergies(List<String> value) {
    final normalized = value
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toSet()
        .toList();
    normalized.sort();
    return normalized;
  }

  static String _normalizedDislikedFoods(String value) {
    return value
        .split(RegExp(r'[\n,]+'))
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .join(',');
  }
}

class UserProfileController extends GetxController {
  UserProfileController({
    UserStatsService? userStatsService,
    AuthSessionController? authSessionController,
  }) : _userStatsService =
           userStatsService ?? UserStatsService.ensureRegistered(),
       _authSessionController =
           authSessionController ?? AuthSessionController.ensureRegistered();

  static const _storageKey = 'user_profile_data';
  static const _legacyStorageKey = 'user_profile_data';
  static const _profileCacheBoxName = 'profile_cache';
  static const double _kilogramsPerPound = 0.45359237;
  static const double _poundsPerKilogram = 2.20462;

  final UserStatsService _userStatsService;
  final AuthSessionController _authSessionController;

  final Rx<UserProfileData> profile = const UserProfileData().obs;
  final RxBool isLoaded = false.obs;
  final RxBool hasRemoteStats = false.obs;

  Box<String>? _profileCacheBox;
  String? _loadedCacheKey;

  static UserProfileController ensureRegistered() {
    if (Get.isRegistered<UserProfileController>()) {
      return Get.find<UserProfileController>();
    }

    return Get.put(UserProfileController(), permanent: true);
  }

  bool get hasCompletedProfile =>
      hasRemoteStats.value || profile.value.onboardingComplete;

  Future<void> init({bool refreshRemote = true}) async {
    await _ensureProfileBox();
    await _loadCachedProfile();
    _seedFromCurrentSession();
    isLoaded.value = true;

    if (refreshRemote && _authSessionController.isLoggedIn) {
      await refreshProfile(suppressErrors: true);
      return;
    }

    await _persistProfile();
  }

  void seedAccountDetails({required String fullName, required String email}) {
    final trimmedEmail = email.trim();
    final currentEmail = profile.value.email.trim();
    final hasDifferentUser =
        trimmedEmail.isNotEmpty &&
        currentEmail.isNotEmpty &&
        currentEmail.toLowerCase() != trimmedEmail.toLowerCase();

    final baseProfile = hasDifferentUser
        ? UserProfileData(
            fullName: profile.value.fullName,
            email: profile.value.email,
            weightUnit: profile.value.weightUnit,
            heightUnit: profile.value.heightUnit,
          )
        : profile.value;

    profile.value = baseProfile.copyWith(
      fullName: fullName.trim().isEmpty
          ? baseProfile.fullName
          : fullName.trim(),
      email: trimmedEmail.isEmpty ? baseProfile.email : trimmedEmail,
    );
  }

  Future<bool> refreshProfile({bool suppressErrors = true}) async {
    await _ensureProfileBox();
    await _loadCachedProfile();
    _seedFromCurrentSession();

    if (!_authSessionController.isLoggedIn) {
      _markStatsMissing(clearFields: false);
      await _persistProfile();
      isLoaded.value = true;
      return false;
    }

    try {
      final response = await _userStatsService.fetchUserStats();
      final stats = response.stats;

      if (stats == null || !stats.hasCompletedSetup) {
        _markStatsMissing();
        isLoaded.value = true;
        await _persistProfile();
        return false;
      }

      profile.value = UserProfileData.fromStats(
        stats,
        fullName: profile.value.fullName,
        email: profile.value.email,
        weightUnit: profile.value.weightUnit,
        heightUnit: profile.value.heightUnit,
        fallbackAge: profile.value.age,
        fallbackGenderKey: profile.value.genderKey,
        fallbackActivityKey: profile.value.activityKey,
        fallbackGoalKey: profile.value.goalKey,
        fallbackDietPreferenceKey: profile.value.dietPreferenceKey,
      );
      hasRemoteStats.value = true;
      isLoaded.value = true;
      await _persistProfile();
      return true;
    } on ApiException catch (error) {
      if (_isMissingStatsError(error)) {
        _markStatsMissing();
        await _persistProfile();
        isLoaded.value = true;
        return false;
      }

      if (!suppressErrors) {
        rethrow;
      }

      isLoaded.value = true;
      return hasRemoteStats.value;
    } catch (_) {
      if (!suppressErrors) {
        rethrow;
      }

      isLoaded.value = true;
      return hasRemoteStats.value;
    }
  }

  Future<UserProfileData> saveDraft(UserProfileData data) async {
    await _ensureProfileBox();
    profile.value = _mergeIdentity(
      data.copyWith(onboardingComplete: hasRemoteStats.value),
    );
    await _persistProfile();
    isLoaded.value = true;
    return profile.value;
  }

  Future<UserProfileData> createProfile(UserProfileData data) async {
    await _ensureProfileBox();
    final sanitized = _mergeIdentity(data).copyWith(onboardingComplete: true);
    final response = await _userStatsService.createUserStats(
      _buildRequestBody(sanitized),
    );

    return _commitStatsResponse(response, fallback: sanitized);
  }

  Future<UserProfileData> updateProfile(UserProfileData data) async {
    await _ensureProfileBox();
    final sanitized = _mergeIdentity(data).copyWith(onboardingComplete: true);
    final response = await _userStatsService.updateUserStats(
      _buildRequestBody(sanitized),
    );

    return _commitStatsResponse(response, fallback: sanitized);
  }

  Map<String, dynamic> _buildRequestBody(UserProfileData data) {
    return {
      'age': int.tryParse(data.age.trim()) ?? 0,
      'gender': normalizeGenderKey(data.genderKey),
      'activityLevel': normalizeActivityKey(data.activityKey),
      'goal': normalizeGoalKey(data.goalKey),
      'heightCm': _heightInCentimeters(data),
      'weightKg': _weightInKilograms(data),
      'mealPreferences': <String>[
        normalizeDietPreferenceKey(data.dietPreferenceKey),
      ],
      'mealAllergies': data.allergies
          .map(normalizeAllergyKey)
          .where((item) => item.isNotEmpty)
          .toList(growable: false),
      'mealDislikes': _splitListInput(data.dislikedFoods),
    };
  }

  Future<UserProfileData> _commitStatsResponse(
    UserStatsResponseModel response, {
    required UserProfileData fallback,
  }) async {
    final stats = response.stats;

    if (stats != null && stats.hasCompletedSetup) {
      profile.value = UserProfileData.fromStats(
        stats,
        fullName: fallback.fullName,
        email: fallback.email,
        weightUnit: fallback.weightUnit,
        heightUnit: fallback.heightUnit,
        fallbackAge: fallback.age,
        fallbackGenderKey: fallback.genderKey,
        fallbackActivityKey: fallback.activityKey,
        fallbackGoalKey: fallback.goalKey,
        fallbackDietPreferenceKey: fallback.dietPreferenceKey,
      );
      hasRemoteStats.value = true;
    } else {
      profile.value = fallback;
      hasRemoteStats.value = fallback.onboardingComplete;
    }

    isLoaded.value = true;
    await _persistProfile();
    return profile.value;
  }

  Future<void> _ensureProfileBox() async {
    if (_profileCacheBox?.isOpen == true) {
      return;
    }

    _profileCacheBox = await Hive.openBox<String>(_profileCacheBoxName);
  }

  Future<void> _loadCachedProfile() async {
    final cacheKey = _resolveProfileCacheKey();
    if (_loadedCacheKey == cacheKey) {
      return;
    }

    var raw = _profileCacheBox!.get(cacheKey);
    raw ??= await _migrateLegacyProfileIfNeeded(cacheKey);

    if (raw == null || raw.isEmpty) {
      final currentProfile = profile.value;
      final currentUser = _authSessionController.currentUser.value;
      profile.value = UserProfileData(
        fullName: currentUser?.name ?? currentProfile.fullName,
        email: currentUser?.email ?? currentProfile.email,
        weightUnit: currentProfile.weightUnit,
        heightUnit: currentProfile.heightUnit,
      );
      hasRemoteStats.value = false;
      _loadedCacheKey = cacheKey;
      return;
    }

    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    profile.value = UserProfileData.fromJson(decoded);
    hasRemoteStats.value = profile.value.onboardingComplete;
    _loadedCacheKey = cacheKey;
  }

  Future<void> _persistProfile() async {
    await _profileCacheBox!.put(
      _resolveProfileCacheKey(),
      jsonEncode(profile.value.toJson()),
    );
  }

  Future<String?> _migrateLegacyProfileIfNeeded(String cacheKey) async {
    final preferences = await SharedPreferences.getInstance();
    final raw = preferences.getString(_legacyStorageKey);
    if (raw == null || raw.isEmpty) {
      return null;
    }

    await _profileCacheBox!.put(cacheKey, raw);
    await preferences.remove(_legacyStorageKey);
    return raw;
  }

  String _resolveProfileCacheKey() {
    final user = _authSessionController.currentUser.value;
    final userIdentifier = user?.id.trim().isNotEmpty == true
        ? user!.id.trim()
        : user?.email.trim().toLowerCase();

    if (userIdentifier == null || userIdentifier.isEmpty) {
      return '$_storageKey::guest';
    }

    return '$_storageKey::$userIdentifier';
  }

  void _seedFromCurrentSession() {
    final user = _authSessionController.currentUser.value;
    if (user == null) {
      return;
    }

    seedAccountDetails(fullName: user.name, email: user.email);
  }

  void _markStatsMissing({bool clearFields = false}) {
    hasRemoteStats.value = false;

    if (!clearFields) {
      profile.value = profile.value.copyWith(onboardingComplete: false);
      return;
    }

    profile.value = UserProfileData(
      fullName: profile.value.fullName,
      email: profile.value.email,
      weightUnit: profile.value.weightUnit,
      heightUnit: profile.value.heightUnit,
      onboardingComplete: false,
    );
  }

  UserProfileData _mergeIdentity(UserProfileData data) {
    final user = _authSessionController.currentUser.value;
    return data.copyWith(
      fullName: data.fullName.trim().isNotEmpty
          ? data.fullName.trim()
          : user?.name ?? profile.value.fullName,
      email: data.email.trim().isNotEmpty
          ? data.email.trim()
          : user?.email ?? profile.value.email,
    );
  }

  bool _isMissingStatsError(ApiException error) {
    if (error.statusCode == 404) {
      return true;
    }

    final message = error.message.trim().toLowerCase();
    return message.contains('not found') || message.contains('no stats');
  }

  double _weightInKilograms(UserProfileData data) {
    final value = double.tryParse(data.weight.trim()) ?? 0;
    if (value <= 0) {
      return 0;
    }

    final weightKg = data.weightUnit == 'lb'
        ? value * _kilogramsPerPound
        : value;
    return _roundToSingleDecimal(weightKg);
  }

  double _heightInCentimeters(UserProfileData data) {
    if (data.heightUnit == 'ft/in') {
      final feet = int.tryParse(data.heightFeet.trim()) ?? 0;
      final inches = int.tryParse(data.heightInches.trim()) ?? 0;
      final heightCm = (feet * 30.48) + (inches * 2.54);
      return _roundToSingleDecimal(heightCm);
    }

    final heightCm = double.tryParse(data.height.trim()) ?? 0;
    return _roundToSingleDecimal(heightCm);
  }

  double _roundToSingleDecimal(double value) {
    return double.parse(value.toStringAsFixed(1));
  }

  List<String> _splitListInput(String raw) {
    return raw
        .split(RegExp(r'[\n,]+'))
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList(growable: false);
  }

  static String normalizeGenderKey(String? raw) {
    final value = raw?.trim().toLowerCase() ?? '';
    switch (value) {
      case 'female':
        return 'female';
      case 'other':
      case 'non-binary':
      case 'nonbinary':
        return 'other';
      default:
        return 'male';
    }
  }

  static String normalizeActivityKey(String? raw) {
    final value = raw?.trim().toLowerCase() ?? '';
    if (value.contains('light')) {
      return 'light';
    }
    if (value.contains('moderate')) {
      return 'moderate';
    }
    if (value.contains('very') ||
        value.contains('high') ||
        value.contains('active')) {
      return 'active';
    }

    return 'moderate';
  }

  static String normalizeGoalKey(String? raw) {
    final value = raw?.trim().toLowerCase() ?? '';
    if (value.contains('lose') || value.contains('loss')) {
      return 'loss';
    }
    if (value.contains('gain') || value.contains('muscle')) {
      return 'gain';
    }

    return 'maintain';
  }

  static String normalizeDietPreferenceKey(String? raw) {
    final value = raw?.trim().toLowerCase() ?? '';
    if (value.contains('vegetarian')) {
      return 'vegetarian';
    }
    if (value.contains('vegan')) {
      return 'vegan';
    }
    if (value.contains('halal')) {
      return 'halal';
    }
    if (value.contains('keto')) {
      return 'keto';
    }
    if (value.contains('high') || value.contains('protein')) {
      return 'high-protein';
    }

    return 'balanced';
  }

  static String normalizeAllergyKey(String raw) {
    final value = raw.trim().toLowerCase();
    if (value.startsWith('peanut')) {
      return 'peanut';
    }
    if (value.contains('tree') && value.contains('nut')) {
      return 'tree-nut';
    }
    if (value.startsWith('egg')) {
      return 'egg';
    }
    if (value.contains('shell')) {
      return 'shellfish';
    }

    if (value == 'dairy' ||
        value == 'fish' ||
        value == 'soy' ||
        value == 'wheat' ||
        value == 'sesame') {
      return value;
    }

    return value;
  }

  static String formatWeightForDisplay(double weightKg, String unit) {
    final value = unit == 'lb' ? weightKg * _poundsPerKilogram : weightKg;
    return value == value.roundToDouble()
        ? value.round().toString()
        : value.toStringAsFixed(1);
  }
}
