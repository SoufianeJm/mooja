import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/themes/theme_exports.dart';
import 'core/router/app_router.dart';
// Prep for future global providers (auth/services) without changing behavior now:
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'core/services/api_service.dart';
// import 'core/services/storage_service.dart';
// import 'core/auth/auth_cubit.dart';

Future<void> main() async {
  // Load environment variables
  await dotenv.load(fileName: ".env");

  // When ready to wire global providers, wrap MyApp as below (keep commented for now):
  // runApp(
  //   MultiRepositoryProvider(
  //     providers: [
  //       RepositoryProvider(create: (_) => StorageService()),
  //       RepositoryProvider(create: (_) => ApiService()),
  //     ],
  //     child: MultiBlocProvider(
  //       providers: [
  //         BlocProvider(create: (ctx) => AuthCubit(ctx.read<StorageService>(), ctx.read<ApiService>())),
  //       ],
  //       child: const MyApp(),
  //     ),
  //   ),
  // );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Mooja',
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.light,
      debugShowCheckedModeBanner: false,
      routerConfig: AppRouter.router,
    );
  }
}
