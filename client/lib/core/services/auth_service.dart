import 'package:dio/dio.dart';
import 'api_service.dart';
import 'storage_service.dart';

class AuthService {
  final ApiService _apiService;
  final StorageService _storageService;

  AuthService(this._apiService, this._storageService);

  /// Login with username and password (with retry logic)
  Future<AuthResult> login({
    required String username,
    required String password,
    int retries = 2,
  }) async {
    for (int attempt = 0; attempt <= retries; attempt++) {
      try {
        final response = await _apiService.dio.post(
          '/auth/org/login',
          data: {'username': username, 'password': password},
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          // Transaction-safe token storage
          try {
            await _storageService.saveAuthToken(response.data['accessToken']);
            if (response.data['refreshToken'] != null) {
              await _storageService.saveRefreshToken(
                response.data['refreshToken'],
              );
            }
            await _storageService.saveUserType('org');
            await _storageService.saveIsFirstTime(false);

            return AuthResult.success(
              token: response.data['accessToken'],
              user: response.data['org'],
            );
          } catch (storageError) {
            // Rollback on storage failure
            await _storageService.deleteAuthToken();
            await _storageService.deleteRefreshToken();
            return AuthResult.failure(
              message: 'Failed to save login data. Please try again.',
            );
          }
        } else {
          return AuthResult.failure(
            message: response.data['message'] ?? 'Login failed',
          );
        }
      } on DioException catch (e) {
        // Retry on network errors (but not auth errors)
        if (attempt < retries && _shouldRetry(e)) {
          await Future.delayed(Duration(milliseconds: 500 * (attempt + 1)));
          continue;
        }

        // Final attempt or non-retryable error
        if (e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.receiveTimeout) {
          return AuthResult.failure(
            message:
                'Connection timeout. Please check your internet connection.',
          );
        } else if (e.type == DioExceptionType.connectionError) {
          return AuthResult.failure(
            message: 'No internet connection. Please check your network.',
          );
        } else if (e.response?.statusCode == 401) {
          return AuthResult.failure(
            message: 'Invalid email or password. Please try again.',
          );
        } else if (e.response?.statusCode == 422) {
          return AuthResult.failure(
            message:
                e.response?.data['message'] ??
                'Invalid input. Please check your details.',
          );
        } else if (e.response?.statusCode == 500) {
          return AuthResult.failure(
            message: 'Server error. Please try again later.',
          );
        } else {
          return AuthResult.failure(
            message: e.message ?? 'Login failed. Please try again.',
          );
        }
      } catch (e) {
        if (attempt < retries) {
          await Future.delayed(Duration(milliseconds: 500 * (attempt + 1)));
          continue;
        }
        return AuthResult.failure(
          message: 'Something went wrong. Please try again.',
        );
      }
    }

    return AuthResult.failure(message: 'Login failed after multiple attempts.');
  }

  /// Determine if an error should trigger a retry
  bool _shouldRetry(DioException e) {
    return e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.connectionError ||
        (e.response?.statusCode != null && e.response!.statusCode! >= 500);
  }

  /// Check if user is already logged in
  Future<AuthResult?> getStoredAuth() async {
    try {
      final accessToken = await _storageService.readAuthToken();
      final userType = await _storageService.readUserType();

      if (accessToken != null && userType == 'org') {
        // Return basic auth info
        final user = <String, dynamic>{'type': 'org'};
        return AuthResult.success(token: accessToken, user: user);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Logout and clear stored tokens
  Future<void> logout() async {
    await _storageService.deleteAuthToken();
    await _storageService.deleteRefreshToken();
    // Note: We keep user preferences like country selection
  }

  /// Check if user is currently logged in
  Future<bool> isLoggedIn() async {
    // Use the StorageService which properly handles auth tokens
    final hasToken = await _storageService.hasAuthToken();
    return hasToken;
  }
}

class AuthResult {
  final bool isSuccess;
  final String? token;
  final Map<String, dynamic>? user;
  final String? message;

  const AuthResult._({
    required this.isSuccess,
    this.token,
    this.user,
    this.message,
  });

  factory AuthResult.success({
    required String token,
    required Map<String, dynamic> user,
  }) {
    return AuthResult._(isSuccess: true, token: token, user: user);
  }

  factory AuthResult.failure({required String message}) {
    return AuthResult._(isSuccess: false, message: message);
  }
}
