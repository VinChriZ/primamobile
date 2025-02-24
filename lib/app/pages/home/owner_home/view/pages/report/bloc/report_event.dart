part of 'report_bloc.dart';

abstract class ReportEvent extends Equatable {
  const ReportEvent();

  @override
  List<Object?> get props => [];
}

class LoadReportEvent extends ReportEvent {
  final DateTime? startDate;
  final DateTime? endDate;

  const LoadReportEvent({this.startDate, this.endDate});

  @override
  List<Object?> get props => [startDate, endDate];
}

class ChangeReportFilterEvent extends ReportEvent {
  final DateTime? startDate;
  final DateTime? endDate;

  const ChangeReportFilterEvent({this.startDate, this.endDate});

  @override
  List<Object?> get props => [startDate, endDate];
}
