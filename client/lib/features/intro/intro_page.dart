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
    final isFirstTime = await _storage.readIsFirstTime();
    final userType = await _storage.readUserType();

    if (!mounted) return;

    if (!isFirstTime && userType == 'protestor') {
      context.goToHome();
      return;
    }

    setState(() {
      _isCheckingStorage = false;
    });
  }

  void _showOrgVerificationModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const OrgVerificationModal(),
    ).then((result) {
      if (result == 'yes') {
        // User confirmed they have an organization
        // Navigate to organization login/registration
        context.goToLogin();
      } else if (result == 'no') {
        // User said they don't have an organization
        _showNotEligibleModal();
      }
    });
  }

  void _showNotEligibleModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const NotEligibleModal(),
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
                        // Navigate to country selection for protestor flow
                        context.goToCountrySelection();
                      },
                      isFullWidth: true,
                    ),

                    8.v,

                    AppButton.secondary(
                      text: 'Continue as an organization',
                      onPressed: _showOrgVerificationModal,
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
