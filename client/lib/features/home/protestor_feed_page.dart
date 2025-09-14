import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../core/themes/theme_exports.dart';
import '../../core/constants/countries.dart';
import '../../core/services/api_service.dart';
import '../../core/services/storage_service.dart';
import '../../core/di/service_locator.dart';
import 'widgets/date_section_header.dart';
import 'widgets/protest_card.dart';
import 'widgets/empty_state_widget.dart';
import 'widgets/no_protests_empty_state.dart';
import 'widgets/country_selector.dart';
import 'bloc/protests_bloc.dart';
import 'bloc/protests_event.dart';
import 'bloc/protests_state.dart';

class ProtestorFeedPage extends StatefulWidget {
  const ProtestorFeedPage({super.key});

  @override
  State<ProtestorFeedPage> createState() => _ProtestorFeedPageState();
}

class _ProtestorFeedPageState extends State<ProtestorFeedPage> {
  Country? _selectedCountry;
  late final StorageService _storage;
  bool _isInitialized = false;
  final Map<String, bool> _orgsCache = {};
  late final ProtestsBloc _protestsBloc;
  
  // Cache Future to prevent recreation on rebuilds
  Future<bool>? _orgCheckFuture;
  String? _lastCheckedCountry;

  @override
  void initState() {
    super.initState();
    _storage = sl<StorageService>();
    _protestsBloc = sl<ProtestsBloc>();
    _bootstrapFromStorage();
  }

  @override
  void dispose() {
    _protestsBloc.close();
    super.dispose();
  }

  Future<void> _bootstrapFromStorage() async {
    final code = await _storage.readSelectedCountryCode();
    if (!mounted) return;

    if (code != null) {
      final country = kCountries.firstWhere(
        (c) => c.code == code,
        orElse: () => kCountries.first,
      );
      setState(() {
        _selectedCountry = country;
        _isInitialized = true;
      });
      _protestsBloc.add(LoadProtests(country: country.code));
    } else {
      setState(() {
        _isInitialized = true;
      });
      _protestsBloc.add(const LoadProtests());
    }
  }

  Future<void> _navigateToCountrySelection() async {
    final result = await context.push('/country-selection');
    if (result != null && result is Country && mounted) {
      setState(() {
        _selectedCountry = result;
      });
      _protestsBloc.add(LoadProtests(country: result.code));
    }
  }

  Future<bool> _hasOrganizationsInCountry(String? countryCode) async {
    if (countryCode == null) return true;

    if (_orgsCache.containsKey(countryCode)) {
      return _orgsCache[countryCode]!;
    }

    try {
      final apiService = sl<ApiService>();
      final orgs = await apiService.getOrganizations(country: countryCode);
      final hasOrgs = orgs.isNotEmpty;
      _orgsCache[countryCode] = hasOrgs;
      return hasOrgs;
    } catch (e) {
      // Default to true on API failure
      _orgsCache[countryCode] = true;
      return true;
    }
  }

  Widget _buildOfflineIndicator() {
    return BlocBuilder<ProtestsBloc, ProtestsState>(
      builder: (context, state) {
        if (state is ProtestsError) {
          final isNetworkError =
              state.message.toLowerCase().contains('connection') ||
              state.message.toLowerCase().contains('network') ||
              state.message.toLowerCase().contains('timeout');

          if (isNetworkError) {
            return Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              color: AppColors.red500,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.wifi_off, color: Colors.white, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'No internet connection',
                    style: AppTypography.bodyMedium.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            );
          }
        }
        return const SizedBox.shrink();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return BlocProvider.value(
      value: _protestsBloc,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildOfflineIndicator(),
          Align(
            alignment: Alignment.centerLeft,
            child: CountrySelector(
              selectedCountry: _selectedCountry,
              onTap: _navigateToCountrySelection,
            ),
          ),
          16.v,
          Container(
            height: 1,
            color: ThemeColors.borderSecondary(context).withValues(alpha: 0.3),
          ),
          Expanded(child: _buildContent()),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return BlocBuilder<ProtestsBloc, ProtestsState>(
      builder: (context, state) {
        if (state is ProtestsInitial || state is ProtestsLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is ProtestsError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 48,
                  color: ThemeColors.textSecondary(context),
                ),
                16.v,
                Text(
                  'Failed to load protests',
                  style: AppTypography.h3SemiBold.copyWith(
                    color: ThemeColors.textPrimary(context),
                  ),
                ),
                8.v,
                Text(
                  state.message,
                  style: AppTypography.bodyMedium.copyWith(
                    color: ThemeColors.textSecondary(context),
                  ),
                  textAlign: TextAlign.center,
                ),
                16.v,
                ElevatedButton(
                  onPressed: () {
                    context.read<ProtestsBloc>().add(
                      const LoadProtests(refresh: true),
                    );
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (state is ProtestsLoaded) {
          if (state.groupedProtests.isEmpty) {
            // Only create new Future when country actually changes
            if (_lastCheckedCountry != state.selectedCountry) {
              _lastCheckedCountry = state.selectedCountry;
              _orgCheckFuture = _hasOrganizationsInCountry(state.selectedCountry);
            }
            
            return FutureBuilder<bool>(
              future: _orgCheckFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Checking organizations...'),
                      ],
                    ),
                  );
                }

                final hasOrganizations = snapshot.data ?? true;

                if (!hasOrganizations) {
                  return EmptyStateWidget(
                    selectedCountry: _selectedCountry ?? kCountries.first,
                    onSuggestionSubmitted: () {
                      // TODO: Handle suggestion submission
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Suggestion submitted! Thank you.'),
                        ),
                      );
                    },
                  );
                } else {
                  return NoProtestsEmptyState(
                    selectedCountry: _selectedCountry ?? kCountries.first,
                  );
                }
              },
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              final bloc = context.read<ProtestsBloc>();
              final blocState = bloc.state;
              final selected = blocState is ProtestsLoaded
                  ? blocState.selectedCountry
                  : _selectedCountry?.code;
              bloc.add(LoadProtests(refresh: true, country: selected));
            },
            child: ListView.builder(
              padding: const EdgeInsets.only(
                bottom: 100,
              ), // Floating action bar clearance
              itemCount:
                  state.groupedProtests.length + (state.hasNextPage ? 1 : 0),
              itemBuilder: (context, sectionIndex) {
                // Show loading indicator for pagination
                if (sectionIndex == state.groupedProtests.length) {
                  return Padding(
                    padding: 20.pv,
                    child: Center(
                      child: state.isLoadingMore
                          ? const CircularProgressIndicator()
                          : ElevatedButton(
                              onPressed: () {
                                context.read<ProtestsBloc>().add(
                                  const LoadMoreProtests(),
                                );
                              },
                              child: const Text('Load More'),
                            ),
                    ),
                  );
                }

                final date = state.groupedProtests.keys.elementAt(sectionIndex);
                final protests = state.groupedProtests[date]!;
                final firstProtest = protests.first;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: 20.pv,
                      child: DateSectionHeader(
                        title: firstProtest.relativeDayText,
                        date: firstProtest.shortFormattedDate,
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Column(
                        children: [
                          // Use for loop instead of map for better performance
                          for (int i = 0; i < protests.length; i++)
                            Padding(
                              padding: EdgeInsets.only(
                                bottom: i < protests.length - 1 ? 20 : 0,
                              ),
                              child: ProtestCard(
                                protest: protests[i],
                                onTap: () {
                                  // TODO(protestor, 2024-12-14): Navigate to protest details when implemented
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Tapped: ${protests[i].title}'),
                                    ),
                                  );
                                },
                                onMoreTap: () {
                                  // TODO(protestor, 2024-12-14): Show protest options menu when implemented
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'More options: ${protests[i].title}',
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                        ],
                      ),
                    ),

                    if (sectionIndex < state.groupedProtests.length - 1) ...[
                      Container(
                        height: 1,
                        color: ThemeColors.borderSecondary(
                          context,
                        ).withValues(alpha: 0.3),
                      ),
                      20.v,
                    ],
                  ],
                );
              },
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}
