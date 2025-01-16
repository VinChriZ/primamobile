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
    // You can add more event handlers here
  }

  Future<void> _onFetchSales(FetchSales event, Emitter<SalesState> emit) async {
    emit(SalesLoading());
    try {
      final transactions = await transactionRepository.fetchTransactions();
      emit(SalesLoaded(transactions));
    } catch (e) {
      emit(SalesError('Failed to fetch transactions: ${e.toString()}'));
    }
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
        emit(SalesLoaded(updatedTransactions));
      } catch (e) {
        emit(SalesError('Failed to delete transaction: ${e.toString()}'));
      }
    }
  }
}
