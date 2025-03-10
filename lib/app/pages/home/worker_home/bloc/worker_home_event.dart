part of 'worker_home_bloc.dart';

abstract class WorkerHomeEvent extends Equatable {
  const WorkerHomeEvent();

  @override
  List<Object> get props => [];
}

class WorkerHomeStarted extends WorkerHomeEvent {}

class WorkerHomeNavigationChanged extends WorkerHomeEvent {
  final int selectedIndex;
  const WorkerHomeNavigationChanged(this.selectedIndex);

  @override
  List<Object> get props => [selectedIndex];
}
