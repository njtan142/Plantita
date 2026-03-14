import 'dart:convert';
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

      // Default stubs
      when(mockPrefs.getString(any)).thenReturn(null);
      when(mockPrefs.getInt(any)).thenReturn(null);
      when(mockPrefs.setString(any, any)).thenAnswer((_) async => true);
      when(mockPrefs.setInt(any, any)).thenAnswer((_) async => true);
      when(mockPrefs.remove(any)).thenAnswer((_) async => true);

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
          id: 1,
          username: 'cacheduser',
          email: 'cached@example.com',
          firstName: 'Cached',
          lastName: 'User',
          isActive: true,
          createdAt: DateTime.now(),
        ),
      ];

      // Simulate cached data
      userService.setCachedUsersForTesting(cachedUsers);
      userService.setLastFetchTimeForTesting(DateTime.now().subtract(const Duration(minutes: 15)));

      // Act
      final result = await userService.fetchUsers();

      // Assert
      expect(result.success, true);
      expect(result.data, cachedUsers);
      verifyNever(mockHttpClient.get<PaginatedResponse<UserModel>>(
        any, 
        headers: anyNamed('headers'),
        queryParams: anyNamed('queryParams'),
        fromJson: anyNamed('fromJson'),
        retryOnFailure: anyNamed('retryOnFailure'),
      ));
    });

    test('fetchUsers fetches fresh data when forceRefresh is true', () async {
      // Arrange
      final apiUsers = [
        UserModel(
          id: 2,
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

      when(mockHttpClient.get<PaginatedResponse<UserModel>>(
        any, 
        headers: anyNamed('headers'),
        queryParams: anyNamed('queryParams'),
        fromJson: anyNamed('fromJson'),
        retryOnFailure: anyNamed('retryOnFailure'),
      )).thenAnswer((_) async => apiResponse);

      // Act
      final result = await userService.fetchUsers(forceRefresh: true);

      // Assert
      expect(result.success, true);
      expect(result.data, apiUsers);
      expect(userService.currentUsers, apiUsers);
    });

    test('fetchUsers handles API errors gracefully', () async {
      // Arrange
      final errorResponse = ApiResponse<PaginatedResponse<UserModel>>.error(message: 'API Error');
      when(mockHttpClient.get<PaginatedResponse<UserModel>>(
        any, 
        headers: anyNamed('headers'),
        queryParams: anyNamed('queryParams'),
        fromJson: anyNamed('fromJson'),
        retryOnFailure: anyNamed('retryOnFailure'),
      )).thenAnswer((_) async => errorResponse);

      // Act
      final result = await userService.fetchUsers(forceRefresh: true);

      // Assert
      expect(result.success, false);
      expect(result.message, 'API Error');
      expect(userService.isLoading, false);
    });

    test('fetchUsers catches exceptions and returns error response', () async {
      // Arrange
      when(mockHttpClient.get<PaginatedResponse<UserModel>>(
        any, 
        headers: anyNamed('headers'),
        queryParams: anyNamed('queryParams'),
        fromJson: anyNamed('fromJson'),
        retryOnFailure: anyNamed('retryOnFailure'),
      )).thenThrow(Exception('Network failure'));

      // Act
      final result = await userService.fetchUsers(forceRefresh: true);

      // Assert
      expect(result.success, false);
      expect(result.message, contains('Failed to fetch users: Exception: Network failure'));
      expect(userService.isLoading, false);
    });

    test('searchUsers returns filtered cached results for non-empty query', () async {
      // Arrange
      final cachedUsers = [
        UserModel(
          id: 1,
          username: 'john',
          email: 'john@example.com',
          firstName: 'John',
          lastName: 'Doe',
          isActive: true,
          createdAt: DateTime.now(),
        ),
        UserModel(
          id: 2,
          username: 'jane',
          email: 'jane@example.com',
          firstName: 'Jane',
          lastName: 'Smith',
          isActive: true,
          createdAt: DateTime.now(),
        ),
      ];
      userService.setCachedUsersForTesting(cachedUsers);

      final searchResult = [cachedUsers[0]];
      final apiResponse = ApiResponse<List<UserModel>>.success(searchResult);

      when(mockHttpClient.get<List<UserModel>>(
        any,
        headers: anyNamed('headers'),
        queryParams: anyNamed('queryParams'),
        fromJson: anyNamed('fromJson'),
        retryOnFailure: anyNamed('retryOnFailure'),
      )).thenAnswer((_) async => apiResponse);

      // Act
      final result = await userService.searchUsers('john');

      // Assert
      expect(result.success, true);
      expect(result.data?.length, 1);
      expect(result.data?[0].username, 'john');
    });

    test('getUserById returns cached user if available', () async {
      // Arrange
      final user = UserModel(
        id: 1,
        username: 'testuser',
        email: 'test@example.com',
        firstName: 'Test',
        lastName: 'User',
        isActive: true,
        createdAt: DateTime.now(),
      );
      userService.setCachedUsersForTesting([user]);

      // Act
      final result = await userService.getUserById(1);

      // Assert
      expect(result.success, true);
      expect(result.data, user);
      verifyNever(mockHttpClient.get<UserModel>(any, fromJson: anyNamed('fromJson')));
    });

    test('getUserById fetches from API if not in cache', () async {
      // Arrange
      final user = UserModel(
        id: 1,
        username: 'apiuser',
        email: 'api@example.com',
        firstName: 'API',
        lastName: 'User',
        isActive: true,
        createdAt: DateTime.now(),
      );
      final apiResponse = ApiResponse.success(user);

      when(mockHttpClient.get<UserModel>(
        any,
        headers: anyNamed('headers'),
        queryParams: anyNamed('queryParams'),
        fromJson: anyNamed('fromJson'),
        retryOnFailure: anyNamed('retryOnFailure'),
      )).thenAnswer((_) async => apiResponse);

      // Act
      final result = await userService.getUserById(1);

      // Assert
      expect(result.success, true);
      expect(result.data?.username, 'apiuser');
    });

    test('clearCache removes data from SharedPreferences', () async {
      // Act
      await userService.clearCache();

      // Assert
      verify(mockPrefs.remove('cached_users')).called(1);
      verify(mockPrefs.remove('users_cache_timestamp')).called(1);
      expect(userService.currentUsers, isEmpty);
    });

    test('refreshUsers forces data refresh', () async {
      // Arrange
      final freshUsers = [
        UserModel(
          id: 3,
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
        items: freshUsers,
        meta: PaginationMeta(
          currentPage: 1,
          totalPages: 1,
          totalItems: 1,
          perPage: 10,
          hasNextPage: false,
          hasPrevPage: false,
        ),
      );
      
      when(mockHttpClient.get<PaginatedResponse<UserModel>>(
        any,
        headers: anyNamed('headers'),
        queryParams: anyNamed('queryParams'),
        fromJson: anyNamed('fromJson'),
        retryOnFailure: anyNamed('retryOnFailure'),
      )).thenAnswer((_) async => ApiResponse.success(paginatedResponse));

      // Act
      await userService.refreshUsers();

      // Assert
      expect(userService.currentUsers, freshUsers);
    });

    test('getUserStats returns correct statistics', () {
      // Arrange
      final users = [
        UserModel(id: 1, username: 'user1', email: 'u1@e.com', firstName: 'U1', lastName: 'L1', isActive: true, createdAt: DateTime.now()),
        UserModel(id: 2, username: 'user2', email: 'u2@e.com', firstName: 'U2', lastName: 'L2', isActive: false, createdAt: DateTime.now()),
      ];
      userService.setCachedUsersForTesting(users);

      // Act
      final stats = userService.getUserStats();

      // Assert
      expect(stats.totalUsers, 2);
      expect(stats.activeUsers, 1);
      expect(stats.inactiveUsers, 1);
    });

    test('usersStream emits updates when users are updated', () async {
      // Arrange
      final users = [
        UserModel(id: 1, username: 'testuser', email: 'test@example.com', firstName: 'Test', lastName: 'User', isActive: true, createdAt: DateTime.now()),
      ];
      final userUpdates = <List<UserModel>>[];
      userService.usersStream.listen(userUpdates.add);

      // Act
      userService.addUsersUpdateForTesting(users);
      
      // Wait for stream events
      await Future.delayed(const Duration(milliseconds: 10));

      // Assert
      expect(userUpdates.length, 1);
      expect(userUpdates[0].length, 1);
      expect(userUpdates[0][0].username, 'testuser');
    });
  });
}
