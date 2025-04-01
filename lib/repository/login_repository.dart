import 'package:primamobile/provider/login_provider.dart';
import 'package:primamobile/repository/user_session_repository.dart';
import 'package:dio/dio.dart';

class LoginRepository {
  final LoginProvider _loginProvider = LoginProvider();
  final UserSessionRepository _userSessionRepository = UserSessionRepository();

  Future<void> login(String username, String password) async {
    try {
      // Fetch the login response from LoginProvider
      final response = await _loginProvider.login(
        username: username,
        password: password,
      );

      // Extract token and user_id from the response
      final String token = response['access_token'];
      final int userId = response['user_id'] as int;

      // Fetch current user session
      final userSession = await _userSessionRepository.getUserSession();

      // Update the user object with the new user_id
      final updatedUser = userSession.user.copyWith(userId: userId);

      // Create a new user session with the updated token and login status
      final updatedUserSession = userSession.copyWith(
        token: token,
        isLogin: true,
        user: updatedUser,
      );

      // Save the updated session to storage
      await _userSessionRepository.saveUserSession(updatedUserSession);

      print(
          'Login successful. Updated session: userId=${updatedUserSession.user.userId}, token=${updatedUserSession.token}');
    } on DioException catch (e) {
      // Handle specific HTTP status codes
      if (e.response != null) {
        switch (e.response!.statusCode) {
          case 403:
            throw Exception('User account is inactive');
          case 409:
            throw Exception('User already logged in elsewhere');
          default:
            throw Exception(
                'Login failed: ${e.response?.data['detail'] ?? e.message}');
        }
      } else {
        throw Exception('Login failed: No response from server');
      }
    } catch (e) {
      throw Exception('Login failed: ${e.toString()}');
    }
  }
}
