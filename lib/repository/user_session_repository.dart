import 'dart:convert';
import 'package:primamobile/app/models/user_session/user_session.dart';
import 'package:primamobile/provider/user_session_provider.dart';
import 'package:primamobile/utils/globals.dart';

class UserSessionInvalidException implements Exception {}

class UserSessionWriteException implements Exception {
  final String message = 'Failed to save user data.';
}

class UserSessionRepository {
  final UserSessionProvider _userSessionProvider = UserSessionProvider();

  Future<UserSession> getUserSession() async {
    try {
      if (!Globals.preferences.containsKey('user_session')) {
        print('No user session found. Returning default session.');
        return UserSession(); // Return a default session instead of throwing an exception
      }

      String? raw = await _userSessionProvider.readUserSession();
      if (raw == null) {
        print('User session data is null. Returning default session.');
        return UserSession(); // Fallback to default session
      }

      Map<String, dynamic> data = jsonDecode(raw);
      return UserSession.fromJson(data);
    } catch (e) {
      print('Error reading user session: $e'); // Log the error
      return UserSession(); // Return a default session on any error
    }
  }

  Future<void> saveUserSession(UserSession userSession) async {
    try {
      await _userSessionProvider.writeUserSession(userSession: userSession);
      Globals.userSession = userSession;
    } catch (e) {
      print('Error saving user session: $e');
      throw UserSessionWriteException();
    }
  }

  Future<void> clearUserSession() async {
    try {
      await _userSessionProvider.flushUserSession();
      Globals.userSession = UserSession(); // Reset Globals
    } catch (e) {
      print('Error clearing user session: $e');
      throw UserSessionCacheFailException();
    }
  }
}
