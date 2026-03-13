import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:get_it/get_it.dart';

import 'package:user_app/features/home/home_screen.dart';
import 'package:user_app/services/api_service.dart';
import 'package:user_app/services/auth_service.dart';
import 'package:user_app/data/repositories/user_repository.dart';
import 'package:user_app/data/repositories/reel_repository.dart';
import 'package:user_app/data/repositories/timelapse_repository.dart';
import 'package:user_app/data/repositories/comment_repository.dart';
import 'package:user_app/data/repositories/content_repository.dart';
import 'package:user_app/state_management/auth_provider.dart';
import 'package:user_app/state_management/reel_provider.dart';
import 'package:user_app/state_management/timelapse_provider.dart';
import 'package:user_app/state_management/user_provider.dart';
import 'package:user_app/state_management/content_provider.dart';
import 'package:user_app/ui/theme.dart';
import 'package:user_app/config/environment_config.dart';
import 'package:user_app/router/app_router.dart';
import 'package:user_app/services/cache_service.dart';

final GetIt getIt = GetIt.instance;

Future<void> startApp(EnvironmentConfig config) async {
  getIt.registerSingleton<EnvironmentConfig>(config);
  setupLocator();
  await getIt<CacheService>().init();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => getIt<AuthProvider>()),
        ChangeNotifierProvider(create: (_) => getIt<ReelProvider>()),
        ChangeNotifierProvider(create: (_) => getIt<TimelapseProvider>()),
        ChangeNotifierProvider(create: (_) => getIt<UserProvider>()),
        ChangeNotifierProvider(create: (_) => getIt<ContentProvider>()),
      ],
      child: const MyApp(),
    ),
  );
}

void main() async {
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    // Fallback if .env is missing
  }
  await startApp(EnvironmentConfig.development());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Plantita User App',
      theme: appTheme,
      routerConfig: appRouter,
    );
  }
}

void setupLocator() {
  // Register services
  getIt.registerLazySingleton<ApiService>(() => ApiService());
  getIt.registerLazySingleton<AuthService>(() => AuthService(getIt<ApiService>()));
  getIt.registerLazySingleton<ReelRepository>(() => ReelRepository(getIt<ApiService>()));
  getIt.registerLazySingleton<TimelapseRepository>(() => TimelapseRepository(getIt<ApiService>()));
  getIt.registerLazySingleton<UserRepository>(() => UserRepository(getIt<ApiService>(), getIt<ReelRepository>(), getIt<TimelapseRepository>()));
  getIt.registerLazySingleton<CommentRepository>(() => CommentRepository(getIt<ApiService>()));
  getIt.registerLazySingleton<ContentRepository>(() => ContentRepository(getIt<ApiService>()));
  getIt.registerLazySingleton<CacheService>(() => CacheService());

  // Register providers
  getIt.registerLazySingleton<AuthProvider>(() => AuthProvider(getIt<AuthService>()));
  getIt.registerLazySingleton<ReelProvider>(() => ReelProvider(getIt<ReelRepository>()));
  getIt.registerLazySingleton<TimelapseProvider>(() => TimelapseProvider(getIt<TimelapseRepository>()));
  getIt.registerLazySingleton<UserProvider>(() => UserProvider(getIt<UserRepository>()));
  getIt.registerLazySingleton<ContentProvider>(() => ContentProvider(getIt<ContentRepository>()));
}
