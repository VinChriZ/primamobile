part of 'report_bloc.dart';

abstract class ReportState extends Equatable {
  final DateTime? startDate;
  final DateTime? endDate;
  const ReportState({this.startDate, this.endDate});

  @override
  List<Object?> get props => [startDate, endDate];
}

class ReportInitial extends ReportState {}

class ReportLoading extends ReportState {}

class ReportLoaded extends ReportState {
  final Map<DateTime, double> salesLineChart;
  final Map<DateTime, double> profitsLineChart;
  final Map<String, double> brandPieChart;
  final Map<String, double> categoryPieChart;
  final Map<DateTime, double> transactionCountChart;
  final bool isMonthlyGrouping;

  const ReportLoaded({
    required this.salesLineChart,
    required this.profitsLineChart,
    required this.brandPieChart,
    required this.categoryPieChart,
    required this.transactionCountChart,
    required this.isMonthlyGrouping,
    super.startDate,
    super.endDate,
  });

  @override
  List<Object?> get props => [
        salesLineChart,
        profitsLineChart,
        brandPieChart,
        categoryPieChart,
        transactionCountChart,
        isMonthlyGrouping,
        startDate,
        endDate,
      ];
}

class ReportError extends ReportState {
  final String message;
  const ReportError({
    required this.message,
    super.startDate,
    super.endDate,
  });

  @override
  List<Object?> get props => [message, startDate, endDate];
}
