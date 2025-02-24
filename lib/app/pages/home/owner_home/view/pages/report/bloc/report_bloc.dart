import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:primamobile/repository/transaction_detail_repository.dart';
import 'package:primamobile/repository/transaction_repository.dart';
import 'package:primamobile/repository/product_repository.dart';

part 'report_event.dart';
part 'report_state.dart';

class ReportBloc extends Bloc<ReportEvent, ReportState> {
  final TransactionRepository transactionRepository;
  final ProductRepository productRepository;
  final TransactionDetailRepository transactionDetailRepository;

  ReportBloc({
    required this.transactionRepository,
    required this.productRepository,
    required this.transactionDetailRepository,
  }) : super(ReportInitial()) {
    on<LoadReportEvent>(_onLoadReport);
    on<ChangeReportFilterEvent>(_onChangeFilter);
  }

  Future<void> _onLoadReport(
      LoadReportEvent event, Emitter<ReportState> emit) async {
    emit(ReportLoading());
    try {
      // Fetch transactions based on date filters
      final transactions = await transactionRepository.fetchTransactions(
          startDate: event.startDate, endDate: event.endDate);

      // Aggregate data for the line charts:
      // Sales line chart aggregates totalDisplayPrice per day
      final salesData =
          _aggregateLineChartData(transactions, (tx) => tx.quantity.toDouble());

      // Profits line chart aggregates (totalAgreedPrice - totalNetPrice) per day
      final profitsData = _aggregateLineChartData(
          transactions, (tx) => tx.totalAgreedPrice - tx.totalNetPrice);

      // For the pie charts, here we simulate aggregated data.
      // In your real implementation, consider joining transaction details with product info.
      final brandTotals = <String, double>{
        'Brand A': 1200.0,
        'Brand B': 800.0,
        'Brand C': 1500.0,
      };

      final categoryTotals = <String, double>{
        'Category X': 1000.0,
        'Category Y': 1700.0,
      };

      emit(ReportLoaded(
        salesLineChart: salesData,
        profitsLineChart: profitsData,
        brandPieChart: brandTotals,
        categoryPieChart: categoryTotals,
      ));
    } catch (e) {
      emit(ReportError(message: e.toString()));
    }
  }

  Future<void> _onChangeFilter(
      ChangeReportFilterEvent event, Emitter<ReportState> emit) async {
    // Simply trigger a new load with the updated filters.
    add(LoadReportEvent(startDate: event.startDate, endDate: event.endDate));
  }

  /// Helper method to aggregate transaction data for line charts.
  Map<DateTime, double> _aggregateLineChartData(
      List transactions, double Function(dynamic) valueSelector) {
    final Map<DateTime, double> data = {};
    for (var tx in transactions) {
      final date = DateTime(
          tx.dateCreated.year, tx.dateCreated.month, tx.dateCreated.day);
      data[date] = (data[date] ?? 0) + valueSelector(tx);
    }
    return data;
  }
}
