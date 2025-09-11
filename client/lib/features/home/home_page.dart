import 'package:flutter/material.dart';
import '../../core/themes/theme_exports.dart';
import '../../core/router/app_router.dart';
import '../../core/constants/countries.dart';
import 'widgets/tab_navigation.dart';
import 'widgets/country_selector.dart';
import 'widgets/date_section_header.dart';
import 'widgets/protest_card.dart';
import 'widgets/floating_action_bar.dart';
import '../../core/services/mock_protest_service.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              CountrySelector(selectedCountry: _selectedCountry),
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
    );
  }

  Widget _buildContent() {
    if (_activeTab == TabType.forYou) {
      final groupedProtests = MockProtestService.getGroupedProtests();

      return ListView.builder(
        padding: const EdgeInsets.only(
          bottom: 100,
        ), // Floating action bar clearance
        itemCount: groupedProtests.length,
        itemBuilder: (context, sectionIndex) {
          final date = groupedProtests.keys.elementAt(sectionIndex);
          final protests = groupedProtests[date]!;
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
                                content: Text('More options: ${protest.title}'),
                              ),
                            );
                          },
                        ),
                      );
                    }),
                  ],
                ),
              ),

              if (sectionIndex < groupedProtests.length - 1) ...[
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
