class LoginActionResult {
  const LoginActionResult({
    required this.isSuccess,
    required this.message,
    this.token,
  });

  final bool isSuccess;
  final String message;
  final String? token;
}
