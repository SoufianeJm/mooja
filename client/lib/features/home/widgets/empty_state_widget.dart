import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../core/themes/theme_exports.dart';
import '../../../core/widgets/inputs/app_input.dart';
import '../../../core/constants/countries.dart';

class EmptyStateWidget extends StatelessWidget {
  final Country selectedCountry;
  final VoidCallback? onSuggestionSubmitted;

  const EmptyStateWidget({
    super.key,
    required this.selectedCountry,
    this.onSuggestionSubmitted,
  });

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
              'Oops, We are still looking for organizations in ${selectedCountry.flag}',
              style: AppTypography.h2SemiBold.copyWith(
                color: ThemeColors.textPrimary(context),
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 16),

            // Illustration
            SizedBox(
              height: 225,
              width: 250,
              child: SvgPicture.asset(
                'assets/images/waiting.svg',
                fit: BoxFit.contain,
              ),
            ),

            const SizedBox(height: 16),

            // Input field with heart icon
            AppInput(
              hintText: 'Know an org? Share it with us',
              enabled: false, // Disabled state as shown in design
              prefixIcon: Image.asset(
                'assets/icons/heart.png',
                width: 24,
                height: 24,
                color: ThemeColors.textPrimary(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
