part of 'worker_report_bloc.dart';

abstract class WorkerReportEvent extends Equatable {
  const WorkerReportEvent();

  @override
  List<Object?> get props => [];
}

class FetchWorkerReport extends WorkerReportEvent {
  final String selectedDateRange;
  final DateTime? startDate;
  final DateTime? endDate;
  final String sortBy;
  final String sortOrder;
  final String? status;
  final String? reportType;

  const FetchWorkerReport({
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

class DeleteWorkerReport extends WorkerReportEvent {
  final int reportId;

  const DeleteWorkerReport(this.reportId);

  @override
  List<Object> get props => [reportId];
}

class ResubmitWorkerReport extends WorkerReportEvent {
  final int reportId;

  const ResubmitWorkerReport(this.reportId);

  @override
  List<Object> get props => [reportId];
}
