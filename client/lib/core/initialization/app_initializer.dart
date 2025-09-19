import '../services/storage_service.dart';
import '../di/service_locator.dart';

/// Handles app initialization and first-time state setup
class AppInitializer {
  static final StorageService _storage = sl<StorageService>();

  /// Initialize app state for first-time users
  static Future<void> initializeAppState() async {
    try {
      // Check if this is a first-time user
      final userType = await _storage.readUserType();

      // If no user type is set, this is a first-time user
      if (userType == null) {
        // Set default state for first-time users
        await _storage.saveUserType('protestor');
        await _storage.saveIsFirstTime(true);
      } else {}
    } catch (e) {
      // Fallback: ensure we have some state even if initialization fails
      try {
        await _storage.saveUserType('protestor');
        await _storage.saveIsFirstTime(true);
      } catch (fallbackError) {}
    }
  }

  /// Check if app state is properly initialized
  static Future<bool> isStateInitialized() async {
    try {
      final userType = await _storage.readUserType();
      return userType != null;
    } catch (e) {
      return false;
    }
  }
}
