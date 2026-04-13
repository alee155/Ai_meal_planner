class ApiEndpoints {
  const ApiEndpoints._();

  static const String baseUrl = 'https://aidietplanner.dgexpense.com';

  static const String register = '/api/auth/register';
  static const String login = '/api/auth/login';
  static const String loggedInUserProfile = '/api/users/me';

  static String url(String endpoint) => '$baseUrl$endpoint';

  static String get registerUrl => url(register);
  static String get loginUrl => url(login);
  static String get loggedInUserProfileUrl => url(loggedInUserProfile);
}
