import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/themes/theme_exports.dart';
import '../../core/widgets/buttons/app_button.dart';
import '../../core/widgets/inputs/app_input.dart';
import '../../core/widgets/app_chip.dart';
import '../../core/router/app_router.dart';
import '../../core/di/service_locator.dart';
import 'bloc/auth_bloc.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  late final AuthBloc _authBloc;

  @override
  void initState() {
    super.initState();
    _authBloc = sl<AuthBloc>();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _authBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _authBloc,
      child: Scaffold(
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

                      // Username input
                      AppInput(
                        label: 'Username',
                        hintText: 'Enter your username',
                        controller: _usernameController,
                        keyboardType: TextInputType.text,
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
                BlocListener<AuthBloc, AuthState>(
                  listener: (context, state) {
                    if (state is AuthSuccess) {
                      // Navigate to organization dashboard
                      context.goToOrganizationFeed();
                    } else if (state is AuthFailure) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(state.message),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  child: BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      final isLoading = state is AuthLoading;

                      return Column(
                        children: [
                          AppButton.primary(
                            text: 'Login',
                            onPressed: isLoading ? null : _handleLogin,
                            isFullWidth: true,
                            isLoading: isLoading,
                          ),

                          AppButton.tertiary(
                            text: "Don't have an account? Get Verified",
                            onPressed: isLoading
                                ? null
                                : () {
                                    context.goToOrganizationName();
                                  },
                            isFullWidth: true,
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleLogin() {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all fields'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    _authBloc.add(LoginRequested(username: username, password: password));
  }
}
