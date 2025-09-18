import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../core/themes/theme_exports.dart';
import '../../core/widgets/app_chip.dart';
import '../../core/widgets/inputs/app_input.dart';
import '../../core/widgets/buttons/app_button.dart';
import '../../core/widgets/buttons/app_back_button.dart';
import '../../core/di/service_locator.dart';
import '../../core/services/storage_service.dart';
import '../../core/services/api_service.dart';
import '../../core/router/app_router.dart';

class CodeVerificationPage extends StatefulWidget {
  const CodeVerificationPage({super.key});

  @override
  State<CodeVerificationPage> createState() => _CodeVerificationPageState();
}

class _CodeVerificationPageState extends State<CodeVerificationPage> {
  final TextEditingController _codeController = TextEditingController();
  bool _isLoading = false;
  String? _errorText;
  int _retryCount = 0;
  static const int _maxRetries = 3;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  void _clearError() {
    if (_errorText != null) {
      setState(() => _errorText = null);
    }
  }

  Future<void> _handleVerify() async {
    final code = _codeController.text.trim();

    // Input validation
    if (code.isEmpty) {
      setState(() => _errorText = 'Please enter your verification code');
      return;
    }

    // Code format validation
    if (code.length < 4) {
      setState(
        () => _errorText = 'Verification code must be at least 4 characters',
      );
      return;
    }

    // Check retry limit
    if (_retryCount >= _maxRetries) {
      setState(
        () => _errorText = 'Too many failed attempts. Please try again later.',
      );
      return;
    }

    setState(() {
      _errorText = null;
      _isLoading = true;
    });

    try {
      final apiService = sl<ApiService>();
      final storage = sl<StorageService>();

      // Get the application ID from storage
      final applicationId = await storage.readPendingApplicationId();

      if (applicationId == null || applicationId.isEmpty) {
        setState(() {
          _errorText =
              'Application not found. Please restart the verification process.';
          _isLoading = false;
        });
        return;
      }

      // Verify the code with the backend using new public endpoint
      final result = await apiService.verifyOrgCode(
        applicationId: applicationId,
        inviteCode: code,
      );

      if (!mounted) return;

      // Code verification successful - extract organization data
      final orgData = result['org'] as Map<String, dynamic>?;
      final orgUsername = orgData?['username'] as String?;

      if (orgUsername == null || orgUsername.isEmpty) {
        // Fallback: use stored username if backend doesn't return one
        final storedUsername = await storage.readPendingOrgUsername();
        if (!mounted) return;

        if (storedUsername == null || storedUsername.isEmpty) {
          setState(() {
            _errorText =
                'Verification successful but organization data is missing. Please try again.';
            _isLoading = false;
          });
          return;
        }

        context.goToOrgRegistration(prefilledUsername: storedUsername);
      } else {
        // Use the username returned from verification
        context.goToOrgRegistration(prefilledUsername: orgUsername);
      }
    } on ApiError catch (e) {
      if (!mounted) return;

      // Increment retry count for failed attempts
      _retryCount++;

      // Handle specific API errors
      String errorMessage;
      switch (e.statusCode) {
        case 400:
          errorMessage =
              'Invalid verification code. Please check and try again.';
          if (_retryCount < _maxRetries) {
            errorMessage +=
                ' (${_maxRetries - _retryCount} attempts remaining)';
          }
          break;
        case 404:
          errorMessage = 'Verification code not found or has expired.';
          break;
        case 410:
          errorMessage = 'This verification code has already been used.';
          break;
        case 408:
          errorMessage =
              'Connection timeout. Please check your internet connection.';
          break;
        default:
          errorMessage = e.message.isNotEmpty
              ? e.message
              : 'Failed to verify code. Please try again.';
      }

      setState(() {
        _errorText = errorMessage;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      // Handle unexpected errors
      setState(() {
        _errorText = 'Something went wrong. Please try again.';
        _isLoading = false;
      });

      // Log the error for debugging but don't show technical details to user
      debugPrint('Code verification error: $e');
    }
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
                          label: 'step 05',
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
                      'Enter your verification code',
                      style: AppTypography.h1SemiBold.copyWith(
                        color: ThemeColors.textPrimary(context),
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 24),

                    AppInput(
                      controller: _codeController,
                      hintText: 'Enter verification code',
                      keyboardType: TextInputType.text,
                      textCapitalization: TextCapitalization.characters,
                      autofocus: true,
                      errorText: _errorText,
                      onChanged: (_) =>
                          _clearError(), // Clear error when user starts typing
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
                      text: 'By tapping Get verified, you agree to our ',
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
                    text: 'Get verified',
                    onPressed: _isLoading ? null : _handleVerify,
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
