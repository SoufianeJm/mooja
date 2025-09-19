import '../services/storage_service.dart';
import '../di/service_locator.dart';

/// Prevents invalid navigation combinations that could cause loops or unexpected behavior
class NavigationGuard {
  static final StorageService _storage = sl<StorageService>();

  /// Check if navigation from one route to another is valid
  static Future<bool> canNavigate(String from, String to) async {
    // Prevent redirect loops
    if (from == to) {
      return false;
    }

    // Prevent problematic navigation patterns
    if (from == '/home/protestor' && to == '/intro') {
      return false;
    }
    if (from == '/home/organization' && to == '/intro') {
      return false;
    }

    // Check first-time user restrictions
    final isFirstTime = await _storage.readIsFirstTime();

    if (isFirstTime == true) {
      // First-time users should only go to onboarding routes
      final allowedFirstTimeRoutes = [
        '/intro',
        '/country-selection',
        '/organization-name',
        '/social-media-selection',
        '/social-username',
        '/verification-timeline',
        '/status-lookup',
        '/code-verification',
        '/org-registration',
        '/login',
        '/signup',
      ];

      if (!allowedFirstTimeRoutes.contains(to)) {
        return false;
      }
    }

    // Check user type restrictions
    final userType = await _storage.readUserType();

    if (userType == 'protestor' && to == '/intro') {
      return false;
    }
    return true;
  }

  /// Get a safe fallback route if navigation is invalid
  static Future<String> getSafeRoute() async {
    final isFirstTime = await _storage.readIsFirstTime();
    final userType = await _storage.readUserType();

    if (isFirstTime == true) {
      return '/intro';
    } else if (userType == 'protestor') {
      return '/home/protestor';
    } else if (userType == 'org') {
      return '/home/organization';
    } else {
      return '/intro';
    }
  }

  /// Log navigation for debugging
  static void logNavigation(String from, String to, String reason) {
    // no-op in production
  }
}
