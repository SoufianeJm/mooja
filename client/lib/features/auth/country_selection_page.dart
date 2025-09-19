import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' as math;
import '../../core/themes/theme_exports.dart';
import '../../core/widgets/buttons/app_button.dart';
import '../../core/widgets/buttons/app_back_button.dart';
import '../../core/widgets/inputs/app_input.dart';
import '../../core/widgets/app_chip.dart';
import '../../core/constants/countries.dart';
import '../../core/constants/flow_origin.dart';
import '../../core/router/app_router.dart';
import '../../core/services/storage_service.dart';
import '../../core/di/service_locator.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'verification_cubit.dart';

class CountrySelectionPage extends StatefulWidget {
  const CountrySelectionPage({
    super.key,
    this.forOrganizationFlow = false,
    this.stepLabel,
    this.origin = FlowOrigin.unknown,
  });

  final bool forOrganizationFlow;
  final String? stepLabel;
  final FlowOrigin origin;

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
  late final StorageService _storage;

  @override
  void initState() {
    super.initState();
    _storage = sl<StorageService>();
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
                    // Title moved to content group (second group)
                    Text(
                      'Where are you from?',
                      style: AppTypography.h1SemiBold,
                      textAlign: TextAlign.center,
                    ),
                    16.v,
                    _buildSearchInput(),
                    8.v,
                    Expanded(child: _buildCountryList(keyboardOpen)),
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
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Row(
        children: [
          const AppBackButton(),
          Expanded(
            child: Center(
              child: Transform.rotate(
                angle: -10 * math.pi / 180,
                child: AppChip(
                  label:
                      widget.stepLabel ??
                      (widget.forOrganizationFlow ? 'step 01' : 'step 02'),
                  backgroundColor: AppColors.lemon,
                ),
              ),
            ),
          ),
          const SizedBox(width: 52, height: 52),
        ],
      ),
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
          Icon(Icons.search_off, size: 48, color: AppColors.gray400),
          16.v,
          Text(
            'No countries found',
            style: AppTypography.bodyMedium.copyWith(color: AppColors.gray600),
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
        bottom: keyboardOpen
            ? _listBottomPaddingOpen
            : _listBottomPaddingClosed,
      ),
      itemCount: _filteredCountries.length,
      separatorBuilder: (context, index) => 8.v,
      itemBuilder: (context, index) =>
          _buildCountryItem(_filteredCountries[index]),
    );
  }

  Widget _buildCountryItem(Country country) {
    // Compare by code to avoid reference equality issues
    final isSelected = _selectedCountry?.code == country.code;

    return AppButton.secondary(
      text: country.name,
      leftIcon: Text(country.flag, style: const TextStyle(fontSize: 18)),
      rightIcon: isSelected
          ? Icon(Icons.check_circle, color: AppColors.gray400, size: 20)
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
                Theme.of(
                  context,
                ).scaffoldBackgroundColor.withValues(alpha: 0.7),
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
                  ? () async {
                      // Persist selected country
                      await _storage.saveSelectedCountryCode(
                        _selectedCountry!.code,
                      );
                      // Update cubit state (org + protestor flows share this)
                      await context.read<VerificationCubit>().setCountry(
                        _selectedCountry!.code,
                      );

                      if (widget.forOrganizationFlow) {
                        // Organization verification flow: advance to org name
                        context.pushToOrganizationName();
                        return;
                      }

                      // Protestor flow: set user type and finish correctly based on origin
                      await _storage.saveUserType('protestor');
                      await _storage.saveIsFirstTime(false);
                      if (widget.origin == FlowOrigin.intro) {
                        // Coming from intro: replace to feed
                        context.goToHome();
                      } else {
                        // Coming from other places: pop to previous
                        if (Navigator.of(context).canPop()) {
                          Navigator.of(context).pop(_selectedCountry);
                        } else {
                          context.goToHome();
                        }
                      }
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
