import 'package:flutter/material.dart';
import 'package:user_app/features/home/home_screen.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:user_app/services/api_service.dart';
import 'package:user_app/services/auth_service.dart';
import 'package:user_app/data/repositories/user_repository.dart';
import 'package:user_app/data/repositories/reel_repository.dart';
import 'package:user_app/data/repositories/timelapse_repository.dart';
import 'package:user_app/data/repositories/comment_repository.dart';
import 'package:user_app/state_management/auth_provider.dart';
import 'package:user_app/state_management/reel_provider.dart';
import 'package:user_app/ui/theme.dart'; // Import the theme

final GetIt getIt = GetIt.instance;

void main() {
  setupLocator();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => getIt<AuthProvider>()),
        ChangeNotifierProvider(create: (_) => getIt<ReelProvider>()),
        // Add other providers here
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: appTheme, // Use the defined theme
      home: const HomeScreen(),
    );
  }
}


void setupLocator() {
  // Register services here
  getIt.registerLazySingleton<ApiService>(() => ApiService());
  getIt.registerLazySingleton<AuthService>(() => AuthService(getIt<ApiService>()));
  getIt.registerLazySingleton<UserRepository>(() => UserRepository());
  getIt.registerLazySingleton<ReelRepository>(() => ReelRepository());
  getIt.registerLazySingleton<TimelapseRepository>(() => TimelapseRepository());
  getIt.registerLazySingleton<CommentRepository>(() => CommentRepository());

  // Register providers
  getIt.registerLazySingleton<AuthProvider>(() => AuthProvider(getIt<AuthService>()));
  getIt.registerLazySingleton<ReelProvider>(() => ReelProvider(getIt<ReelRepository>()));
}


