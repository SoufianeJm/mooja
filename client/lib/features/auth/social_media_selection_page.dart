import 'package:flutter/material.dart';
import '../../core/themes/theme_exports.dart';
import '../../core/widgets/buttons/app_button.dart';
import '../../core/widgets/inputs/app_dropdown.dart';

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

    // TODO: Navigate to next step
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Selected: $_selectedSocialMedia')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeColors.backgroundPrimary(context),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            children: [
              // Spacer to push content to center
              const Spacer(),

              // Step indicator
              Center(
                child: Transform.rotate(
                  angle: -0.1745, // -10 degrees in radians
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.lemon,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'step 01',
                      style: AppTypography.bodySubMedium.copyWith(
                        color: AppColors.lemon900,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

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

              const Spacer(),

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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
