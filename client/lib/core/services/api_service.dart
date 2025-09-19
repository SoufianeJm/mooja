import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:io' show Platform;
import '../models/protest_model.dart';

class ApiService {
  static String get _baseUrl {
    final envUrl = dotenv.env['API_BASE_URL'];
    if (envUrl != null && envUrl.isNotEmpty) return envUrl;

    // Default per-platform sensible base URL
    bool isAndroid = false;
    try {
      isAndroid = Platform.isAndroid;
    } catch (_) {
      // Platform not available (e.g., web); fall through to localhost
    }
    if (isAndroid) return 'http://10.0.2.2:3000/api';
    return 'http://localhost:3000/api';
  }

  static String get baseUrl => _baseUrl;

  late final Dio _dio;
  Dio get dio => _dio;

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
          handler.next(options);
        },
        onError: (error, handler) {
          if (error.response?.statusCode == 401) {}
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

  /// Request organization verification
  Future<Map<String, dynamic>> requestOrgVerification({
    required String name,
    required String country,
    String? socialMediaPlatform,
    String? socialMediaHandle,
  }) async {
    try {
      final response = await _dio.post(
        '/orgs/verify',
        data: {
          'name': name,
          'country': country,
          if (socialMediaPlatform != null)
            'socialMediaPlatform': socialMediaPlatform,
          if (socialMediaHandle != null) 'socialMediaHandle': socialMediaHandle,
        },
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Verify organization invite code (public endpoint for pre-registration)
  Future<Map<String, dynamic>> verifyOrgCode({
    required String applicationId,
    required String inviteCode,
  }) async {
    try {
      final response = await _dio.post(
        '/orgs/verify-code',
        data: {'applicationId': applicationId, 'inviteCode': inviteCode},
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Verify organization with invite code (authenticated endpoint - legacy)
  Future<Map<String, dynamic>> verifyOrgWithCode({
    required String inviteCode,
  }) async {
    try {
      final response = await _dio.post(
        '/orgs/verify-with-code',
        data: {'inviteCode': inviteCode},
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get verification status by username
  /// Deprecated: Prefer getOrgStatusByApplicationId
  Future<String> getOrgStatusByUsername(String username) async {
    try {
      final response = await _dio.get(
        '/orgs/status',
        queryParameters: {'username': username},
      );
      final data = response.data as Map<String, dynamic>;
      return (data['verificationStatus'] as String?) ?? 'pending';
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get verification status by application id (org.id)
  Future<String> getOrgStatusByApplicationId(String applicationId) async {
    try {
      final response = await _dio.get(
        '/orgs/applications/$applicationId/status',
      );
      final data = response.data as Map<String, dynamic>;
      return (data['verificationStatus'] as String?) ?? 'pending';
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Register organization account after verification
  Future<Map<String, dynamic>> register({
    required String name,
    required String username,
    required String password,
    required String country,
    String? socialMediaPlatform,
    String? socialMediaHandle,
    String? pictureUrl,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/org/register',
        data: {
          'name': name,
          'username': username,
          'password': password,
          'country': country,
          if (socialMediaPlatform != null)
            'socialMediaPlatform': socialMediaPlatform,
          if (socialMediaHandle != null) 'socialMediaHandle': socialMediaHandle,
          if (pictureUrl != null) 'pictureUrl': pictureUrl,
        },
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get application id by username (fallback diagnostic)
  Future<String?> getApplicationIdByUsername(String username) async {
    try {
      final response = await _dio.get(
        '/orgs/by-username',
        queryParameters: {'username': username},
      );
      final data = response.data as Map<String, dynamic>?;
      return data?['id'] as String?;
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
        final data = e.response?.data;
        String message = 'Server error occurred';

        if (data != null) {
          if (data is Map) {
            // Handle validation errors
            if (data['message'] is List) {
              message = (data['message'] as List).join(', ');
            } else if (data['message'] != null) {
              message = data['message'].toString();
            }
          } else if (data is String) {
            message = data;
          }
        }

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
