part of 'authentication_bloc.dart';

abstract class AuthenticationState extends Equatable {
  const AuthenticationState();

  @override
  List<Object?> get props => [];
}

class AuthenticationInitial extends AuthenticationState {}

class AuthenticationLoading extends AuthenticationState {}

class AuthenticationAuthenticated extends AuthenticationState {}

class AuthenticationFailure extends AuthenticationState {
  final String error;

  const AuthenticationFailure({required this.error});

  @override
  List<Object?> get props => [error];
}
