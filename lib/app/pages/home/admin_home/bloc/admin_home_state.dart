part of 'admin_home_bloc.dart';

abstract class AdminHomeState extends Equatable {
  const AdminHomeState();

  @override
  List<Object> get props => [];
}

class AdminHomeInitial extends AdminHomeState {}

class AdminHomeNavigationState extends AdminHomeState {
  final int selectedIndex;

  const AdminHomeNavigationState(this.selectedIndex);

  @override
  List<Object> get props => [selectedIndex];
}
