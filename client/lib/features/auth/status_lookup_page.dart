import 'package:flutter/material.dart';
import '../../core/themes/theme_exports.dart';
import '../../core/widgets/app_chip.dart';
import '../../core/widgets/buttons/app_button.dart';
import '../../core/router/app_router.dart';

class StatusLookupPage extends StatefulWidget {
  const StatusLookupPage({super.key});

  @override
  State<StatusLookupPage> createState() => _StatusLookupPageState();
}

class _StatusLookupPageState extends State<StatusLookupPage> {
  String? _selected; // 'new' | 'check'

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeColors.backgroundPrimary(context),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(
            left: 16,
            right: 16,
            top: 8,
            bottom: 32,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Transform.rotate(
                  angle: -0.1745,
                  child: const AppChip(
                    label: 'Get verified',
                    backgroundColor: AppColors.lemon,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // The two buttons container takes the remaining space
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 16,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AppButton.secondary(
                        text: 'Submit a new application',
                        isFullWidth: true,
                        leftIcon: Image.asset(
                          'assets/icons/new_application.png',
                        ),
                        textAlign: TextAlign.left,
                        rightIcon: _selected == 'new'
                            ? Image.asset('assets/icons/check-circle.png')
                            : null,
                        onPressed: () {
                          setState(() => _selected = 'new');
                        },
                      ),
                      const SizedBox(height: 16),
                      AppButton.secondary(
                        text: 'Check application status',
                        isFullWidth: true,
                        leftIcon: Image.asset('assets/icons/check_status.png'),
                        textAlign: TextAlign.left,
                        rightIcon: _selected == 'check'
                            ? Image.asset('assets/icons/check-circle.png')
                            : null,
                        onPressed: () {
                          setState(() => _selected = 'check');
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // Bottom button with natural (hug) height from the design system
              AppButton.primary(
                text: 'Continue',
                isFullWidth: true,
                onPressed: () async {
                  if (_selected == 'new') {
                    await context.pushToCountrySelectionForOrg();
                  } else if (_selected == 'check') {
                    // Placeholder until decision; keep user on the page
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Coming soon'),
                        duration: Duration(milliseconds: 900),
                      ),
                    );
                  } else {
                    // No selection feedback
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please choose an option'),
                        duration: Duration(milliseconds: 900),
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
