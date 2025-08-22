import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:uploader_app/models/models.dart';
import 'package:uploader_app/services/services.dart';
import '../mocks/mocks.mocks.dart';

void main() {
  group('UserService Tests', () {
    late MockHttpClientService mockHttpClient;
    late MockSharedPreferences mockPrefs;
    late UserService userService;

    setUp(() {
      mockHttpClient = MockHttpClientService();
      mockPrefs = MockSharedPreferences();
      userService = UserService(
        httpClient: mockHttpClient,
        prefs: mockPrefs,
      );
    });

    tearDown(() {
      reset(mockHttpClient);
      reset(mockPrefs);
    });

    test('initialize loads cached users successfully', () async {
      // Arrange
      final cachedUsersJson = '[{"id": 1, "username": "cacheduser", "email": "cached@example.com", "first_name": "Cached", "last_name": "User", "is_active": true, "created_at": "${DateTime.now().toIso8601String()}"}]';
      final timestamp = DateTime.now().millisecondsSinceEpoch;

      when(mockPrefs.getString('cached_users')).thenReturn(cachedUsersJson);
      when(mockPrefs.getInt('users_cache_timestamp')).thenReturn(timestamp);

      // Act
      await userService.initialize();

      // Assert
      expect(userService.currentUsers.length, 1);
      expect(userService.currentUsers[0].username, 'cacheduser');
      expect(userService.isLoading, false);
    });

    test('fetchUsers returns cached data when valid', () async {
      // Arrange
      final cachedUsers = [
        UserModel(
          id: '1',
          username: 'cacheduser',
          email: 'cached@example.com',
          firstName: 'Cached',
          lastName: 'User',
          isActive: true,
          createdAt: DateTime.now(),
        ),
      ];

      userService = UserService(
        httpClient: mockHttpClient,
        prefs: mockPrefs,
      );

      // Simulate cached data
      userService = UserService(
        httpClient: mockHttpClient,
        prefs: mockPrefs,
      );
      userService.setCachedUsersForTesting(cachedUsers);
      userService.setLastFetchTimeForTesting(DateTime.now().subtract(const Duration(minutes: 15)));

      // Act
      final result = await userService.fetchUsers();

      // Assert
      expect(result.success, true);
      expect(result.data, cachedUsers);
      verifyNever(mockHttpClient.get<PaginatedResponse<UserModel>>(any, fromJson: anyNamed('fromJson')));
    });

    test('fetchUsers fetches fresh data when forceRefresh is true', () async {
      // Arrange
      final apiUsers = [
        UserModel(
          id: '2',
          username: 'apiuser',
          email: 'api@example.com',
          firstName: 'API',
          lastName: 'User',
          isActive: true,
          createdAt: DateTime.now(),
        ),
      ];
      final paginatedResponse = PaginatedResponse(
        success: true,
        items: apiUsers,
        meta: PaginationMeta(
          currentPage: 1,
          totalPages: 1,
          totalItems: 1,
          perPage: 10,
          hasNextPage: false,
          hasPrevPage: false,
        ),
      );
      final apiResponse = ApiResponse.success(paginatedResponse);

      when(mockHttpClient.get<PaginatedResponse<UserModel>>(any, fromJson: anyNamed('fromJson')))
          .thenAnswer((_) async => apiResponse);
      when(mockPrefs.setString(any, any)).thenAnswer((_) async {});
      when(mockPrefs.setInt(any, any)).thenAnswer((_) async {});

      // Act
      final result = await userService.fetchUsers(forceRefresh: true);

      // Assert
      expect(result.success, true);
      expect(result.data, apiUsers);
      expect(userService.currentUsers, apiUsers);
      verify(mockHttpClient.get<PaginatedResponse<UserModel>>(any, fromJson: anyNamed('fromJson'))).called(1);
    });

    test('fetchUsers handles API errors gracefully', () async {
      // Arrange
      final errorResponse = ApiResponse.error(message: 'API Error');

      when(mockHttpClient.get<PaginatedResponse<UserModel>>(any, fromJson: anyNamed('fromJson')))
          .thenAnswer((_) async => errorResponse);

      // Act
      final result = await userService.fetchUsers(forceRefresh: true);

      // Assert
      expect(result.success, false);
      expect(result.message, 'API Error');
      expect(userService.isLoading, false);
    });

    test('searchUsers returns filtered cached results for non-empty query', () async {
      // Arrange
      final users = [
        UserModel(
          id: '1',
          username: 'john_doe',
          email: 'john@example.com',
          firstName: 'John',
          lastName: 'Doe',
          isActive: true,
          createdAt: DateTime.now(),
        ),
        UserModel(
          id: '2',
          username: 'jane_smith',
          email: 'jane@example.com',
          firstName: 'Jane',
          lastName: 'Smith',
          isActive: true,
          createdAt: DateTime.now(),
        ),
      ];

      userService = UserService(
        httpClient: mockHttpClient,
        prefs: mockPrefs,
      ).._cachedUsers = users;

      // Act
      final result = await userService.searchUsers('john');

      // Assert
      expect(result.success, true);
      expect(result.data?.length, 1);
      expect(result.data?[0].username, 'john_doe');
    });

    test('searchUsers returns all cached results for empty query', () async {
      // Arrange
      final users = [
        UserModel(
          id: '1',
          username: 'user1',
          email: 'user1@example.com',
          firstName: 'User',
          lastName: 'One',
          isActive: true,
          createdAt: DateTime.now(),
        ),
      ];

      userService = UserService(
        httpClient: mockHttpClient,
        prefs: mockPrefs,
      ).._cachedUsers = users;

      // Act
      final result = await userService.searchUsers('');

      // Assert
      expect(result.success, true);
      expect(result.data, users);
    });

    test('getUserById returns cached user if available', () async {
      // Arrange
      final users = [
        UserModel(
          id: '1',
          username: 'cacheduser',
          email: 'cached@example.com',
          firstName: 'Cached',
          lastName: 'User',
          isActive: true,
          createdAt: DateTime.now(),
        ),
      ];

      userService = UserService(
        httpClient: mockHttpClient,
        prefs: mockPrefs,
      ).._cachedUsers = users;

      // Act
      final result = await userService.getUserById(1);

      // Assert
      expect(result.success, true);
      expect(result.data?.username, 'cacheduser');
      verifyNever(mockHttpClient.get<UserModel>(any, fromJson: anyNamed('fromJson')));
    });

    test('getUserById fetches from API when not cached', () async {
      // Arrange
      final apiUser = UserModel(
        id: '2',
        username: 'apiuser',
        email: 'api@example.com',
        firstName: 'API',
        lastName: 'User',
        isActive: true,
        createdAt: DateTime.now(),
      );
      final apiResponse = ApiResponse.success(apiUser);

      when(mockHttpClient.get<UserModel>(any, fromJson: anyNamed('fromJson')))
          .thenAnswer((_) async => apiResponse);
      when(mockPrefs.setString(any, any)).thenAnswer((_) async {});
      when(mockPrefs.setInt(any, any)).thenAnswer((_) async {});

      // Act
      final result = await userService.getUserById(2);

      // Assert
      expect(result.success, true);
      expect(result.data?.username, 'apiuser');
      expect(userService.currentUsers.contains(apiUser), true);
    });

    test('filterUsers filters by username correctly', () {
      // Arrange
      final users = [
        UserModel(
          id: '1',
          username: 'john_doe',
          email: 'john@example.com',
          firstName: 'John',
          lastName: 'Doe',
          isActive: true,
          createdAt: DateTime.now(),
        ),
        UserModel(
          id: '2',
          username: 'jane_smith',
          email: 'jane@example.com',
          firstName: 'Jane',
          lastName: 'Smith',
          isActive: true,
          createdAt: DateTime.now(),
        ),
      ];

      userService = UserService(
        httpClient: mockHttpClient,
        prefs: mockPrefs,
      );
      userService.setCachedUsersForTesting(users);

      // Act
      final filteredUsers = userService.filterUsers(username: 'john');

      // Assert
      expect(filteredUsers.length, 1);
      expect(filteredUsers[0].username, 'john_doe');
    });

    test('filterUsers filters by multiple criteria', () {
      // Arrange
      final users = [
        UserModel(
          id: '1',
          username: 'john_doe',
          email: 'john@example.com',
          firstName: 'John',
          lastName: 'Doe',
          isActive: true,
          createdAt: DateTime.now(),
        ),
        UserModel(
          id: '2',
          username: 'jane_smith',
          email: 'jane@example.com',
          firstName: 'Jane',
          lastName: 'Smith',
          isActive: false,
          createdAt: DateTime.now(),
        ),
      ];

      userService = UserService(
        httpClient: mockHttpClient,
        prefs: mockPrefs,
      );
      userService.setCachedUsersForTesting(users);

      // Act
      final filteredUsers = userService.filterUsers(
        firstName: 'Jane',
        isActive: false,
      );

      // Assert
      expect(filteredUsers.length, 1);
      expect(filteredUsers[0].username, 'jane_smith');
    });

    test('getUsersForSelection returns only active users', () {
      // Arrange
      final users = [
        UserModel(
          id: '1',
          username: 'active_user',
          email: 'active@example.com',
          firstName: 'Active',
          lastName: 'User',
          isActive: true,
          createdAt: DateTime.now(),
        ),
        UserModel(
          id: '2',
          username: 'inactive_user',
          email: 'inactive@example.com',
          firstName: 'Inactive',
          lastName: 'User',
          isActive: false,
          createdAt: DateTime.now(),
        ),
      ];

      userService = UserService(
        httpClient: mockHttpClient,
        prefs: mockPrefs,
      ).._cachedUsers = users;

      // Act
      final selectableUsers = userService.getUsersForSelection();

      // Assert
      expect(selectableUsers.length, 1);
      expect(selectableUsers[0].username, 'active_user');
    });

    test('getUsersForSelection filters by search query', () {
      // Arrange
      final users = [
        UserModel(
          id: '1',
          username: 'john_doe',
          email: 'john@example.com',
          firstName: 'John',
          lastName: 'Doe',
          isActive: true,
          createdAt: DateTime.now(),
        ),
        UserModel(
          id: '2',
          username: 'jane_smith',
          email: 'jane@example.com',
          firstName: 'Jane',
          lastName: 'Smith',
          isActive: true,
          createdAt: DateTime.now(),
        ),
      ];

      userService = UserService(
        httpClient: mockHttpClient,
        prefs: mockPrefs,
      ).._cachedUsers = users;

      // Act
      final filteredUsers = userService.getUsersForSelection(searchQuery: 'john');

      // Assert
      expect(filteredUsers.length, 1);
      expect(filteredUsers[0].username, 'john_doe');
    });

    test('refreshUsers forces data refresh', () async {
      // Arrange
      final apiUsers = [
        UserModel(
          id: '3',
          username: 'refreshed_user',
          email: 'refreshed@example.com',
          firstName: 'Refreshed',
          lastName: 'User',
          isActive: true,
          createdAt: DateTime.now(),
        ),
      ];
      final paginatedResponse = PaginatedResponse(
        success: true,
        items: apiUsers,
        meta: PaginationMeta(
          currentPage: 1,
          totalPages: 1,
          totalItems: 1,
          perPage: 10,
          hasNextPage: false,
          hasPrevPage: false,
        ),
      );

      when(mockHttpClient.get<PaginatedResponse<UserModel>>(any, fromJson: anyNamed('fromJson')))
          .thenAnswer((_) async => ApiResponse.success(paginatedResponse));
      when(mockPrefs.setString(any, any)).thenAnswer((_) async {});
      when(mockPrefs.setInt(any, any)).thenAnswer((_) async {});

      // Act
      await userService.refreshUsers();

      // Assert
      expect(userService.currentUsers, apiUsers);
      verify(mockHttpClient.get<PaginatedResponse<UserModel>>(any, fromJson: anyNamed('fromJson'))).called(1);
    });

    test('clearCache removes all cached data', () async {
      // Arrange
      userService = UserService(
        httpClient: mockHttpClient,
        prefs: mockPrefs,
      ).._cachedUsers = [
        UserModel(
          id: '1',
          username: 'testuser',
          email: 'test@example.com',
          firstName: 'Test',
          lastName: 'User',
          isActive: true,
          createdAt: DateTime.now(),
        ),
      ];

      when(mockPrefs.remove('cached_users')).thenAnswer((_) async {});
      when(mockPrefs.remove('users_cache_timestamp')).thenAnswer((_) async {});

      // Act
      await userService.clearCache();

      // Assert
      expect(userService.currentUsers.isEmpty, true);
      expect(userService._lastFetchTime, null);
      verify(mockPrefs.remove('cached_users')).called(1);
      verify(mockPrefs.remove('users_cache_timestamp')).called(1);
    });

    test('getUserStats returns correct statistics', () {
      // Arrange
      final users = [
        UserModel(
          id: '1',
          username: 'active_user',
          email: 'active@example.com',
          firstName: 'Active',
          lastName: 'User',
          isActive: true,
          createdAt: DateTime.now().subtract(const Duration(days: 5)),
        ),
        UserModel(
          id: '2',
          username: 'inactive_user',
          email: 'inactive@example.com',
          firstName: 'Inactive',
          lastName: 'User',
          isActive: false,
          createdAt: DateTime.now().subtract(const Duration(days: 10)),
        ),
        UserModel(
          id: '3',
          username: 'recent_user',
          email: 'recent@example.com',
          firstName: 'Recent',
          lastName: 'User',
          isActive: true,
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
      ];

      userService = UserService(
        httpClient: mockHttpClient,
        prefs: mockPrefs,
      ).._cachedUsers = users;

      // Act
      final stats = userService.getUserStats();

      // Assert
      expect(stats.totalUsers, 3);
      expect(stats.activeUsers, 2);
      expect(stats.inactiveUsers, 1);
      expect(stats.recentUsers, 1); // User created within last 7 days
    });

    test('dispose closes all stream controllers', () {
      // Arrange
      userService = UserService(
        httpClient: mockHttpClient,
        prefs: mockPrefs,
      );

      // Act
      userService.dispose();

      // Assert - Should not throw any errors
      expect(() => userService.dispose(), returnsNormally);
    });

    test('loadingStream emits loading states correctly', () async {
      // Arrange
      final loadingStates = <bool>[];

      userService.loadingStream.listen(loadingStates.add);

      // Act
      userService._loadingController.add(true);
      userService._loadingController.add(false);

      // Wait for stream events
      await Future.delayed(const Duration(milliseconds: 10));

      // Assert
      expect(loadingStates, [true, false]);
    });

    test('usersStream emits user updates correctly', () async {
      // Arrange
      final userUpdates = <List<UserModel>>[];
      final testUser = UserModel(
        id: '1',
        username: 'testuser',
        email: 'test@example.com',
        firstName: 'Test',
        lastName: 'User',
        isActive: true,
        createdAt: DateTime.now(),
      );

      userService.usersStream.listen(userUpdates.add);

      // Act
      userService._usersController.add([testUser]);

      // Wait for stream events
      await Future.delayed(const Duration(milliseconds: 10));

      // Assert
      expect(userUpdates.length, 1);
      expect(userUpdates[0].length, 1);
      expect(userUpdates[0][0].username, 'testuser');
    });
  });
}