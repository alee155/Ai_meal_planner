class LoginActionResult {
  const LoginActionResult({
    required this.isSuccess,
    required this.message,
    this.token,
    this.nextRoute,
  });

  final bool isSuccess;
  final String message;
  final String? token;
  final String? nextRoute;
}
