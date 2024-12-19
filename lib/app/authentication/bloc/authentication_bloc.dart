import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'authentication_event.dart';
part 'authentication_state.dart';

class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  AuthenticationBloc() : super(AuthenticationInitial()) {
    on<AppStarted>(_onAppStarted);
    on<LoginButtonPressed>(_onLoginButtonPressed);
  }

  void _onAppStarted(AppStarted event, Emitter<AuthenticationState> emit) {
    // Check for existing session or start unauthenticated
    emit(AuthenticationInitial());
  }

  Future<void> _onLoginButtonPressed(
      LoginButtonPressed event, Emitter<AuthenticationState> emit) async {
    emit(AuthenticationLoading());

    // Simulate API call for authentication
    await Future.delayed(const Duration(seconds: 2));

    if (event.username == 'u' && event.password == 'p') {
      emit(AuthenticationAuthenticated());
    } else {
      emit(const AuthenticationFailure(error: 'Invalid username or password'));
    }
  }
}
