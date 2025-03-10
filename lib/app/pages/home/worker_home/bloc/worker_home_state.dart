part of 'worker_home_bloc.dart';

abstract class WorkerHomeState extends Equatable {
  const WorkerHomeState();

  @override
  List<Object> get props => [];
}

class WorkerHomeInitial extends WorkerHomeState {}

class WorkerHomeNavigationState extends WorkerHomeState {
  final int selectedIndex;
  const WorkerHomeNavigationState(this.selectedIndex);

  @override
  List<Object> get props => [selectedIndex];
}
