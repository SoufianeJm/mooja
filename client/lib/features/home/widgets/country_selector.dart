import 'package:flutter/material.dart';
import '../../../core/themes/theme_exports.dart';
import '../../../core/router/app_router.dart';
import '../../../core/constants/countries.dart';

class CountrySelector extends StatelessWidget {
  final Country? selectedCountry;
  
  const CountrySelector({
    super.key,
    this.selectedCountry,
  });

  @override
  Widget build(BuildContext context) {
    final country = selectedCountry ?? 
        kCountries.firstWhere(
          (c) => c.code == 'MA',
          orElse: () => kCountries.first,
        );

    return GestureDetector(
      onTap: () => context.goToCountrySelection(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 18,
              height: 18,
              alignment: Alignment.center,
              child: Text(
                country.flag,
                style: const TextStyle(fontSize: 16),
              ),
            ),
            8.h,
            Text(
              country.name,
              style: AppTypography.bodyMedium.copyWith(
                color: ThemeColors.textPrimary(context),
              ),
            ),
            8.h,
            Icon(
              Icons.keyboard_arrow_down,
              size: 18,
              color: ThemeColors.textPrimary(context),
            ),
          ],
        ),
      ),
    );
  }
}
