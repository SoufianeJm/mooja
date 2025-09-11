import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Secure storage service for tokens and user data
class StorageService {
  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  // Auth token methods
  Future<void> saveAuthToken(String token) async {
    await _storage.write(key: 'auth_token', value: token);
  }

  Future<String?> readAuthToken() async {
    return await _storage.read(key: 'auth_token');
  }

  Future<void> deleteAuthToken() async {
    await _storage.delete(key: 'auth_token');
  }

  // Refresh token methods
  Future<void> saveRefreshToken(String token) async {
    await _storage.write(key: 'refresh_token', value: token);
  }

  Future<String?> readRefreshToken() async {
    return await _storage.read(key: 'refresh_token');
  }

  Future<void> deleteRefreshToken() async {
    await _storage.delete(key: 'refresh_token');
  }

  // Clear all auth data
  Future<void> clear() async {
    await _storage.deleteAll();
  }

  // Check if user has valid token
  Future<bool> hasAuthToken() async {
    final token = await readAuthToken();
    return token != null && token.isNotEmpty;
  }
}
