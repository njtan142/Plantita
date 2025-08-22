import 'dart:convert';

class AuthTokenModel {
  final String accessToken;
  final String refreshToken;
  final DateTime expiresAt;
  final String tokenType;

  const AuthTokenModel({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresAt,
    this.tokenType = 'Bearer',
  });

  // Check if token is expired
  bool get isExpired => DateTime.now().isAfter(expiresAt);

  // Get time until expiration
  Duration get timeUntilExpiration => expiresAt.difference(DateTime.now());

  // Check if token needs refresh (within 5 minutes of expiration)
  bool get needsRefresh {
    final fiveMinutesFromNow = DateTime.now().add(const Duration(minutes: 5));
    return fiveMinutesFromNow.isAfter(expiresAt);
  }

  // Create from JSON
  factory AuthTokenModel.fromJson(String jsonString) {
    final Map<String, dynamic> json = jsonDecode(jsonString);
    return AuthTokenModel.fromMap(json);
  }

  factory AuthTokenModel.fromMap(Map<String, dynamic> map) {
    return AuthTokenModel(
      accessToken: map['accessToken'] as String,
      refreshToken: map['refreshToken'] as String,
      expiresAt: DateTime.parse(map['expiresAt'] as String),
      tokenType: map['tokenType'] as String? ?? 'Bearer',
    );
  }

  // Convert to JSON
  String toJson() {
    return jsonEncode(toMap());
  }

  Map<String, dynamic> toMap() {
    return {
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'expiresAt': expiresAt.toIso8601String(),
      'tokenType': tokenType,
    };
  }

  // Copy with method
  AuthTokenModel copyWith({
    String? accessToken,
    String? refreshToken,
    DateTime? expiresAt,
    String? tokenType,
  }) {
    return AuthTokenModel(
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      expiresAt: expiresAt ?? this.expiresAt,
      tokenType: tokenType ?? this.tokenType,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AuthTokenModel &&
        other.accessToken == accessToken &&
        other.refreshToken == refreshToken &&
        other.expiresAt == expiresAt &&
        other.tokenType == tokenType;
  }

  @override
  int get hashCode {
    return accessToken.hashCode ^
        refreshToken.hashCode ^
        expiresAt.hashCode ^
        tokenType.hashCode;
  }

  @override
  String toString() {
    return 'AuthTokenModel(accessToken: ${accessToken.substring(0, 10)}..., refreshToken: ${refreshToken.substring(0, 10)}..., expiresAt: $expiresAt, tokenType: $tokenType)';
  }
}