import '../services/storage_service.dart';
import '../di/service_locator.dart';
import 'package:flutter/foundation.dart';

/// Validates and recovers from corrupted or inconsistent app state
class StateValidator {
  static final StorageService _storage = sl<StorageService>();

  /// Check if the current app state is valid
  static Future<bool> isValid() async {
    try {
      final userType = await _storage.readUserType();

      // Basic validation - userType can be null
      if (userType == null) return false;

      // Validate user type values
      if (userType != 'protestor' && userType != 'org') return false;

      return true;
    } catch (e) {
      if (kDebugMode) debugPrint('STATE_VALIDATOR: Error validating state: $e');
      return false;
    }
  }

  /// Recover from corrupted state by resetting to safe defaults
  static Future<void> recover() async {
    if (kDebugMode)
      debugPrint('STATE_VALIDATOR: Recovering from corrupted state');

    try {
      // Reset to safe protestor state
      await _storage.saveUserType('protestor');
      await _storage.saveIsFirstTime(true);

      // Clear any corrupted org data
      await _storage.clearPendingOrgData();

      if (kDebugMode)
        debugPrint('STATE_VALIDATOR: State recovered successfully');
    } catch (e) {
      if (kDebugMode) debugPrint('STATE_VALIDATOR: Error during recovery: $e');
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
    if (!await isValid()) {
      if (kDebugMode)
        debugPrint('STATE_VALIDATOR: Invalid state detected, recovering...');
      await recover();
      return false;
    }
    return true;
  }
}
