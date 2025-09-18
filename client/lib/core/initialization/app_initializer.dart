import '../services/storage_service.dart';
import '../di/service_locator.dart';
import 'package:flutter/foundation.dart';

/// Handles app initialization and first-time state setup
class AppInitializer {
  static final StorageService _storage = sl<StorageService>();

  /// Initialize app state for first-time users
  static Future<void> initializeAppState() async {
    try {
      if (kDebugMode) debugPrint('APP_INIT: Starting app initialization...');

      // Check if this is a first-time user
      final userType = await _storage.readUserType();
      final isFirstTime = await _storage.readIsFirstTime();

      // If no user type is set, this is a first-time user
      if (userType == null) {
        if (kDebugMode)
          debugPrint('APP_INIT: First-time user detected, setting defaults...');

        // Set default state for first-time users
        await _storage.saveUserType('protestor');
        await _storage.saveIsFirstTime(true);

        if (kDebugMode)
          debugPrint('APP_INIT: Default state set for first-time user');
      } else {
        if (kDebugMode)
          debugPrint(
            'APP_INIT: Returning user detected (userType: $userType, isFirstTime: $isFirstTime)',
          );
      }

      if (kDebugMode) debugPrint('APP_INIT: App initialization completed');
    } catch (e) {
      if (kDebugMode) debugPrint('APP_INIT: Error during initialization: $e');

      // Fallback: ensure we have some state even if initialization fails
      try {
        await _storage.saveUserType('protestor');
        await _storage.saveIsFirstTime(true);
        if (kDebugMode) debugPrint('APP_INIT: Fallback state set');
      } catch (fallbackError) {
        if (kDebugMode)
          debugPrint(
            'APP_INIT: Fallback initialization failed: $fallbackError',
          );
      }
    }
  }

  /// Check if app state is properly initialized
  static Future<bool> isStateInitialized() async {
    try {
      final userType = await _storage.readUserType();
      return userType != null;
    } catch (e) {
      if (kDebugMode)
        debugPrint('APP_INIT: Error checking state initialization: $e');
      return false;
    }
  }
}
