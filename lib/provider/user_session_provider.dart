import 'dart:convert';

import 'package:primamobile/app/models/user_session/user_session.dart';
import 'package:primamobile/utils/globals.dart';

class UserSessionNotFoundException implements Exception {}

class UserSessionCacheFailException implements Exception {}

class UserSessionProvider {
  Future<String?> readUserSession() async {
    return Globals.preferences.getString('user_session');
  }

  Future<void> writeUserSession({required UserSession userSession}) async {
    final success = await Globals.preferences
        .setString('user_session', jsonEncode(userSession.toJson()));
    if (!success) {
      throw UserSessionCacheFailException();
    }
  }

  Future<void> flushUserSession() async {
    final success = await Globals.preferences.remove('user_session');
    if (!success) {
      throw UserSessionCacheFailException();
    }
  }
}
