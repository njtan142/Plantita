import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:user_app/features/home/home_screen.dart';
import 'package:user_app/ui/screens/login_screen.dart';
import 'package:user_app/ui/screens/register_screen.dart';
import 'package:user_app/ui/screens/timelapse_comparison_screen.dart'; // Import the new screen
import 'package:user_app/ui/screens/reel_detail_screen.dart';
import 'package:user_app/ui/screens/timelapse_detail_screen.dart';
import 'package:user_app/data/models/reel.dart';
import 'package:user_app/data/models/timelapse.dart'; // Import Timelapse model
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
    GoRoute(
      path: '/profile/:userId',
      builder: (BuildContext context, GoRouterState state) {
        final userId = state.pathParameters['userId']!;
        return UserProfileScreen(userId: userId);
      },
    ),
    GoRoute(
      path: '/edit-profile',
      builder: (BuildContext context, GoRouterState state) {
        return const EditProfileScreen();
      },
    ),
    GoRoute(
      path: '/playlists',
      builder: (BuildContext context, GoRouterState state) {
        return const PlaylistScreen();
      },
      routes: <RouteBase>[
        GoRoute(
          path: ':playlistId',
          builder: (BuildContext context, GoRouterState state) {
            final playlistId = state.pathParameters['playlistId']!;
            return PlaylistDetailScreen(playlistId: playlistId);
          },
        ),
      ],
    ),
    GoRoute(
      path: '/compare-timelapses',
      builder: (BuildContext context, GoRouterState state) {
        final timelapses = state.extra as Map<String, Timelapse>;
        return TimelapseComparisonScreen(
          timelapse1: timelapses['timelapse1']!,
          timelapse2: timelapses['timelapse2']!,
        );
      },
    ),
    GoRoute(
      path: '/reels/:reelId',
      builder: (BuildContext context, GoRouterState state) {
        final reel = state.extra as Reel;
        return ReelDetailScreen(reel: reel);
      },
    ),
    GoRoute(
      path: '/timelapses/:timelapseId',
      builder: (BuildContext context, GoRouterState state) {
        final timelapse = state.extra as Timelapse;
        return TimelapseDetailScreen(timelapse: timelapse);
      },
    ),
  ],
);
