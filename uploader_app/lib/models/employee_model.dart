/// Employee model representing an employee who can authenticate and upload media
class Employee {
  final int id;
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final String role;
  final List<String> permissions;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? lastLoginAt;

  const Employee({
    required this.id,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.role,
    required this.permissions,
    required this.isActive,
    required this.createdAt,
    this.lastLoginAt,
  });

  /// Full name getter
  String get fullName => '$firstName $lastName';

  /// Display name for UI
  String get displayName => fullName.isNotEmpty ? fullName : username;

  /// Check if employee has a specific permission
  bool hasPermission(String permission) => permissions.contains(permission);

  /// Check if employee has admin role
  bool get isAdmin => role.toLowerCase() == 'admin';

  /// Check if employee has uploader role
  bool get isUploader => role.toLowerCase() == 'uploader' || isAdmin;

  /// Create Employee from JSON response
  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['id'] as int,
      username: json['username'] as String,
      email: json['email'] as String,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      role: json['role'] as String,
      permissions: List<String>.from(json['permissions'] as List<dynamic>? ?? []),
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      lastLoginAt: json['last_login_at'] != null
          ? DateTime.parse(json['last_login_at'] as String)
          : null,
    );
  }

  /// Convert Employee to JSON for API requests
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'role': role,
      'permissions': permissions,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'last_login_at': lastLoginAt?.toIso8601String(),
    };
  }

  /// Create a copy of Employee with updated fields
  Employee copyWith({
    int? id,
    String? username,
    String? email,
    String? firstName,
    String? lastName,
    String? role,
    List<String>? permissions,
    bool? isActive,
    DateTime? createdAt,
    DateTime? lastLoginAt,
  }) {
    return Employee(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      role: role ?? this.role,
      permissions: permissions ?? this.permissions,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Employee && other.id == id && other.username == username;
  }

  @override
  int get hashCode => id.hashCode ^ username.hashCode;

  @override
  String toString() {
    return 'Employee(id: $id, username: $username, name: $fullName, role: $role)';
  }
}