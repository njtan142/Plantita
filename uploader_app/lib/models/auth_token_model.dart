import 'dart:convert';

class AuthTokenModel {
  final String accessToken;
  final String refreshToken;
  final DateTime expiresAt;
  final String tokenType;
  final String scope;

  AuthTokenModel({
    required this.accessToken,
    required this.refreshToken,
    required DateTime expiresAt,
    this.tokenType = 'Bearer',
    this.scope = 'read write',
  }) : expiresAt = DateTime.parse(expiresAt.toIso8601String());

  // Check if token is expired
  bool get isExpired => DateTime.now().isAfter(expiresAt);

  // Get time until expiration
  Duration get timeUntilExpiration {
    final difference = expiresAt.difference(DateTime.now());
    return difference.isNegative ? Duration.zero : difference;
  }

  // Check if token needs refresh (within 5 minutes of expiration)
  bool get needsRefresh {
    final fiveMinutesFromNow = DateTime.now().add(const Duration(minutes: 5));
    return fiveMinutesFromNow.isAfter(expiresAt);
  }

  // Check if token will expire within given duration
  bool willExpireIn(Duration duration) {
    final futureTime = DateTime.now().add(duration);
    return futureTime.isAfter(expiresAt);
  }

  // Get JWT payload
  Map<String, dynamic>? get jwtPayload {
    try {
      if (accessToken.split('.').length == 3) {
        final parts = accessToken.split('.');
        if (parts.length >= 2) {
          final payload = parts[1];
          final normalized = base64Url.normalize(payload);
          final decoded = utf8.decode(base64Url.decode(normalized));
          final payloadMap = jsonDecode(decoded) as Map<String, dynamic>;

          // Check if JWT is expired
          if (payloadMap.containsKey('exp')) {
            final exp = payloadMap['exp'];
            final expiryDate = DateTime.fromMillisecondsSinceEpoch(exp * 1000, isUtc: true);
            if (DateTime.now().toUtc().isAfter(expiryDate)) {
              return null; // JWT is expired
            }
          }

          return payloadMap;
        }
      }
    } catch (e) {
      // Invalid JWT format or decoding error
    }
    return null;
  }

  // Get user ID from JWT
  int? get userId {
    final payload = jwtPayload;
    if (payload != null && payload.containsKey('user_id')) {
      final userId = payload['user_id'];
      return userId is int ? userId : int.tryParse(userId.toString());
    }
    return null;
  }

  // Get username from JWT
  String? get username {
    final payload = jwtPayload;
    return payload?['username'] as String?;
  }

  // Get role from JWT
  String? get role {
    final payload = jwtPayload;
    return payload?['role'] as String?;
  }

  // Get permissions from JWT
  List<String>? get permissions {
    final payload = jwtPayload;
    if (payload != null && payload.containsKey('permissions')) {
      final perms = payload['permissions'];
      if (perms is List) {
        return perms.map((p) => p.toString()).toList();
      }
    }
    return null;
  }

  // Create from JSON
  factory AuthTokenModel.fromJson(String jsonString) {
    final Map<String, dynamic> json = jsonDecode(jsonString);
    return AuthTokenModel.fromMap(json);
  }

  factory AuthTokenModel.fromMap(Map<String, dynamic> map) {
    // Handle both camelCase and snake_case keys
    final accessToken = map['access_token'] as String? ?? map['accessToken'] as String;
    final refreshToken = map['refresh_token'] as String? ?? map['refreshToken'] as String;
    final tokenType = map['token_type'] as String? ?? map['tokenType'] as String? ?? 'Bearer';
    final scope = map['scope'] as String? ?? 'read write';

    // Handle expiresAt - either from expires_at or calculated from expires_in
    DateTime expiresAt;
    if (map.containsKey('expires_at')) {
      final val = map['expires_at'];
      expiresAt = val is DateTime ? val : DateTime.parse(val as String);
    } else if (map.containsKey('expiresAt')) {
      final val = map['expiresAt'];
      expiresAt = val is DateTime ? val : DateTime.parse(val as String);
    } else if (map.containsKey('expires_in')) {
      final expiresInSeconds = map['expires_in'] as int;
      expiresAt = DateTime.now().add(Duration(seconds: expiresInSeconds));
    } else {
      // Default to 1 hour from now if no expiration info provided
      expiresAt = DateTime.now().add(const Duration(hours: 1));
    }

    return AuthTokenModel(
      accessToken: accessToken,
      refreshToken: refreshToken,
      expiresAt: expiresAt,
      tokenType: tokenType,
      scope: scope,
    );
  }

  // Convert to JSON
  String toJson() {
    return jsonEncode(toMap());
  }

  Map<String, dynamic> toMap() {
    return {
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'expires_at': expiresAt.toIso8601String(),
      'token_type': tokenType,
      'scope': scope,
    };
  }

  // Copy with method
  AuthTokenModel copyWith({
    String? accessToken,
    String? refreshToken,
    DateTime? expiresAt,
    String? tokenType,
    String? scope,
  }) {
    return AuthTokenModel(
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      expiresAt: expiresAt ?? this.expiresAt,
      tokenType: tokenType ?? this.tokenType,
      scope: scope ?? this.scope,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AuthTokenModel &&
        other.accessToken == accessToken &&
        other.refreshToken == refreshToken &&
        other.expiresAt.millisecondsSinceEpoch == expiresAt.millisecondsSinceEpoch &&
        other.tokenType == tokenType &&
        other.scope == scope;
  }

  @override
  int get hashCode {
    return accessToken.hashCode ^
        refreshToken.hashCode ^
        expiresAt.millisecondsSinceEpoch.hashCode ^
        tokenType.hashCode ^
        scope.hashCode;
  }

  @override
  String toString() {
    return 'AuthTokenModel(accessToken: ${accessToken.substring(0, 10)}..., refreshToken: ${refreshToken.substring(0, 10)}..., expiresAt: $expiresAt, tokenType: $tokenType, scope: $scope, isExpired: $isExpired)';
  }
}