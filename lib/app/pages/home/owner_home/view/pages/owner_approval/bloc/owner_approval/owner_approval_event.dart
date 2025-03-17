part of 'owner_approval_bloc.dart';

abstract class OwnerApprovalEvent extends Equatable {
  const OwnerApprovalEvent();
  @override
  List<Object?> get props => [];
}

class FetchOwnerApprovals extends OwnerApprovalEvent {
  const FetchOwnerApprovals();
}

class ApproveReport extends OwnerApprovalEvent {
  final int reportId;
  const ApproveReport(this.reportId);

  @override
  List<Object?> get props => [reportId];
}

class DenyReport extends OwnerApprovalEvent {
  final int reportId;
  const DenyReport(this.reportId);

  @override
  List<Object?> get props => [reportId];
}
