part of 'transaction_detail_bloc.dart';

abstract class TransactionDetailState extends Equatable {
  const TransactionDetailState();

  @override
  List<Object> get props => [];
}

class TransactionDetailInitial extends TransactionDetailState {}

class TransactionDetailLoading extends TransactionDetailState {}

// Updated state: includes both the transaction header and its details
class TransactionDetailLoaded extends TransactionDetailState {
  final Transaction transaction; // Updated header info
  final List<TransactionDetail> details;

  const TransactionDetailLoaded({
    required this.transaction,
    required this.details,
  });

  @override
  List<Object> get props => [transaction, details];
}

class TransactionDetailError extends TransactionDetailState {
  final String message;

  const TransactionDetailError(this.message);

  @override
  List<Object> get props => [message];
}
