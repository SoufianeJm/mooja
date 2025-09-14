import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'api_service.dart';

class AuthService {
  final ApiService _apiService;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  AuthService(this._apiService);

  /// Login with username and password
  Future<AuthResult> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await _apiService.dio.post(
        '/auth/org/login',
        data: {'username': username, 'password': password},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Store tokens for session persistence
        await _storage.write(
          key: 'access_token',
          value: response.data['accessToken'],
        );
        if (response.data['refreshToken'] != null) {
          await _storage.write(
            key: 'refresh_token',
            value: response.data['refreshToken'],
          );
        }
        await _storage.write(
          key: 'user_data',
          value: response.data['org'].toString(),
        );

        return AuthResult.success(
          token: response.data['accessToken'],
          user: response.data['org'],
        );
      } else {
        return AuthResult.failure(
          message: response.data['message'] ?? 'Login failed',
        );
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        return AuthResult.failure(
          message: 'Connection timeout. Please check your internet connection.',
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
      return AuthResult.failure(
        message: 'Something went wrong. Please try again.',
      );
    }
  }

  /// Check if user is already logged in
  Future<AuthResult?> getStoredAuth() async {
    try {
      final accessToken = await _storage.read(key: 'access_token');
      final userData = await _storage.read(key: 'user_data');

      if (accessToken != null && userData != null) {
        // Parse user data (simplified - in real app you'd want proper JSON parsing)
        final user = <String, dynamic>{}; // Placeholder for now
        return AuthResult.success(token: accessToken, user: user);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Logout and clear stored tokens
  Future<void> logout() async {
    await _storage.delete(key: 'access_token');
    await _storage.delete(key: 'refresh_token');
    await _storage.delete(key: 'user_data');
  }

  /// Check if user is currently logged in
  Future<bool> isLoggedIn() async {
    final token = await _storage.read(key: 'access_token');
    return token != null;
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
