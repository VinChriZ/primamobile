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

class DeleteOwnerApproval extends OwnerApprovalEvent {
  final int reportId;
  const DeleteOwnerApproval(this.reportId);

  @override
  List<Object?> get props => [reportId];
}

class UpdateReportNote extends OwnerApprovalEvent {
  final int reportId;
  final String note;
  final Function onSuccess;
  final Function(String) onError;

  const UpdateReportNote({
    required this.reportId,
    required this.note,
    required this.onSuccess,
    required this.onError,
  });

  @override
  List<Object?> get props => [reportId, note];
}
