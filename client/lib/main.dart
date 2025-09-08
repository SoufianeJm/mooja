import 'package:flutter/material.dart';
import 'shared/themes/theme_exports.dart';
import 'shared/widgets/inputs/app_input.dart';

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
      home: const InputDemoScreen(),
    );
  }
}

class InputDemoScreen extends StatefulWidget {
  const InputDemoScreen({super.key});

  @override
  State<InputDemoScreen> createState() => _InputDemoScreenState();
}

class _InputDemoScreenState extends State<InputDemoScreen> {
  final TextEditingController _filledController = TextEditingController(text: 'hello@example.com');
  final TextEditingController _errorController = TextEditingController(text: 'invalid');

  @override
  void dispose() {
    _filledController.dispose();
    _errorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Input Field Demo', style: AppTypography.h3SemiBold),
        actions: [
          IconButton(
            icon: Icon(context.isDark ? Icons.light_mode : Icons.dark_mode),
            onPressed: () {
              // This would toggle theme in a real app
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.s5.p,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Input States', style: AppTypography.bodySubSemiBold),
            AppSpacing.v4,
            
            // Default state
            const AppInput(
              label: 'Email',
              hintText: 'Enter your email',
              helperText: 'This is a hint text to help the user.',
            ),
            
            AppSpacing.v5,
            
            // Filled state
            AppInput(
              label: 'Filled Input',
              controller: _filledController,
              helperText: 'This field has content',
            ),
            
            AppSpacing.v5,
            
            // Error state
            AppInput(
              label: 'Error State',
              controller: _errorController,
              errorText: 'Please enter a valid email address',
            ),
            
            AppSpacing.v6,
            const Divider(),
            AppSpacing.v6,
            
            Text('With Icons', style: AppTypography.bodySubSemiBold),
            AppSpacing.v4,
            
            // With prefix icon
            const AppInput(
              label: 'Search',
              hintText: 'Search here...',
              prefixIcon: Icon(Icons.search),
            ),
            
            AppSpacing.v5,
            
            // With suffix icon
            const AppInput(
              label: 'Password',
              hintText: 'Enter password',
              obscureText: true,
              suffixIcon: Icon(Icons.visibility),
            ),
            
            AppSpacing.v5,
            
            // With both icons
            const AppInput(
              label: 'Amount',
              hintText: '0.00',
              prefixIcon: Icon(Icons.attach_money),
              suffixIcon: Icon(Icons.calculate),
              keyboardType: TextInputType.number,
            ),
            
            AppSpacing.v6,
            const Divider(),
            AppSpacing.v6,
            
            Text('Other Variations', style: AppTypography.bodySubSemiBold),
            AppSpacing.v4,
            
            // Disabled state
            const AppInput(
              label: 'Disabled',
              hintText: 'This field is disabled',
              enabled: false,
            ),
            
            AppSpacing.v5,
            
            // Multiline
            const AppInput(
              label: 'Description',
              hintText: 'Enter a description...',
              maxLines: 3,
            ),
            
            AppSpacing.v5,
            
            // Without label
            const AppInput(
              hintText: 'Input without label',
              prefixIcon: Icon(Icons.person),
            ),
          ],
        ),
      ),
    );
  }
}
