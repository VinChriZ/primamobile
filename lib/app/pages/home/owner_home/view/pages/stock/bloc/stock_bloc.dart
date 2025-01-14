import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:primamobile/app/models/product/product.dart';
import 'package:primamobile/repository/product_repository.dart';

part 'stock_event.dart';
part 'stock_state.dart';

class StockBloc extends Bloc<StockEvent, StockState> {
  final ProductRepository productRepository;

  StockBloc({required this.productRepository}) : super(StockInitial()) {
    on<LoadProducts>(_onLoadProducts);
    on<AddProduct>(_onAddProduct);
    on<DeleteProduct>(_onDeleteProduct);
    on<SearchProducts>(_onSearchProducts);
    on<FilterProducts>(_onFilterProducts);
    on<SortProducts>(_onSortProducts);
    on<UpdateProduct>(_onUpdateProduct);
  }

  /// Handles loading of all products, categories, and brands.
  Future<void> _onLoadProducts(
      LoadProducts event, Emitter<StockState> emit) async {
    emit(StockLoading());
    try {
      // Fetch all products, categories, and brands concurrently
      final productsFuture = productRepository.fetchProducts();
      final categoriesFuture = productRepository.fetchUniqueCategories();
      final brandsFuture = productRepository.fetchUniqueBrands();

      final results = await Future.wait([
        productsFuture,
        categoriesFuture,
        brandsFuture,
      ]);

      final allProducts = results[0] as List<Product>;
      final categories = results[1] as List<String>;
      final brands = results[2] as List<String>;

      emit(StockLoaded(
        allProducts: allProducts,
        displayedProducts: allProducts,
        categories: categories,
        brands: brands,
        selectedCategory: null,
        selectedBrand: null,
        searchQuery: '',
        sortOption: 'Last Updated', // Set "Last Updated" as default
      ));

      // Apply default sorting
      add(SortProducts('Last Updated'));
    } catch (e) {
      emit(StockError('Failed to load products, categories, or brands.'));
    }
  }

  /// Handles adding a new product.
  Future<void> _onAddProduct(AddProduct event, Emitter<StockState> emit) async {
    if (state is StockLoaded) {
      try {
        await productRepository.addProduct(event.product);
        // Reload products after adding
        add(LoadProducts());
      } catch (e) {
        emit(StockError('Failed to add product.'));
      }
    }
  }

  Future<void> _onUpdateProduct(
    UpdateProduct event,
    Emitter<StockState> emit,
  ) async {
    try {
      // Call the repository method with upc + partial fields
      await productRepository.editProduct(event.upc, event.updateFields);

      // Reload after updating
      add(LoadProducts());
    } catch (e) {
      emit(StockError('Failed to update product: $e'));
    }
  }

  /// Handles deleting a product.
  Future<void> _onDeleteProduct(
      DeleteProduct event, Emitter<StockState> emit) async {
    if (state is StockLoaded) {
      try {
        await productRepository.removeProduct(event.upc);
        // Reload products after deletion
        add(LoadProducts());
      } catch (e) {
        emit(StockError('Failed to delete product.'));
      }
    }
  }

  /// Handles searching products by name.
  void _onSearchProducts(SearchProducts event, Emitter<StockState> emit) {
    if (state is StockLoaded) {
      final currentState = state as StockLoaded;
      final query = event.query.trim().toLowerCase();

      List<Product> filteredProducts = currentState.allProducts;

      // Apply search filter
      if (query.isNotEmpty) {
        filteredProducts = filteredProducts.where((product) {
          return product.name.toLowerCase().contains(query);
        }).toList();
      }

      // Apply category filter if any
      if (currentState.selectedCategory != null) {
        filteredProducts = filteredProducts.where((product) {
          return product.category == currentState.selectedCategory;
        }).toList();
      }

      // Apply brand filter if any
      if (currentState.selectedBrand != null) {
        filteredProducts = filteredProducts.where((product) {
          return product.brand == currentState.selectedBrand;
        }).toList();
      }

      // Apply sorting
      if (currentState.sortOption != null) {
        filteredProducts =
            _applySorting(filteredProducts, currentState.sortOption!);
      }

      emit(currentState.copyWith(
        displayedProducts: filteredProducts,
        searchQuery: event.query,
      ));
    }
  }

  /// Handles filtering products by category and/or brand.
  void _onFilterProducts(FilterProducts event, Emitter<StockState> emit) {
    if (state is StockLoaded) {
      final currentState = state as StockLoaded;

      String? category = event.category ?? currentState.selectedCategory;
      String? brand = event.brand ?? currentState.selectedBrand;

      List<Product> filteredProducts = currentState.allProducts;

      // Apply category filter if selected
      if (category != null) {
        filteredProducts = filteredProducts.where((product) {
          return product.category == category;
        }).toList();
      }

      // Apply brand filter if selected
      if (brand != null) {
        filteredProducts = filteredProducts.where((product) {
          return product.brand == brand;
        }).toList();
      }

      // Apply search filter if any
      if (currentState.searchQuery != null &&
          currentState.searchQuery!.trim().isNotEmpty) {
        final query = currentState.searchQuery!.trim().toLowerCase();
        filteredProducts = filteredProducts.where((product) {
          return product.name.toLowerCase().contains(query);
        }).toList();
      }

      // Apply sorting
      if (currentState.sortOption != null) {
        filteredProducts =
            _applySorting(filteredProducts, currentState.sortOption!);
      }

      emit(currentState.copyWith(
        displayedProducts: filteredProducts,
        selectedCategory: category,
        selectedBrand: brand,
      ));
    }
  }

  /// Handles sorting products based on the selected option.
  void _onSortProducts(SortProducts event, Emitter<StockState> emit) {
    if (state is StockLoaded) {
      final currentState = state as StockLoaded;
      final sortOption = event.sortOption;

      List<Product> sortedProducts =
          _applySorting(currentState.displayedProducts, sortOption);

      emit(currentState.copyWith(
        displayedProducts: sortedProducts,
        sortOption: sortOption,
      ));
    }
  }

  /// Helper method to apply sorting to a list of products.
  List<Product> _applySorting(List<Product> products, String sortOption) {
    List<Product> sorted = List<Product>.from(products);
    switch (sortOption) {
      case 'Lowest Stock':
        sorted.sort((a, b) => a.stock.compareTo(b.stock));
        break;
      case 'Highest Stock':
        sorted.sort((a, b) => b.stock.compareTo(a.stock));
        break;
      case 'Last Updated':
        sorted.sort((a, b) {
          final aDate = a.lastUpdated ?? DateTime.fromMillisecondsSinceEpoch(0);
          final bDate = b.lastUpdated ?? DateTime.fromMillisecondsSinceEpoch(0);
          return bDate.compareTo(aDate);
        });
        break;
      default:
        break;
    }
    return sorted;
  }
}
