import 'package:dio/dio.dart';
import 'package:primamobile/repository/user_session_repository.dart';
import 'package:primamobile/app/models/user_session/user_session.dart';
import 'package:primamobile/provider/exceptions/exceptions.dart';

class AuthInterceptor extends Interceptor {
  final UserSessionRepository _userSessionRepository = UserSessionRepository();

  bool _needAuthHeader(RequestOptions options) {
    return !options.path.contains('/login'); // Skip auth for login endpoint
  }

  @override
  Future<void> onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    try {
      if (_needAuthHeader(options)) {
        UserSession userSession = await _userSessionRepository.getUserSession();

        if (userSession.token != null && userSession.token!.isNotEmpty) {
          // String base64Token = base64.encode(utf8.encode(userSession.token!));
          options.headers['Authorization'] = 'Bearer ${userSession.token!}';
        } else {
          print('No valid token found in user session.');
          throw ProviderUnauthorizedException(
              message: 'User is not authorized to perform this action.');
        }
      }
    } catch (e) {
      print('Error in AuthInterceptor: $e');
      // Throw the custom exception directly
      rethrow;
    }

    // Pass the request to the next handler
    handler.next(options);
  }
}
