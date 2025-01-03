import 'dart:convert';
import 'package:primamobile/provider/dio/dio_client.dart';
import 'package:primamobile/provider/models/request_api/request_api.dart';

class LoginProvider {
  Future<String> login(
      {required String username, required String password}) async {
    // Create a request parameter object
    final RequestParam param = RequestParam(parameters: {
      'username': username,
      'password': password,
    });

    // Convert the request parameter object into a request object
    final RequestObject request =
        RequestObjectGET(requestParam: param); // Assuming POST is used here

    // Debug print the request
    print('Request: ${jsonEncode(await request.toJson())}');

    try {
      // Send the request using the dioClient
      final response = await dioClient.post(
        '/login',
        data: await request.toJson(), // Serialize request object to JSON
      );

      // Debug print the response
      print('Response: ${response.data}');

      // Handle the response
      if (response.statusCode == 200) {
        // Assuming the backend response includes an `access_token` field
        return response.data['access_token'] as String;
      } else {
        throw Exception(
            'Failed to login with status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error during login: $e');
      rethrow;
    }
  }
}
