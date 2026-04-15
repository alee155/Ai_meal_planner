class UserStatsModel {
  const UserStatsModel({
    required this.userId,
    required this.age,
    required this.gender,
    required this.activityLevel,
    required this.goal,
    required this.heightCm,
    required this.weightKg,
    required this.mealPreferences,
    required this.mealAllergies,
    required this.mealDislikes,
  });

  final String userId;
  final int age;
  final String gender;
  final String activityLevel;
  final String goal;
  final double heightCm;
  final double weightKg;
  final List<String> mealPreferences;
  final List<String> mealAllergies;
  final List<String> mealDislikes;

  bool get hasCompletedSetup {
    return heightCm > 0 && weightKg > 0;
  }

  factory UserStatsModel.fromJson(Map<String, dynamic> json) {
    return UserStatsModel(
      userId: json['userId']?.toString() ?? '',
      age: _readInt(json['age']),
      gender: json['gender']?.toString().trim() ?? '',
      activityLevel: json['activityLevel']?.toString().trim() ?? '',
      goal: json['goal']?.toString().trim() ?? '',
      heightCm: _readDouble(json['heightCm']),
      weightKg: _readDouble(json['weightKg']),
      mealPreferences: _readStringList(json['mealPreferences']),
      mealAllergies: _readStringList(json['mealAllergies']),
      mealDislikes: _readStringList(json['mealDislikes']),
    );
  }

  static int _readInt(dynamic value) {
    if (value is int) {
      return value;
    }

    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static double _readDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  static List<String> _readStringList(dynamic value) {
    final list = value is List ? value : const [];
    return list
        .map((item) => item.toString().trim())
        .where((item) => item.isNotEmpty)
        .toList(growable: false);
  }
}

class UserStatsResponseModel {
  const UserStatsResponseModel({
    required this.success,
    required this.message,
    this.stats,
  });

  final bool success;
  final String message;
  final UserStatsModel? stats;

  factory UserStatsResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    final normalizedData = data is Map<String, dynamic>
        ? data
        : data is Map
        ? data.map((key, value) => MapEntry(key.toString(), value))
        : null;
    final nestedMessage = normalizedData?['message']?.toString().trim() ?? '';
    final rootMessage = json['message']?.toString().trim() ?? '';

    return UserStatsResponseModel(
      success: json['success'] == true,
      message: nestedMessage.isNotEmpty ? nestedMessage : rootMessage,
      stats: normalizedData == null
          ? null
          : UserStatsModel.fromJson(normalizedData),
    );
  }
}
