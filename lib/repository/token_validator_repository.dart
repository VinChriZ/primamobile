import 'package:primamobile/provider/token_validator_provider.dart';
import 'package:primamobile/repository/user_session_repository.dart';

class TokenValidatorRepository {
  final TokenValidatorProvider _tokenValidatorProvider =
      TokenValidatorProvider();
  final UserSessionRepository _userSessionRepository = UserSessionRepository();

  Future<bool> validateToken() async {
    try {
      // Get the current user session
      final userSession = await _userSessionRepository.getUserSession();

      // If there's no token, it's invalid
      if (userSession.token == null || userSession.token!.isEmpty) {
        return false;
      }

      // Validate the token with the backend
      final isValid =
          await _tokenValidatorProvider.validateToken(userSession.token!);

      // If token is invalid, clear the user session
      if (!isValid) {
        final clearedSession = userSession.copyWith(
          isLogin: false,
          token: null,
        );
        await _userSessionRepository.saveUserSession(clearedSession);
      }

      return isValid;
    } catch (e) {
      // On error, clear session and return false
      print('Error validating token: $e');
      await _clearSession();
      return false;
    }
  }

  Future<void> _clearSession() async {
    final userSession = await _userSessionRepository.getUserSession();
    final clearedSession = userSession.copyWith(
      isLogin: false,
      token: null,
    );
    await _userSessionRepository.saveUserSession(clearedSession);
  }
}
