part of 'admin_home_bloc.dart';

abstract class AdminHomeEvent extends Equatable {
  const AdminHomeEvent();

  @override
  List<Object> get props => [];
}

class AdminHomeStarted extends AdminHomeEvent {}

class AdminHomeNavigationChanged extends AdminHomeEvent {
  final int selectedIndex;

  const AdminHomeNavigationChanged(this.selectedIndex);

  @override
  List<Object> get props => [selectedIndex];
}
