import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../di/service_locator.dart';
import '../services/storage_service.dart';
import '../services/user_context_service.dart';
import '../../features/intro/intro_page.dart';
import '../../features/auth/login_page.dart';
import '../../features/auth/signup_page.dart';
import '../../features/auth/country_selection_page.dart';
import '../../features/auth/organization_name_page.dart';
import '../../features/auth/social_media_selection_page.dart';
import '../../features/auth/social_username_page.dart';
import '../../features/auth/verification_timeline_page.dart';
import '../../features/auth/status_lookup_page.dart';
import '../../features/auth/code_verification_page.dart';
import '../../features/auth/org_registration_page.dart';
import '../../features/auth/bloc/auth_bloc.dart';
import '../../features/home/widgets/feed_shell.dart';
import '../../features/home/protestor_feed_page.dart';
import '../../features/home/organization_feed_page.dart';
import '../../features/placeholder/placeholder_screen.dart';
import '../../features/home/widgets/tab_navigation.dart';
import '../../features/intro/widgets/org_verification_modal.dart';
import '../../features/intro/widgets/not_eligible_modal.dart';
import '../navigation/navigation_guard.dart';
import '../state/state_validator.dart';

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
  static const codeVerification = '/code-verification';
  static const orgRegistration = '/org-registration';
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

  static final RouteObserver<ModalRoute<void>> routeObserver =
      RouteObserver<ModalRoute<void>>();

  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.intro,
    debugLogDiagnostics: kDebugMode, // Only log diagnostics in debug mode
    observers: [routeObserver],
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

      GoRoute(
        path: AppRoutes.codeVerification,
        name: 'codeVerification',
        builder: (context, state) => const CodeVerificationPage(),
      ),

      GoRoute(
        path: AppRoutes.orgRegistration,
        name: 'orgRegistration',
        builder: (context, state) {
          final prefilled = state.uri.queryParameters['username'];
          return BlocProvider(
            create: (context) => sl<AuthBloc>(),
            child: OrgRegistrationPage(prefilledUsername: prefilled),
          );
        },
      ),

      // Keeps tab state when switching between tabs
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return FeedShell(
            activeTab: navigationShell.currentIndex == 0
                ? TabType.forYou
                : TabType.forOrganizations,
            onTabChanged: (newTab) async {
              print('DEBUG: Tab changed to: $newTab');

              // Validate state before tab changes
              if (!await StateValidator.validateBeforeNavigation()) {
                print('DEBUG: State validation failed during tab change');
                return;
              }

              // Handle tab changes using UserContextService
              if (newTab == TabType.forYou) {
                print('DEBUG: Switching to For You tab');
                // Always allow switching to For You tab
                navigationShell.goBranch(0);
              } else if (newTab == TabType.forOrganizations) {
                print('DEBUG: Switching to For Organizations tab');

                // Use UserContextService to determine org access
                final userContext = sl<UserContextService>();
                final canAccess = await userContext.canAccessOrgFeatures();
                print('DEBUG: Can access org features: $canAccess');

                if (canAccess) {
                  print(
                    'DEBUG: User can access org features, switching to org tab',
                  );
                  // User is verified org, allow access
                  navigationShell.goBranch(1);
                } else {
                  // Determine where to send them based on journey
                  final journey = await userContext.getCurrentJourney();
                  print('DEBUG: User journey: $journey');
                  if (context.mounted) {
                    switch (journey) {
                      case UserJourney.orgPending:
                        print(
                          'DEBUG: User has pending org application, going to verification timeline',
                        );
                        // Has applied before - go to verification timeline
                        context.go('/verification-timeline');
                        break;
                      case UserJourney.firstTime:
                      case UserJourney.protestorActive:
                      default:
                        print(
                          'DEBUG: User is protestor, showing eligibility modal from feed',
                        );
                        // Show eligibility modal directly (not intro page)
                        _showOrgVerificationModalFromFeed(context);
                        break;
                    }
                  }
                }
              }
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
      // Validate state before any navigation
      if (!await StateValidator.validateBeforeNavigation()) {
        print('DEBUG: State validation failed, using safe route');
        return await NavigationGuard.getSafeRoute();
      }

      final storage = sl<StorageService>();
      final isFirstTime = await storage.readIsFirstTime();
      final userType = await storage.readUserType();

      print(
        'DEBUG: Router redirect - isFirstTime: $isFirstTime, userType: $userType, location: ${state.matchedLocation}',
      );

      // Check if navigation is valid (only if actually navigating somewhere)
      if (state.uri.toString() != state.matchedLocation) {
        print(
          'DEBUG: Checking navigation from "${state.uri.toString()}" to "${state.matchedLocation}"',
        );
        final canNavigate = await NavigationGuard.canNavigate(
          state.uri.toString(),
          state.matchedLocation,
        );

        if (!canNavigate) {
          print('DEBUG: Navigation blocked by guard, using safe route');
          return await NavigationGuard.getSafeRoute();
        }
      } else {
        print('DEBUG: No navigation needed, already on correct route');
      }

      // For first-time users, allow them to go through their respective flows
      if (isFirstTime) {
        // Allow access to intro and all auth/onboarding pages
        final allowedFirstTimeRoutes = [
          AppRoutes.intro,
          AppRoutes.countrySelection,
          AppRoutes.organizationName,
          AppRoutes.socialMediaSelection,
          AppRoutes.socialUsername,
          AppRoutes.verificationTimeline,
          AppRoutes.statusLookup,
          AppRoutes.codeVerification,
          AppRoutes.orgRegistration,
          AppRoutes.login,
          AppRoutes.signup,
        ];

        // Only redirect if trying to access protected routes (like feed pages)
        if (!allowedFirstTimeRoutes.contains(state.matchedLocation)) {
          print(
            'DEBUG: First-time user trying to access protected route, redirecting to intro',
          );
          return AppRoutes.intro;
        }
      } else {
        // For returning users, redirect based on user type
        if (userType == 'protestor') {
          // Returning protestors should go to feed, not intro
          if (state.matchedLocation == AppRoutes.intro) {
            print('DEBUG: Returning protestor on intro, redirecting to feed');
            return AppRoutes.protestorFeed;
          }
        }
        // For orgs, let the tab navigation handle the routing logic
      }

      print('DEBUG: Router redirect - no redirect needed');
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

// Helper function to show org verification modal from feed context
void _showOrgVerificationModalFromFeed(BuildContext context) {
  print('DEBUG: Showing org verification modal from feed context');

  // Validate state before showing modal
  StateValidator.validateBeforeNavigation().then((isValid) {
    if (!isValid) {
      print('DEBUG: State validation failed, not showing modal');
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const OrgVerificationModal(),
    ).then((result) {
      print('DEBUG: Modal result from feed: $result');
      if (result == 'yes') {
        // User confirmed they have an organization
        // Navigate to organization login/registration
        print('DEBUG: Navigating to login from feed modal');
        context.goToLogin();
      } else if (result == 'no') {
        // User said they don't have an organization
        print('DEBUG: Showing not eligible modal from feed');
        _showNotEligibleModalFromFeed(context);
      }
    });
  });
}

// Helper function to show not eligible modal from feed context
void _showNotEligibleModalFromFeed(BuildContext context) {
  print('DEBUG: Showing not eligible modal from feed context');
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => const NotEligibleModal(fromFeed: true),
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
    bool fromIntro = false,
  }) => go(
    '${AppRoutes.verificationTimeline}?status=$status${username != null ? '&username=$username' : ''}${fromIntro ? '&from=intro' : ''}',
  );
  void goToCodeVerification() => go(AppRoutes.codeVerification);
  void goToOrgRegistration({String? prefilledUsername}) => go(
    prefilledUsername == null
        ? AppRoutes.orgRegistration
        : '${AppRoutes.orgRegistration}?username=$prefilledUsername',
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
