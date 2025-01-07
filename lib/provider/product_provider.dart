import 'package:primamobile/app/models/models.dart';
import 'package:primamobile/provider/dio/dio_client.dart';

class ProductProvider {
  // Fetch all products
  Future<List<Product>> getProducts() async {
    try {
      final response = await dioClient.get('/products');
      print('Get Products Response: ${response.data}');

      if (response.statusCode == 200) {
        final data = response.data as List<dynamic>;
        return data.map((item) => Product.fromJson(item)).toList();
      } else {
        throw Exception(
            'Failed to fetch products with status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching products: $e');
      rethrow;
    }
  }

  // Fetch product by UPC
  Future<Product> getProduct(String upc) async {
    try {
      final response = await dioClient.get('/products/$upc');
      print('Get Product Response: ${response.data}');

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        return Product.fromJson(data);
      } else {
        throw Exception(
            'Failed to fetch product with status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching product: $e');
      rethrow;
    }
  }

  // Create a new product
  Future<void> createProduct(Product product) async {
    try {
      final response = await dioClient.post(
        '/products',
        data: product.toJson(),
      );
      print('Create Product Response: ${response.data}');
    } catch (e) {
      print('Error creating product: $e');
      rethrow;
    }
  }

  // Update an existing product
  Future<void> updateProduct(String upc, Product product) async {
    try {
      final response = await dioClient.put(
        '/products/$upc',
        data: product.toJson(),
      );
      print('Update Product Response: ${response.data}');
    } catch (e) {
      print('Error updating product: $e');
      rethrow;
    }
  }

  // Delete a product
  Future<void> deleteProduct(String upc) async {
    try {
      final response = await dioClient.delete('/products/$upc');
      print('Delete Product Response: ${response.data}');
    } catch (e) {
      print('Error deleting product: $e');
      rethrow;
    }
  }

  // Fetch products by category
  Future<List<Product>> getProductsByCategory(String category) async {
    try {
      final response = await dioClient
          .get('/products', queryParameters: {'category': category});
      print('Get Products by Category Response: ${response.data}');

      if (response.statusCode == 200) {
        final data = response.data as List<dynamic>;
        return data.map((item) => Product.fromJson(item)).toList();
      } else {
        throw Exception(
            'Failed to fetch products by category with status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching products by category: $e');
      rethrow;
    }
  }

  // Update product stock
  Future<void> updateProductStock(String upc, int stock) async {
    try {
      final response = await dioClient.put(
        '/products/$upc/stock',
        data: {'stock': stock},
      );
      print('Update Product Stock Response: ${response.data}');
    } catch (e) {
      print('Error updating product stock: $e');
      rethrow;
    }
  }
}
