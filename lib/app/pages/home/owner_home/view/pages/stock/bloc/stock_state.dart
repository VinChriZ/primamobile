// stock_state.dart
part of 'stock_bloc.dart';

abstract class StockState extends Equatable {
  const StockState();

  @override
  List<Object?> get props => [];
}

class StockInitial extends StockState {}

class StockLoading extends StockState {}

class StockLoaded extends StockState {
  final List<Product> allProducts; // Master list of all products
  final List<Product>
      displayedProducts; // Products after filtering/searching/sorting
  final List<String> categories; // Unique categories
  final List<String> brands; // Unique brands
  final String? selectedCategory; // Currently selected category filter
  final String? selectedBrand; // Currently selected brand filter
  final String? searchQuery; // Current search query
  final String? sortOption; // Current sort option

  const StockLoaded({
    required this.allProducts,
    required this.displayedProducts,
    required this.categories,
    required this.brands,
    this.selectedCategory,
    this.selectedBrand,
    this.searchQuery,
    this.sortOption,
  });

  @override
  List<Object?> get props => [
        allProducts,
        displayedProducts,
        categories,
        brands,
        selectedCategory ?? '',
        selectedBrand ?? '',
        searchQuery ?? '',
        sortOption ?? '',
      ];

  // Method to copy the current state with updated properties
  StockLoaded copyWith({
    List<Product>? allProducts,
    List<Product>? displayedProducts,
    List<String>? categories,
    List<String>? brands,
    String? selectedCategory,
    String? selectedBrand,
    String? searchQuery,
    String? sortOption,
  }) {
    return StockLoaded(
      allProducts: allProducts ?? this.allProducts,
      displayedProducts: displayedProducts ?? this.displayedProducts,
      categories: categories ?? this.categories,
      brands: brands ?? this.brands,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      selectedBrand: selectedBrand ?? this.selectedBrand,
      searchQuery: searchQuery ?? this.searchQuery,
      sortOption: sortOption ?? this.sortOption,
    );
  }
}

class StockError extends StockState {
  final String message;

  const StockError(this.message);

  @override
  List<Object?> get props => [message];
}
