import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppBackButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const AppBackButton({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return IconButton.filled(
      onPressed:
          onPressed ??
          () {
            if (GoRouter.of(context).canPop()) {
              context.pop();
            }
          },
      icon: const Icon(Icons.arrow_back, size: 22),
    );
  }
}
