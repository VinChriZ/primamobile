part of 'login_bloc.dart';

abstract class LoginEvent extends Equatable {
  const LoginEvent();

  @override
  List<Object?> get props => [];
}

class LoginUsernameFilled extends LoginEvent {
  final String username;

  const LoginUsernameFilled(this.username);

  @override
  List<Object?> get props => [username];
}

class LoginPasswordFilled extends LoginEvent {
  final String password;

  const LoginPasswordFilled(this.password);

  @override
  List<Object?> get props => [password];
}

class LoginPasswordVisibilityPressed extends LoginEvent {}

class LoginTermsChecked extends LoginEvent {
  final bool agreeToTerms;

  const LoginTermsChecked({required this.agreeToTerms});

  @override
  List<Object?> get props => [agreeToTerms];
}

class LoginPressed extends LoginEvent {}

class LoginReset extends LoginEvent {}
