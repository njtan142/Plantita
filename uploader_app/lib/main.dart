import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'providers/app_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/camera_provider.dart';
import 'providers/upload_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/camera/camera_screen.dart';
import 'screens/upload/upload_screen.dart';
import 'screens/user_selection/user_selection_screen.dart';
import 'constants/app_constants.dart';
import 'constants/theme_constants.dart';

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
        ChangeNotifierProvider(create: (_) => CameraProvider()),
        ChangeNotifierProvider(create: (_) => UploadProvider()),
      ],
      child: ScreenUtilInit(
        designSize: const Size(375, 812), // iPhone X dimensions
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return MaterialApp(
            title: AppConstants.appName,
            debugShowCheckedModeBanner: false,
            theme: ThemeConstants.lightTheme,
            darkTheme: ThemeConstants.darkTheme,
            themeMode: ThemeMode.system,
            builder: (context, child) => ResponsiveWrapper.builder(
              BouncingScrollWrapper.builder(context, child!),
              maxWidth: 1200,
              minWidth: 450,
              defaultScale: true,
              breakpoints: [
                const ResponsiveBreakpoint.resize(450, name: MOBILE),
                const ResponsiveBreakpoint.autoScale(800, name: TABLET),
                const ResponsiveBreakpoint.autoScale(1000, name: TABLET),
                const ResponsiveBreakpoint.resize(1200, name: DESKTOP),
                const ResponsiveBreakpoint.autoScale(2460, name: "4K"),
              ],
              background: Container(color: const Color(0xFFF5F5F5)),
            ),
            initialRoute: AppConstants.loginRoute,
            routes: {
              AppConstants.loginRoute: (context) => const LoginScreen(),
              AppConstants.registerRoute: (context) => const RegisterScreen(),
              AppConstants.homeRoute: (context) => const HomeScreen(),
              AppConstants.cameraRoute: (context) => const CameraScreen(),
              AppConstants.uploadRoute: (context) => const UploadScreen(),
              AppConstants.userSelectionRoute: (context) => const UserSelectionScreen(),
            },
          );
        },
      ),
    );
  }
}
