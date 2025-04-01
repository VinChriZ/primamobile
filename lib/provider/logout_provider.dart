import 'package:primamobile/provider/dio/dio_client.dart';

class LogoutProvider {
  Future<void> logout() async {
    try {
      // Send logout request to the backend
      final response = await dioClient.post('/auth/logout');

      // Check response
      if (response.statusCode != 200) {
        throw Exception(
            'Failed to logout with status code: ${response.statusCode}');
      }

      print('Logout successful: ${response.data}');
    } catch (e) {
      print('Error during logout: $e');
      rethrow;
    }
  }
}
