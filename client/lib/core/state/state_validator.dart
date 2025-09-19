import '../services/storage_service.dart';
import '../di/service_locator.dart';

/// Validates and recovers from corrupted or inconsistent app state
class StateValidator {
  static final StorageService _storage = sl<StorageService>();

  /// Check if the current app state is valid
  static Future<bool> isValid() async {
    try {
      final userType = await _storage.readUserType();

      // If userType is null, this might be a first-time user before initialization
      // This is now handled by AppInitializer, so we should not warn here
      if (userType == null) return false;

      // Validate user type values
      if (userType != 'protestor' && userType != 'org') return false;

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Recover from corrupted state by resetting to safe defaults
  static Future<void> recover() async {
    try {
      // Reset to safe protestor state
      await _storage.saveUserType('protestor');
      await _storage.saveIsFirstTime(true);

      // Clear any corrupted org data
      await _storage.clearPendingOrgData();
    } catch (e) {
      // If recovery fails, clear everything
      await _storage.clear();
      await _storage.saveUserType('protestor');
      await _storage.saveIsFirstTime(true);
    }
  }

  /// Get current state summary for debugging
  static Future<Map<String, dynamic>> getStateSummary() async {
    try {
      return {
        'userType': await _storage.readUserType(),
        'isFirstTime': await _storage.readIsFirstTime(),
        'country': await _storage.readSelectedCountryCode(),
        'hasAuthToken': await _storage.hasAuthToken(),
        'pendingOrgName': await _storage.readPendingOrgName(),
        'pendingApplicationId': await _storage.readPendingApplicationId(),
      };
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  /// Validate state before critical operations
  static Future<bool> validateBeforeNavigation() async {
    try {
      final userType = await _storage.readUserType();

      // If userType is null, this is likely a first-time user before proper initialization
      // Don't show warning as this is expected behavior
      if (userType == null) {
        await recover();
        return false;
      }

      // Check if state is valid
      if (!await isValid()) {
        await recover();
        return false;
      }

      return true;
    } catch (e) {
      await recover();
      return false;
    }
  }
}
