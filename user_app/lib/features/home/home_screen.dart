import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:user_app/main.dart'; // Import getIt
import 'package:user_app/services/auth_service.dart'; // Import AuthService

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Screen'),
        actions: [
          TextButton(
            onPressed: () async {
              final authService = getIt<AuthService>();
              await authService.logout();
              GoRouter.of(context).go('/login');
            },
            child: const Text('Logout', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: const Center(
        child: Text('Welcome to the Home Screen!'),
      ),
    );
  }
}