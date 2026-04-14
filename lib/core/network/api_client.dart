// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:ai_meal_planner/core/network/api_endpoints.dart';
import 'package:ai_meal_planner/core/network/api_exception.dart';
import 'package:ai_meal_planner/core/network/api_response.dart';
import 'package:ai_meal_planner/core/network/interceptors/auth_interceptor.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response;

class ApiClient {
  ApiClient({Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: ApiEndpoints.baseUrl,
              connectTimeout: const Duration(seconds: 30),
              receiveTimeout: const Duration(seconds: 30),
              sendTimeout: const Duration(seconds: 30),
              responseType: ResponseType.json,
              validateStatus: (_) => true,
              headers: const {
                'Accept': 'application/json',
                'Content-Type': 'application/json',
              },
            ),
          ) {
    _dio.interceptors.add(AuthInterceptor());
  }

  final Dio _dio;

  static ApiClient ensureRegistered() {
    if (Get.isRegistered<ApiClient>()) {
      return Get.find<ApiClient>();
    }

    return Get.put(ApiClient(), permanent: true);
  }

  Future<Map<String, dynamic>> postRequest(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    final response = await post(endpoint, body: body, headers: headers);

    return response.data;
  }

  Future<ApiResponse<Map<String, dynamic>>> post(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    return _send(
      () => _dio.post<dynamic>(
        endpoint,
        data: body,
        options: Options(headers: _jsonHeaders(headers)),
      ),
      method: 'POST',
      endpoint: endpoint,
      body: body,
      headers: headers,
    );
  }

  Future<Map<String, dynamic>> getRequest(
    String endpoint, {
    Map<String, String>? headers,
  }) async {
    final response = await get(endpoint, headers: headers);
    return response.data;
  }

  Future<ApiResponse<Map<String, dynamic>>> get(
    String endpoint, {
    Map<String, String>? headers,
  }) async {
    return _send(
      () => _dio.get<dynamic>(
        endpoint,
        options: Options(headers: _jsonHeaders(headers)),
      ),
      method: 'GET',
      endpoint: endpoint,
      headers: headers,
    );
  }

  Future<Map<String, dynamic>> patchRequest(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    final response = await patch(endpoint, body: body, headers: headers);

    return response.data;
  }

  Future<ApiResponse<Map<String, dynamic>>> patch(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    return _send(
      () => _dio.patch<dynamic>(
        endpoint,
        data: body,
        options: Options(headers: _jsonHeaders(headers)),
      ),
      method: 'PATCH',
      endpoint: endpoint,
      body: body,
      headers: headers,
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> _send(
    Future<Response<dynamic>> Function() requestBuilder, {
    required String method,
    required String endpoint,
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    _logRequest(
      method: method,
      endpoint: endpoint,
      body: body,
      headers: headers,
    );

    try {
      final response = await requestBuilder();
      final responseBody = _responseBodyAsMap(response);
      final statusCode = response.statusCode ?? 0;

      _logResponse(
        method: method,
        endpoint: endpoint,
        statusCode: statusCode,
        responseBody: responseBody,
      );

      if (statusCode >= 200 && statusCode < 300) {
        return ApiResponse<Map<String, dynamic>>(
          data: responseBody,
          statusCode: statusCode,
          headers: response.headers.map.map(
            (key, value) => MapEntry(key, List<String>.from(value)),
          ),
        );
      }

      throw ApiException(
        message:
            _extractMessage(responseBody) ??
            response.statusMessage ??
            'Request failed. Please try again.',
        statusCode: response.statusCode,
        data: responseBody.isEmpty ? null : responseBody,
      );
    } on ApiException {
      rethrow;
    } on DioException catch (error) {
      final response = error.response;
      final responseBody = response == null
          ? <String, dynamic>{}
          : _responseBodyAsMap(response);

      _logError(
        method: method,
        endpoint: endpoint,
        statusCode: response?.statusCode,
        responseBody: responseBody,
        message: error.message,
      );

      if (response != null) {
        throw ApiException(
          message:
              _extractMessage(responseBody) ??
              response.statusMessage ??
              'Request failed. Please try again.',
          statusCode: response.statusCode,
          data: responseBody.isEmpty ? null : responseBody,
        );
      }

      throw ApiException(message: _resolveDioErrorMessage(error));
    } on FormatException {
      throw const ApiException(
        message: 'Invalid server response. Please try again later.',
      );
    } catch (_) {
      throw const ApiException(
        message: 'Unable to connect to the server. Please try again.',
      );
    }
  }

  void _logRequest({
    required String method,
    required String endpoint,
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) {
    print('******** API REQUEST START ********');
    print('method: $method');
    print('url: ${ApiEndpoints.url(endpoint)}');
    print('headers: ${_stringifyPayload(_jsonHeaders(headers))}');
    print('body: ${_stringifyPayload(body ?? <String, dynamic>{})}');
    print('******** API REQUEST END ********');
  }

  void _logResponse({
    required String method,
    required String endpoint,
    required int statusCode,
    required Map<String, dynamic> responseBody,
  }) {
    print('******** API RESPONSE START ********');
    print('method: $method');
    print('url: ${ApiEndpoints.url(endpoint)}');
    print('statusCode: $statusCode');
    print('******** response ********');
    print(_stringifyPayload(responseBody));
    print('******** API RESPONSE END ********');
  }

  void _logError({
    required String method,
    required String endpoint,
    required int? statusCode,
    required Map<String, dynamic> responseBody,
    String? message,
  }) {
    print('******** API ERROR START ********');
    print('method: $method');
    print('url: ${ApiEndpoints.url(endpoint)}');
    print('statusCode: ${statusCode ?? 'N/A'}');
    if ((message ?? '').trim().isNotEmpty) {
      print('error: $message');
    }
    print('******** response ********');
    print(_stringifyPayload(responseBody));
    print('******** API ERROR END ********');
  }

  String _stringifyPayload(Object payload) {
    const encoder = JsonEncoder.withIndent('  ');

    try {
      return encoder.convert(payload);
    } catch (_) {
      return payload.toString();
    }
  }

  Map<String, String> _jsonHeaders(Map<String, String>? headers) {
    return <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      ...?headers,
    };
  }

  Map<String, dynamic> _responseBodyAsMap(Response<dynamic> response) {
    final body = response.data;

    if (body is Map<String, dynamic>) {
      return body;
    }

    if (body is Map) {
      return body.map((key, value) => MapEntry(key.toString(), value));
    }

    if (body is String) {
      final bodyString = body.trim();
      if (bodyString.isEmpty) {
        return <String, dynamic>{};
      }

      final decoded = jsonDecode(bodyString);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }

      if (decoded is Map) {
        return decoded.map((key, value) => MapEntry(key.toString(), value));
      }
    }

    throw const FormatException('Response body is not a JSON object');
  }

  String? _extractMessage(Map<String, dynamic> body) {
    final message = body['message']?.toString().trim() ?? '';
    if (message.isEmpty) {
      final nestedData = body['data'];
      if (nestedData is Map<String, dynamic>) {
        final nestedMessage = nestedData['message']?.toString().trim() ?? '';
        return nestedMessage.isEmpty ? null : nestedMessage;
      }

      if (nestedData is Map) {
        final normalizedData = nestedData.map(
          (key, value) => MapEntry(key.toString(), value),
        );
        final nestedMessage =
            normalizedData['message']?.toString().trim() ?? '';
        return nestedMessage.isEmpty ? null : nestedMessage;
      }

      return null;
    }

    return message;
  }

  String _resolveDioErrorMessage(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'The server is taking too long to respond. Please try again.';
      case DioExceptionType.connectionError:
        return 'Unable to connect to the server. Please try again.';
      case DioExceptionType.cancel:
        return 'Request was cancelled.';
      case DioExceptionType.badCertificate:
        return 'Secure connection failed. Please try again later.';
      case DioExceptionType.badResponse:
      case DioExceptionType.unknown:
        return 'Unable to connect to the server. Please try again.';
    }
  }
}
