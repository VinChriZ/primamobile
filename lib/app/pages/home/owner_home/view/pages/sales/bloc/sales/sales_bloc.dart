import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:primamobile/app/models/transaction/transaction.dart';
import 'package:primamobile/repository/transaction_repository.dart';

part 'sales_event.dart';
part 'sales_state.dart';

class SalesBloc extends Bloc<SalesEvent, SalesState> {
  final TransactionRepository transactionRepository;

  SalesBloc({required this.transactionRepository}) : super(SalesInitial()) {
    on<FetchSales>(_onFetchSales);
    on<DeleteTransaction>(_onDeleteTransaction);
  }

  Future<void> _onFetchSales(FetchSales event, Emitter<SalesState> emit) async {
    emit(SalesLoading());
    try {
      // Fetch transactions using provided filter parameters.
      final transactions = await transactionRepository.fetchTransactions(
        startDate: event.startDate,
        endDate: event.endDate,
        sortBy: event.sortBy,
        sortOrder: event.sortOrder,
      );
      // Apply client-side sorting if needed.
      final sortedTransactions =
          _applySorting(transactions, event.sortBy, event.sortOrder);
      // Emit state including all filter values.
      emit(SalesLoaded(
        transactions: sortedTransactions,
        selectedDateRange: event.selectedDateRange,
        selectedSortBy: event.sortBy,
        selectedSortOrder: event.sortOrder,
        startDate: event.startDate,
        endDate: event.endDate,
      ));
    } catch (e) {
      emit(SalesError('Failed to fetch transactions: ${e.toString()}'));
    }
  }

  List<Transaction> _applySorting(
      List<Transaction> transactions, String sortBy, String sortOrder) {
    List<Transaction> sorted = List<Transaction>.from(transactions);
    int orderMultiplier = sortOrder.toLowerCase() == 'asc' ? 1 : -1;

    switch (sortBy) {
      case 'last_updated':
        sorted.sort((a, b) {
          final aDate = a.lastUpdated;
          final bDate = b.lastUpdated;
          return orderMultiplier * aDate.compareTo(bDate);
        });
        break;
      case 'quantity':
        sorted
            .sort((a, b) => orderMultiplier * a.quantity.compareTo(b.quantity));
        break;
      case 'profit':
        sorted.sort((a, b) {
          final aProfit = a.totalAgreedPrice - a.totalNetPrice;
          final bProfit = b.totalAgreedPrice - b.totalNetPrice;
          return orderMultiplier * aProfit.compareTo(bProfit);
        });
        break;
      case 'date_created':
        sorted.sort((a, b) {
          // Primary sort by date_created
          int dateCompare =
              orderMultiplier * a.dateCreated.compareTo(b.dateCreated);
          if (dateCompare != 0) {
            return dateCompare;
          }
          // Secondary sort by last_updated (always descending for better UX)
          return b.lastUpdated.compareTo(a.lastUpdated);
        });
        break;
      default:
        break;
    }
    return sorted;
  }

  Future<void> _onDeleteTransaction(
      DeleteTransaction event, Emitter<SalesState> emit) async {
    if (state is SalesLoaded) {
      final currentState = state as SalesLoaded;
      try {
        await transactionRepository.removeTransaction(event.transactionId);
        final updatedTransactions = currentState.transactions
            .where((txn) => txn.transactionId != event.transactionId)
            .toList();
        emit(SalesLoaded(
          transactions: updatedTransactions,
          selectedDateRange: currentState.selectedDateRange,
          selectedSortBy: currentState.selectedSortBy,
          selectedSortOrder: currentState.selectedSortOrder,
          startDate: currentState.startDate,
          endDate: currentState.endDate,
        ));
      } catch (e) {
        emit(SalesError('Failed to delete transaction: ${e.toString()}'));
      }
    }
  }
}
