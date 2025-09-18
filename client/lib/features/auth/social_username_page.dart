import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../core/themes/theme_exports.dart';
import '../../core/widgets/buttons/app_button.dart';
import '../../core/widgets/buttons/app_back_button.dart';
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
    if (username.isEmpty) {
      setState(
        () => _errorText =
            'Please enter your ${widget.selectedSocialMedia} username',
      );
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
      // Navigate to timeline; mark fromIntro so app remembers returning user
      final normalized = username.startsWith('@') ? username : '@' + username;
      if (mounted) {
        context.goToVerificationTimeline(
          status: 'pending',
          username: normalized,
          fromIntro: true,
        );
      }
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

  // Removed strict validation; keep minimal helper if needed later

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
                          label: 'step 03',
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
                  ],
                ),
              ),
            ),

            // ===== Bottom group =====
            Padding(
              padding: 32.p,
              child: Column(
                children: [
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
