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
}

class UserApiEndpoints {
  const UserApiEndpoints._();

  final String me = '/api/users/me';
}
