import 'package:primamobile/app/models/users/users.dart';
import 'package:primamobile/utils/extensions.dart';

class UserSession {
  final User user;
  final DateTime lastLogin;
  final bool isLogin;
  final String? token;

  UserSession({
    User? user,
    DateTime? lastLogin,
    this.isLogin = false,
    this.token,
  })  : user = user ??
            User(
              userId: 0,
              username: '',
              passwordHash: '',
              roleId: 0,
              active: true,
            ),
        lastLogin = lastLogin ?? DateTime.now();

  // Factory method to create a UserSession from JSON
  factory UserSession.fromJson(Map<String, dynamic> json) {
    return UserSession(
      user: User.fromJson({
        'user_id': json['user_id'],
        'username': json['username'],
        'password_hash': json['password_hash'],
        'role_id': json['role_id'],
        'active': json['active'],
      }),
      lastLogin: DateTimeExtension.fromString(
        dateTimeString: json['last_login'],
      ),
      isLogin: json['is_login'] == 1,
      token: json['TOKEN'],
    );
  }

  // Convert a UserSession instance to JSON
  Map<String, dynamic> toJson() => {
        'user_id': user.userId,
        'username': user.username,
        'password_hash': user.passwordHash,
        'role_id': user.roleId,
        'active': user.active,
        'last_login': lastLogin.toLongString(),
        'is_login': isLogin ? 1 : 0,
        'TOKEN': token,
      };

  // CopyWith method for immutability
  UserSession copyWith({
    User? user,
    DateTime? lastLogin,
    bool? isLogin,
    String? token,
  }) {
    return UserSession(
      user: user ?? this.user,
      lastLogin: lastLogin ?? this.lastLogin,
      isLogin: isLogin ?? this.isLogin,
      token: token ?? this.token,
    );
  }
}
