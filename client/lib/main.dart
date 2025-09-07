import 'package:flutter/material.dart';
import 'shared/themes/theme_exports.dart';
import 'shared/widgets/buttons/app_button.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Button Demo',
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      home: const ButtonDemoScreen(),
    );
  }
}

class ButtonDemoScreen extends StatelessWidget {
  const ButtonDemoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Button Variants Demo', style: AppTypography.h3SemiBold),
        actions: [
          IconButton(
            icon: Icon(context.isDark ? Icons.light_mode : Icons.dark_mode),
            onPressed: () {
              // This would toggle theme in a real app
            },
          ),
        ],
      ),
      body: Padding(
        padding: AppSpacing.s5.p,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Basic Variants', style: AppTypography.bodySubSemiBold),
            AppSpacing.v4,

            // Primary Button
            AppButton.primary(
              text: 'Primary Button',
              onPressed: () => print('Primary pressed'),
            ),

            AppSpacing.v3,

            // Secondary Button
            AppButton.secondary(
              text: 'Secondary Button',
              onPressed: () => print('Secondary pressed'),
            ),

            AppSpacing.v3,

            // Tertiary Button
            AppButton.tertiary(
              text: 'Tertiary Button',
              onPressed: () => print('Tertiary pressed'),
            ),

            AppSpacing.v6,
            const Divider(),
            AppSpacing.v6,

            Text('With Icon & Alignment', style: AppTypography.bodySubSemiBold),
            AppSpacing.v4,

            // Secondary with left icon and left aligned text (like logout)
            AppButton.secondary(
              text: 'Logout',
              leftIcon: const Icon(Icons.logout),
              textAlign: TextAlign.left,
              onPressed: () => print('Logout pressed'),
            ),

            AppSpacing.v6,
            const Divider(),
            AppSpacing.v6,

            Text('States', style: AppTypography.bodySubSemiBold),
            AppSpacing.v4,

            // Loading State
            AppButton.primary(
              text: 'Loading...',
              isLoading: true,
              onPressed: () {},
            ),

            AppSpacing.v3,

            // Disabled State
            AppButton.primary(text: 'Disabled Button', onPressed: null),
          ],
        ),
      ),
    );
  }
}
