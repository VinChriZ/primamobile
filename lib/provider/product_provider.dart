import 'package:primamobile/app/models/models.dart';
import 'package:primamobile/provider/dio/dio_client.dart';
import 'package:primamobile/provider/models/request_api/request_api.dart';

class ProductProvider {
  // Fetch all products
  Future<List<Product>> getProducts() async {
    final RequestParam param = RequestParam(parameters: {});
    final RequestObject request = RequestObjectFunction(requestParam: param);

    try {
      final response = await dioClient.get(
        '/products/',
        queryParameters: await request.toJson(),
      );
      print('Response received: ${response.data}'); // Debug log

      if (response.statusCode == 200) {
        final data =
            response.data['products'] as List<dynamic>; // Extract 'products'
        return data
            .map((item) => Product.fromJson(item))
            .toList(); // Map to Product list
      } else {
        throw Exception(
            'Failed to fetch products. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching products: $e'); // Debug log
      throw Exception('Error fetching products: $e');
    }
  }

  // Fetch product by UPC
  Future<Product> getProduct(String upc) async {
    final RequestParam param = RequestParam(parameters: {});
    final RequestObject request = RequestObjectFunction(requestParam: param);

    try {
      final response = await dioClient.get(
        '/products/$upc',
        queryParameters: await request.toJson(),
      );
      print('Response received: ${response.data}'); // Debug log

      if (response.statusCode == 200) {
        final data = response.data; // Directly fetch product details
        return Product.fromJson(data);
      } else {
        throw Exception(
            'Failed to fetch product. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching product: $e'); // Debug log
      throw Exception('Error fetching product: $e');
    }
  }

  // Create a new product
  Future<void> createProduct(Product product) async {
    final RequestParam param = RequestParam(parameters: product.toJson());
    final RequestObject request = RequestObjectFunction(requestParam: param);
    final jsonPayload = await request.toJson();
    print("JSON Payload Sent to API: $jsonPayload");

    try {
      final response = await dioClient.post(
        '/products/',
        data: jsonPayload,
      );
      print('Response received: ${response.data}'); // Debug log
    } catch (e) {
      print('Error creating product: $e'); // Debug log
      throw Exception('Error creating product: $e');
    }
  }

  // Update an existing product
  Future<void> updateProduct(
      String upc, Map<String, dynamic> updateFields) async {
    try {
      print('Sending PUT /products/$upc with data: $updateFields'); // Debug log
      final response = await dioClient.put(
        '/products/$upc',
        data: updateFields,
      );
      print('Response received: ${response.data}'); // Debug log
    } catch (e) {
      print('Error updating product: $e'); // Debug log
      throw Exception('Error updating product: $e');
    }
  }

  // Delete a product
  Future<void> deleteProduct(String upc) async {
    final RequestParam param = RequestParam(parameters: {});
    final RequestObject request = RequestObjectFunction(requestParam: param);

    try {
      final response = await dioClient.delete(
        '/products/$upc',
        data: await request.toJson(),
      );
      print('Response received: ${response.data}'); // Debug log
    } catch (e) {
      print('Error deleting product: $e'); // Debug log
      throw Exception('Error deleting product: $e');
    }
  }

  // Fetch products by category
  Future<List<Product>> getProductsByCategory(String category) async {
    final RequestParam param = RequestParam(parameters: {'category': category});
    final RequestObject request = RequestObjectFunction(requestParam: param);

    try {
      final response = await dioClient.get(
        '/products',
        queryParameters: await request.toJson(),
      );
      print('Response received: ${response.data}'); // Debug log

      if (response.statusCode == 200) {
        final data =
            response.data['products'] as List<dynamic>; // Extract 'products'
        return data
            .map((item) => Product.fromJson(item))
            .toList(); // Map to Product list
      } else {
        throw Exception(
            'Failed to fetch products by category. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching products by category: $e'); // Debug log
      throw Exception('Error fetching products by category: $e');
    }
  }

  // Update product stock
  Future<void> updateProductStock(String upc, int stock) async {
    final RequestParam param = RequestParam(parameters: {'stock': stock});
    final RequestObject request = RequestObjectFunction(requestParam: param);

    try {
      final response = await dioClient.put(
        '/products/$upc/stock',
        data: await request.toJson(),
      );
      print('Response received: ${response.data}'); // Debug log
    } catch (e) {
      print('Error updating product stock: $e'); // Debug log
      throw Exception('Error updating product stock: $e');
    }
  }

  // Fetch unique categories
  Future<List<String>> getUniqueCategories() async {
    try {
      final response = await dioClient.get('/products/unique/categories');
      if (response.statusCode == 200) {
        final data = response.data['categories'] as List<dynamic>;
        return List<String>.from(data);
      } else {
        throw Exception(
            'Failed to fetch categories. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching categories: $e');
    }
  }

  // Fetch unique brands
  Future<List<String>> getUniqueBrands() async {
    try {
      final response = await dioClient.get('/products/unique/brands');
      if (response.statusCode == 200) {
        final data = response.data['brands'] as List<dynamic>;
        return List<String>.from(data);
      } else {
        throw Exception(
            'Failed to fetch brands. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching brands: $e');
    }
  }

  // Activate a product
  Future<void> activateProduct(String upc) async {
    try {
      final response = await dioClient.patch('/products/$upc/activate');
      print('Response received: ${response.data}'); // Debug log
    } catch (e) {
      print('Error activating product: $e'); // Debug log
      throw Exception('Error activating product: $e');
    }
  }

  // Deactivate a product
  Future<void> deactivateProduct(String upc) async {
    try {
      final response = await dioClient.patch('/products/$upc/deactivate');
      print('Response received: ${response.data}'); // Debug log
    } catch (e) {
      print('Error deactivating product: $e'); // Debug log
      throw Exception('Error deactivating product: $e');
    }
  }
}
