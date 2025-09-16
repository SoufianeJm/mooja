import 'package:flutter/material.dart';
import '../../core/themes/theme_exports.dart';
import '../../core/widgets/buttons/app_button.dart';
import '../../core/widgets/inputs/app_input.dart';
import '../../core/widgets/app_chip.dart';
import '../../core/services/api_service.dart';
import 'verification_cubit.dart';
import '../../core/di/service_locator.dart';
import '../../core/router/app_router.dart';

class SocialUsernamePage extends StatefulWidget {
  final String selectedSocialMedia;

  const SocialUsernamePage({super.key, required this.selectedSocialMedia});

  @override
  State<SocialUsernamePage> createState() => _SocialUsernamePageState();
}

class _SocialUsernamePageState extends State<SocialUsernamePage> {
  final TextEditingController _usernameController = TextEditingController();
  bool _isLoading = false;
  String? _errorText;

  static const _socialMediaData = {
    'instagram': {
      'icon': 'assets/images/instagram.png',
      'placeholder': 'What\'s your Instagram username?',
    },
    'twitter': {
      'icon': 'assets/images/x.png',
      'placeholder': 'What\'s your X (Twitter) username?',
    },
    'x': {
      'icon': 'assets/images/x.png',
      'placeholder': 'What\'s your X (Twitter) username?',
    },
    'facebook': {
      'icon': 'assets/images/facebook.png',
      'placeholder': 'What\'s your Facebook username?',
    },
  };

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  void _handleContinue() async {
    final username = _usernameController.text.trim();
    final error = _validateUsername(username);

    if (error != null) {
      setState(() => _errorText = error);
      return;
    }

    setState(() {
      _errorText = null;
      _isLoading = true;
    });

    try {
      // Use cubit from service locator to persist handle and submit
      final vc = sl<VerificationCubit>();
      vc.setHandle(username);
      await vc.submit();

      final err = vc.state.errorMessage;
      if (err != null) {
        throw ApiError(err);
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Application submitted. Status: pending')),
      );
      // Navigate to timeline
      if (mounted) context.goToVerificationTimeline(status: 'pending');
    } catch (e) {
      final message = e is ApiError
          ? e.message
          : 'Failed to submit application';
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String? _validateUsername(String username) {
    if (username.isEmpty)
      return 'Please enter your ${widget.selectedSocialMedia} username';
    if (username.length < 2) return 'Username must be at least 2 characters';
    return null;
  }

  String _getSocialMediaIconPath() {
    final key = widget.selectedSocialMedia.toLowerCase();
    return _socialMediaData[key]?['icon'] ?? 'assets/images/instagram.png';
  }

  String _getUsernamePlaceholder() {
    final key = widget.selectedSocialMedia.toLowerCase();
    return _socialMediaData[key]?['placeholder'] ?? 'What\'s your username?';
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
              const Spacer(),
              Center(
                child: Transform.rotate(
                  angle: -0.1745,
                  child: AppChip(
                    label: 'step 03',
                    backgroundColor: AppColors.lemon,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                "What is your ${widget.selectedSocialMedia}'s username?",
                style: AppTypography.h1SemiBold.copyWith(
                  color: ThemeColors.textPrimary(context),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              AppInput(
                controller: _usernameController,
                hintText: _getUsernamePlaceholder(),
                keyboardType: TextInputType.text,
                autofocus: true,
                errorText: _errorText,
                prefixIcon: Image.asset(
                  _getSocialMediaIconPath(),
                  width: 24,
                  height: 24,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.person,
                      size: 24,
                      color: ThemeColors.textSecondary(context),
                    );
                  },
                ),
              ),
              const Spacer(),
              Text.rich(
                TextSpan(
                  text: 'By tapping Verify, you are agreeing to our ',
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
              AppButton.primary(
                text: 'Verify',
                onPressed: _isLoading ? null : _handleContinue,
                isLoading: _isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
