class User {
  final int userId;
  final String username;
  final String passwordHash;
  final int roleId;
  final bool active;

  User({
    required this.userId,
    required this.username,
    required this.passwordHash,
    required this.roleId,
    required this.active,
  });

  // Factory constructor to create a User from JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['user_id'],
      username: json['username'],
      passwordHash: json['password_hash'],
      roleId: json['role_id'],
      active: json['active'],
    );
  }

  // Method to convert a User instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'username': username,
      'password_hash': passwordHash,
      'role_id': roleId,
      'active': active,
    };
  }

  // Add the copyWith method for immutability
  User copyWith({
    int? userId,
    String? username,
    String? passwordHash,
    int? roleId,
    bool? active,
  }) {
    return User(
      userId: userId ?? this.userId,
      username: username ?? this.username,
      passwordHash: passwordHash ?? this.passwordHash,
      roleId: roleId ?? this.roleId,
      active: active ?? this.active,
    );
  }
}
