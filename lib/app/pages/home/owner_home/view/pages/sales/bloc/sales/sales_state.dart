part of 'sales_bloc.dart';

abstract class SalesState extends Equatable {
  const SalesState();

  @override
  List<Object> get props => [];
}

class SalesInitial extends SalesState {}

class SalesLoading extends SalesState {}

class SalesLoaded extends SalesState {
  final List<Transaction> transactions;

  const SalesLoaded(this.transactions);

  @override
  List<Object> get props => [transactions];
}

class SalesError extends SalesState {
  final String message;

  const SalesError(this.message);

  @override
  List<Object> get props => [message];
}
