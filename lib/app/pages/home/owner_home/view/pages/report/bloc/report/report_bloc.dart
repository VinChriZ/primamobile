import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:primamobile/repository/transaction_repository.dart';
import 'package:primamobile/repository/product_repository.dart';
import 'package:primamobile/repository/transaction_detail_repository.dart';

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
      // If dates are not provided, default to last 7 days.
      final DateTime endDate = event.endDate ?? DateTime.now();
      final DateTime startDate =
          event.startDate ?? endDate.subtract(const Duration(days: 7));

      // Determine if we should group by month based on date range and number of days
      final int daysDifference = endDate.difference(startDate).inDays;
      final bool groupByMonth =
          daysDifference > 21; // Reduce threshold to 21 days

      // Fetch transactions based on the date range.
      final transactions = await transactionRepository.fetchTransactions(
          startDate: startDate, endDate: endDate);

      // Aggregate data for charts.
      final Map<DateTime, double> salesData = {};
      final Map<DateTime, double> profitsData = _aggregateLineChartData(
          transactions,
          (tx) => tx.totalAgreedPrice - tx.totalNetPrice,
          groupByMonth);
      final Map<DateTime, double> transactionCountData = {};

      // Data for pie charts.
      final Map<String, double> brandTotals = {};
      final Map<String, double> categoryTotals = {};

      // Process each transaction.
      for (var tx in transactions) {
        // Use grouping key based on the flag.
        final DateTime key = groupByMonth
            ? DateTime(tx.dateCreated.year, tx.dateCreated.month)
            : DateTime(
                tx.dateCreated.year, tx.dateCreated.month, tx.dateCreated.day);

        // Initialize product quantity.
        double transactionQuantity = 0;
        // Fetch transaction details.
        final details = await transactionDetailRepository
            .fetchTransactionDetails(tx.transactionId);
        for (var detail in details) {
          transactionQuantity += detail.quantity.toDouble();
          // Fetch product info to update pie chart aggregations.
          final product = await productRepository.fetchProduct(detail.upc);
          brandTotals[product.brand] =
              (brandTotals[product.brand] ?? 0) + detail.quantity.toDouble();
          categoryTotals[product.category] =
              (categoryTotals[product.category] ?? 0) +
                  detail.quantity.toDouble();
        }
        salesData[key] = (salesData[key] ?? 0) + transactionQuantity;
        transactionCountData[key] = (transactionCountData[key] ?? 0) + 1;
      }

      // Emit the loaded state with the grouping flag.
      emit(ReportLoaded(
        salesLineChart: salesData,
        profitsLineChart: profitsData,
        transactionCountChart: transactionCountData,
        brandPieChart: brandTotals,
        categoryPieChart: categoryTotals,
        isMonthlyGrouping: groupByMonth,
        startDate: startDate,
        endDate: endDate,
      ));
    } catch (e) {
      if (e.toString().contains("401")) {
        emit(const ReportError(
            message: "Login expired, please restart the app and login again"));
      } else if (e.toString().contains("404")) {
        emit(const ReportError(
            message: "No transactions on the selected date."));
      } else {
        emit(ReportError(
            message: "Failed to load report data",
            startDate: event.startDate,
            endDate: event.endDate));
      }
    }
  }

  Future<void> _onChangeFilter(
      ChangeReportFilterEvent event, Emitter<ReportState> emit) async {
    add(LoadReportEvent(startDate: event.startDate, endDate: event.endDate));
  }

  /// Helper method to aggregate chart data based on the grouping flag.
  Map<DateTime, double> _aggregateLineChartData(List transactions,
      double Function(dynamic) valueSelector, bool groupByMonth) {
    final Map<DateTime, double> data = {};
    for (var tx in transactions) {
      final DateTime key = groupByMonth
          ? DateTime(tx.dateCreated.year, tx.dateCreated.month)
          : DateTime(
              tx.dateCreated.year, tx.dateCreated.month, tx.dateCreated.day);
      data[key] = (data[key] ?? 0) + valueSelector(tx);
    }
    return data;
  }
}
