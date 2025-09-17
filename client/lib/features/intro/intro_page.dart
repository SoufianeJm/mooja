import 'package:flutter/material.dart';
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
    print('DEBUG: Starting _maybeRedirect');
    final isFirstTime = await _storage.readIsFirstTime();
    final userType = await _storage.readUserType();
    print('DEBUG: isFirstTime: $isFirstTime, userType: $userType');

    if (!mounted) {
      print('DEBUG: Widget not mounted, returning');
      return;
    }

    if (!isFirstTime && userType == 'protestor') {
      print('DEBUG: Redirecting to home');
      context.goToHome();
      return;
    }

    print('DEBUG: Setting _isCheckingStorage to false');
    setState(() {
      _isCheckingStorage = false;
    });
  }

  void _showOrgVerificationModal() {
    print('DEBUG: Showing org verification modal');
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const OrgVerificationModal(),
    ).then((result) {
      print('DEBUG: Modal result: $result');
      if (result == 'yes') {
        // User confirmed they have an organization
        // Navigate to organization login/registration
        print('DEBUG: Navigating to login');
        context.goToLogin();
      } else if (result == 'no') {
        // User said they don't have an organization
        print('DEBUG: Showing not eligible modal');
        _showNotEligibleModal();
      }
    });
  }

  void _showNotEligibleModal() {
    print('DEBUG: Showing not eligible modal from intro');
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
                        print('DEBUG: Protestor button pressed');
                        print('DEBUG: Context mounted: $mounted');
                        print(
                          'DEBUG: goToCountrySelection method exists: ${context.goToCountrySelection}',
                        );
                        // Navigate to country selection for protestor flow
                        try {
                          context.goToCountrySelection();
                          print(
                            'DEBUG: goToCountrySelection called successfully',
                          );
                        } catch (e) {
                          print(
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
                        print('DEBUG: Organization button pressed');
                        print('DEBUG: Context mounted: $mounted');
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
