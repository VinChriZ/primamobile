part of 'report_bloc.dart';

abstract class ReportState extends Equatable {
  const ReportState();

  @override
  List<Object?> get props => [];
}

class ReportInitial extends ReportState {}

class ReportLoading extends ReportState {}

class ReportLoaded extends ReportState {
  final Map<DateTime, double> salesLineChart;
  final Map<DateTime, double> profitsLineChart;
  final Map<String, double> brandPieChart;
  final Map<String, double> categoryPieChart;

  const ReportLoaded({
    required this.salesLineChart,
    required this.profitsLineChart,
    required this.brandPieChart,
    required this.categoryPieChart,
  });

  @override
  List<Object?> get props =>
      [salesLineChart, profitsLineChart, brandPieChart, categoryPieChart];
}

class ReportError extends ReportState {
  final String message;

  const ReportError({required this.message});

  @override
  List<Object?> get props => [message];
}
