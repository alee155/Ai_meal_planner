class SignupRequestModel {
  const SignupRequestModel({
    required this.name,
    required this.email,
    required this.password,
  });

  final String name;
  final String email;
  final String password;

  Map<String, dynamic> toJson() {
    return {'name': name.trim(), 'email': email.trim(), 'password': password};
  }
}
