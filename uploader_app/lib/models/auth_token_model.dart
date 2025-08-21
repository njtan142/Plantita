import 'package:jwt_decoder/jwt_decoder.dart';

/// Authentication token model with JWT handling and refresh capabilities
class AuthToken {
  final String accessToken;
  final String refreshToken;
  final DateTime expiresAt;
  final String tokenType;
  final String? scope;

  const AuthToken({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresAt,
    this.tokenType = 'Bearer',
    this.scope,
  });

  /// Check if the access token is expired
  bool get isExpired => DateTime.now().isAfter(expiresAt);

  /// Check if the token will expire within the next specified minutes
  bool willExpireIn(Duration duration) {
    return DateTime.now().add(duration).isAfter(expiresAt);
  }

  /// Get remaining time until expiration
  Duration get timeUntilExpiration {
    final now = DateTime.now();
    return now.isBefore(expiresAt) ? expiresAt.difference(now) : Duration.zero;
  }

  /// Check if token needs refresh (expires within 5 minutes)
  bool get needsRefresh => willExpireIn(const Duration(minutes: 5));

  /// Decode JWT payload from access token
  Map<String, dynamic>? get jwtPayload {
    try {
      if (JwtDecoder.isExpired(accessToken)) return null;
      return JwtDecoder.decode(accessToken);
    } catch (e) {
      return null;
    }
  }

  /// Get user ID from JWT payload
  int? get userId {
    final payload = jwtPayload;
    if (payload == null) return null;
    return payload['user_id'] as int? ?? payload['sub'] as int?;
  }

  /// Get username from JWT payload
  String? get username {
    final payload = jwtPayload;
    if (payload == null) return null;
    return payload['username'] as String?;
  }

  /// Get user role from JWT payload
  String? get role {
    final payload = jwtPayload;
    if (payload == null) return null;
    return payload['role'] as String?;
  }

  /// Get permissions from JWT payload
  List<String>? get permissions {
    final payload = jwtPayload;
    if (payload == null) return null;
    final perms = payload['permissions'];
    if (perms is List) {
      return perms.map((e) => e.toString()).toList();
    }
    return null;
  }

  /// Create AuthToken from JSON response
  factory AuthToken.fromJson(Map<String, dynamic> json) {
    final accessToken = json['access_token'] as String;
    final expiresIn = json['expires_in'] as int? ?? 3600; // Default 1 hour
    final tokenType = json['token_type'] as String? ?? 'Bearer';

    // Calculate expiration time
    DateTime expiresAt;
    if (json['expires_at'] != null) {
      expiresAt = DateTime.parse(json['expires_at'] as String);
    } else {
      expiresAt = DateTime.now().add(Duration(seconds: expiresIn));
    }

    return AuthToken(
      accessToken: accessToken,
      refreshToken: json['refresh_token'] as String,
      expiresAt: expiresAt,
      tokenType: tokenType,
      scope: json['scope'] as String?,
    );
  }

  /// Convert AuthToken to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'expires_at': expiresAt.toIso8601String(),
      'token_type': tokenType,
      'scope': scope,
    };
  }

  /// Create a copy of AuthToken with updated fields
  AuthToken copyWith({
    String? accessToken,
    String? refreshToken,
    DateTime? expiresAt,
    String? tokenType,
    String? scope,
  }) {
    return AuthToken(
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
    return other is AuthToken && other.accessToken == accessToken;
  }

  @override
  int get hashCode => accessToken.hashCode;

  @override
  String toString() {
    return 'AuthToken(tokenType: $tokenType, expiresAt: $expiresAt, isExpired: $isExpired)';
  }
}