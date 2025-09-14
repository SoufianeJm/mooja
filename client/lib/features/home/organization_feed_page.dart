import 'package:flutter/material.dart';
import '../../core/themes/theme_exports.dart';
import '../../core/di/service_locator.dart';
import '../../features/auth/bloc/auth_bloc.dart';
import '../../core/router/app_router.dart';

/// Organization-specific feed page with NGO tools and features
class OrganizationFeedPage extends StatelessWidget {
  const OrganizationFeedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.business,
              size: 64,
              color: ThemeColors.textSecondary(context),
            ),
            24.v,
            Text(
              'Organization Dashboard',
              style: AppTypography.h2SemiBold.copyWith(
                color: ThemeColors.textPrimary(context),
              ),
            ),
            16.v,
            Text(
              'NGO tools and features will be implemented here',
              style: AppTypography.bodyMedium.copyWith(
                color: ThemeColors.textSecondary(context),
              ),
              textAlign: TextAlign.center,
            ),
            24.v,
            Container(
              padding: 16.pv + 24.ph,
              decoration: BoxDecoration(
                color: ThemeColors.backgroundSecondary(context),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: ThemeColors.borderSecondary(
                    context,
                  ).withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.construction,
                    size: 32,
                    color: ThemeColors.textSecondary(context),
                  ),
                  12.v,
                  Text(
                    'Coming Soon',
                    style: AppTypography.h3SemiBold.copyWith(
                      color: ThemeColors.textPrimary(context),
                    ),
                  ),
                  8.v,
                  Text(
                    'Organization management tools, event creation, member management, and analytics will be available here.',
                    style: AppTypography.bodyMedium.copyWith(
                      color: ThemeColors.textSecondary(context),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            32.v,
            // Temporary logout button
            GestureDetector(
              onTap: () => _handleLogout(context),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.withOpacity(0.3)),
                ),
                child: Text(
                  'Logout',
                  style: AppTypography.bodyMedium.copyWith(
                    color: Colors.red,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleLogout(BuildContext context) async {
    final authBloc = sl<AuthBloc>();
    authBloc.add(const LogoutRequested());

    // Wait a moment for the logout to complete, then navigate
    await Future.delayed(const Duration(milliseconds: 100));
    context.goToIntro();
  }
}
