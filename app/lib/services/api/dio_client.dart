import 'package:dio/dio.dart';

class DioClient {
  static late final Dio _dio;

  static void createInterceptors() {
    _dio = Dio(BaseOptions(
      baseUrl: 'http://192.168.1.220:5000',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ));
    _dio.interceptors.add(LogInterceptor(
      request: true,
      error: true,
      responseBody: true,
      requestBody: true,
    ));
  }

  static Dio get instance => _dio;
}
