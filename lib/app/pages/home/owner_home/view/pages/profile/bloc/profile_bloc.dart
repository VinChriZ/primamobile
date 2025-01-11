import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:primamobile/repository/user_repository.dart';
import 'package:primamobile/app/authentication/bloc/authentication_bloc.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final UserRepository userRepository;
  final AuthenticationBloc authenticationBloc;

  ProfileBloc({
    required this.userRepository,
    required this.authenticationBloc,
  }) : super(ProfileLoading()) {
    on<LoadProfile>(_onLoadProfile);
    on<Logout>(_onLogout);
  }

  Future<void> _onLoadProfile(
      LoadProfile event, Emitter<ProfileState> emit) async {
    try {
      emit(ProfileLoading());
      final name = await userRepository.getName();
      final role = await userRepository.getRole();
      emit(ProfileLoaded(name: name, role: role));
    } catch (_) {
      emit(ProfileError(message: "Failed to load profile."));
    }
  }

  void _onLogout(Logout event, Emitter<ProfileState> emit) {
    authenticationBloc
        .add(LogoutRequested()); // Send logout to AuthenticationBloc
  }
}
