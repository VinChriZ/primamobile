import 'package:primamobile/app/models/models.dart';
import 'package:primamobile/provider/dio/dio_client.dart';
import 'package:primamobile/provider/models/request_api/request_api.dart';

class UserProvider {
  Future<User> getUserDetails(int userId) async {
    final RequestParam param = RequestParam(parameters: {});
    final RequestObject request = RequestObjectFunction(requestParam: param);

    try {
      // Make an API call to fetch user details
      final response = await dioClient.get(
        '/users/$userId',
        queryParameters: await request.toJson(),
      );

      // Debug print the response
      print('User Details Response: ${response.data}');

      // Ensure the response is valid
      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        return User.fromJson(data); // Parse response into User model
      } else {
        throw Exception(
            'Failed to fetch user details with status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching user details: $e');
      rethrow;
    }
  }
}
