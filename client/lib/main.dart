import 'package:flutter/material.dart';
import 'shared/themes/theme_exports.dart';
import 'features/intro/intro_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mooja',
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.light,  // Default to light mode
      debugShowCheckedModeBanner: false,  // Remove debug banner
      home: const IntroPage(),
    );
  }
}
