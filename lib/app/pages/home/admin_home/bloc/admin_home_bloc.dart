import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:primamobile/repository/product_repository.dart';

part 'admin_home_event.dart';
part 'admin_home_state.dart';

class AdminHomeBloc extends Bloc<AdminHomeEvent, AdminHomeState> {
  final ProductRepository productRepository;

  AdminHomeBloc({required this.productRepository}) : super(AdminHomeInitial()) {
    on<AdminHomeStarted>(_onStarted);
    on<AdminHomeNavigationChanged>(_onNavigationChanged);
  }

  void _onStarted(AdminHomeStarted event, Emitter<AdminHomeState> emit) {
    emit(const AdminHomeNavigationState(0)); // Start at the Dashboard tab
  }

  void _onNavigationChanged(
      AdminHomeNavigationChanged event, Emitter<AdminHomeState> emit) {
    emit(AdminHomeNavigationState(event.selectedIndex));
  }
}
