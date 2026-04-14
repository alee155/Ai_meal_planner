class ApiEndpoints {
  const ApiEndpoints._();

  static const String baseUrl = 'https://aidietplanner.dgexpense.com';
  static const AuthApiEndpoints auth = AuthApiEndpoints._();
  static const UserApiEndpoints users = UserApiEndpoints._();

  static String url(String endpoint) => '$baseUrl$endpoint';
}

class AuthApiEndpoints {
  const AuthApiEndpoints._();

  final String register = '/api/auth/register';
  final String verifyOtp = '/api/auth/verify-otp';
  final String resendOtp = '/api/auth/resend-otp';
  final String login = '/api/auth/login';
  final AuthPasswordApiEndpoints password = const AuthPasswordApiEndpoints._();
}

class UserApiEndpoints {
  const UserApiEndpoints._();

  final String me = '/api/users/me';
  final UserAccountApiEndpoints account = const UserAccountApiEndpoints._();
}

class AuthPasswordApiEndpoints {
  const AuthPasswordApiEndpoints._();

  final String update = '/api/auth/password/update';
  final String resetRequest = '/api/auth/password/reset/request';
  final String resetConfirm = '/api/auth/password/reset/confirm';
}

class UserAccountApiEndpoints {
  const UserAccountApiEndpoints._();

  final String delete = '/api/users/account';
  final String deactivate = '/api/users/data';
}
