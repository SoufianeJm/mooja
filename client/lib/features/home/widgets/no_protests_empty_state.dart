import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../core/themes/theme_exports.dart';
import '../../../core/constants/countries.dart';

class NoProtestsEmptyState extends StatelessWidget {
  final Country selectedCountry;

  const NoProtestsEmptyState({super.key, required this.selectedCountry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Title
            Text(
              'The protest calendar is currently… protest-free.',
              style: AppTypography.h2SemiBold.copyWith(
                color: ThemeColors.textPrimary(context),
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 16),

            // Illustration
            SizedBox(
              height: 250,
              width: 250,
              child: SvgPicture.asset(
                'assets/images/megaphone.svg',
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
