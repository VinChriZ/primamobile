import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:primamobile/app/models/transaction/transaction_detail.dart';
import 'package:primamobile/repository/transaction_detail_repository.dart';

part 'transaction_detail_event.dart';
part 'transaction_detail_state.dart';

class TransactionDetailBloc
    extends Bloc<TransactionDetailEvent, TransactionDetailState> {
  final TransactionDetailRepository transactionDetailRepository;

  TransactionDetailBloc({required this.transactionDetailRepository})
      : super(TransactionDetailInitial()) {
    on<FetchTransactionDetails>(_onFetchTransactionDetails);
    on<AddTransactionDetail>(_onAddTransactionDetail);
    on<UpdateTransactionDetail>(_onUpdateTransactionDetail);
    on<DeleteTransactionDetail>(_onDeleteTransactionDetail);
  }

  Future<void> _onFetchTransactionDetails(FetchTransactionDetails event,
      Emitter<TransactionDetailState> emit) async {
    emit(TransactionDetailLoading());
    try {
      final details = await transactionDetailRepository
          .fetchTransactionDetails(event.transactionId);
      emit(TransactionDetailLoaded(details));
    } catch (e) {
      emit(TransactionDetailError(
          'Failed to fetch transaction details: ${e.toString()}'));
    }
  }

  Future<void> _onAddTransactionDetail(
      AddTransactionDetail event, Emitter<TransactionDetailState> emit) async {
    if (state is TransactionDetailLoaded) {
      try {
        await transactionDetailRepository.addTransactionDetail(
            event.transactionId, event.fields);
        // Re-fetch transaction details after adding
        add(FetchTransactionDetails(event.transactionId));
      } catch (e) {
        emit(TransactionDetailError(
            'Failed to add transaction detail: ${e.toString()}'));
      }
    }
  }

  Future<void> _onUpdateTransactionDetail(UpdateTransactionDetail event,
      Emitter<TransactionDetailState> emit) async {
    if (state is TransactionDetailLoaded) {
      try {
        await transactionDetailRepository.updateTransactionDetail(
            event.transactionId, event.detailId, event.fields);
        // Re-fetch transaction details after updating
        add(FetchTransactionDetails(event.transactionId));
      } catch (e) {
        emit(TransactionDetailError(
            'Failed to update transaction detail: ${e.toString()}'));
      }
    }
  }

  Future<void> _onDeleteTransactionDetail(DeleteTransactionDetail event,
      Emitter<TransactionDetailState> emit) async {
    if (state is TransactionDetailLoaded) {
      try {
        await transactionDetailRepository.removeTransactionDetail(
            event.transactionId, event.detailId);
        // Re-fetch transaction details after deleting
        add(FetchTransactionDetails(event.transactionId));
      } catch (e) {
        emit(TransactionDetailError(
            'Failed to delete transaction detail: ${e.toString()}'));
      }
    }
  }
}
