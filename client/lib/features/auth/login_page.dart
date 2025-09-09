import 'package:flutter/material.dart';
import '../../shared/themes/theme_exports.dart';
import '../../shared/widgets/buttons/app_button.dart';
import '../../shared/widgets/inputs/app_input.dart';
import '../../shared/widgets/app_chip.dart';

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
                        label: 'step 01',
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
                      // TODO: Handle login
                    },
                    isFullWidth: true,
                  ),

                  AppButton.tertiary(
                    text: 'Create an account',
                    onPressed: () {
                      // TODO: Navigate to signup
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
