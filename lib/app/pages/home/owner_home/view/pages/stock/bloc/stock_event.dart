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

class AddProduct extends StockEvent {
  final Product product;

  const AddProduct(this.product);

  @override
  List<Object> get props => [product];
}
