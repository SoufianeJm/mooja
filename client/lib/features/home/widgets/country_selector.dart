import 'package:flutter/material.dart';
import '../../../core/themes/theme_exports.dart';
import '../../../core/router/app_router.dart';
import '../../../core/constants/countries.dart';

class CountrySelector extends StatelessWidget {
  final Country? selectedCountry;
  final ValueChanged<Country?>? onCountryChanged;

  const CountrySelector({
    super.key,
    this.selectedCountry,
    this.onCountryChanged,
  });

  @override
  Widget build(BuildContext context) {
    final country =
        selectedCountry ??
        kCountries.firstWhere(
          (c) => c.code == 'MA',
          orElse: () => kCountries.first,
        );

    return GestureDetector(
      onTap: () {
        if (onCountryChanged != null) {
          // For now, just cycle through a few countries for demo
          // In a real app, this would open a country selection modal
          final currentIndex = kCountries.indexOf(country);
          final nextIndex = (currentIndex + 1) % kCountries.length;
          onCountryChanged!(kCountries[nextIndex]);
        } else {
          context.goToCountrySelection();
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 6),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 18,
              height: 18,
              alignment: Alignment.center,
              child: Text(country.flag, style: const TextStyle(fontSize: 16)),
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
