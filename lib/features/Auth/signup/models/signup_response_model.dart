class SignupResponseModel {
  const SignupResponseModel({required this.success, required this.message});

  final bool success;
  final String message;

  factory SignupResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    final normalizedData = data is Map<String, dynamic>
        ? data
        : data is Map
        ? data.map((key, value) => MapEntry(key.toString(), value))
        : null;
    final nestedMessage = normalizedData?['message']?.toString().trim() ?? '';
    final rootMessage = json['message']?.toString().trim() ?? '';

    return SignupResponseModel(
      success: json['success'] == true,
      message: nestedMessage.isNotEmpty ? nestedMessage : rootMessage,
    );
  }
}
