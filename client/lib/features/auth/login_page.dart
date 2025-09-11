import 'package:flutter/material.dart';
import '../../core/themes/theme_exports.dart';
import '../../core/widgets/buttons/app_button.dart';
import '../../core/widgets/inputs/app_input.dart';
import '../../core/widgets/app_chip.dart';
import '../../core/router/app_router.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
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
                        label: 'Login',
                        backgroundColor: AppColors.lemon,
                      ),
                    ),

                    16.v,

                    // Title
                    Text(
                      'Welcome back',
                      style: AppTypography.h1SemiBold,
                      textAlign: TextAlign.center,
                    ),

                    16.v,

                    // Email input
                    AppInput(
                      label: 'Email',
                      hintText: 'Enter your email',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                    ),

                    16.v,

                    // Password input
                    AppInput(
                      label: 'Password',
                      hintText: 'Enter your password',
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
                    text: 'Login',
                    onPressed: () {
                      // TODO: Implement actual login logic with API
                      // TODO: Navigate to home when home page is built
                      // For now, just show success
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Login functionality coming soon'),
                        ),
                      );
                    },
                    isFullWidth: true,
                  ),

                  AppButton.tertiary(
                    text: 'Create an account',
                    onPressed: () {
                      context.goToSignup();
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
