part of 'sales_bloc.dart';

abstract class SalesEvent extends Equatable {
  const SalesEvent();

  @override
  List<Object?> get props => [];
}

class FetchSales extends SalesEvent {
  final String selectedDateRange;
  final DateTime? startDate;
  final DateTime? endDate;
  final String sortBy;
  final String sortOrder;
  // Default values are provided here so that the event is always complete.
  const FetchSales({
    this.selectedDateRange = 'Last 7 Days',
    this.startDate,
    this.endDate,
    this.sortBy = 'date_created',
    this.sortOrder = 'desc',
  });

  @override
  List<Object?> get props =>
      [selectedDateRange, startDate, endDate, sortBy, sortOrder];
}

class DeleteTransaction extends SalesEvent {
  final int transactionId;

  const DeleteTransaction(this.transactionId);

  @override
  List<Object> get props => [transactionId];
}
