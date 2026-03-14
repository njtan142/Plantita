import 'dart:convert';

class UserModel {
  final int id;
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final String? profileImageUrl;
  final String? department;
  final String? employeeId;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? lastLoginAt;

  const UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.profileImageUrl,
    this.department,
    this.employeeId,
    required this.isActive,
    required this.createdAt,
    this.lastLoginAt,
  });

  // Get full name
  String get fullName => '$firstName $lastName'.trim();

  // Get display name
  String get displayName => fullName.isNotEmpty ? fullName : username;

  // Create from JSON
  factory UserModel.fromJson(String jsonString) {
    final Map<String, dynamic> json = jsonDecode(jsonString);
    return UserModel.fromMap(json);
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: (map['id'] as num?)?.toInt() ?? 0,
      username: map['username'] as String? ?? '',
      email: map['email'] as String? ?? '',
      firstName: map['first_name'] as String? ?? map['firstName'] as String? ?? '',
      lastName: map['last_name'] as String? ?? map['lastName'] as String? ?? '',
      profileImageUrl: map['profile_image_url'] as String? ?? map['avatar'] as String?,
      department: map['department'] as String?,
      employeeId: map['employee_id'] as String?,
      isActive: map['is_active'] as bool? ?? map['isActive'] as bool? ?? true,
      createdAt: map['created_at'] != null 
          ? DateTime.parse(map['created_at'] as String) 
          : DateTime.now(),
      lastLoginAt: map['last_login_at'] != null
          ? DateTime.parse(map['last_login_at'] as String)
          : null,
    );
  }

  // Convert to JSON
  String toJson() {
    return jsonEncode(toMap());
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'profile_image_url': profileImageUrl,
      'department': department,
      'employee_id': employeeId,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'last_login_at': lastLoginAt?.toIso8601String(),
    };
  }

  // Copy with method
  UserModel copyWith({
    int? id,
    String? username,
    String? email,
    String? firstName,
    String? lastName,
    String? profileImageUrl,
    String? department,
    String? employeeId,
    bool? isActive,
    DateTime? createdAt,
    DateTime? lastLoginAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      department: department ?? this.department,
      employeeId: employeeId ?? this.employeeId,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserModel &&
        other.id == id &&
        other.username == username &&
        other.email == email &&
        other.firstName == firstName &&
        other.lastName == lastName &&
        other.profileImageUrl == profileImageUrl &&
        other.department == department &&
        other.employeeId == employeeId &&
        other.isActive == isActive &&
        other.createdAt == createdAt &&
        other.lastLoginAt == lastLoginAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        username.hashCode ^
        email.hashCode ^
        firstName.hashCode ^
        lastName.hashCode ^
        profileImageUrl.hashCode ^
        department.hashCode ^
        employeeId.hashCode ^
        isActive.hashCode ^
        createdAt.hashCode ^
        lastLoginAt.hashCode;
  }

  @override
  String toString() {
    return 'User(id: $id, username: $username, name: $fullName)';
  }
}
