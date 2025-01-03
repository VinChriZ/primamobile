import 'dart:convert';
import 'package:primamobile/provider/dio/dio_client.dart';
import 'package:primamobile/provider/models/request_api/request_api.dart';

class LoginProvider {
  Future<String> login(
      {required String username, required String password}) async {
    // Prepare request parameters
    final RequestParam param = RequestParam(parameters: {
      'username': username,
      'password': password,
    });
    final RequestObject request = RequestObjectGET(requestParam: param);

    print('Request: ${jsonEncode(await request.toJson())}');

    try {
      // Send API request
      final response = await dioClient.post(
        '/login',
        data: jsonEncode(await request.toJson()),
      );

      // Parse and return token from response
      if (response.statusCode == 200) {
        return response.data['data']['TOKEN'] as String;
      } else {
        throw Exception('Failed to login');
      }
    } catch (e) {
      rethrow;
    }
  }
}
