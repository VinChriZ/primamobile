import 'dart:convert';

import 'package:primamobile/app/models/user_session/user_session.dart';
import 'package:primamobile/utils/globals.dart';

class UserSessionNotFoundException implements Exception {}

class UserSessionCacheFailException implements Exception {}

class UserSessionProvider {
  Future readUserSession() async {
    return Globals.preferences.getString('user_session');
  }

  Future writeUserSession({required UserSession userSession}) async {
    return await Globals.preferences
        .setString('user_session', jsonEncode(userSession.toJson()));
  }

  Future flushUserSession() async {
    return await Globals.preferences.remove('user_session');
  }
}
