import 'package:flutter/material.dart';
import '../../shared/themes/theme_exports.dart';
import '../../shared/widgets/buttons/app_button.dart';
import '../../core/router/app_router.dart';

class IntroPage extends StatelessWidget {
  const IntroPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: 18.pt,
          child: Column(
            children: [
              // Hero image
              Expanded(
                child: Padding(
                  padding: 32.ph,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: 40.radius,
                      image: const DecorationImage(
                        image: AssetImage('assets/images/intro.jpg'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),

              32.v,

              // Tagline
              Text(
                'Change begins\nright here.',
                style: AppTypography.h3SemiBold,
                textAlign: TextAlign.center,
              ),

              32.v,

              // Action buttons
              Padding(
                padding: 32.ph + 46.pb,
                child: Column(
                  children: [
                    AppButton.primary(
                      text: 'Continue as a protestor',
                      onPressed: () {
                        // TODO: Navigate to protestor registration when built
                        // For now, go to login
                        context.goToLogin();
                      },
                      isFullWidth: true,
                    ),

                    8.v,

                    AppButton.secondary(
                      text: 'Continue as an organization',
                      onPressed: () {
                        // Navigate to organization login
                        context.goToLogin();
                      },
                      isFullWidth: true,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
