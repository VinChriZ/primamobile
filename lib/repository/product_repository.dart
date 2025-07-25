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
  Future<void> editProduct(
      String upc, Map<String, dynamic> updateFields) async {
    // Convert updateFields if needed, then call provider
    await _provider.updateProduct(upc, updateFields);
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

  // Fetch unique categories
  Future<List<String>> fetchUniqueCategories() async {
    return await _provider.getUniqueCategories();
  }

  // Fetch unique brands
  Future<List<String>> fetchUniqueBrands() async {
    return await _provider.getUniqueBrands();
  }

  // Activate a product
  Future<void> activateProduct(String upc) async {
    await _provider.activateProduct(upc);
  }

  // Deactivate a product
  Future<void> deactivateProduct(String upc) async {
    await _provider.deactivateProduct(upc);
  }
}
