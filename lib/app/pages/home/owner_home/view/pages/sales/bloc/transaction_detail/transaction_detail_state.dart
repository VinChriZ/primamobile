part of 'transaction_detail_bloc.dart';

abstract class TransactionDetailState extends Equatable {
  const TransactionDetailState();

  @override
  List<Object?> get props => [];
}

class TransactionDetailInitial extends TransactionDetailState {}

class TransactionDetailLoading extends TransactionDetailState {}

class TransactionDetailLoaded extends TransactionDetailState {
  final Transaction transaction;
  final List<TransactionDetail> details;
  final User user; // New field

  const TransactionDetailLoaded({
    required this.transaction,
    required this.details,
    required this.user,
  });

  @override
  List<Object?> get props => [transaction, details, user];
}

class TransactionDetailError extends TransactionDetailState {
  final String message;

  const TransactionDetailError(this.message);

  @override
  List<Object?> get props => [message];
}
