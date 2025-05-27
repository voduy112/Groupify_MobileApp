import 'package:dio/dio.dart';

class DioClient {
  static late Dio _dio;

  static void createInterceptors() {
    _dio = Dio(BaseOptions(
      baseUrl: 'http://10.0.2.2:5000',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ));
    _dio.interceptors.add(LogInterceptor(
      request: true,
      error: true,
    ));
  }

  static Dio get instance => _dio;
}
