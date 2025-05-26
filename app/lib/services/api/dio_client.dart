import 'package:dio/dio.dart';

class DioClient {
  static final Dio _dio = Dio(BaseOptions(
    baseUrl: 'http://10.0.2.2:5000',
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  static Dio get instance => _dio;
}
