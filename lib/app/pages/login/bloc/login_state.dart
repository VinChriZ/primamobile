part of 'login_bloc.dart';

enum LoginStatus { initial, loading, success, failure }

class LoginState extends Equatable {
  final String username;
  final String password;
  final bool isPasswordVisible;
  final bool isAgreedToTerms;
  final LoginStatus status;

  const LoginState({
    this.username = '',
    this.password = '',
    this.isPasswordVisible = false,
    this.isAgreedToTerms = false,
    this.status = LoginStatus.initial,
  });

  LoginState copyWith({
    String? username,
    String? password,
    bool? isPasswordVisible,
    bool? isAgreedToTerms,
    LoginStatus? status,
  }) {
    return LoginState(
      username: username ?? this.username,
      password: password ?? this.password,
      isPasswordVisible: isPasswordVisible ?? this.isPasswordVisible,
      isAgreedToTerms: isAgreedToTerms ?? this.isAgreedToTerms,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [
        username,
        password,
        isPasswordVisible,
        isAgreedToTerms,
        status,
      ];
}
