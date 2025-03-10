import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:primamobile/repository/product_repository.dart';

part 'worker_home_event.dart';
part 'worker_home_state.dart';

class WorkerHomeBloc extends Bloc<WorkerHomeEvent, WorkerHomeState> {
  final ProductRepository productRepository;

  WorkerHomeBloc({required this.productRepository})
      : super(WorkerHomeInitial()) {
    on<WorkerHomeStarted>(_onStarted);
    on<WorkerHomeNavigationChanged>(_onNavigationChanged);
  }

  void _onStarted(WorkerHomeStarted event, Emitter<WorkerHomeState> emit) {
    emit(const WorkerHomeNavigationState(0)); // Start at the default tab
  }

  void _onNavigationChanged(
      WorkerHomeNavigationChanged event, Emitter<WorkerHomeState> emit) {
    emit(WorkerHomeNavigationState(event.selectedIndex));
  }
}
