
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:user_app/state_management/user_provider.dart';
import 'package:user_app/ui/widgets/error_state_widget.dart';
import 'package:user_app/ui/widgets/responsive_grid_layout.dart';
import 'package:user_app/data/models/reel.dart';
import 'package:user_app/data/models/timelapse.dart';
import 'package:cached_network_image/cached_network_image.dart';

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
        title: const Semantics(
          label: 'User Profile screen title',
          child: Text('User Profile'),
        ),
        actions: [
          Semantics(
            button: true,
            label: 'Edit profile button',
            child: IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                // Navigate to edit profile screen
                context.go('/edit-profile');
              },
              tooltip: 'Edit Profile',
            ),
          ),
        ],
      ),
      body: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          if (userProvider.isLoading) {
            return const Semantics(
              label: 'Loading user profile',
              child: Center(child: CircularProgressIndicator()),
            );
          } else if (userProvider.errorMessage != null) {
            return Semantics(
              label: 'Error loading user profile',
              child: ErrorStateWidget(
                message: userProvider.errorMessage!,
                onRetry: () => userProvider.fetchUserProfileAndContent(widget.userId),
              ),
            );
          } else if (userProvider.userProfile == null) {
            return const Semantics(
              label: 'User profile not found',
              child: Center(child: Text('User profile not found.')),
            );
          } else {
            final user = userProvider.userProfile!;
            return SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Semantics(
                          label: 'User avatar',
                          child: CircleAvatar(
                            radius: 50,
                            backgroundImage: user.avatarUrl != null && user.avatarUrl!.isNotEmpty
                                ? CachedNetworkImageProvider(user.avatarUrl!)
                                : null,
                            child: user.avatarUrl == null || user.avatarUrl!.isEmpty
                                ? const Icon(Icons.person, size: 50)
                                : null,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Semantics(
                          label: 'Username: ${user.username}',
                          child: Text(
                            user.username,
                            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Semantics(
                          label: 'User bio: ${user.bio ?? 'No bio provided.'}',
                          child: Text(
                            'Bio: ${user.bio ?? 'No bio provided.'}',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Semantics(
                          label: 'Followers: ${user.followersCount} and Following: ${user.followingCount}',
                          child: Text(
                            'Followers: ${user.followersCount} | Following: ${user.followingCount}',
                          ),
                        ),
                        const SizedBox(height: 10),
                        Semantics(
                          label: 'Total Reels Uploaded: ${user.totalReelsUploaded} and Total Timelapses Uploaded: ${user.totalTimelapsesUploaded}',
                          child: Text('Total Reels: ${user.totalReelsUploaded} | Total Timelapses: ${user.totalTimelapsesUploaded}'),
                        ),
                        const SizedBox(height: 10),
                        Semantics(
                          label: 'Total Likes Received: ${user.totalLikesReceived}, Total Comments Received: ${user.totalCommentsReceived}, and Total Shares Received: ${user.totalSharesReceived}',
                          child: Text('Total Likes: ${user.totalLikesReceived} | Total Comments: ${user.totalCommentsReceived} | Total Shares: ${user.totalSharesReceived}'),
                        ),
                        const SizedBox(height: 10),
                        if (user.id != 'currentUserId') // Replace with actual current user ID check
                          Semantics(
                            button: true,
                            label: user.isFollowing ? 'Unfollow ${user.username}' : 'Follow ${user.username}',
                            child: ElevatedButton(
                              onPressed: user.isFollowing
                                  ? () => userProvider.unfollowUser(user.id)
                                  : () => userProvider.followUser(user.id),
                              child: Text(user.isFollowing ? 'Unfollow' : 'Follow'),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const Divider(),
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Semantics(
                      label: 'Uploaded Content section',
                      child: Text(
                        'Uploaded Content',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  if (userProvider.uploadedContent.isEmpty)
                    const Semantics(
                      label: 'No uploaded content available',
                      child: Center(child: Text('No uploaded content.')),
                    )
                  else
                    ResponsiveGridLayout(
                      children: userProvider.uploadedContent.map((content) {
                        String title = '';
                        if (content is Reel) {
                          title = content.title;
                        } else if (content is Timelapse) {
                          title = content.title;
                        }
                        return Semantics(
                          label: 'Uploaded content item: $title',
                          child: Card(
                            child: Center(
                              child: Text(title),
                            ),
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
