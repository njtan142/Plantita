import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:uploader_app/models/auth_token_model.dart';

void main() {
  group('AuthTokenModel Model Tests', () {
    const testTokenJson = {
      'access_token': 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoxLCJ1c2VybmFtZSI6InRlc3R1c2VyIiwicm9sZSI6InVzZXIiLCJwZXJtaXNzaW9ucyI6WyJ1cGxvYWQiXSwiZXhwIjoxNzM1Njg5NjAwfQ.test_signature',
      'refresh_token': 'refresh_token_123',
      'token_type': 'Bearer',
      'scope': 'read write',
      'expires_in': 3600,
    };

    const expiredTokenJson = {
      'access_token': 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoxLCJ1c2VybmFtZSI6InRlc3R1c2VyIiwicm9sZSI6InVzZXIiLCJwZXJtaXNzaW9ucyI6WyJ1cGxvYWQiXSwiZXhwIjoxNjA5NDg5NjAwfQ.expired_signature',
      'refresh_token': 'refresh_token_456',
      'token_type': 'Bearer',
      'expires_in': 3600,
    };

    test('AuthTokenModel.fromMap creates AuthTokenModel correctly', () {
      final token = AuthTokenModel.fromMap(testTokenJson);

      expect(token.accessToken, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoxLCJ1c2VybmFtZSI6InRlc3R1c2VyIiwicm9sZSI6InVzZXIiLCJwZXJtaXNzaW9ucyI6WyJ1cGxvYWQiXSwiZXhwIjoxNzM1Njg5NjAwfQ.test_signature');
      expect(token.refreshToken, 'refresh_token_123');
      expect(token.tokenType, 'Bearer');
      expect(token.isExpired, false);
    });

    test('AuthTokenModel.fromMap handles minimal JSON', () {
      final minimalJson = {
        'access_token': 'access_token_123',
        'refresh_token': 'refresh_token_456',
      };

      final token = AuthTokenModel.fromMap(minimalJson);

      expect(token.accessToken, 'access_token_123');
      expect(token.refreshToken, 'refresh_token_456');
      expect(token.tokenType, 'Bearer'); // default value
    });

    test('AuthTokenModel.fromMap with expires_at field', () {
      // Use ISO 8601 string to avoid precision issues
      final futureDateStr = DateTime.now().add(const Duration(hours: 2)).toIso8601String();
      final futureDate = DateTime.parse(futureDateStr);
      
      final jsonWithExpiresAt = {
        'access_token': 'access_token_123',
        'refresh_token': 'refresh_token_456',
        'expires_at': futureDateStr,
        'token_type': 'Bearer',
      };

      final token = AuthTokenModel.fromMap(jsonWithExpiresAt);

      expect(token.accessToken, 'access_token_123');
      expect(token.refreshToken, 'refresh_token_456');
      expect(token.tokenType, 'Bearer');
      expect(token.expiresAt, futureDate);
    });

    test('AuthTokenModel.toMap converts AuthTokenModel to Map correctly', () {
      final expiresAtStr = DateTime.now().add(const Duration(hours: 1)).toIso8601String();
      final expiresAt = DateTime.parse(expiresAtStr);
      
      final token = AuthTokenModel(
        accessToken: 'access_token_123',
        refreshToken: 'refresh_token_456',
        expiresAt: expiresAt,
        tokenType: 'Bearer',
      );

      final json = token.toMap();

      expect(json['access_token'], 'access_token_123');
      expect(json['refresh_token'], 'refresh_token_456');
      expect(json['token_type'], 'Bearer');
      expect(json['scope'], 'read write');
      expect(json['expires_at'], expiresAtStr);
    });

    test('AuthTokenModel.isExpired returns false for future expiration', () {
      final futureDate = DateTime.now().add(const Duration(hours: 1));
      final token = AuthTokenModel(
        accessToken: 'access_token_123',
        refreshToken: 'refresh_token_456',
        expiresAt: futureDate,
      );

      expect(token.isExpired, false);
    });

    test('AuthTokenModel.isExpired returns true for past expiration', () {
      final pastDate = DateTime.now().subtract(const Duration(hours: 1));
      final token = AuthTokenModel(
        accessToken: 'access_token_123',
        refreshToken: 'refresh_token_456',
        expiresAt: pastDate,
      );

      expect(token.isExpired, true);
    });

    test('AuthTokenModel.willExpireIn returns correct values', () {
      final token = AuthTokenModel(
        accessToken: 'access_token_123',
        refreshToken: 'refresh_token_456',
        expiresAt: DateTime.now().add(const Duration(minutes: 30)),
      );

      expect(token.willExpireIn(const Duration(minutes: 15)), false);
      expect(token.willExpireIn(const Duration(minutes: 45)), true);
    });

    test('AuthTokenModel.needsRefresh returns true when expires within 5 minutes', () {
      final token = AuthTokenModel(
        accessToken: 'access_token_123',
        refreshToken: 'refresh_token_456',
        expiresAt: DateTime.now().add(const Duration(minutes: 3)),
      );

      expect(token.needsRefresh, true);
    });

    test('AuthTokenModel.needsRefresh returns false when expires after 5 minutes', () {
      final token = AuthTokenModel(
        accessToken: 'access_token_123',
        refreshToken: 'refresh_token_456',
        expiresAt: DateTime.now().add(const Duration(minutes: 10)),
      );

      expect(token.needsRefresh, false);
    });

    test('AuthTokenModel.timeUntilExpiration returns correct duration', () {
      final expiresAt = DateTime.now().add(const Duration(minutes: 30));
      final token = AuthTokenModel(
        accessToken: 'access_token_123',
        refreshToken: 'refresh_token_456',
        expiresAt: expiresAt,
      );

      final timeUntilExpiration = token.timeUntilExpiration;
      expect(timeUntilExpiration.inMinutes, closeTo(30, 1));
    });

    test('AuthTokenModel.timeUntilExpiration returns zero for expired token', () {
      final pastDate = DateTime.now().subtract(const Duration(hours: 1));
      final token = AuthTokenModel(
        accessToken: 'access_token_123',
        refreshToken: 'refresh_token_456',
        expiresAt: pastDate,
      );

      expect(token.timeUntilExpiration, Duration.zero);
    });

    test('AuthTokenModel.copyWith creates new AuthTokenModel with updated fields', () {
      final originalToken = AuthTokenModel(
        accessToken: 'original_access',
        refreshToken: 'original_refresh',
        expiresAt: DateTime.now().add(const Duration(hours: 1)),
        tokenType: 'Bearer',
      );

      final newExpiresAt = DateTime.now().add(const Duration(hours: 2));
      final updatedToken = originalToken.copyWith(
        accessToken: 'new_access',
        refreshToken: 'new_refresh',
        expiresAt: newExpiresAt,
        tokenType: 'JWT',
      );

      expect(updatedToken.accessToken, 'new_access');
      expect(updatedToken.refreshToken, 'new_refresh');
      expect(updatedToken.expiresAt, newExpiresAt);
      expect(updatedToken.tokenType, 'JWT');
      expect(updatedToken.scope, 'read write');
    });

    test('AuthTokenModel.copyWith returns same object when no changes', () {
      final token = AuthTokenModel(
        accessToken: 'access_token_123',
        refreshToken: 'refresh_token_456',
        expiresAt: DateTime.now().add(const Duration(hours: 1)),
      );

      final sameToken = token.copyWith();

      expect(sameToken.accessToken, token.accessToken);
      expect(sameToken.refreshToken, token.refreshToken);
      expect(sameToken.expiresAt, token.expiresAt);
      expect(sameToken.tokenType, token.tokenType);
      expect(sameToken.scope, token.scope);
    });

    test('AuthTokenModel equality and hashCode work correctly', () {
      final nowStr = DateTime.now().toIso8601String();
      final now = DateTime.parse(nowStr);
      
      final token1 = AuthTokenModel(
        accessToken: 'access_token_123',
        refreshToken: 'refresh_token_456',
        expiresAt: now,
      );

      final token2 = AuthTokenModel(
        accessToken: 'access_token_123',
        refreshToken: 'refresh_token_456',
        expiresAt: now,
      );

      final token3 = AuthTokenModel(
        accessToken: 'different_token',
        refreshToken: 'different_refresh',
        expiresAt: now.add(const Duration(hours: 2)),
      );

      expect(token1 == token2, true);
      expect(token1.hashCode, token2.hashCode);
      expect(token1 == token3, false);
      expect(token1.hashCode == token3.hashCode, false);
    });

    test('AuthTokenModel.toString returns correct string representation', () {
      final expiresAt = DateTime.now().add(const Duration(hours: 1));
      final token = AuthTokenModel(
        accessToken: 'access_token_123',
        refreshToken: 'refresh_token_456',
        expiresAt: expiresAt,
        tokenType: 'Bearer',
      );

      final toString = token.toString();

      expect(toString, contains('AuthTokenModel'));
      expect(toString, contains('Bearer'));
      expect(toString, contains('false')); // isExpired should be false
    });

    test('AuthTokenModel serialization is reversible', () {
      final nowStr = DateTime.now().add(const Duration(hours: 1)).toIso8601String();
      final now = DateTime.parse(nowStr);
      
      final originalToken = AuthTokenModel(
        accessToken: 'access_token_123',
        refreshToken: 'refresh_token_456',
        expiresAt: now,
        tokenType: 'Bearer',
      );

      final jsonString = originalToken.toJson();
      final deserializedToken = AuthTokenModel.fromJson(jsonString);

      expect(deserializedToken.accessToken, originalToken.accessToken);
      expect(deserializedToken.refreshToken, originalToken.refreshToken);
      expect(deserializedToken.tokenType, originalToken.tokenType);
      expect(deserializedToken.scope, originalToken.scope);
      expect(deserializedToken.expiresAt, originalToken.expiresAt);
    });

    test('AuthTokenModel handles JWT decoding edge cases', () {
      // Test with malformed JWT payload
      final malformedToken = AuthTokenModel(
        accessToken: 'header.${base64Encode('{"invalid": json}'.codeUnits)}.signature',
        refreshToken: 'refresh_token_123',
        expiresAt: DateTime.now().add(const Duration(hours: 1)),
      );

      expect(malformedToken.jwtPayload, isNull);
      expect(malformedToken.userId, isNull);
      expect(malformedToken.username, isNull);
      expect(malformedToken.role, isNull);
      expect(malformedToken.permissions, isNull);
    });

    test('AuthTokenModel handles JWT without standard claims', () {
      // Create a simple JWT without standard claims
      final header = base64Encode('{"alg":"HS256","typ":"JWT"}'.codeUnits);
      final payload = base64Encode('{"custom_claim":"value"}'.codeUnits);
      final simpleJwt = '$header.$payload.signature';

      final token = AuthTokenModel(
        accessToken: simpleJwt,
        refreshToken: 'refresh_token_123',
        expiresAt: DateTime.now().add(const Duration(hours: 1)),
      );

      expect(token.userId, isNull);
      expect(token.username, isNull);
      expect(token.role, isNull);
      expect(token.permissions, isNull);
    });
  });
}
