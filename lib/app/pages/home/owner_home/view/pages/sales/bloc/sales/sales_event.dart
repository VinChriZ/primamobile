part of 'sales_bloc.dart';

abstract class SalesEvent extends Equatable {
  const SalesEvent();

  @override
  List<Object> get props => [];
}

class FetchSales extends SalesEvent {}

class DeleteTransaction extends SalesEvent {
  final int transactionId;

  const DeleteTransaction(this.transactionId);

  @override
  List<Object> get props => [transactionId];
}
