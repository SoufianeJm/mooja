import 'package:flutter/material.dart';
import '../../core/themes/theme_exports.dart';
import '../../core/widgets/buttons/app_button.dart';
import '../../core/widgets/inputs/app_input.dart';
import '../../core/widgets/app_chip.dart';
import '../../core/router/app_router.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _organizationController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _organizationController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Padding(
          padding: 32.p,
          child: Column(
            children: [
              // Content section
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    16.v,

                    // Rotated chip
                    Transform.rotate(
                      angle: -10 * 3.14159 / 180,
                      child: AppChip(
                        label: 'Register',
                        backgroundColor: AppColors.lavender,
                      ),
                    ),

                    16.v,

                    // Title
                    Text(
                      'Create account',
                      style: AppTypography.h1SemiBold,
                      textAlign: TextAlign.center,
                    ),

                    16.v,

                    // Organization name input
                    AppInput(
                      label: 'Organization name',
                      hintText: 'Enter your organization name',
                      controller: _organizationController,
                      keyboardType: TextInputType.text,
                    ),

                    16.v,

                    // Username input
                    AppInput(
                      label: 'Username',
                      hintText: 'Choose a username',
                      controller: _usernameController,
                      keyboardType: TextInputType.text,
                    ),

                    16.v,

                    // Password input
                    AppInput(
                      label: 'Password',
                      hintText: 'Create a password',
                      controller: _passwordController,
                      obscureText: true,
                    ),
                  ],
                ),
              ),

              // Bottom buttons
              Column(
                children: [
                  AppButton.primary(
                    text: 'Continue',
                    onPressed: () {
                      context.goToCountrySelection();
                    },
                    isFullWidth: true,
                  ),

                  AppButton.tertiary(
                    text: 'Already have an account? Log in',
                    onPressed: () {
                      context.pushToLogin();
                    },
                    isFullWidth: true,
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
