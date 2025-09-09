import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/intro/intro_page.dart';
import '../../features/auth/login_page.dart';
import '../../features/auth/signup_page.dart';
import '../../features/auth/country_selection_page.dart';

// Route path constants - single source of truth
abstract class AppRoutes {
  // Public routes
  static const intro = '/intro';
  static const login = '/login';
  static const signup = '/signup';
  static const countrySelection = '/country-selection';
  
  // TODO: Add more routes as you build them
  // Example: static const home = '/';
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
  
  // Single router instance (singleton pattern)
  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.intro,
    debugLogDiagnostics: true, // Set to false in production
    
    // Route definitions
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
        builder: (context, state) => const CountrySelectionPage(),
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
    
    // Global redirect logic for auth
    redirect: (BuildContext context, GoRouterState state) {
      // TODO: Implement auth redirect when you have authentication
      // Example of how to define public routes:
      // const publicRoutes = {
      //   AppRoutes.intro,
      //   AppRoutes.login,
      //   AppRoutes.signup,
      //   '/forgot-password'
      // };
      // final isPublicRoute = publicRoutes.contains(state.matchedLocation);
      
      // TODO: When you have a home page, uncomment this auth logic:
      // if (!_isAuthenticated && !isPublicRoute) {
      //   return AppRoutes.login;
      // }
      // if (_isAuthenticated && state.matchedLocation == AppRoutes.login) {
      //   return AppRoutes.home;
      // }
      
      // For now, no redirect
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

// Navigation extensions for type safety and convenience
extension NavigationExtensions on BuildContext {
  // Current navigation methods
  void goToLogin() => go(AppRoutes.login);
  void goToIntro() => go(AppRoutes.intro);
  void goToSignup() => go(AppRoutes.signup);
  void goToCountrySelection() => go(AppRoutes.countrySelection);
  
  // TODO: Add more navigation methods as you create screens
  // Example: void goHome() => go(AppRoutes.home);
  // Example: void goToProtest(String id) => go('/protest/$id');
  
  // Check current route
  bool get isLoginPage => GoRouterState.of(this).matchedLocation == AppRoutes.login;
  bool get isIntroPage => GoRouterState.of(this).matchedLocation == AppRoutes.intro;
  bool get isSignupPage => GoRouterState.of(this).matchedLocation == AppRoutes.signup;
  bool get isCountrySelectionPage => GoRouterState.of(this).matchedLocation == AppRoutes.countrySelection;
  
  // Get route parameters
  String? getParam(String name) => GoRouterState.of(this).pathParameters[name];
  String? getQueryParam(String name) => GoRouterState.of(this).uri.queryParameters[name];
}
