import 'package:flutter/material.dart';
import '../../core/themes/theme_exports.dart';
import '../home/widgets/tab_navigation.dart';
import '../../core/router/app_router.dart';

class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeColors.backgroundPrimary(context),
      body: SafeArea(
        child: Padding(
          padding: 16.p,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tab Navigation - with "For Organizations" active
              TabNavigation(
                activeTab: TabType.forOrganizations,
                onTabChanged: (tab) {
                  if (tab == TabType.forYou) {
                    // Navigate back to home when "For you" is clicked
                    context.goToHome();
                  }
                  // Do nothing if "For Organizations" is clicked (already here)
                },
              ),
              
              24.v, // Space after tabs
              
              // Placeholder content
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.business_center_outlined,
                        size: 64,
                        color: ThemeColors.textSecondary(context),
                      ),
                      16.v,
                      Text(
                        'Hello, I\'m a placeholder',
                        style: AppTypography.h2SemiBold.copyWith(
                          color: ThemeColors.textPrimary(context),
                        ),
                      ),
                      8.v,
                      Text(
                        'Organization features coming soon',
                        style: AppTypography.bodyMedium.copyWith(
                          color: ThemeColors.textSecondary(context),
                        ),
                      ),
                    ],
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
