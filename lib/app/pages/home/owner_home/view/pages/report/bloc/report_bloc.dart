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
      // Fetch transactions based on provided filter dates.
      final transactions = await transactionRepository.fetchTransactions(
          startDate: event.startDate, endDate: event.endDate);

      // For the "Total Sales" chart, aggregate quantity sold per day.
      final Map<DateTime, double> salesData = {};
      // For the "Total Profits" chart, aggregate (totalAgreedPrice - totalNetPrice) per day.
      final Map<DateTime, double> profitsData = _aggregateLineChartData(
          transactions, (tx) => tx.totalAgreedPrice - tx.totalNetPrice);

      // Initialize aggregations for pie charts.
      final Map<String, double> brandTotals = {};
      final Map<String, double> categoryTotals = {};

      // Process each transaction.
      for (var tx in transactions) {
        // Fetch transaction details for this transaction.
        final details = await transactionDetailRepository
            .fetchTransactionDetails(tx.transactionId);
        double transactionQuantity = 0;
        for (var detail in details) {
          // Sum quantity from each transaction detail.
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
        // Group total sales by transaction date.
        final date = DateTime(
            tx.dateCreated.year, tx.dateCreated.month, tx.dateCreated.day);
        salesData[date] = (salesData[date] ?? 0) + transactionQuantity;
      }

      // Emit a loaded state carrying the aggregated data along with the filter.
      emit(ReportLoaded(
        salesLineChart: salesData,
        profitsLineChart: profitsData,
        brandPieChart: brandTotals,
        categoryPieChart: categoryTotals,
        startDate: event.startDate,
        endDate: event.endDate,
      ));
    } catch (e) {
      emit(ReportError(message: e.toString()));
    }
  }

  Future<void> _onChangeFilter(
      ChangeReportFilterEvent event, Emitter<ReportState> emit) async {
    add(LoadReportEvent(startDate: event.startDate, endDate: event.endDate));
  }

  /// Helper method to aggregate data for line charts.
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
