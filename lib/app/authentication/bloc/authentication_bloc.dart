import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:primamobile/repository/login_repository.dart';
import 'package:primamobile/repository/logout_repository.dart';
import 'package:primamobile/repository/user_session_repository.dart';
import 'package:primamobile/repository/token_validator_repository.dart'; // New import

part 'authentication_event.dart';
part 'authentication_state.dart';

class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  final LoginRepository loginRepository;
  final UserSessionRepository userSessionRepository;
  final LogoutRepository logoutRepository;
  final TokenValidatorRepository tokenValidatorRepository; // New repository

  AuthenticationBloc({
    required this.loginRepository,
    required this.userSessionRepository,
    required this.logoutRepository,
    required this.tokenValidatorRepository, // Add parameter
  }) : super(AuthenticationInitial()) {
    on<AppStarted>(_onAppStarted);
    on<LoginButtonPressed>(_onLoginButtonPressed);
    on<LogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onAppStarted(
      AppStarted event, Emitter<AuthenticationState> emit) async {
    try {
      final userSession = await userSessionRepository.getUserSession();

      // Check if user is logged in and has a token
      if (userSession.isLogin && userSession.token != null) {
        // Validate the token with the backend
        final isTokenValid = await tokenValidatorRepository.validateToken();

        if (isTokenValid) {
          emit(AuthenticationAuthenticated());
        } else {
          // If token is invalid, clear session and emit unauthenticated
          await userSessionRepository.saveUserSession(
              userSession.copyWith(isLogin: false, token: null));
          emit(AuthenticationUnauthenticated());
        }
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
      await loginRepository.login(event.username, event.password);
      emit(AuthenticationAuthenticated());
    } catch (e) {
      // Pass the specific error message
      emit(AuthenticationFailure(error: e.toString()));
    }
  }

  Future<void> _onLogoutRequested(
      LogoutRequested event, Emitter<AuthenticationState> emit) async {
    emit(AuthenticationLoading());
    try {
      await logoutRepository
          .logout(); // Use logout repository instead of just clearing session
      emit(AuthenticationUnauthenticated());
    } catch (e) {
      emit(AuthenticationFailure(error: "Logout failed: ${e.toString()}"));
    }
  }
}
