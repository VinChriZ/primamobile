import 'package:primamobile/provider/dio/dio_client.dart';

class TokenValidatorProvider {
  Future<bool> validateToken(String token) async {
    try {
      // Set the token in the headers
      dioClient.options.headers['Authorization'] = 'Bearer $token';

      // Call the validate-token endpoint
      final response = await dioClient.get('/auth/validate-token');

      // Return true if the token is valid
      return response.statusCode == 200;
    } catch (e) {
      print('Token validation failed: $e');
      return false;
    }
  }
}
