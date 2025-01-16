part of 'transaction_detail_bloc.dart';

abstract class TransactionDetailState extends Equatable {
  const TransactionDetailState();

  @override
  List<Object> get props => [];
}

class TransactionDetailInitial extends TransactionDetailState {}

class TransactionDetailLoading extends TransactionDetailState {}

class TransactionDetailLoaded extends TransactionDetailState {
  final List<TransactionDetail> details;

  const TransactionDetailLoaded(this.details);

  @override
  List<Object> get props => [details];
}

class TransactionDetailError extends TransactionDetailState {
  final String message;

  const TransactionDetailError(this.message);

  @override
  List<Object> get props => [message];
}
