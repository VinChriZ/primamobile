import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc() : super(const LoginState()) {
    on<LoginUsernameFilled>(_onUsernameFilled);
    on<LoginPasswordFilled>(_onPasswordFilled);
    on<LoginPasswordVisibilityPressed>(_onPasswordVisibilityPressed);
    on<LoginTermsChecked>(_onTermsChecked);
    on<LoginPressed>(_onLoginPressed);
    on<LoginReset>(_onLoginReset);
  }

  void _onUsernameFilled(LoginUsernameFilled event, Emitter<LoginState> emit) {
    emit(state.copyWith(
      username: event.username,
      status: LoginStatus.initial,
    ));
  }

  void _onPasswordFilled(LoginPasswordFilled event, Emitter<LoginState> emit) {
    emit(state.copyWith(
      password: event.password,
      status: LoginStatus.initial,
    ));
  }

  void _onTermsChecked(LoginTermsChecked event, Emitter<LoginState> emit) {
    emit(state.copyWith(
      isAgreedToTerms: event.agreeToTerms,
      status: LoginStatus.initial,
    ));
  }

  Future<void> _onLoginPressed(
      LoginPressed event, Emitter<LoginState> emit) async {
    emit(state.copyWith(status: LoginStatus.loading));
    // await Future.delayed(const Duration(seconds: 2));
    // emit(state.copyWith(status: LoginStatus.success));
  }

  void _onPasswordVisibilityPressed(
      LoginPasswordVisibilityPressed event, Emitter<LoginState> emit) {
    emit(state.copyWith(isPasswordVisible: !state.isPasswordVisible));
  }

  void _onLoginReset(LoginReset event, Emitter<LoginState> emit) {
    emit(state.copyWith(status: LoginStatus.initial));
  }
}
