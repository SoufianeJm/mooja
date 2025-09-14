import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/themes/theme_exports.dart';
import '../../core/constants/countries.dart';
import '../../core/services/storage_service.dart';
import '../../core/di/service_locator.dart';

class CountrySelectionPage extends StatefulWidget {
  const CountrySelectionPage({super.key});

  @override
  State<CountrySelectionPage> createState() => _CountrySelectionPageState();
}

class _CountrySelectionPageState extends State<CountrySelectionPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  List<Country> _allCountries = kCountries;
  List<Country> _filteredCountries = [];
  Country? _selectedCountry;
  late final StorageService _storage;

  @override
  void initState() {
    super.initState();
    _storage = sl<StorageService>();
    _filteredCountries = _allCountries;
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredCountries = _allCountries
          .where(
            (country) =>
                country.name.toLowerCase().contains(query) ||
                country.code.toLowerCase().contains(query),
          )
          .toList();
    });
  }

  void _selectCountry(Country country) {
    setState(() {
      _selectedCountry = country;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeColors.backgroundPrimary(context),
      appBar: AppBar(
        backgroundColor: ThemeColors.backgroundPrimary(context),
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: ThemeColors.textPrimary(context),
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Select Country',
          style: AppTypography.h2SemiBold.copyWith(
            color: ThemeColors.textPrimary(context),
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: 24.p,
          child: Column(
            children: [
              // Search Bar
              Container(
                decoration: BoxDecoration(
                  color: ThemeColors.backgroundSecondary(context),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: ThemeColors.borderSecondary(
                      context,
                    ).withValues(alpha: 0.3),
                  ),
                ),
                child: TextField(
                  controller: _searchController,
                  focusNode: _searchFocusNode,
                  style: AppTypography.bodyMedium.copyWith(
                    color: ThemeColors.textPrimary(context),
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search countries...',
                    hintStyle: AppTypography.bodyMedium.copyWith(
                      color: ThemeColors.textSecondary(context),
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: ThemeColors.textSecondary(context),
                    ),
                    border: InputBorder.none,
                    contentPadding: 16.p,
                  ),
                ),
              ),

              24.v,

              // Countries List
              Expanded(
                child: ListView.builder(
                  itemCount: _filteredCountries.length,
                  itemBuilder: (context, index) {
                    final country = _filteredCountries[index];
                    final isSelected = _selectedCountry?.code == country.code;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.lavender900.withValues(alpha: 0.1)
                            : ThemeColors.backgroundSecondary(context),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.lavender900
                              : ThemeColors.borderSecondary(
                                  context,
                                ).withValues(alpha: 0.3),
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: ListTile(
                        onTap: () => _selectCountry(country),
                        leading: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: ThemeColors.backgroundPrimary(context),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              country.flag,
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                        title: Text(
                          country.name,
                          style: AppTypography.bodyMedium.copyWith(
                            color: ThemeColors.textPrimary(context),
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                        subtitle: Text(
                          country.code,
                          style: AppTypography.bodyMedium.copyWith(
                            color: ThemeColors.textSecondary(context),
                            fontSize: 12,
                          ),
                        ),
                        trailing: isSelected
                            ? Icon(
                                Icons.check_circle,
                                color: AppColors.lavender900,
                                size: 24,
                              )
                            : null,
                      ),
                    );
                  },
                ),
              ),

              24.v,

              // Continue Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _selectedCountry != null
                      ? () {
                          _storage.saveSelectedCountryCode(
                            _selectedCountry!.code,
                          );
                          _storage.saveUserType('protestor');
                          _storage.saveIsFirstTime(false);

                          if (Navigator.of(context).canPop()) {
                            Navigator.of(context).pop(_selectedCountry);
                          } else {
                            context.go('/home/protestor');
                          }
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selectedCountry != null
                        ? AppColors.lavender900
                        : ThemeColors.borderSecondary(context),
                    foregroundColor: _selectedCountry != null
                        ? Colors.white
                        : ThemeColors.textSecondary(context),
                    padding: 16.pv,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Continue',
                    style: AppTypography.bodyMedium.copyWith(
                      color: _selectedCountry != null
                          ? Colors.white
                          : ThemeColors.textSecondary(context),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
