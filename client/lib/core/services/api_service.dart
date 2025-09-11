import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/protest_model.dart';
import 'storage_service.dart';

/// Typed API error used across the app
class ApiError implements Exception {
  ApiError({this.statusCode, required this.message, this.details});

  final int? statusCode;
  final String message;
  final Object? details;

  @override
  String toString() =>
      'ApiError(statusCode: '
      '${statusCode?.toString() ?? 'n/a'}, message: $message)';
}

/// API Service for handling all backend communication
/// Uses Dio for HTTP requests with proper error handling and interceptors
class ApiService {
  // Get base URL from environment variable or use default
  static String get _baseUrl =>
      dotenv.env['API_BASE_URL'] ?? 'http://localhost:3000/api';

  late final Dio _dio;
  late final StorageService _storage;

  // Singleton pattern for single instance
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;

  ApiService._internal() {
    _storage = StorageService();
    _dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add interceptors
    _setupInterceptors();
  }

  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Add auth token if available
          final token = await _storage.readAuthToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          // Log request in debug mode
          if (kDebugMode) {
            print('REQUEST[${options.method}] => PATH: ${options.path}');
            print('Query params: ${options.queryParameters}');
          }

          return handler.next(options);
        },
        onResponse: (response, handler) {
          // Log response in debug mode
          if (kDebugMode) {
            print(
              'RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}',
            );
          }

          return handler.next(response);
        },
        onError: (DioException error, handler) {
          // Handle and log errors
          if (kDebugMode) {
            print(
              'ERROR[${error.response?.statusCode}] => PATH: ${error.requestOptions.path}',
            );
            print('Error message: ${error.message}');
          }

          // You can add custom error handling here
          // For example, refresh token on 401, show error messages, etc.

          return handler.next(error);
        },
      ),
    );
  }

  // ============= PUBLIC ENDPOINTS (No Auth Required) =============

  /// Get paginated protests feed
  /// Returns upcoming protests with optional country filter
  Future<PaginatedProtests> getProtests({
    String? cursor,
    int limit = 10,
    String? country,
  }) async {
    try {
      final response = await _dio.get(
        '/protests',
        queryParameters: {
          if (cursor != null) 'cursor': cursor,
          'limit': limit,
          if (country != null) 'country': country,
        },
      );

      // The backend returns data in pagination wrapper
      // We need to flatten it for the frontend model
      final data = response.data;

      // Transform backend response to match frontend expectations
      return PaginatedProtests(
        data: (data['data'] as List)
            .map((item) => Protest.fromJson(item))
            .toList(),
        nextCursor: data['pagination']?['nextCursor'],
        hasNextPage: data['pagination']?['hasNextPage'] ?? false,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get protest details by ID
  Future<Protest> getProtestById(String id) async {
    try {
      final response = await _dio.get('/protests/$id');
      return Protest.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Request organization verification
  Future<Map<String, dynamic>> requestVerification({
    required String username,
    required String country,
    required String socialMediaPlatform,
    required String socialMediaHandle,
  }) async {
    try {
      final response = await _dio.post(
        '/orgs/verify',
        data: {
          'username': username,
          'country': country,
          'socialMediaPlatform': socialMediaPlatform,
          'socialMediaHandle': socialMediaHandle,
        },
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ============= ORGANIZATION AUTH ENDPOINTS =============

  /// Organization login
  Future<Map<String, dynamic>> orgLogin({
    required String username,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/org/login',
        data: {'username': username, 'password': password},
      );

      // Save token to secure storage
      if (response.data['accessToken'] != null) {
        await _storage.saveAuthToken(response.data['accessToken']);
      }

      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Organization registration
  Future<Map<String, dynamic>> orgRegister({
    required String username,
    required String password,
    String? name,
    String? country,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/org/register',
        data: {
          'username': username,
          'password': password,
          if (name != null) 'name': name,
          if (country != null) 'country': country,
        },
      );

      // Save token if registration includes auto-login
      if (response.data['accessToken'] != null) {
        await _storage.saveAuthToken(response.data['accessToken']);
      }

      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get current organization profile
  Future<Organization> getOrgProfile() async {
    try {
      final response = await _dio.get('/auth/org/profile');

      return Organization.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Logout - Clear stored tokens
  Future<void> logout() async {
    await _storage.deleteAuthToken();
    await _storage.deleteRefreshToken();
  }

  // ============= PROTECTED ENDPOINTS (Auth Required) =============

  /// Create a new protest (Organization only)
  Future<Protest> createProtest({
    required String title,
    required DateTime dateTime,
    required String country,
    required String city,
    required String location,
    String? description,
    String? pictureUrl,
  }) async {
    try {
      final response = await _dio.post(
        '/protests',
        data: {
          'title': title,
          'dateTime': dateTime.toIso8601String(),
          'country': country,
          'city': city,
          'location': location,
          if (description != null) 'description': description,
          if (pictureUrl != null) 'pictureUrl': pictureUrl,
        },
      );

      // The response includes a message and the protest
      return Protest.fromJson(response.data['protest']);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Delete a protest (Organization only - own protests)
  Future<void> deleteProtest(String id) async {
    try {
      await _dio.delete('/protests/$id');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ============= ERROR HANDLING =============

  /// Handle Dio errors and convert to a typed ApiError
  ApiError _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiError(
          statusCode: error.response?.statusCode,
          message:
              'Connection timed out. Please check your internet connection.',
          details: error.response?.data,
        );

      case DioExceptionType.connectionError:
        return ApiError(
          statusCode: error.response?.statusCode,
          message:
              'Cannot connect to server. Please check your internet connection.',
          details: error.response?.data,
        );

      case DioExceptionType.badResponse:
        // Handle specific HTTP status codes
        final int? statusCode = error.response?.statusCode;
        final String? message = error.response?.data?['message'] as String?;

        String resolvedMessage;
        switch (statusCode) {
          case 400:
            resolvedMessage =
                message ?? 'Invalid request. Please check your input.';
            break;
          case 401:
            resolvedMessage = 'Authentication failed. Please login again.';
            break;
          case 403:
            resolvedMessage =
                'You don\'t have permission to perform this action.';
            break;
          case 404:
            resolvedMessage = 'The requested resource was not found.';
            break;
          case 409:
            resolvedMessage = message ?? 'Conflict with existing data.';
            break;
          case 429:
            resolvedMessage = 'Too many requests. Please try again later.';
            break;
          case 500:
          case 502:
          case 503:
            resolvedMessage = 'Server error. Please try again later.';
            break;
          default:
            resolvedMessage = message ?? 'An error occurred. Please try again.';
            break;
        }

        return ApiError(
          statusCode: statusCode,
          message: resolvedMessage,
          details: error.response?.data,
        );

      case DioExceptionType.cancel:
        return ApiError(
          statusCode: error.response?.statusCode,
          message: 'Request was cancelled.',
          details: error.response?.data,
        );

      default:
        return ApiError(
          statusCode: error.response?.statusCode,
          message: error.message ?? 'An unexpected error occurred.',
          details: error.response?.data,
        );
    }
  }

  // ============= UTILITY METHODS =============

  /// Update base URL (useful for switching between dev/prod)
  void updateBaseUrl(String newBaseUrl) {
    _dio.options.baseUrl = newBaseUrl;
  }

  /// Check if user is authenticated
  Future<bool> isAuthenticated() async {
    return await _storage.hasAuthToken();
  }
}
