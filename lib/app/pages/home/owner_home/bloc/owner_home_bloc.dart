import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'owner_home_event.dart';
part 'owner_home_state.dart';

class OwnerHomeBloc extends Bloc<OwnerHomeEvent, OwnerHomeState> {
  OwnerHomeBloc() : super(OwnerHomeInitial()) {
    on<OwnerHomeStarted>(_onStarted);
    on<OwnerHomeNavigationChanged>(_onNavigationChanged);
  }

  void _onStarted(OwnerHomeStarted event, Emitter<OwnerHomeState> emit) {
    emit(const OwnerHomeNavigationState(0)); // Start at the Home tab
  }

  void _onNavigationChanged(
      OwnerHomeNavigationChanged event, Emitter<OwnerHomeState> emit) {
    emit(OwnerHomeNavigationState(event.selectedIndex));
  }
}
