import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../core/themes/theme_exports.dart';
import '../../core/widgets/buttons/app_button.dart';
import '../../core/widgets/buttons/app_back_button.dart';
import '../../core/widgets/inputs/app_input.dart';
import '../../core/widgets/app_chip.dart';
import '../../core/router/app_router.dart';
import '../../core/di/service_locator.dart';
import '../../core/services/storage_service.dart';
import 'verification_cubit.dart';

class OrganizationNamePage extends StatefulWidget {
  const OrganizationNamePage({super.key});

  @override
  State<OrganizationNamePage> createState() => _OrganizationNamePageState();
}

class _OrganizationNamePageState extends State<OrganizationNamePage> {
  final TextEditingController _organizationNameController =
      TextEditingController();
  bool _isLoading = false;
  String? _errorText;

  @override
  void dispose() {
    _organizationNameController.dispose();
    super.dispose();
  }

  void _handleContinue() {
    final organizationName = _organizationNameController.text.trim();

    // Validate input
    if (organizationName.isEmpty) {
      setState(() {
        _errorText = 'Please enter your organization name';
      });
      return;
    }

    if (organizationName.length < 2) {
      setState(() {
        _errorText = 'Organization name must be at least 2 characters';
      });
      return;
    }

    // Clear any previous errors
    setState(() {
      _errorText = null;
      _isLoading = true;
    });

    // Persist org name and navigate
    final storage = sl<StorageService>();
    storage.savePendingOrgName(organizationName).whenComplete(() async {
      await sl<VerificationCubit>().setOrgName(organizationName);
      if (!mounted) return;
      setState(() => _isLoading = false);
      context.pushToSocialMediaSelection();
    });
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
                          label: 'step 02',
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
                      'Organization\'s name',
                      style: AppTypography.h1SemiBold.copyWith(
                        color: ThemeColors.textPrimary(context),
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 24),

                    // Input field
                    AppInput(
                      controller: _organizationNameController,
                      hintText: 'What\'s your organization\'s name ?',
                      keyboardType: TextInputType.text,
                      autofocus: true,
                      errorText: _errorText,
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
