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
  final String selectedDateRange;
  final String selectedSortBy;
  final String selectedSortOrder;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? selectedStatus;
  final String? selectedReportType;

  const OwnerApprovalLoaded({
    required this.reports,
    required this.selectedDateRange,
    required this.selectedSortBy,
    required this.selectedSortOrder,
    this.startDate,
    this.endDate,
    this.selectedStatus,
    this.selectedReportType,
  });

  @override
  List<Object?> get props => [
        reports,
        selectedDateRange,
        selectedSortBy,
        selectedSortOrder,
        startDate,
        endDate,
        selectedStatus,
        selectedReportType
      ];
}

class OwnerApprovalError extends OwnerApprovalState {
  final String message;
  const OwnerApprovalError(this.message);

  @override
  List<Object?> get props => [message];
}
