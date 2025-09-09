import 'package:flutter/material.dart';

class AppChip extends StatelessWidget {
  final String label;
  final Color? backgroundColor;

  const AppChip({super.key, required this.label, this.backgroundColor});

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label),
      backgroundColor: backgroundColor,
      side: BorderSide.none,
    );
  }
}
