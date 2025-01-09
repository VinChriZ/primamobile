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
    on<DeleteProduct>(_onDeleteProduct);
    on<AddProduct>(_onAddProduct);
  }

  Future<void> _onLoadProducts(
      LoadProducts event, Emitter<StockState> emit) async {
    emit(StockLoading());
    try {
      final products = await productRepository.fetchProducts();
      emit(StockLoaded(products: products));
    } catch (e) {
      emit(const StockError('Failed to load products.'));
    }
  }

  Future<void> _onAddProduct(AddProduct event, Emitter<StockState> emit) async {
    if (state is StockLoaded) {
      try {
        await productRepository.addProduct(event.product);
        add(LoadProducts()); // Refresh product list
      } catch (e) {
        emit(const StockError('Failed to add product.'));
      }
    }
  }

  Future<void> _onDeleteProduct(
      DeleteProduct event, Emitter<StockState> emit) async {
    if (state is StockLoaded) {
      try {
        await productRepository.removeProduct(event.upc);
        add(LoadProducts()); // Refresh product list
      } catch (e) {
        emit(const StockError('Failed to delete product.'));
      }
    }
  }
}
