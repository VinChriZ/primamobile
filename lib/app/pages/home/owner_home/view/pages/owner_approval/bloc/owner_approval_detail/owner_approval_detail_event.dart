part of 'owner_approval_detail_bloc.dart';

abstract class OwnerApprovalDetailEvent extends Equatable {
  const OwnerApprovalDetailEvent();
  @override
  List<Object?> get props => [];
}

class FetchOwnerApprovalDetails extends OwnerApprovalDetailEvent {
  final int reportId;
  const FetchOwnerApprovalDetails(this.reportId);

  @override
  List<Object?> get props => [reportId];
}
