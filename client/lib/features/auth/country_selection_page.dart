import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' as math;
import '../../shared/themes/theme_exports.dart';
import '../../shared/widgets/buttons/app_button.dart';
import '../../shared/widgets/inputs/app_input.dart';
import '../../shared/widgets/app_chip.dart';
import '../../core/constants/countries.dart';

class CountrySelectionPage extends StatefulWidget {
  const CountrySelectionPage({super.key});

  @override
  State<CountrySelectionPage> createState() => _CountrySelectionPageState();
}

class _CountrySelectionPageState extends State<CountrySelectionPage> {
  // Layout constants
  static const double _listBottomPaddingClosed = 180;
  static const double _listBottomPaddingOpen = 20;
  static const double _gradientOverlayHeight = 100;
  
  final _searchController = TextEditingController();
  Timer? _debounceTimer;

  // Use countries from the constants file
  final List<Country> _allCountries = kCountries;

  List<Country> _filteredCountries = [];
  Country? _selectedCountry;

  @override
  void initState() {
    super.initState();
    _filteredCountries = _allCountries;
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    // Cancel previous timer
    _debounceTimer?.cancel();

    // Start new timer
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      _filterCountries();
    });
  }

  void _filterCountries() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredCountries = _allCountries;
      } else {
        _filteredCountries = _allCountries
            .where((country) => country.name.toLowerCase().contains(query))
            .toList();
      }
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final keyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;
    
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: 32.ph,
                child: Column(
                  children: [
                    _buildHeader(),
                    16.v,
                    _buildSearchInput(),
                    8.v,
                    Expanded(
                      child: _buildCountryList(keyboardOpen),
                    ),
                  ],
                ),
              ),
            ),
            _buildBottomSection(keyboardOpen),
          ],
        ),
      ),
    );
  }
  
  Widget _buildHeader() {
    return Column(
      children: [
        16.v,
        // Rotated chip
        Transform.rotate(
          angle: -10 * math.pi / 180,
          child: AppChip(
            label: 'step 02',
            backgroundColor: AppColors.lemon,
          ),
        ),
        16.v,
        // Title
        Text(
          'Where are you from?',
          style: AppTypography.h1SemiBold,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
  
  Widget _buildSearchInput() {
    return AppInput(
      hintText: 'Search',
      controller: _searchController,
      suffixIcon: Image.asset(
        'assets/icons/search.png',
        width: 20,
        height: 20,
        color: AppColors.gray600,
        semanticLabel: 'Search',
      ),
    );
  }
  
  Widget _buildCountryList(bool keyboardOpen) {
    return Stack(
      children: [
        _filteredCountries.isEmpty
            ? _buildEmptyState()
            : _buildCountryListView(keyboardOpen),
        _buildGradientOverlay(keyboardOpen),
      ],
    );
  }
  
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 48,
            color: AppColors.gray400,
          ),
          16.v,
          Text(
            'No countries found',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.gray600,
            ),
          ),
          8.v,
          Text(
            'Try searching with a different term',
            style: AppTypography.bodySubMedium.copyWith(
              color: AppColors.gray400,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildCountryListView(bool keyboardOpen) {
    return ListView.separated(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: EdgeInsets.only(
        bottom: keyboardOpen ? _listBottomPaddingOpen : _listBottomPaddingClosed,
      ),
      itemCount: _filteredCountries.length,
      separatorBuilder: (context, index) => 8.v,
      itemBuilder: (context, index) => _buildCountryItem(_filteredCountries[index]),
    );
  }
  
  Widget _buildCountryItem(Country country) {
    // Compare by code to avoid reference equality issues
    final isSelected = _selectedCountry?.code == country.code;
    
    return AppButton.secondary(
      text: country.name,
      leftIcon: Text(
        country.flag,
        style: const TextStyle(fontSize: 18),
      ),
      rightIcon: isSelected
          ? Icon(
              Icons.check_circle,
              color: AppColors.lemon,
              size: 20,
            )
          : null,
      textAlign: TextAlign.left,
      onPressed: () {
        setState(() {
          _selectedCountry = country;
        });
      },
      isFullWidth: true,
    );
  }
  
  Widget _buildGradientOverlay(bool keyboardOpen) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: IgnorePointer(
        child: Container(
          height: keyboardOpen ? 0 : _gradientOverlayHeight,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0),
                Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0.7),
                Theme.of(context).scaffoldBackgroundColor,
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildBottomSection(bool keyboardOpen) {
    return Offstage(
      offstage: keyboardOpen,
      child: Container(
        padding: 32.p,
        child: Column(
          children: [
            // Terms text
            Text(
              'By selecting your country, we can show you\nprotests and movements happening near you',
              style: AppTypography.caption1Medium.copyWith(
                color: AppColors.gray600.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
            16.v,
            // Continue button
            AppButton.primary(
              text: 'Continue',
              onPressed: _selectedCountry != null
                  ? () {
                      // TODO: Navigate to next screen
                      // For now, show selected country
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Selected: ${_selectedCountry!.name} ${_selectedCountry!.flag}',
                          ),
                        ),
                      );
                    }
                  : null,
              isFullWidth: true,
            ),
          ],
        ),
      ),
    );
  }
}
