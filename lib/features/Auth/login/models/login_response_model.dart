import 'package:ai_meal_planner/core/network/api_response.dart';

class LoginResponseModel {
  const LoginResponseModel({
    required this.success,
    required this.message,
    required this.token,
  });

  final bool success;
  final String message;
  final String token;

  factory LoginResponseModel.fromApiResponse(
    ApiResponse<Map<String, dynamic>> response,
  ) {
    final json = response.data;
    final data = json['data'];
    final normalizedData = data is Map<String, dynamic>
        ? data
        : data is Map
        ? data.map((key, value) => MapEntry(key.toString(), value))
        : null;
    final nestedMessage = normalizedData?['message']?.toString().trim() ?? '';
    final rootMessage = json['message']?.toString().trim() ?? '';

    return LoginResponseModel(
      success: json['success'] == true,
      message: nestedMessage.isNotEmpty ? nestedMessage : rootMessage,
      token: _extractToken(json, normalizedData, response),
    );
  }

  static String _extractToken(
    Map<String, dynamic> rootJson,
    Map<String, dynamic>? dataJson,
    ApiResponse<Map<String, dynamic>> response,
  ) {
    final bodyCandidates = <dynamic>[
      dataJson?['token'],
      dataJson?['accessToken'],
      dataJson?['jwt'],
      rootJson['token'],
      rootJson['accessToken'],
      rootJson['jwt'],
    ];

    for (final candidate in bodyCandidates) {
      final token = candidate?.toString().trim() ?? '';
      if (token.isNotEmpty) {
        return token;
      }
    }

    final headerCandidates = <String?>[
      response.firstHeader('authorization'),
      response.firstHeader('Authorization'),
      response.firstHeader('x-access-token'),
      response.firstHeader('token'),
    ];

    for (final candidate in headerCandidates) {
      final value = candidate?.trim() ?? '';
      if (value.isEmpty) {
        continue;
      }

      if (value.toLowerCase().startsWith('bearer ')) {
        return value.substring(7).trim();
      }

      return value;
    }

    return '';
  }
}
