import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/themes/theme_exports.dart';
import '../../core/router/app_router.dart';
import '../../core/constants/countries.dart';
import '../../core/services/api_service.dart';
import 'widgets/tab_navigation.dart';
import 'widgets/country_selector.dart';
import 'widgets/date_section_header.dart';
import 'widgets/protest_card.dart';
import 'widgets/floating_action_bar.dart';
import 'bloc/protests_bloc.dart';
import 'bloc/protests_event.dart';
import 'bloc/protests_state.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TabType _activeTab = TabType.forYou;
  Country? _selectedCountry;

  void _handleTabChange(TabType newTab) {
    if (newTab == TabType.forOrganizations) {
      context.goToPlaceholder();
    } else {
      setState(() {
        _activeTab = newTab;
      });
    }
  }

  void _handleCountryChange(Country? country) {
    setState(() {
      _selectedCountry = country;
    });

    // Filter protests by country
    context.read<ProtestsBloc>().add(FilterByCountry(country?.code));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          ProtestsBloc(apiService: ApiService())..add(const LoadProtests()),
      child: Scaffold(
        backgroundColor: ThemeColors.backgroundPrimary(context),
        body: SafeArea(
          child: Padding(
            padding: 16.ph + 20.pt,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TabNavigation(
                  activeTab: _activeTab,
                  onTabChanged: _handleTabChange,
                ),
                24.v,
                CountrySelector(
                  selectedCountry: _selectedCountry,
                  onCountryChanged: _handleCountryChange,
                ),
                16.v,
                Container(
                  height: 1,
                  color: ThemeColors.borderSecondary(
                    context,
                  ).withValues(alpha: 0.3),
                ),
                Expanded(child: _buildContent()),
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionBar(
          onContributeTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Contribute tapped - Navigate to create protest'),
              ),
            );
            // TODO: Navigate to contribution board
          },
          onAddTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Add tapped - Quick action')),
            );
            // TODO: Show menu
          },
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }

  Widget _buildContent() {
    if (_activeTab == TabType.forYou) {
      return BlocBuilder<ProtestsBloc, ProtestsState>(
        builder: (context, state) {
          if (state is ProtestsLoading) {
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
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.event_available_outlined,
                      size: 48,
                      color: ThemeColors.textSecondary(context),
                    ),
                    16.v,
                    Text(
                      'No protests found',
                      style: AppTypography.h3SemiBold.copyWith(
                        color: ThemeColors.textPrimary(context),
                      ),
                    ),
                    8.v,
                    Text(
                      state.selectedCountry != null
                          ? 'No protests in ${state.selectedCountry}'
                          : 'Check back later for new protests',
                      style: AppTypography.bodyMedium.copyWith(
                        color: ThemeColors.textSecondary(context),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
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
                          ...protests.asMap().entries.map((entry) {
                            final index = entry.key;
                            final protest = entry.value;
                            return Padding(
                              padding: EdgeInsets.only(
                                bottom: index < protests.length - 1 ? 20 : 0,
                              ),
                              child: ProtestCard(
                                protest: protest,
                                onTap: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Tapped: ${protest.title}'),
                                    ),
                                  );
                                },
                                onMoreTap: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'More options: ${protest.title}',
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          }),
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
            );
          }

          return const SizedBox.shrink();
        },
      );
    } else {
      return Center(
        child: Text(
          'For Organizations Content\n(Organization features will go here)',
          style: AppTypography.bodyMedium.copyWith(
            color: ThemeColors.textSecondary(context),
          ),
          textAlign: TextAlign.center,
        ),
      );
    }
  }
}
