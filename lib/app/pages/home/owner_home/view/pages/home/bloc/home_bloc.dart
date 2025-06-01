import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:primamobile/app/models/models.dart';
import 'package:primamobile/repository/product_repository.dart';
import 'package:primamobile/repository/transaction_repository.dart';
import 'package:primamobile/repository/transaction_detail_repository.dart';
import 'package:primamobile/repository/user_session_repository.dart';

part 'home_event.dart';
part 'home_state.dart';

/// A simple model to hold the dashboard metrics.
class DashboardData {
  final List<Product> lowStockProducts;
  final int transactionsToday;
  final int transactionsMonth;
  final int transactionsYear;
  final int itemsSoldToday;
  final int itemsSoldMonth;
  final int itemsSoldYear;
  final double profitToday;
  final double profitMonth;
  final double profitYear;
  final double totalStockPrice;

  DashboardData({
    required this.lowStockProducts,
    required this.transactionsToday,
    required this.transactionsMonth,
    required this.transactionsYear,
    required this.itemsSoldToday,
    required this.itemsSoldMonth,
    required this.itemsSoldYear,
    required this.profitToday,
    required this.profitMonth,
    required this.profitYear,
    required this.totalStockPrice,
  });
}

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final UserSessionRepository userSessionRepository;
  final ProductRepository productRepository;
  final TransactionRepository transactionRepository;
  final TransactionDetailRepository transactionDetailRepository;

  HomeBloc({
    required this.userSessionRepository,
    required this.productRepository,
    required this.transactionRepository,
    required this.transactionDetailRepository,
  }) : super(HomeInitial()) {
    on<HomeStarted>(_onStarted);
  }

  Future<List<Transaction>> _fetchTransactionsSafe({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      return await transactionRepository.fetchTransactions(
        startDate: startDate,
        endDate: endDate,
      );
    } catch (e) {
      // If the error indicates a 404, return an empty list.
      if (e.toString().contains("404")) {
        return [];
      } else {
        rethrow;
      }
    }
  }

  Future<void> _onStarted(HomeStarted event, Emitter<HomeState> emit) async {
    emit(HomeLoading());
    try {
      // 1. Fetch the user session.
      final userSession = await userSessionRepository.getUserSession();
      final User user = userSession.user;

      // 2. Load dashboard data.
      // Fetch all products and filter for low stock (stock < 5).
      final products = await productRepository.fetchProducts();
      final lowStockProducts = products.where((p) => p.stock < 3).toList();
      final totalStockPrice = products.fold<double>(
        0.0,
        (sum, p) => sum + (p.stock * p.netPrice),
      );

      // Define date ranges for today, this month, and this year.
      final now = DateTime.now();
      final startOfToday = DateTime(now.year, now.month, now.day);
      final startOfMonth = DateTime(now.year, now.month, 1);
      final startOfYear = DateTime(now.year, 1, 1);

      // Use the helper method to safely fetch transactions.
      final transactionsToday = await _fetchTransactionsSafe(
        startDate: startOfToday,
        endDate: now,
      );
      final transactionsMonth = await _fetchTransactionsSafe(
        startDate: startOfMonth,
        endDate: now,
      );
      final transactionsYear = await _fetchTransactionsSafe(
        startDate: startOfYear,
        endDate: now,
      );

      // Calculate items sold and profit from transactions.
      int calcItemsSold(List<Transaction> txns) =>
          txns.fold(0, (sum, t) => sum + t.quantity);
      double calcProfit(List<Transaction> txns) => txns.fold(
          0.0, (sum, t) => sum + (t.totalAgreedPrice - t.totalNetPrice));

      final dashboardData = DashboardData(
        lowStockProducts: lowStockProducts,
        transactionsToday: transactionsToday.length,
        transactionsMonth: transactionsMonth.length,
        transactionsYear: transactionsYear.length,
        itemsSoldToday: calcItemsSold(transactionsToday),
        itemsSoldMonth: calcItemsSold(transactionsMonth),
        itemsSoldYear: calcItemsSold(transactionsYear),
        profitToday: calcProfit(transactionsToday),
        profitMonth: calcProfit(transactionsMonth),
        profitYear: calcProfit(transactionsYear),
        totalStockPrice: totalStockPrice,
      );

      emit(HomeLoaded(user: user, dashboardData: dashboardData));
    } catch (e) {
      if (e.toString().contains("401")) {
        emit(const HomeError(
            "Login expired, please restart the app and login again"));
      } else {
        emit(const HomeError("Failed to load dashboard data."));
      }
    }
  }
}
