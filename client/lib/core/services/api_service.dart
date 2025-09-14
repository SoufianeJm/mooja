import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/protest_model.dart';

class ApiService {
  static String get _baseUrl =>
      dotenv.env['API_BASE_URL'] ?? 'http://localhost:3000/api';
  static String get baseUrl => _baseUrl;

  late final Dio _dio;

  ApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // TODO(api, 2024-12-14): Add auth token when auth is implemented
          handler.next(options);
        },
        onError: (error, handler) {
          if (error.response?.statusCode == 401) {
            // TODO(api, 2024-12-14): Clear token when auth is implemented
          }
          handler.next(error);
        },
      ),
    );
  }

  /// Get protests with optional filtering
  Future<PaginatedProtests> getProtests({
    String? country,
    String? cursor,
    int? limit,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (country != null) queryParams['country'] = country;
      if (cursor != null) queryParams['cursor'] = cursor;
      if (limit != null) queryParams['limit'] = limit;

      final response = await _dio.get(
        '/protests',
        queryParameters: queryParams,
      );

      return PaginatedProtests.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get organizations with optional country filtering
  Future<List<Organization>> getOrganizations({String? country}) async {
    try {
      final response = await _dio.get(
        '/orgs',
        queryParameters: {if (country != null) 'country': country},
      );
      return (response.data as List)
          .map((item) => Organization.fromJson(item))
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Handle Dio errors and convert to ApiError
  ApiError _handleError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiError(
          'Connection timeout. Please check your internet connection.',
          408,
        );
      case DioExceptionType.connectionError:
        return ApiError(
          'No internet connection. Please check your network.',
          0,
        );
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode ?? 500;
        final message = e.response?.data?['message'] ?? 'Server error occurred';
        return ApiError(message, statusCode);
      case DioExceptionType.cancel:
        return ApiError('Request was cancelled', 499);
      default:
        return ApiError('An unexpected error occurred', 500);
    }
  }
}

/// API Error class
class ApiError implements Exception {
  final String message;
  final int? statusCode;

  ApiError(this.message, [this.statusCode]);

  @override
  String toString() => 'ApiError: $message (Status: $statusCode)';
}
