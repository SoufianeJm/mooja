import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../core/themes/theme_exports.dart';
import '../../core/widgets/buttons/app_button.dart';
import '../../core/widgets/buttons/app_back_button.dart';
import '../../core/router/app_router.dart';
import '../../core/widgets/inputs/app_dropdown.dart';
import '../../core/widgets/app_chip.dart';
import '../../core/di/service_locator.dart';
import '../../core/services/storage_service.dart';
import 'verification_cubit.dart';

class SocialMediaSelectionPage extends StatefulWidget {
  const SocialMediaSelectionPage({super.key});

  @override
  State<SocialMediaSelectionPage> createState() =>
      _SocialMediaSelectionPageState();
}

class _SocialMediaSelectionPageState extends State<SocialMediaSelectionPage> {
  // Custom dropdown state
  String? _selectedSocialMedia;

  // Social media options with icons
  final List<AppDropdownItem<String>> _socialMediaOptions = [
    AppDropdownItem(
      value: 'instagram',
      label: 'Instagram',
      leftIcon: Image.asset(
        'assets/images/instagram.png',
        width: 22,
        height: 22,
        fit: BoxFit.contain,
      ),
    ),
    AppDropdownItem(
      value: 'facebook',
      label: 'Facebook',
      leftIcon: Image.asset(
        'assets/images/facebook.png',
        width: 22,
        height: 22,
        fit: BoxFit.contain,
      ),
    ),
    AppDropdownItem(
      value: 'x',
      label: 'X (Twitter)',
      leftIcon: Image.asset(
        'assets/images/x.png',
        width: 22,
        height: 22,
        fit: BoxFit.contain,
      ),
    ),
  ];

  void _handleContinue() {
    if (_selectedSocialMedia == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a social media platform')),
      );
      return;
    }

    // Navigate to username input screen
    final storage = sl<StorageService>();
    storage.savePendingSocialPlatform(_selectedSocialMedia!).whenComplete(
      () async {
        await sl<VerificationCubit>().setPlatform(_selectedSocialMedia!);
        if (!mounted) return;
        context.pushToSocialUsername(_selectedSocialMedia!);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeColors.backgroundPrimary(context),
      body: SafeArea(
        child: Column(
          children: [
            // ===== Header group =====
            Padding(
              padding: 32.ph + 16.pt,
              child: Row(
                children: [
                  const AppBackButton(),
                  Expanded(
                    child: Center(
                      child: Transform.rotate(
                        angle: -10 * math.pi / 180,
                        child: AppChip(
                          label: 'step 01',
                          backgroundColor: AppColors.lemon,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 52, height: 52),
                ],
              ),
            ),

            // ===== Content group (vertically centered) =====
            Expanded(
              child: Padding(
                padding: 32.ph,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Main title
                    Text(
                      'Where did you promote your protests before ?',
                      style: AppTypography.h1SemiBold.copyWith(
                        color: ThemeColors.textPrimary(context),
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 24),

                    // Custom Dropdown
                    AppDropdown<String>(
                      items: _socialMediaOptions,
                      value: _selectedSocialMedia,
                      hint: 'e.g Instagram',
                      rightIcon: Image.asset(
                        'assets/icons/down.png',
                        width: 22,
                        height: 22,
                        fit: BoxFit.contain,
                      ),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedSocialMedia = newValue;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),

            // ===== Bottom group =====
            Padding(
              padding: 32.p,
              child: Column(
                children: [
                  // Terms and conditions
                  Text.rich(
                    TextSpan(
                      text: 'By tapping Continue, you are agreeing to our ',
                      style: AppTypography.caption1Medium.copyWith(
                        color: ThemeColors.textSecondary(context),
                      ),
                      children: [
                        TextSpan(
                          text: 'Terms of Service',
                          style: AppTypography.caption1Medium.copyWith(
                            color: ThemeColors.textPrimary(context),
                          ),
                        ),
                        const TextSpan(text: ' and '),
                        TextSpan(
                          text: 'Privacy Policy',
                          style: AppTypography.caption1Medium.copyWith(
                            color: ThemeColors.textPrimary(context),
                          ),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 16),

                  // Continue button
                  AppButton.primary(
                    text: 'Continue',
                    onPressed: _selectedSocialMedia != null
                        ? _handleContinue
                        : null,
                    isFullWidth: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
