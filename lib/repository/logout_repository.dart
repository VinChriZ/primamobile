import 'package:primamobile/provider/logout_provider.dart';
import 'package:primamobile/repository/user_session_repository.dart';

class LogoutRepository {
  final LogoutProvider _logoutProvider = LogoutProvider();
  final UserSessionRepository _userSessionRepository = UserSessionRepository();

  Future<void> logout() async {
    try {
      // First call the logout API to clear token on server
      await _logoutProvider.logout();

      // Then clear local session data
      await _userSessionRepository.clearUserSession();

      print('Logout completed successfully');
    } catch (e) {
      print('Logout failed: $e');
      throw Exception('Logout failed: ${e.toString()}');
    }
  }
}
