import 'dart:convert'; // Import dart:convert for base64 encoding
import 'package:dio/dio.dart';
import 'package:primamobile/repository/user_session_repository.dart';
import 'package:primamobile/app/models/user_session/user_session.dart';

class AuthInterceptor extends Interceptor {
  final UserSessionRepository _userSessionRepository = UserSessionRepository();

  bool _needAuthHeader(RequestOptions options) => true;

  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    if (_needAuthHeader(options)) {
      // Retrieve the current user session
      UserSession userSession = await _userSessionRepository.getUserSession();

      // Check if the user session has a valid token
      if (userSession.token != null && userSession.token!.isNotEmpty) {
        // Base64 encode the token
        String base64Token = base64.encode(utf8.encode(userSession.token!));

        // Set the Authorization header with the encoded token
        options.headers['Authorization'] = 'Basic $base64Token';
      }
    }

    super.onRequest(options, handler);
  }
}
