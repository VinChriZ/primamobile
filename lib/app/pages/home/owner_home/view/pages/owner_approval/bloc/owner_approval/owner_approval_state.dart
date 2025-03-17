part of 'owner_approval_bloc.dart';

abstract class OwnerApprovalState extends Equatable {
  const OwnerApprovalState();
  @override
  List<Object?> get props => [];
}

class OwnerApprovalInitial extends OwnerApprovalState {}

class OwnerApprovalLoading extends OwnerApprovalState {}

class OwnerApprovalLoaded extends OwnerApprovalState {
  final List reports;
  const OwnerApprovalLoaded({required this.reports});

  @override
  List<Object?> get props => [reports];
}

class OwnerApprovalError extends OwnerApprovalState {
  final String message;
  const OwnerApprovalError(this.message);

  @override
  List<Object?> get props => [message];
}
