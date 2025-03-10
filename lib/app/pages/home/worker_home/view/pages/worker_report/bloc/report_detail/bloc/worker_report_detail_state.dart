part of 'worker_report_detail_bloc.dart';

abstract class WorkerReportDetailState extends Equatable {
  const WorkerReportDetailState();

  @override
  List<Object?> get props => [];
}

class WorkerReportDetailInitial extends WorkerReportDetailState {}

class WorkerReportDetailLoading extends WorkerReportDetailState {}

class WorkerReportDetailLoaded extends WorkerReportDetailState {
  final int reportId;
  final List<ReportDetail> details;

  const WorkerReportDetailLoaded(
      {required this.reportId, required this.details});

  @override
  List<Object?> get props => [reportId, details];
}

class WorkerReportDetailError extends WorkerReportDetailState {
  final String message;

  const WorkerReportDetailError(this.message);

  @override
  List<Object> get props => [message];
}
