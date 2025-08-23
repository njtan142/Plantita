import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:user_app/features/home/home_screen.dart';
import 'package:user_app/ui/screens/login_screen.dart';
import 'package:user_app/ui/screens/register_screen.dart';
import 'package:user_app/services/auth_service.dart'; // Import AuthService
import 'package:user_app/main.dart'; // Import getIt

final GoRouter appRouter = GoRouter(
  redirect: (BuildContext context, GoRouterState state) {
    final authService = getIt<AuthService>();
    final isAuthenticated = authService.isAuthenticated;

    final loggingIn = state.uri.path == '/login';
    final registering = state.uri.path == '/register';

    // If not logged in, and not on the login/register page, redirect to login
    if (!isAuthenticated && !loggingIn && !registering) {
      return '/login';
    }
    // If logged in, and on the login/register page, redirect to home
    if (isAuthenticated && (loggingIn || registering)) {
      return '/';
    }

    // No redirect needed
    return null;
  },
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) {
        return const HomeScreen();
      },
    ),
    GoRoute(
      path: '/login',
      builder: (BuildContext context, GoRouterState state) {
        return const LoginScreen();
      },
    ),
    GoRoute(
      path: '/register',
      builder: (BuildContext context, GoRouterState state) {
        return const RegisterScreen();
      },
    ),
  ],
);
