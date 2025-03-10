part of 'worker_report_bloc.dart';

abstract class WorkerReportState extends Equatable {
  const WorkerReportState();

  @override
  List<Object?> get props => [];
}

class WorkerReportInitial extends WorkerReportState {}

class WorkerReportLoading extends WorkerReportState {}

class WorkerReportLoaded extends WorkerReportState {
  final List<Report> reports;
  final String selectedDateRange;
  final String selectedSortBy;
  final String selectedSortOrder;
  final DateTime? startDate;
  final DateTime? endDate;

  const WorkerReportLoaded({
    required this.reports,
    required this.selectedDateRange,
    required this.selectedSortBy,
    required this.selectedSortOrder,
    this.startDate,
    this.endDate,
  });

  @override
  List<Object?> get props => [
        reports,
        selectedDateRange,
        selectedSortBy,
        selectedSortOrder,
        startDate,
        endDate
      ];
}

class WorkerReportError extends WorkerReportState {
  final String message;

  const WorkerReportError(this.message);

  @override
  List<Object> get props => [message];
}
