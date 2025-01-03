import 'package:primamobile/provider/login_provider.dart';
import 'package:primamobile/repository/user_session_repository.dart';

class LoginRepository {
  final LoginProvider _loginProvider = LoginProvider();
  final UserSessionRepository _userSessionRepository = UserSessionRepository();

  Future<void> login(String username, String password) async {
    try {
      // Fetch token from the LoginProvider
      final token =
          await _loginProvider.login(username: username, password: password);

      // Fetch current user session
      final userSession = await _userSessionRepository.getUserSession();

      // Update the employee object with the new username (nik)
      final updatedUser = userSession.user.copyWith(username: username);

      // Create a new user session with the updated token and login status
      final updatedUserSession = userSession.copyWith(
        token: token,
        isLogin: true,
        user: updatedUser, // Updated user object
      );

      // Save the updated session to storage
      await _userSessionRepository.saveUserSession(updatedUserSession);

      print(
          'Login successful. Updated session: ${updatedUserSession.user.username}');
    } catch (e) {
      // Handle exceptions
      throw Exception('Login failed: ${e.toString()}');
    }
  }
}
