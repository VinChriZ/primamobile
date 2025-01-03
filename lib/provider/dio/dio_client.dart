import 'package:dio/dio.dart';
import 'package:primamobile/utils/constants.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/response_interceptor.dart';

Dio dioClient = Dio(
  BaseOptions(
    baseUrl: apiUrl,
    connectTimeout: const Duration(seconds: 5),
    contentType: Headers.jsonContentType,
  ),
)
  ..interceptors.add(AuthInterceptor())
  ..interceptors.add(ResponseInterceptor());
