import 'package:dio/dio.dart';
import 'package:primamobile/provider/exceptions/exceptions.dart';

class ResponseInterceptor extends Interceptor {
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (response.statusCode! >= 400 && response.statusCode! < 500) {
      throw ProviderBadRequestException();
    }
    if (response.statusCode! >= 500) {
      throw ProviderInternalServerErrorException();
    }
    if (response.data == null) {
      throw ProviderNoContentException();
    }

    var responseData = response.data as Map<String, dynamic>;
    if (!responseData.containsKey('data')) {
      throw ProviderBadRequestException();
    }

    super.onResponse(response, handler);
  }
}
