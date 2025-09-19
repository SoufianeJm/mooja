import 'package:flutter/material.dart';
import '../../../core/themes/theme_exports.dart';
import '../../../core/widgets/buttons/app_button.dart';
import '../../../core/widgets/app_chip.dart';

class NotEligibleModal extends StatelessWidget {
  const NotEligibleModal({super.key, this.fromFeed = false});

  final bool fromFeed;

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewPadding.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + bottomPadding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header with chip and message
          Column(
            children: [
              AppChip(
                label: 'You are not eligible',
                backgroundColor: const Color(0xFFD1F2EB),
              ),
              const SizedBox(height: 8),
              Text(
                'Currently only organizations can\nadd or promote protest',
                style: AppTypography.bodyMedium.copyWith(
                  color: Colors.black.withValues(alpha: 0.5),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Button
          AppButton.primary(
            text: fromFeed ? 'Go back to Feed' : 'Go back to Intro screen',
            onPressed: () {
              Navigator.of(context).pop();
            },
            isFullWidth: true,
          ),
        ],
      ),
    );
  }
}
