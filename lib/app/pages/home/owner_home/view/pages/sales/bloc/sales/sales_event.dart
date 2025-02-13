part of 'sales_bloc.dart';

abstract class SalesEvent extends Equatable {
  const SalesEvent();

  @override
  List<Object?> get props => [];
}

class FetchSales extends SalesEvent {
  final DateTime? startDate;
  final DateTime? endDate;
  final String? sortBy;
  final String? sortOrder;

  const FetchSales({this.startDate, this.endDate, this.sortBy, this.sortOrder});

  @override
  List<Object?> get props => [startDate, endDate, sortBy, sortOrder];
}

class DeleteTransaction extends SalesEvent {
  final int transactionId;

  const DeleteTransaction(this.transactionId);

  @override
  List<Object> get props => [transactionId];
}
