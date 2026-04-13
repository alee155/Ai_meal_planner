class ApiException implements Exception {
  const ApiException({required this.message, this.statusCode, this.data});

  final String message;
  final int? statusCode;
  final Map<String, dynamic>? data;

  @override
  String toString() {
    if (statusCode == null) {
      return 'ApiException(message: $message)';
    }

    return 'ApiException(statusCode: $statusCode, message: $message)';
  }
}
