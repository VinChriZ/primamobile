part of 'worker_report_detail_bloc.dart';

abstract class WorkerReportDetailEvent extends Equatable {
  const WorkerReportDetailEvent();

  @override
  List<Object?> get props => [];
}

class FetchWorkerReportDetails extends WorkerReportDetailEvent {
  final int reportId;

  const FetchWorkerReportDetails(this.reportId);

  @override
  List<Object> get props => [reportId];
}

class AddWorkerReportDetail extends WorkerReportDetailEvent {
  final int reportId;
  final Map<String, dynamic> fields;

  const AddWorkerReportDetail(this.reportId, this.fields);

  @override
  List<Object> get props => [reportId, fields];
}

class UpdateWorkerReportDetail extends WorkerReportDetailEvent {
  final int reportId;
  final int detailId;
  final Map<String, dynamic> fields;

  const UpdateWorkerReportDetail(this.reportId, this.detailId, this.fields);

  @override
  List<Object> get props => [reportId, detailId, fields];
}

class DeleteWorkerReportDetail extends WorkerReportDetailEvent {
  final int reportId;
  final int detailId;

  const DeleteWorkerReportDetail(this.reportId, this.detailId);

  @override
  List<Object> get props => [reportId, detailId];
}
