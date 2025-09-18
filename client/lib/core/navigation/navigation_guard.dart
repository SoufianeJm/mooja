import '../services/storage_service.dart';
import '../di/service_locator.dart';

/// Prevents invalid navigation combinations that could cause loops or unexpected behavior
class NavigationGuard {
  static final StorageService _storage = sl<StorageService>();

  /// Check if navigation from one route to another is valid
  static Future<bool> canNavigate(String from, String to) async {
    print('NAV_GUARD: Checking navigation from "$from" to "$to"');

    // Prevent redirect loops
    if (from == to) {
      print('NAV_GUARD: Blocked - redirect loop (from == to)');
      return false;
    }

    // Prevent problematic navigation patterns
    if (from == '/home/protestor' && to == '/intro') {
      print('NAV_GUARD: Blocked - protestor trying to go to intro');
      return false;
    }
    if (from == '/home/organization' && to == '/intro') {
      print('NAV_GUARD: Blocked - org trying to go to intro');
      return false;
    }

    // Check first-time user restrictions
    final isFirstTime = await _storage.readIsFirstTime();
    print('NAV_GUARD: isFirstTime = $isFirstTime');

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

      print(
        'NAV_GUARD: Checking if "$to" is in allowed routes: ${allowedFirstTimeRoutes.contains(to)}',
      );

      if (!allowedFirstTimeRoutes.contains(to)) {
        print(
          'NAV_GUARD: Blocked - first-time user trying to access restricted route',
        );
        return false;
      }
    }

    // Check user type restrictions
    final userType = await _storage.readUserType();
    print('NAV_GUARD: userType = $userType');

    if (userType == 'protestor' && to == '/intro') {
      print('NAV_GUARD: Blocked - returning protestor trying to go to intro');
      return false;
    }

    print('NAV_GUARD: Navigation allowed');
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
    print('NAV_GUARD: $from → $to ($reason)');
  }
}
