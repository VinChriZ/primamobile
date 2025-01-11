import 'package:dio/dio.dart';
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
  Future<void> updateProduct(String upc, Product product) async {
    final RequestParam param = RequestParam(parameters: product.toJson());
    final RequestObject request = RequestObjectFunction(requestParam: param);

    try {
      final response = await dioClient.put(
        '/products/$upc',
        data: await request.toJson(),
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

  // Upload product image
  Future<String> uploadProductImage(String upc, String imagePath) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(imagePath),
      });
      final response =
          await dioClient.post('/products/$upc/upload-image', data: formData);

      print('Response received: ${response.data}'); // Debug log

      if (response.statusCode == 200) {
        return response.data['image_url'];
      } else {
        throw Exception(
            'Failed to upload product image. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error uploading product image: $e'); // Debug log
      throw Exception('Error uploading product image: $e');
    }
  }
}
