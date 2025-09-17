import 'storage_service.dart';
import 'auth_service.dart';

enum UserType { protestor, organization }

enum UserJourney { 
  firstTime,       // Brand new user
  protestorActive, // Using protestor features
  orgPending,      // Started org verification
  orgVerified      // Fully verified org user
}

/// Single source of truth for user state across all journeys
/// Prevents cross-journey state pollution and provides consistent user context
class UserContextService {
  final StorageService _storage;
  final AuthService _authService;
  
  UserContextService(this._storage, this._authService);

  /// Get current user journey state
  Future<UserJourney> getCurrentJourney() async {
    final isFirstTime = await _storage.readIsFirstTime();
    if (isFirstTime) return UserJourney.firstTime;
    
    final isLoggedIn = await _authService.isLoggedIn();
    if (isLoggedIn) return UserJourney.orgVerified;
    
    final hasOrgApplication = await _storage.readPendingApplicationId();
    if (hasOrgApplication != null) return UserJourney.orgPending;
    
    return UserJourney.protestorActive;
  }

  /// Switch to protestor journey (clear org-specific data)
  Future<void> switchToProtestorJourney() async {
    await _storage.saveUserType('protestor');
    await _storage.saveIsFirstTime(false);
    // Keep global preferences like selected country
  }

  /// Switch to organization journey (clear protestor-specific data if needed)
  Future<void> switchToOrgJourney() async {
    // Don't set user type yet - wait until verified
    // Keep global preferences like selected country
  }

  /// Complete organization verification
  Future<void> completeOrgVerification({
    required String token,
    required String refreshToken,
  }) async {
    // Transaction-like behavior: if any step fails, rollback all
    try {
      await _storage.saveAuthToken(token);
      await _storage.saveRefreshToken(refreshToken);
      await _storage.saveUserType('org');
      await _storage.saveIsFirstTime(false);
      await _storage.clearPendingOrgData();
    } catch (e) {
      // Rollback on any failure
      await _rollbackOrgVerification();
      rethrow;
    }
  }

  /// Clear all user data (logout)
  Future<void> clearAllUserData() async {
    await _authService.logout();
    // Keep only global preferences
    final country = await _storage.readSelectedCountryCode();
    await _storage.clear(); // This clears everything
    if (country != null) {
      await _storage.saveSelectedCountryCode(country);
    }
    await _storage.saveIsFirstTime(false); // They're not first-time anymore
  }

  /// Get user-specific country (org users might have different country than protestor preference)
  Future<String?> getUserCountry() async {
    final userType = await _storage.readUserType();
    if (userType == 'org') {
      // For orgs, country is part of their verification data
      return await _storage.readSelectedCountryCode();
    } else {
      // For protestors, use their selected preference
      return await _storage.readSelectedCountryCode();
    }
  }

  /// Check if user can access organization features
  Future<bool> canAccessOrgFeatures() async {
    return await _authService.isLoggedIn();
  }

  /// Get display context for UI
  Future<Map<String, dynamic>> getDisplayContext() async {
    final journey = await getCurrentJourney();
    final userType = await _storage.readUserType();
    final country = await getUserCountry();
    
    return {
      'journey': journey,
      'userType': userType,
      'country': country,
      'isLoggedIn': await _authService.isLoggedIn(),
      'isFirstTime': await _storage.readIsFirstTime(),
    };
  }

  /// Private method to rollback failed org verification
  Future<void> _rollbackOrgVerification() async {
    try {
      await _storage.deleteAuthToken();
      await _storage.deleteRefreshToken();
      // Don't clear user type if it was already set to something else
    } catch (e) {
      // Silent failure on rollback - already in error state
    }
  }
}