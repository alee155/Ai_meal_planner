import 'package:ai_meal_planner/core/auth/models/auth_user.dart';

class LoginActionResult {
  const LoginActionResult({
    required this.isSuccess,
    required this.message,
    this.token,
    this.user,
  });

  final bool isSuccess;
  final String message;
  final String? token;
  final AuthUser? user;
}
