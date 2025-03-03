import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:primamobile/app/models/users/users.dart';
import 'package:primamobile/repository/product_repository.dart';
import 'package:primamobile/repository/user_session_repository.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final UserSessionRepository userSessionRepository;
  final ProductRepository productRepository;

  HomeBloc({
    required this.userSessionRepository,
    required this.productRepository,
  }) : super(HomeInitial()) {
    on<HomeStarted>(_onStarted);
  }

  Future<void> _onStarted(HomeStarted event, Emitter<HomeState> emit) async {
    emit(HomeLoading());
    try {
      // Fetch the user session
      final userSession = await userSessionRepository.getUserSession();

      // Extract the user from the session
      final User user = userSession.user;

      emit(HomeLoaded(user: user));
    } catch (e) {
      emit(const HomeError("Failed to load user session."));
    }
  }
}
