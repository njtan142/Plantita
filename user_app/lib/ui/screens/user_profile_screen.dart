
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:user_app/state_management/user_provider.dart';
import 'package:user_app/ui/widgets/error_state_widget.dart';
import 'package:user_app/ui/widgets/responsive_grid_layout.dart';
import 'package:user_app/data/models/reel.dart';
import 'package:user_app/data/models/timelapse.dart';

class UserProfileScreen extends StatefulWidget {
  final String userId; // Assuming userId is passed as an argument

  const UserProfileScreen({Key? key, required this.userId}) : super(key: key);

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<UserProvider>(context, listen: false).fetchUserProfileAndContent(widget.userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // Navigate to edit profile screen
              context.go('/edit-profile');
            },
            tooltip: 'Edit Profile',
          ),
        ],
      ),
      body: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          if (userProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (userProvider.errorMessage != null) {
            return ErrorStateWidget(
              message: userProvider.errorMessage!,
              onRetry: () => userProvider.fetchUserProfileAndContent(widget.userId),
            );
          } else if (userProvider.userProfile == null) {
            return const Center(child: Text('User profile not found.'));
          } else {
            final user = userProvider.userProfile!;
            return SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundImage: user.avatarUrl != null && user.avatarUrl!.isNotEmpty
                              ? NetworkImage(user.avatarUrl!)
                              : null,
                          child: user.avatarUrl == null || user.avatarUrl!.isEmpty
                              ? const Icon(Icons.person, size: 50)
                              : null,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          user.username,
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Bio: ${user.bio ?? 'No bio provided.'}',
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Followers: ${user.followersCount} | Following: ${user.followingCount}',
                        ),
                        const SizedBox(height: 10),
                        Text('Total Reels: ${user.totalReelsUploaded} | Total Timelapses: ${user.totalTimelapsesUploaded}'),
                        const SizedBox(height: 10),
                        Text('Total Likes: ${user.totalLikesReceived} | Total Comments: ${user.totalCommentsReceived} | Total Shares: ${user.totalSharesReceived}'),
                        const SizedBox(height: 10),
                        if (user.id != 'currentUserId') // Replace with actual current user ID check
                          ElevatedButton(
                            onPressed: user.isFollowing
                                ? () => userProvider.unfollowUser(user.id)
                                : () => userProvider.followUser(user.id),
                            child: Text(user.isFollowing ? 'Unfollow' : 'Follow'),
                          ),
                      ],
                    ),
                  ),
                  const Divider(),
                    ),
                  ),
                  const Divider(),
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'Uploaded Content',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  if (userProvider.uploadedContent.isEmpty)
                    const Center(child: Text('No uploaded content.'))
                  else
                    ResponsiveGridLayout(
                      children: userProvider.uploadedContent.map((content) {
                        String title = '';
                        if (content is Reel) {
                          title = content.title;
                        } else if (content is Timelapse) {
                          title = content.title;
                        }
                        return Card(
                          child: Center(
                            child: Text(title),
                          ),
                        );
                      }).toList(),
                    ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
