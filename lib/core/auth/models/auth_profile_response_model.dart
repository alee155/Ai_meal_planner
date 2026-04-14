import 'package:ai_meal_planner/core/auth/models/auth_user.dart';

class AuthProfileResponseModel {
  const AuthProfileResponseModel({
    required this.success,
    required this.message,
    this.user,
  });

  final bool success;
  final String message;
  final AuthUser? user;

  factory AuthProfileResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    final normalizedData = data is Map<String, dynamic>
        ? data
        : data is Map
        ? data.map((key, value) => MapEntry(key.toString(), value))
        : null;

    return AuthProfileResponseModel(
      success: json['success'] == true,
      message:
          normalizedData?['message']?.toString().trim() ??
          json['message']?.toString().trim() ??
          '',
      user: normalizedData == null ? null : AuthUser.fromJson(normalizedData),
    );
  }
}
