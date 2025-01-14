// stock_event.dart
part of 'stock_bloc.dart';

abstract class StockEvent extends Equatable {
  const StockEvent();

  @override
  List<Object?> get props => [];
}

// Load all products along with categories and brands
class LoadProducts extends StockEvent {}

// Add a new product
class AddProduct extends StockEvent {
  final Product product;

  const AddProduct(this.product);

  @override
  List<Object?> get props => [product];
}

// Delete a product
class DeleteProduct extends StockEvent {
  final String upc;

  const DeleteProduct(this.upc);

  @override
  List<Object?> get props => [upc];
}

// Search products by name
class SearchProducts extends StockEvent {
  final String query;

  const SearchProducts(this.query);

  @override
  List<Object?> get props => [query];
}

// Filter products by category and/or brand
class FilterProducts extends StockEvent {
  final String? category;
  final String? brand;

  const FilterProducts({this.category, this.brand});

  @override
  List<Object?> get props => [category, brand];
}

// Sort products based on selected option
class SortProducts extends StockEvent {
  final String sortOption;

  const SortProducts(this.sortOption);

  @override
  List<Object?> get props => [sortOption];
}
