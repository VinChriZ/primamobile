part of 'owner_home_bloc.dart';

abstract class OwnerHomeEvent extends Equatable {
  const OwnerHomeEvent();

  @override
  List<Object> get props => [];
}

class OwnerHomeStarted extends OwnerHomeEvent {}

class OwnerHomeNavigationChanged extends OwnerHomeEvent {
  final int selectedIndex;

  const OwnerHomeNavigationChanged(this.selectedIndex);

  @override
  List<Object> get props => [selectedIndex];
}
