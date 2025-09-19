import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../di/service_locator.dart';
import '../services/storage_service.dart';
import '../services/user_context_service.dart';
import '../constants/flow_origin.dart';
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
import '../../features/auth/verification_cubit.dart';
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
}

// Main router configuration
class AppRouter {
  // Private constructor to prevent instantiation
  AppRouter._();

  static final RouteObserver<ModalRoute<void>> routeObserver =
      RouteObserver<ModalRoute<void>>();

  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.intro,
    debugLogDiagnostics: false,
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
          final origin = state.extra as FlowOrigin? ?? FlowOrigin.unknown;
          return BlocProvider(
            create: (_) => sl<VerificationCubit>(),
            child: CountrySelectionPage(
              forOrganizationFlow: isOrgFlow,
              stepLabel: stepLabel,
              origin: origin,
            ),
          );
        },
      ),

      GoRoute(
        path: AppRoutes.organizationName,
        name: 'organizationName',
        builder: (context, state) => BlocProvider(
          create: (_) => sl<VerificationCubit>(),
          child: const OrganizationNamePage(),
        ),
      ),

      GoRoute(
        path: AppRoutes.socialMediaSelection,
        name: 'socialMediaSelection',
        builder: (context, state) => BlocProvider(
          create: (_) => sl<VerificationCubit>(),
          child: const SocialMediaSelectionPage(),
        ),
      ),

      GoRoute(
        path: AppRoutes.socialUsername,
        name: 'socialUsername',
        builder: (context, state) {
          final socialMedia =
              state.uri.queryParameters['socialMedia'] ?? 'Instagram';
          return BlocProvider(
            create: (_) => sl<VerificationCubit>(),
            child: SocialUsernamePage(selectedSocialMedia: socialMedia),
          );
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
              // Validate state before tab changes
              if (!await StateValidator.validateBeforeNavigation()) {
                return;
              }

              // Handle tab changes using UserContextService
              if (newTab == TabType.forYou) {
                // Always allow switching to For You tab
                navigationShell.goBranch(0);
              } else if (newTab == TabType.forOrganizations) {
                // Use UserContextService to determine org access
                final userContext = sl<UserContextService>();
                final canAccess = await userContext.canAccessOrgFeatures();

                if (canAccess) {
                  // User is verified org, allow access
                  navigationShell.goBranch(1);
                } else {
                  // Determine where to send them based on journey
                  final journey = await userContext.getCurrentJourney();
                  if (context.mounted) {
                    switch (journey) {
                      case UserJourney.orgPending:
                        // Has applied before - go to verification timeline
                        context.go('/verification-timeline');
                        break;
                      case UserJourney.firstTime:
                      case UserJourney.protestorActive:
                      default:
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
    ],

    redirect: (BuildContext context, GoRouterState state) async {
      // Validate state before any navigation
      if (!await StateValidator.validateBeforeNavigation()) {
        return await NavigationGuard.getSafeRoute();
      }

      final storage = sl<StorageService>();
      final isFirstTime = await storage.readIsFirstTime();
      final userType = await storage.readUserType();

      // Check if navigation is valid (only if actually navigating somewhere)
      if (state.uri.toString() != state.matchedLocation) {
        final canNavigate = await NavigationGuard.canNavigate(
          state.uri.toString(),
          state.matchedLocation,
        );

        if (!canNavigate) {
          return await NavigationGuard.getSafeRoute();
        }
      } else {}

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

        // If user has a pending application, allow feed access as protestor
        final pendingAppId = await storage.readPendingApplicationId();
        final pendingUsername = await storage.readPendingOrgUsername();
        final hasPending =
            (pendingAppId != null && pendingAppId.isNotEmpty) ||
            (pendingUsername != null && pendingUsername.isNotEmpty);

        final isFeed = state.matchedLocation == AppRoutes.protestorFeed;

        // Only redirect if trying to access protected routes (like feed pages)
        if (!allowedFirstTimeRoutes.contains(state.matchedLocation) &&
            !(hasPending && isFeed)) {
          return AppRoutes.intro;
        }
      } else {
        // For returning users, redirect based on user type
        if (userType == 'protestor') {
          // Returning protestors should go to feed, not intro
          if (state.matchedLocation == AppRoutes.intro) {
            return AppRoutes.protestorFeed;
          }
        } else if (userType == 'org') {
          // Returning orgs with token should not see intro on cold start
          final hasToken = await sl<StorageService>().hasAuthToken();
          if (hasToken && state.matchedLocation == AppRoutes.intro) {
            return AppRoutes.organizationFeed;
          }
        }
        // For orgs without token, let the tab navigation handle the routing logic
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

// Helper function to show org verification modal from feed context
void _showOrgVerificationModalFromFeed(BuildContext context) {
  // Validate state before showing modal
  StateValidator.validateBeforeNavigation().then((isValid) {
    if (!isValid) {
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const OrgVerificationModal(),
    ).then((result) {
      if (!context.mounted) return;
      if (result == 'yes') {
        if (!context.mounted) return;
        context.pushToLogin();
      } else if (result == 'no') {
        if (!context.mounted) return;
        _showNotEligibleModalFromFeed(context);
      }
    });
  });
}

// Helper function to show not eligible modal from feed context
void _showNotEligibleModalFromFeed(BuildContext context) {
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
  Future<T?> pushToLogin<T>() => GoRouter.of(this).push<T>(AppRoutes.login);
  void goToIntro() => go(AppRoutes.intro);
  void goToSignup() => go(AppRoutes.signup);
  void goToCountrySelection() => go(AppRoutes.countrySelection);
  Future<T?> pushToCountrySelection<T>({
    FlowOrigin origin = FlowOrigin.unknown,
  }) => GoRouter.of(this).push<T>(AppRoutes.countrySelection, extra: origin);
  Future<T?> pushToCountrySelectionForOrg<T>() => GoRouter.of(
    this,
  ).push<T>("${AppRoutes.countrySelection}?orgFlow=1&stepLabel=step%2001");
  void goToOrganizationName() => go(AppRoutes.organizationName);
  Future<T?> pushToOrganizationName<T>() =>
      GoRouter.of(this).push<T>(AppRoutes.organizationName);
  void goToSocialMediaSelection() => go(AppRoutes.socialMediaSelection);
  Future<T?> pushToSocialMediaSelection<T>() =>
      GoRouter.of(this).push<T>(AppRoutes.socialMediaSelection);
  void goToSocialUsername(String socialMedia) =>
      go('${AppRoutes.socialUsername}?socialMedia=$socialMedia');
  Future<T?> pushToSocialUsername<T>(String socialMedia) => GoRouter.of(
    this,
  ).push<T>('${AppRoutes.socialUsername}?socialMedia=$socialMedia');
  void goToVerificationTimeline({
    String status = 'pending',
    String? username,
    bool fromIntro = false,
  }) => go(
    '${AppRoutes.verificationTimeline}?status=$status${username != null ? '&username=$username' : ''}${fromIntro ? '&from=intro' : ''}',
  );
  void goToCodeVerification() => go(AppRoutes.codeVerification);
  Future<T?> pushToCodeVerification<T>() =>
      GoRouter.of(this).push<T>(AppRoutes.codeVerification);
  void goToOrgRegistration({String? prefilledUsername}) => go(
    prefilledUsername == null
        ? AppRoutes.orgRegistration
        : '${AppRoutes.orgRegistration}?username=$prefilledUsername',
  );
  void goToStatusLookup() => go(AppRoutes.statusLookup);
  Future<T?> pushToStatusLookup<T>() =>
      GoRouter.of(this).push<T>(AppRoutes.statusLookup);
  void goToHome() => go(AppRoutes.protestorFeed);
  void goToProtestorFeed() => go(AppRoutes.protestorFeed);
  void goToOrganizationFeed() => go(AppRoutes.organizationFeed);
  void goToPlaceholder() => go(AppRoutes.placeholder);

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
