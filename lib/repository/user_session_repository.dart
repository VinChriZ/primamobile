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
      bool hasKey = Globals.preferences.containsKey('user_session');
      print('UserSession key exists: $hasKey'); // Debug print

      if (!hasKey) {
        throw UserSessionInvalidException();
      }

      String? raw = await _userSessionProvider.readUserSession();
      // print('Raw user session read from preferences: $raw'); // Debug print

      if (raw == null) {
        throw UserSessionNotFoundException();
      }

      Map<String, dynamic> data = jsonDecode(raw);
      // print('Decoded user session data: $data'); // Debug print

      UserSession userSession = UserSession.fromJson(data);
      // print('User session deserialized: ${userSession.toJson()}'); // Debug print

      return userSession;
    } catch (e) {
      print('Error reading user session: $e'); // Debug print
      return UserSession();
    }
  }

  Future<void> saveUserSession(UserSession userSession) async {
    try {
      await _userSessionProvider.writeUserSession(userSession: userSession);
      Globals.userSession = userSession;
      // print('User session saved: ${userSession.toJson()}'); // Debug print
    } catch (e) {
      print('Error saving user session: $e'); // Debug print
      throw UserSessionWriteException();
    }
  }

  Future<void> clearUserSession() async {
    try {
      await _userSessionProvider.flushUserSession();
      Globals.userSession = UserSession();
      print('User session cleared');
    } catch (e) {
      print('Error clearing user session: $e');
    }
  }
}
