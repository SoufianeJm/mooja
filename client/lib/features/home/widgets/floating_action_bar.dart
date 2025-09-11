import 'package:flutter/material.dart';
import '../../../core/themes/theme_exports.dart';
import '../../../core/widgets/buttons/app_button.dart';

class FloatingActionBar extends StatelessWidget {
  final VoidCallback? onContributeTap;
  final VoidCallback? onAddTap;

  const FloatingActionBar({super.key, this.onContributeTap, this.onAddTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: AppRadius.md.radius,
          boxShadow: AppShadows.sm,
        ),
        child: Row(
          children: [
            Expanded(
              child: AppButton.primary(
                text: 'Contribute',
                onPressed: onContributeTap,
                isFullWidth: true,
              ),
            ),
            18.h,
            GestureDetector(
              onTap: onAddTap,
              child: Container(
                width: 55,
                height: 55,
                decoration: BoxDecoration(
                  color: ThemeColors.backgroundSecondary(context),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Center(
                  child: Opacity(
                    opacity: 0.5,
                    child: Image.asset(
                      'assets/icons/add.png',
                      width: 24,
                      height: 24,
                      color: ThemeColors.textPrimary(context),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
