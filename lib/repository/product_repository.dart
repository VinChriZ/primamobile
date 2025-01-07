import 'package:primamobile/app/models/models.dart';
import 'package:primamobile/provider/product_provider.dart';

class ProductRepository {
  final ProductProvider _provider = ProductProvider();

  // Fetch all products
  Future<List<Product>> fetchProducts() async {
    return await _provider.getProducts();
  }

  // Fetch product by UPC
  Future<Product> fetchProduct(String upc) async {
    return await _provider.getProduct(upc);
  }

  // Create a new product
  Future<void> addProduct(Product product) async {
    await _provider.createProduct(product);
  }

  // Update an existing product
  Future<void> editProduct(String upc, Product product) async {
    await _provider.updateProduct(upc, product);
  }

  // Delete a product
  Future<void> removeProduct(String upc) async {
    await _provider.deleteProduct(upc);
  }

  // Fetch products by category
  Future<List<Product>> fetchProductsByCategory(String category) async {
    return await _provider.getProductsByCategory(category);
  }

  // Update product stock
  Future<void> updateProductStock(String upc, int stock) async {
    await _provider.updateProductStock(upc, stock);
  }
}
