import 'package:dio/dio.dart';
import 'package:primamobile/provider/exceptions/exceptions.dart';

class ResponseInterceptor extends Interceptor {
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    print('Response received: ${response.data}'); // Log the raw response

    try {
      // Handle client-side errors
      if (response.statusCode! >= 400 && response.statusCode! < 500) {
        throw ProviderBadRequestException(
            message: response.data?['message'] ?? 'Client error occurred.');
      }

      // Handle server-side errors
      if (response.statusCode! >= 500) {
        throw ProviderInternalServerErrorException(
            message: response.data?['message'] ?? 'Server error occurred.');
      }

      // Validate token existence
      // if (response.data is! Map || !response.data.containsKey('access_token')) {
      //   throw ProviderBadRequestException(
      //       message: 'Response does not contain access_token.');
      // }

      handler.next(response); // Pass the response to the next handler
    } catch (e) {
      print('Error in ResponseInterceptor: $e');
      rethrow; // Throw the error for further handling
    }
  }
}
