import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:primamobile/repository/login_repository.dart';
import 'package:primamobile/repository/user_session_repository.dart';

part 'authentication_event.dart';
part 'authentication_state.dart';

class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  final LoginRepository loginRepository;
  final UserSessionRepository userSessionRepository;

  AuthenticationBloc({
    required this.loginRepository,
    required this.userSessionRepository,
  }) : super(AuthenticationInitial()) {
    on<AppStarted>(_onAppStarted);
    on<LoginButtonPressed>(_onLoginButtonPressed);
    on<LogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onAppStarted(
      AppStarted event, Emitter<AuthenticationState> emit) async {
    try {
      final userSession = await userSessionRepository.getUserSession();
      if (userSession.isLogin && userSession.token != null) {
        emit(AuthenticationAuthenticated());
      } else {
        emit(AuthenticationUnauthenticated());
      }
    } catch (_) {
      emit(AuthenticationUnauthenticated());
    }
  }

  Future<void> _onLoginButtonPressed(
      LoginButtonPressed event, Emitter<AuthenticationState> emit) async {
    emit(AuthenticationLoading());

    try {
      await loginRepository.login(
          event.username, event.password); // Assume successful login
      emit(AuthenticationAuthenticated());
    } catch (_) {
      emit(AuthenticationFailure(error: "Invalid username or password"));
    }
  }

  Future<void> _onLogoutRequested(
      LogoutRequested event, Emitter<AuthenticationState> emit) async {
    await userSessionRepository.clearUserSession(); // Clear the user session
    emit(AuthenticationUnauthenticated()); // Emit unauthenticated state
  }
}
