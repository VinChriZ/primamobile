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
        throw UserSessionInvalidException();
      }

      String? raw = await _userSessionProvider.readUserSession();
      if (raw == null) {
        throw UserSessionNotFoundException();
      }

      Map<String, dynamic> data = jsonDecode(raw);
      return UserSession.fromJson(data);
    } catch (e) {
      print('Error reading user session: $e'); // Debug for now
      throw UserSessionInvalidException(); // Rethrow specific exception
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
