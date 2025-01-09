part of 'owner_home_bloc.dart';

abstract class OwnerHomeState extends Equatable {
  const OwnerHomeState();

  @override
  List<Object> get props => [];
}

class OwnerHomeInitial extends OwnerHomeState {}

class OwnerHomeNavigationState extends OwnerHomeState {
  final int selectedIndex;

  const OwnerHomeNavigationState(this.selectedIndex);

  @override
  List<Object> get props => [selectedIndex];
}
