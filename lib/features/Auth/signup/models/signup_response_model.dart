class SignupResponseModel {
  const SignupResponseModel({
    required this.success,
    required this.message,
    this.data,
  });

  final bool success;
  final String message;
  final SignupResponseData? data;

  factory SignupResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'];

    return SignupResponseModel(
      success: json['success'] == true,
      message: json['message']?.toString() ?? '',
      data: data is Map<String, dynamic>
          ? SignupResponseData.fromJson(data)
          : data is Map
          ? SignupResponseData.fromJson(
              data.map((key, value) => MapEntry(key.toString(), value)),
            )
          : null,
    );
  }
}

class SignupResponseData {
  const SignupResponseData({required this.userId});

  final String userId;

  factory SignupResponseData.fromJson(Map<String, dynamic> json) {
    return SignupResponseData(userId: json['userId']?.toString() ?? '');
  }
}
