import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:io' show Platform;
import '../models/protest_model.dart';
import '../domain/domain_objects.dart';

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
    Country? country,
    String? cursor,
    int? limit,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (country != null) queryParams['country'] = country.value;
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
  Future<List<Organization>> getOrganizations({Country? country}) async {
    try {
      final response = await _dio.get(
        '/orgs',
        queryParameters: {if (country != null) 'country': country.value},
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
    required OrganizationName name,
    required Country country,
    SocialMediaPlatform? socialMediaPlatform,
    SocialMediaHandle? socialMediaHandle,
  }) async {
    try {
      final response = await _dio.post(
        '/orgs/verify',
        data: {
          'name': name.value,
          'country': country.value,
          if (socialMediaPlatform != null)
            'socialMediaPlatform': socialMediaPlatform.value,
          if (socialMediaHandle != null)
            'socialMediaHandle': socialMediaHandle.value,
        },
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Verify organization invite code (public endpoint for pre-registration)
  Future<Map<String, dynamic>> verifyOrgCode({
    required ApplicationId applicationId,
    required InviteCode inviteCode,
  }) async {
    return _makeRequest<Map<String, dynamic>>(
      'POST',
      '/orgs/verify-code',
      data: {
        'applicationId': applicationId.value,
        'inviteCode': inviteCode.value,
      },
    );
  }

  /// Get verification status by application id (org.id)
  Future<String> getOrgStatusByApplicationId(
    ApplicationId applicationId,
  ) async {
    final data = await _makeRequest<Map<String, dynamic>>(
      'GET',
      '/orgs/applications/${applicationId.value}/status',
    );
    return (data['verificationStatus'] as String?) ?? 'pending';
  }

  /// Register organization account after verification
  Future<Map<String, dynamic>> register(
    OrganizationRegistrationData data,
  ) async {
    try {
      final response = await _dio.post(
        '/auth/org/register',
        data: {
          'name': data.name.value,
          'username': data.username.value,
          'password': data.password.value,
          'country': data.country.value,
          if (data.socialMediaPlatform != null)
            'socialMediaPlatform': data.socialMediaPlatform!.value,
          if (data.socialMediaHandle != null)
            'socialMediaHandle': data.socialMediaHandle!.value,
          if (data.pictureUrl != null) 'pictureUrl': data.pictureUrl!.value,
        },
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Handle Dio errors and convert to ApiError
  ApiError _handleError(DioException e) {
    // Handle special case that needs response data
    if (e.type == DioExceptionType.badResponse) {
      return _createBadResponseError(e);
    }

    // Use lookup table for simple error types
    final errorHandler = _errorHandlers[e.type];
    return errorHandler?.call() ?? _createUnexpectedError();
  }

  /// Error handler lookup table
  static final Map<DioExceptionType, ApiError Function()> _errorHandlers = {
    DioExceptionType.connectionTimeout: () => ApiError(
      'Connection timeout. Please check your internet connection.',
      408,
    ),
    DioExceptionType.sendTimeout: () => ApiError(
      'Connection timeout. Please check your internet connection.',
      408,
    ),
    DioExceptionType.receiveTimeout: () => ApiError(
      'Connection timeout. Please check your internet connection.',
      408,
    ),
    DioExceptionType.connectionError: () =>
        ApiError('No internet connection. Please check your network.', 0),
    DioExceptionType.cancel: () => ApiError('Request was cancelled', 499),
  };

  /// Create bad response error with message extraction
  ApiError _createBadResponseError(DioException e) {
    final statusCode = e.response?.statusCode ?? 500;
    final message = _extractErrorMessage(e.response?.data);
    return ApiError(message, statusCode);
  }

  /// Extract error message from response data
  String _extractErrorMessage(dynamic data) {
    if (data == null) return 'Server error occurred';

    if (data is Map) {
      final message = data['message'];
      if (message is List) {
        return message.join(', ');
      }
      if (message != null) {
        return message.toString();
      }
    }

    if (data is String) {
      return data;
    }

    return 'Server error occurred';
  }

  /// Create unexpected error
  ApiError _createUnexpectedError() {
    return ApiError('An unexpected error occurred', 500);
  }

  /// Generic request method to eliminate duplication
  Future<T> _makeRequest<T>(
    String method,
    String endpoint, {
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      late final Response response;

      switch (method.toUpperCase()) {
        case 'GET':
          response = await _dio.get(endpoint, queryParameters: queryParameters);
          break;
        case 'POST':
          response = await _dio.post(
            endpoint,
            data: data,
            queryParameters: queryParameters,
          );
          break;
        case 'PUT':
          response = await _dio.put(
            endpoint,
            data: data,
            queryParameters: queryParameters,
          );
          break;
        case 'DELETE':
          response = await _dio.delete(
            endpoint,
            data: data,
            queryParameters: queryParameters,
          );
          break;
        default:
          throw ArgumentError('Unsupported HTTP method: $method');
      }

      return response.data as T;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
}

/// Organization registration data
class OrganizationRegistrationData {
  final OrganizationName name;
  final Username username;
  final Password password;
  final Country country;
  final SocialMediaPlatform? socialMediaPlatform;
  final SocialMediaHandle? socialMediaHandle;
  final PictureUrl? pictureUrl;

  const OrganizationRegistrationData({
    required this.name,
    required this.username,
    required this.password,
    required this.country,
    this.socialMediaPlatform,
    this.socialMediaHandle,
    this.pictureUrl,
  });
}

/// API Error class
class ApiError implements Exception {
  final String message;
  final int? statusCode;

  ApiError(this.message, [this.statusCode]);

  @override
  String toString() => 'ApiError: $message (Status: $statusCode)';
}
