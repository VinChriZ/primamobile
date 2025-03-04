import 'package:primamobile/app/models/models.dart';
import 'package:primamobile/provider/dio/dio_client.dart';
import 'package:primamobile/provider/models/request_api/request_api.dart';

class UserProvider {
  Future<User> getUserDetails(int userId) async {
    final RequestParam param = RequestParam(parameters: {});
    final RequestObject request = RequestObjectFunction(requestParam: param);

    try {
      final response = await dioClient.get(
        '/users/$userId',
        queryParameters: await request.toJson(),
      );
      print('User Details Response: ${response.data}');
      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        return User.fromJson(data);
      } else {
        throw Exception(
            'Failed to fetch user details with status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching user details: $e');
      rethrow;
    }
  }

  Future<User> addUser(User user, String password) async {
    // Using 'password' separately so that the User model doesn't store plain text.
    final RequestParam param = RequestParam(parameters: {
      'username': user.username,
      'password': password,
      'role_id': user.roleId,
    });
    final RequestObject request = RequestObjectFunction(requestParam: param);
    try {
      final response = await dioClient.post(
        '/users/',
        data: await request.toJson(),
      );
      print('Add User Response: ${response.data}');
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data as Map<String, dynamic>;
        return User.fromJson(data);
      } else {
        throw Exception(
            'Failed to add user with status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error adding user: $e');
      rethrow;
    }
  }

  Future<User> updateUser(int userId, Map<String, dynamic> updatedData) async {
    final RequestParam param = RequestParam(parameters: updatedData);
    final RequestObject request = RequestObjectFunction(requestParam: param);
    try {
      final response = await dioClient.patch(
        '/users/$userId',
        data: await request.toJson(),
      );
      print('Update User Response: ${response.data}');
      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        return User.fromJson(data);
      } else {
        throw Exception(
            'Failed to update user with status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error updating user: $e');
      rethrow;
    }
  }

  Future<User> deactivateUser(int userId) async {
    try {
      final response = await dioClient.delete('/users/$userId');
      print('Deactivate User Response: ${response.data}');
      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        return User.fromJson(data);
      } else {
        throw Exception(
            'Failed to deactivate user with status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error deactivating user: $e');
      rethrow;
    }
  }

  Future<List<User>> fetchAllUsers() async {
    try {
      final response = await dioClient.get('/users/');
      print('Fetch All Users Response: ${response.data}');
      if (response.statusCode == 200) {
        final data = response.data as List;
        return data.map((json) => User.fromJson(json)).toList();
      } else {
        throw Exception(
            'Failed to fetch all users with status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching all users: $e');
      rethrow;
    }
  }
}
