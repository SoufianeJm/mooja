import 'package:get_it/get_it.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../../features/home/bloc/protests_bloc.dart';

/// Global service locator instance
final GetIt sl = GetIt.instance;

/// Initialize all dependencies
/// Call this in main.dart before runApp()
Future<void> setupServiceLocator() async {
  // Register services as singletons (stateful services)
  sl.registerLazySingleton<StorageService>(() => StorageService());
  sl.registerLazySingleton<ApiService>(() => ApiService());

  // Register BLoCs as factories (stateless, created per use)
  sl.registerFactory<ProtestsBloc>(
    () => ProtestsBloc(apiService: sl<ApiService>()),
  );

  // TODO: Add more services and BLoCs as you build them
  // Example:
  // sl.registerLazySingleton<AuthService>(() => AuthService());
  // sl.registerFactory<AuthBloc>(() => AuthBloc(authService: sl<AuthService>()));
}

/// Reset all dependencies (useful for testing)
Future<void> resetServiceLocator() async {
  await sl.reset();
}
