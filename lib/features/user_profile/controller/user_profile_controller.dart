import 'dart:convert';

import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProfileData {
  const UserProfileData({
    this.fullName = '',
    this.email = '',
    this.weight = '70',
    this.height = '170',
    this.heightFeet = '5',
    this.heightInches = '7',
    this.age = '28',
    this.genderKey = 'male',
    this.weightUnit = 'kg',
    this.heightUnit = 'cm',
    this.activityKey = 'moderatelyActive',
    this.goalKey = 'loseWeight',
    this.dietPreferenceKey = 'balancedDiet',
    this.allergies = const [],
    this.dislikedFoods = '',
    this.onboardingComplete = false,
  });

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
      weight: json['weight'] as String? ?? '70',
      height: json['height'] as String? ?? '170',
      heightFeet: json['heightFeet'] as String? ?? '5',
      heightInches: json['heightInches'] as String? ?? '7',
      age: json['age'] as String? ?? '28',
      genderKey: json['genderKey'] as String? ?? 'male',
      weightUnit: json['weightUnit'] as String? ?? 'kg',
      heightUnit: json['heightUnit'] as String? ?? 'cm',
      activityKey: json['activityKey'] as String?,
      goalKey: json['goalKey'] as String? ?? 'loseWeight',
      dietPreferenceKey: json['dietPreferenceKey'] as String? ?? 'balancedDiet',
      allergies: (json['allergies'] as List<dynamic>? ?? const [])
          .map((item) => item.toString())
          .where((item) => item.isNotEmpty)
          .toList(),
      dislikedFoods: json['dislikedFoods'] as String? ?? '',
      onboardingComplete: json['onboardingComplete'] as bool? ?? false,
    );
  }
}

class UserProfileController extends GetxController {
  UserProfileController._();

  static const _storageKey = 'user_profile_data';

  static UserProfileController ensureRegistered() {
    if (Get.isRegistered<UserProfileController>()) {
      return Get.find<UserProfileController>();
    }

    return Get.put(UserProfileController._(), permanent: true);
  }

  final Rx<UserProfileData> profile = const UserProfileData().obs;
  final RxBool isLoaded = false.obs;

  SharedPreferences? _preferences;

  Future<void> init() async {
    if (_preferences != null) {
      isLoaded.value = true;
      return;
    }

    _preferences = await SharedPreferences.getInstance();
    final raw = _preferences!.getString(_storageKey);

    if (raw != null && raw.isNotEmpty) {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      profile.value = UserProfileData.fromJson(decoded);
    }

    isLoaded.value = true;
  }

  void seedAccountDetails({required String fullName, required String email}) {
    profile.value = profile.value.copyWith(
      fullName: fullName.trim().isEmpty ? profile.value.fullName : fullName,
      email: email.trim().isEmpty ? profile.value.email : email,
    );
  }

  Future<void> saveProfile(UserProfileData data) async {
    await init();
    profile.value = data;
    await _preferences!.setString(_storageKey, jsonEncode(data.toJson()));
  }
}
