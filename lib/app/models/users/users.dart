class User {
  final int userId;
  final String username;
  final String passwordHash;
  final int roleId;

  User({
    required this.userId,
    required this.username,
    required this.passwordHash,
    required this.roleId,
  });

  // Factory constructor to create a User from JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['user_id'],
      username: json['username'],
      passwordHash: json['password_hash'],
      roleId: json['role_id'],
    );
  }

  // Method to convert a User instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'username': username,
      'password_hash': passwordHash,
      'role_id': roleId,
    };
  }

  // Add the copyWith method for immutability
  User copyWith({
    int? userId,
    String? username,
    String? passwordHash,
    int? roleId,
  }) {
    return User(
      userId: userId ?? this.userId,
      username: username ?? this.username,
      passwordHash: passwordHash ?? this.passwordHash,
      roleId: roleId ?? this.roleId,
    );
  }
}
