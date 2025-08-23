import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:user_app/features/home/home_screen.dart';
import 'package:user_app/ui/screens/login_screen.dart';
import 'package:user_app/ui/screens/register_screen.dart';

final GoRouter appRouter = GoRouter(
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
