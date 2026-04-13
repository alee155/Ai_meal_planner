import 'package:ai_meal_planner/core/auth/models/auth_user.dart';

class LoginResponseModel {
  const LoginResponseModel({
    required this.success,
    required this.message,
    this.data,
  });

  final bool success;
  final String message;
  final LoginResponseData? data;

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'];

    return LoginResponseModel(
      success: json['success'] == true,
      message: json['message']?.toString() ?? '',
      data: data is Map<String, dynamic>
          ? LoginResponseData.fromJson(data)
          : data is Map
          ? LoginResponseData.fromJson(
              data.map((key, value) => MapEntry(key.toString(), value)),
            )
          : null,
    );
  }
}

class LoginResponseData {
  const LoginResponseData({required this.token, required this.user});

  final String token;
  final AuthUser? user;

  factory LoginResponseData.fromJson(Map<String, dynamic> json) {
    final user = json['user'];

    return LoginResponseData(
      token: json['token']?.toString() ?? '',
      user: user is Map<String, dynamic>
          ? AuthUser.fromJson(user)
          : user is Map
          ? AuthUser.fromJson(
              user.map((key, value) => MapEntry(key.toString(), value)),
            )
          : null,
    );
  }
}
