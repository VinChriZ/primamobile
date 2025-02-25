part of 'sales_bloc.dart';

abstract class SalesState extends Equatable {
  const SalesState();

  @override
  List<Object?> get props => [];
}

class SalesInitial extends SalesState {}

class SalesLoading extends SalesState {}

class SalesLoaded extends SalesState {
  final List<Transaction> transactions;
  final String selectedDateRange;
  final String selectedSortBy;
  final String selectedSortOrder;
  final DateTime? startDate;
  final DateTime? endDate;

  const SalesLoaded({
    required this.transactions,
    required this.selectedDateRange,
    required this.selectedSortBy,
    required this.selectedSortOrder,
    this.startDate,
    this.endDate,
  });

  @override
  List<Object?> get props => [
        transactions,
        selectedDateRange,
        selectedSortBy,
        selectedSortOrder,
        startDate,
        endDate
      ];
}

class SalesError extends SalesState {
  final String message;

  const SalesError(this.message);

  @override
  List<Object> get props => [message];
}
