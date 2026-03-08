import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:user_app/main.dart'; // Import getIt
import 'package:user_app/services/auth_service.dart'; // Import AuthService
import 'package:user_app/ui/screens/reels_view.dart';
import 'package:user_app/ui/screens/timelapse_gallery.dart';
import 'package:user_app/ui/screens/content_discovery_screen.dart';
import 'package:user_app/ui/screens/user_profile_screen.dart';
import 'package:user_app/ui/screens/playlist_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late PageController _pageController;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _pageController.jumpToPage(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plantita App'),
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
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        children: const [
          // Placeholder for a general home/feed screen
          Center(child: Text('Main Feed')),
          ReelsView(),
          TimelapseGallery(),
          ContentDiscoveryScreen(),
          // UserProfileScreen(userId: 'currentUserId'), // Requires current user ID
          // PlaylistScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.movie),
            label: 'Reels',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.timelapse),
            label: 'Timelapses',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.explore),
            label: 'Discover',
          ),
          // BottomNavigationBarItem(
          //   icon: Icon(Icons.person),
          //   label: 'Profile',
          // ),
          // BottomNavigationBarItem(
          //   icon: Icon(Icons.playlist_play),
          //   label: 'Playlists',
          // ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
}