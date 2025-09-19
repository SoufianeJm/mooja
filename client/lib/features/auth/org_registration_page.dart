import 'package:flutter/material.dart';
import '../../core/themes/theme_exports.dart';
import '../../core/widgets/app_chip.dart';
import '../../core/widgets/inputs/app_input.dart';
import '../../core/widgets/buttons/app_button.dart';
import '../../core/router/app_router.dart';
import '../../core/di/service_locator.dart';
import '../../core/services/api_service.dart';
import '../../core/services/storage_service.dart';
import '../../core/services/user_context_service.dart';
import '../../core/domain/domain_objects.dart';

class OrgRegistrationPage extends StatefulWidget {
  final String? prefilledUsername;
  const OrgRegistrationPage({super.key, this.prefilledUsername});

  @override
  State<OrgRegistrationPage> createState() => _OrgRegistrationPageState();
}

class _OrgRegistrationPageState extends State<OrgRegistrationPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.prefilledUsername != null &&
        widget.prefilledUsername!.isNotEmpty) {
      _usernameController.text = widget.prefilledUsername!;
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();
    final confirm = _confirmController.text.trim();

    if (username.isEmpty || password.isEmpty || confirm.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    if (username.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Username must be at least 3 characters')),
      );
      return;
    }

    if (password.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password must be at least 8 characters')),
      );
      return;
    }

    if (password != confirm) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Passwords do not match')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final apiService = sl<ApiService>();
      final storage = sl<StorageService>();

      // Get stored org data
      final orgName = await storage.readPendingOrgName();
      final country = await storage.readSelectedCountryCode();
      final applicationId = await storage.readPendingApplicationId();

      if (orgName == null || country == null || applicationId == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Organization data missing. Please restart the process.',
            ),
          ),
        );
        setState(() => _isLoading = false);
        return;
      }

      // Register the organization account by application id
      final response = await apiService.registerWithApplicationId(
        applicationId: ApplicationId(applicationId),
        username: Username(username),
        password: Password(password),
      );

      if (!mounted) return;

      // Use UserContextService for transaction safety
      final userContext = sl<UserContextService>();

      if (response['accessToken'] != null) {
        await userContext.completeOrgVerification(
          token: response['accessToken'],
          refreshToken: response['refreshToken'] ?? '',
        );
      }

      if (mounted) {
        // Navigate to organization feed
        context.goToOrganizationFeed();
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration failed: ${e.toString()}')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: ThemeColors.backgroundPrimary(context),
      body: SafeArea(
        child: Padding(
          padding: 32.p,
          child: Column(
            children: [
              // Content section (login-like layout)
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    16.v,
                    Transform.rotate(
                      angle: -10 * 3.14159 / 180,
                      child: AppChip(
                        label: 'Create account',
                        backgroundColor: AppColors.lemon,
                      ),
                    ),
                    16.v,
                    Text(
                      'Set your credentials',
                      style: AppTypography.h1SemiBold,
                      textAlign: TextAlign.center,
                    ),
                    16.v,
                    AppInput(
                      label: 'Username',
                      hintText: 'Pick a username',
                      controller: _usernameController,
                      keyboardType: TextInputType.text,
                    ),
                    16.v,
                    AppInput(
                      label: 'Password',
                      hintText: 'Minimum 8 characters',
                      controller: _passwordController,
                      obscureText: true,
                    ),
                    16.v,
                    AppInput(
                      label: 'Confirm password',
                      hintText: 'Re-enter your password',
                      controller: _confirmController,
                      obscureText: true,
                    ),
                  ],
                ),
              ),
              AppButton.primary(
                text: 'Finish',
                onPressed: _isLoading ? null : _handleRegister,
                isFullWidth: true,
                isLoading: _isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
