part of 'authentication_bloc.dart';

abstract class AuthenticationEvent extends Equatable {
  const AuthenticationEvent();

  @override
  List<Object?> get props => [];
}

class AppStarted extends AuthenticationEvent {}

class LoginButtonPressed extends AuthenticationEvent {
  final String username;
  final String password;

  const LoginButtonPressed({required this.username, required this.password});

  @override
  List<Object?> get props => [username, password];
}
