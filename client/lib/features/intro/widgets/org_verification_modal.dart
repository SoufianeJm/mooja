import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../../core/themes/theme_exports.dart';
import '../../../core/widgets/buttons/app_button.dart';
import '../../../core/widgets/app_chip.dart';

class OrgVerificationModal extends StatelessWidget {
  const OrgVerificationModal({super.key});

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
          // Header with chip and question
          Column(
            children: [
              AppChip(
                label: 'Waitt...',
                backgroundColor: const Color(0xFFD1F2EB),
              ),
              const SizedBox(height: 8),
              Text(
                'Did you promote protests or engage in digital activism in the past 2 years ?',
                style: AppTypography.bodyMedium.copyWith(
                  color: Colors.black.withValues(alpha: 0.5),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Buttons
          Column(
            children: [
              AppButton.primary(
                text: 'Yes, I did',
                onPressed: () {
                  if (kDebugMode)
                    debugPrint(
                      'DEBUG: Org verification modal - Yes button pressed',
                    );
                  Navigator.of(context).pop('yes');
                },
                isFullWidth: true,
              ),
              const SizedBox(height: 8),
              AppButton.secondary(
                text: 'No, I did not',
                onPressed: () {
                  if (kDebugMode)
                    debugPrint(
                      'DEBUG: Org verification modal - No button pressed',
                    );
                  Navigator.of(context).pop('no');
                },
                isFullWidth: true,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
