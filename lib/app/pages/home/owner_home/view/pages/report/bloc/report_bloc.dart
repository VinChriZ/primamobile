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
      // Apply default filter: if no dates provided, default to the last 7 days.
      final DateTime endDate = event.endDate ?? DateTime.now();
      final DateTime startDate =
          event.startDate ?? endDate.subtract(const Duration(days: 7));

      // Determine if we should group by month (for a full year filter)
      final bool groupByMonth = endDate.difference(startDate).inDays >= 365;

      // Fetch transactions based on provided or default filter dates.
      final transactions = await transactionRepository.fetchTransactions(
          startDate: startDate, endDate: endDate);

      // For the "Total Sales" chart, aggregate quantity sold per day or month.
      final Map<DateTime, double> salesData = {};
      // For the "Total Profits" chart, aggregate (totalAgreedPrice - totalNetPrice) per day or month.
      final Map<DateTime, double> profitsData = _aggregateLineChartData(
          transactions,
          (tx) => tx.totalAgreedPrice - tx.totalNetPrice,
          groupByMonth);

      // New: For counting transactions per day or month.
      final Map<DateTime, double> transactionCountData = {};

      // Initialize aggregations for pie charts.
      final Map<String, double> brandTotals = {};
      final Map<String, double> categoryTotals = {};

      // Process each transaction.
      for (var tx in transactions) {
        // Determine grouping key based on the flag.
        final DateTime key = groupByMonth
            ? DateTime(tx.dateCreated.year, tx.dateCreated.month)
            : DateTime(
                tx.dateCreated.year, tx.dateCreated.month, tx.dateCreated.day);

        // Update sales data: accumulate total product quantity.
        double transactionQuantity = 0;
        // Fetch transaction details for this transaction.
        final details = await transactionDetailRepository
            .fetchTransactionDetails(tx.transactionId);
        for (var detail in details) {
          transactionQuantity += detail.quantity.toDouble();
          // Fetch product info to determine brand and category.
          final product = await productRepository.fetchProduct(detail.upc);
          // Aggregate quantity by product brand.
          brandTotals[product.brand] =
              (brandTotals[product.brand] ?? 0) + detail.quantity.toDouble();
          // Aggregate quantity by product category.
          categoryTotals[product.category] =
              (categoryTotals[product.category] ?? 0) +
                  detail.quantity.toDouble();
        }
        salesData[key] = (salesData[key] ?? 0) + transactionQuantity;

        // Increment transaction count for this grouping.
        transactionCountData[key] = (transactionCountData[key] ?? 0) + 1;
      }

      // Emit a loaded state carrying the aggregated data along with the filter.
      emit(ReportLoaded(
        salesLineChart: salesData,
        profitsLineChart: profitsData,
        transactionCountChart:
            transactionCountData, // new field for transaction counts
        brandPieChart: brandTotals,
        categoryPieChart: categoryTotals,
        startDate: startDate,
        endDate: endDate,
      ));
    } catch (e) {
      emit(ReportError(message: e.toString()));
    }
  }

  Future<void> _onChangeFilter(
      ChangeReportFilterEvent event, Emitter<ReportState> emit) async {
    add(LoadReportEvent(startDate: event.startDate, endDate: event.endDate));
  }

  /// Updated helper method to aggregate line chart data with an option for monthly grouping.
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
