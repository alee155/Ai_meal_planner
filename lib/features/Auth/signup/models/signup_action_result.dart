class SignupActionResult {
  const SignupActionResult({
    required this.isSuccess,
    required this.message,
    this.email,
  });

  final bool isSuccess;
  final String message;
  final String? email;
}
