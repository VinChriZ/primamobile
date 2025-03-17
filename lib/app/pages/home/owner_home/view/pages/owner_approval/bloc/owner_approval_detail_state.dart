part of 'owner_approval_detail_bloc.dart';

abstract class OwnerApprovalDetailState extends Equatable {
  const OwnerApprovalDetailState();
  @override
  List<Object?> get props => [];
}

class OwnerApprovalDetailInitial extends OwnerApprovalDetailState {}

class OwnerApprovalDetailLoading extends OwnerApprovalDetailState {}

class OwnerApprovalDetailLoaded extends OwnerApprovalDetailState {
  final int reportId;
  final List<ReportDetail> details;
  const OwnerApprovalDetailLoaded(
      {required this.reportId, required this.details});

  @override
  List<Object?> get props => [reportId, details];
}

class OwnerApprovalDetailError extends OwnerApprovalDetailState {
  final String message;
  const OwnerApprovalDetailError(this.message);

  @override
  List<Object?> get props => [message];
}
