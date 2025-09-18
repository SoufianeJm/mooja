import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../core/themes/theme_exports.dart';
import '../../core/widgets/buttons/app_button.dart';
import '../../core/router/app_router.dart';
import '../../core/services/storage_service.dart';
import '../../core/di/service_locator.dart';
import 'widgets/org_verification_modal.dart';
import 'widgets/not_eligible_modal.dart';

class IntroPage extends StatefulWidget {
  const IntroPage({super.key});

  @override
  State<IntroPage> createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> {
  late final StorageService _storage;
  bool _isCheckingStorage = true;

  @override
  void initState() {
    super.initState();
    _storage = sl<StorageService>();
    _maybeRedirect();
  }

  Future<void> _maybeRedirect() async {
    if (kDebugMode) debugPrint('DEBUG: Starting _maybeRedirect');
    final isFirstTime = await _storage.readIsFirstTime();
    final userType = await _storage.readUserType();
    final hasToken = await _storage.hasAuthToken();
    if (kDebugMode)
      debugPrint('DEBUG: isFirstTime: $isFirstTime, userType: $userType');

    if (!mounted) {
      if (kDebugMode) debugPrint('DEBUG: Widget not mounted, returning');
      return;
    }

    if (!isFirstTime && userType == 'protestor') {
      if (kDebugMode) debugPrint('DEBUG: Redirecting to home');
      context.goToHome();
      return;
    }

    // Bounce logged-in orgs away from intro on cold start
    if (!isFirstTime && userType == 'org' && hasToken) {
      if (kDebugMode)
        debugPrint(
          'DEBUG: Logged-in org detected on intro, redirecting to org feed',
        );
      context.goToOrganizationFeed();
      return;
    }

    if (kDebugMode) debugPrint('DEBUG: Setting _isCheckingStorage to false');
    setState(() {
      _isCheckingStorage = false;
    });
  }

  void _showOrgVerificationModal() {
    if (kDebugMode) debugPrint('DEBUG: Showing org verification modal');
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const OrgVerificationModal(),
    ).then((result) {
      if (!mounted) return;
      if (kDebugMode) debugPrint('DEBUG: Modal result: $result');
      if (result == 'yes') {
        if (!mounted) return;
        if (kDebugMode) debugPrint('DEBUG: Navigating to login');
        context.goToLogin();
      } else if (result == 'no') {
        if (!mounted) return;
        if (kDebugMode) debugPrint('DEBUG: Showing not eligible modal');
        _showNotEligibleModal();
      }
    });
  }

  void _showNotEligibleModal() {
    if (kDebugMode) debugPrint('DEBUG: Showing not eligible modal from intro');
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const NotEligibleModal(fromFeed: false),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isCheckingStorage) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: 18.pt,
          child: Column(
            children: [
              // Hero image
              Expanded(
                child: Padding(
                  padding: 32.ph,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: 40.radius,
                      image: const DecorationImage(
                        image: AssetImage('assets/images/intro.jpg'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),

              32.v,

              // Tagline
              Text(
                'Change begins\nright here.',
                style: AppTypography.h3SemiBold,
                textAlign: TextAlign.center,
              ),

              32.v,

              // Action buttons
              Padding(
                padding: 32.ph + 46.pb,
                child: Column(
                  children: [
                    AppButton.primary(
                      text: 'Continue as a protestor',
                      onPressed: () {
                        if (kDebugMode)
                          debugPrint('DEBUG: Protestor button pressed');
                        if (kDebugMode)
                          debugPrint('DEBUG: Context mounted: $mounted');
                        if (kDebugMode)
                          debugPrint(
                            'DEBUG: goToCountrySelection method exists: ${context.goToCountrySelection}',
                          );
                        // Navigate to country selection for protestor flow
                        try {
                          context.goToCountrySelection();
                          if (kDebugMode)
                            debugPrint(
                              'DEBUG: goToCountrySelection called successfully',
                            );
                        } catch (e) {
                          if (kDebugMode)
                            debugPrint(
                              'DEBUG: Error calling goToCountrySelection: $e',
                            );
                        }
                      },
                      isFullWidth: true,
                    ),

                    8.v,

                    AppButton.secondary(
                      text: 'Continue as an organization',
                      onPressed: () {
                        if (kDebugMode)
                          debugPrint('DEBUG: Organization button pressed');
                        if (kDebugMode)
                          debugPrint('DEBUG: Context mounted: $mounted');
                        _showOrgVerificationModal();
                      },
                      isFullWidth: true,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
