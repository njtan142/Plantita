import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:responsive_framework/responsive_framework.dart';

import 'providers/app_provider.dart';
import 'providers/auth_provider.dart';
import 'constants/app_constants.dart';
import 'constants/theme_constants.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const PlantitaUploaderApp());
}

class PlantitaUploaderApp extends StatelessWidget {
  const PlantitaUploaderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: MaterialApp(
        builder: (context, child) => ResponsiveWrapper.builder(
          child,
          maxWidth: 1200,
          minWidth: 480,
          defaultScale: true,
          breakpoints: [
            const ResponsiveBreakpoint.resize(480, name: MOBILE),
            const ResponsiveBreakpoint.autoScale(800, name: TABLET),
            const ResponsiveBreakpoint.resize(1000, name: DESKTOP),
          ],
        ),
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: ThemeConstants.lightTheme,
        darkTheme: ThemeConstants.darkTheme,
        themeMode: ThemeMode.system,
        initialRoute: AppConstants.loginRoute,
        routes: {
          AppConstants.loginRoute: (context) => const LoginScreen(),
          AppConstants.homeRoute: (context) => const HomeScreen(),
        },
      ),
    );
  }
}
