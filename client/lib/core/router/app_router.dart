import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import '../di/service_locator.dart';
import '../services/auth_service.dart';
import '../../features/intro/intro_page.dart';
import '../../features/auth/login_page.dart';
import '../../features/auth/signup_page.dart';
import '../../features/auth/country_selection_page.dart';
import '../../features/auth/organization_name_page.dart';
import '../../features/auth/social_media_selection_page.dart';
import '../../features/auth/social_username_page.dart';
import '../../features/auth/verification_timeline_page.dart';
import '../../features/auth/status_lookup_page.dart';
import '../../features/home/widgets/feed_shell.dart';
import '../../features/home/protestor_feed_page.dart';
import '../../features/home/organization_feed_page.dart';
import '../../features/placeholder/placeholder_screen.dart';
import '../../features/home/widgets/tab_navigation.dart';

// Route path constants - single source of truth
abstract class AppRoutes {
  // Public routes
  static const intro = '/intro';
  static const login = '/login';
  static const signup = '/signup';
  static const countrySelection = '/country-selection';
  static const organizationName = '/organization-name';
  static const socialMediaSelection = '/social-media-selection';
  static const socialUsername = '/social-username';
  static const verificationTimeline = '/verification-timeline';
  static const statusLookup = '/status-lookup';
  static const home = '/home';
  static const protestorFeed = '/home/protestor';
  static const organizationFeed = '/home/organization';
  static const placeholder = '/placeholder';

  // TODO: Add more routes as you build them
  // Example: static const profile = '/profile';
  // Example: static const protestDetails = '/protest/:id';

  // TODO: Add helper methods for dynamic routes
  // Example: static String protest(String id) => '/protest/$id';
}

// Main router configuration
class AppRouter {
  // Private constructor to prevent instantiation
  AppRouter._();

  // TODO: Connect this to AuthBloc when implemented
  // For now, keeping auth state simple
  // static bool _isAuthenticated = false;
  // static void setAuthState(bool isAuthenticated) {
  //   _isAuthenticated = isAuthenticated;
  // }

  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.intro,
    debugLogDiagnostics: kDebugMode, // Only log diagnostics in debug mode
    routes: <RouteBase>[
      // Public routes (no auth required)
      GoRoute(
        path: AppRoutes.intro,
        name: 'intro',
        builder: (context, state) => const IntroPage(),
      ),

      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),

      GoRoute(
        path: AppRoutes.signup,
        name: 'signup',
        builder: (context, state) => const SignupPage(),
      ),

      GoRoute(
        path: AppRoutes.countrySelection,
        name: 'countrySelection',
        builder: (context, state) {
          final isOrgFlow = state.uri.queryParameters['orgFlow'] == '1';
          final stepLabel = state.uri.queryParameters['stepLabel'];
          return CountrySelectionPage(
            forOrganizationFlow: isOrgFlow,
            stepLabel: stepLabel,
          );
        },
      ),

      GoRoute(
        path: AppRoutes.organizationName,
        name: 'organizationName',
        builder: (context, state) => const OrganizationNamePage(),
      ),

      GoRoute(
        path: AppRoutes.socialMediaSelection,
        name: 'socialMediaSelection',
        builder: (context, state) => const SocialMediaSelectionPage(),
      ),

      GoRoute(
        path: AppRoutes.socialUsername,
        name: 'socialUsername',
        builder: (context, state) {
          final socialMedia =
              state.uri.queryParameters['socialMedia'] ?? 'Instagram';
          return SocialUsernamePage(selectedSocialMedia: socialMedia);
        },
      ),

      GoRoute(
        path: AppRoutes.verificationTimeline,
        name: 'verificationTimeline',
        builder: (context, state) {
          final username = state.uri.queryParameters['username'];
          final initialStatus = state.uri.queryParameters['status'];
          return VerificationTimelinePage(
            username: username,
            initialStatus: initialStatus,
          );
        },
      ),

      GoRoute(
        path: AppRoutes.statusLookup,
        name: 'statusLookup',
        builder: (context, state) => const StatusLookupPage(),
      ),

      // Keeps tab state when switching between tabs
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return FeedShell(
            activeTab: navigationShell.currentIndex == 0
                ? TabType.forYou
                : TabType.forOrganizations,
            onTabChanged: (newTab) {
              final newIndex = newTab == TabType.forYou ? 0 : 1;
              navigationShell.goBranch(newIndex);
            },
            child: navigationShell,
          );
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.protestorFeed,
                name: 'protestorFeed',
                builder: (context, state) => const ProtestorFeedPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.organizationFeed,
                name: 'organizationFeed',
                builder: (context, state) => const OrganizationFeedPage(),
              ),
            ],
          ),
        ],
      ),

      GoRoute(
        path: AppRoutes.placeholder,
        name: 'placeholder',
        builder: (context, state) => const PlaceholderScreen(),
      ),

      // TODO: Add more routes as you build screens

      // Example for protected home route with nested routes:
      // GoRoute(
      //   path: '/',
      //   name: 'home',
      //   builder: (context, state) => const HomePage(),
      //   routes: [
      //     GoRoute(
      //       path: 'profile',
      //       builder: (context, state) => const ProfilePage(),
      //     ),
      //   ],
      // ),

      // Example for dynamic route with parameters:
      // GoRoute(
      //   path: '/protest/:id',
      //   builder: (context, state) {
      //     final id = state.pathParameters['id']!;
      //     return ProtestDetailsPage(protestId: id);
      //   },
      // ),
    ],

    redirect: (BuildContext context, GoRouterState state) async {
      // Check if user is already logged in
      final authService = sl<AuthService>();
      final isLoggedIn = await authService.isLoggedIn();

      // If user is logged in and trying to access intro/login, redirect to home
      if (isLoggedIn &&
          (state.matchedLocation == AppRoutes.intro ||
              state.matchedLocation == AppRoutes.login)) {
        return AppRoutes.organizationFeed;
      }

      // If user is not logged in and trying to access protected routes, redirect to intro
      // Protestor feed is PUBLIC; only organization feed requires auth
      if (!isLoggedIn && state.matchedLocation == AppRoutes.organizationFeed) {
        return AppRoutes.intro;
      }

      return null;
    },

    // Error page handler
    errorBuilder: (context, state) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Page not found',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                state.error?.message ?? 'Unknown error',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.goToIntro(),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    },
  );
}

extension NavigationExtensions on BuildContext {
  // Current navigation methods
  void goToLogin() => go(AppRoutes.login);
  void goToIntro() => go(AppRoutes.intro);
  void goToSignup() => go(AppRoutes.signup);
  void goToCountrySelection() => go(AppRoutes.countrySelection);
  Future<T?> pushToCountrySelection<T>() =>
      GoRouter.of(this).push<T>(AppRoutes.countrySelection);
  Future<T?> pushToCountrySelectionForOrg<T>() => GoRouter.of(
    this,
  ).push<T>("${AppRoutes.countrySelection}?orgFlow=1&stepLabel=step%2001");
  void goToOrganizationName() => go(AppRoutes.organizationName);
  void goToSocialMediaSelection() => go(AppRoutes.socialMediaSelection);
  void goToSocialUsername(String socialMedia) =>
      go('${AppRoutes.socialUsername}?socialMedia=$socialMedia');
  void goToVerificationTimeline({
    String status = 'pending',
    String? username,
  }) => go(
    '${AppRoutes.verificationTimeline}?status=$status${username != null ? '&username=$username' : ''}',
  );
  void goToStatusLookup() => go(AppRoutes.statusLookup);
  void goToHome() => go(AppRoutes.protestorFeed);
  void goToProtestorFeed() => go(AppRoutes.protestorFeed);
  void goToOrganizationFeed() => go(AppRoutes.organizationFeed);
  void goToPlaceholder() => go(AppRoutes.placeholder);

  // TODO: Add more navigation methods as you create screens
  // Example: void goToProtest(String id) => go('/protest/$id');

  // Check current route
  bool get isLoginPage =>
      GoRouterState.of(this).matchedLocation == AppRoutes.login;
  bool get isIntroPage =>
      GoRouterState.of(this).matchedLocation == AppRoutes.intro;
  bool get isSignupPage =>
      GoRouterState.of(this).matchedLocation == AppRoutes.signup;
  bool get isCountrySelectionPage =>
      GoRouterState.of(this).matchedLocation == AppRoutes.countrySelection;
  bool get isHomePage =>
      GoRouterState.of(this).matchedLocation == AppRoutes.protestorFeed;
  bool get isPlaceholderPage =>
      GoRouterState.of(this).matchedLocation == AppRoutes.placeholder;

  // Get route parameters
  String? getParam(String name) => GoRouterState.of(this).pathParameters[name];
  String? getQueryParam(String name) =>
      GoRouterState.of(this).uri.queryParameters[name];
}
