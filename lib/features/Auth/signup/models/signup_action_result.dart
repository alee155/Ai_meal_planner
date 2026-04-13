class SignupActionResult {
  const SignupActionResult({
    required this.isSuccess,
    required this.message,
    this.userId,
  });

  final bool isSuccess;
  final String message;
  final String? userId;
}
