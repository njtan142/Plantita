import '../models/user_model.dart';

/// Internal model for optimized user searching
class CachedSearchUser {
  final UserModel user;
  final String usernameLower;
  final String firstNameLower;
  final String lastNameLower;
  final String emailLower;

  CachedSearchUser(this.user)
      : usernameLower = user.username.toLowerCase(),
        firstNameLower = user.firstName.toLowerCase(),
        lastNameLower = user.lastName.toLowerCase(),
        emailLower = user.email.toLowerCase();
}

/// User statistics model
class UserStats {
  final int totalUsers;
  final int activeUsers;
  final int inactiveUsers;
  final int recentUsers;

  const UserStats({
    required this.totalUsers,
    required this.activeUsers,
    required this.inactiveUsers,
    required this.recentUsers,
  });

  @override
  String toString() {
    return 'UserStats(total: $totalUsers, active: $activeUsers, inactive: $inactiveUsers, recent: $recentUsers)';
  }
}
