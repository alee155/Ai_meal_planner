class PasswordResetRequestModel {
  const PasswordResetRequestModel({required this.email});

  final String email;

  Map<String, dynamic> toJson() {
    return {'email': email.trim()};
  }
}
