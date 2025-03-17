part of 'owner_approval_bloc.dart';

abstract class OwnerApprovalEvent extends Equatable {
  const OwnerApprovalEvent();
  @override
  List<Object?> get props => [];
}

class FetchOwnerApprovals extends OwnerApprovalEvent {
  final String selectedDateRange;
  final DateTime? startDate;
  final DateTime? endDate;
  final String sortBy;
  final String sortOrder;
  final String? status;
  final String? reportType;

  const FetchOwnerApprovals({
    this.selectedDateRange = 'All Dates',
    this.startDate,
    this.endDate,
    this.sortBy = 'date_created',
    this.sortOrder = 'desc',
    this.status,
    this.reportType,
  });

  @override
  List<Object?> get props => [
        selectedDateRange,
        startDate,
        endDate,
        sortBy,
        sortOrder,
        status,
        reportType
      ];
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
