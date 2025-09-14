import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/themes/theme_exports.dart';
import '../../core/router/app_router.dart';
import '../../core/services/storage_service.dart';
import '../../core/di/service_locator.dart';
import '../auth/country_selection_page.dart';
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
      if (result == true) {
        // User confirmed they have an organization
        // Navigate to organization login/registration
        context.goToLogin();
      } else if (result == false) {
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
      backgroundColor: ThemeColors.backgroundPrimary(context),
      body: SafeArea(
        child: Padding(
          padding: 24.p,
          child: Column(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // App Logo/Icon
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: AppColors.lavender900,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Icon(
                        Icons.handshake,
                        size: 60,
                        color: Colors.white,
                      ),
                    ),
                    32.v,

                    // Welcome Text
                    Text(
                      'Welcome to Mooja',
                      style: AppTypography.h1SemiBold.copyWith(
                        color: ThemeColors.textPrimary(context),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    16.v,

                    Text(
                      'Connect with protests and organizations in your area',
                      style: AppTypography.bodyMedium.copyWith(
                        color: ThemeColors.textSecondary(context),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              // Action Buttons
              Column(
                children: [
                  // Continue as Protestor Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        context.goToCountrySelection();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.lavender900,
                        foregroundColor: Colors.white,
                        padding: 16.pv,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Continue as Protestor',
                        style: AppTypography.bodyMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  16.v,

                  // Continue as Organization Button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: _showOrgVerificationModal,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.lavender900,
                        side: BorderSide(
                          color: AppColors.lavender900,
                          width: 1.5,
                        ),
                        padding: 16.pv,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Continue as Organization',
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.lavender900,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
