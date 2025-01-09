part of 'stock_bloc.dart';

abstract class StockEvent extends Equatable {
  const StockEvent();

  @override
  List<Object> get props => [];
}

class LoadProducts extends StockEvent {}

class DeleteProduct extends StockEvent {
  final String upc;

  const DeleteProduct(this.upc);

  @override
  List<Object> get props => [upc];
}
