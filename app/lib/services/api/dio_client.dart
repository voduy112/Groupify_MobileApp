import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:async';
import 'package:flutter/material.dart';

class DioClient {
  static final Dio _dio = Dio(BaseOptions(
    baseUrl: 'http://192.168.1.174:5000',
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  static final FlutterSecureStorage _storage = const FlutterSecureStorage();

  static bool _hasRefreshed = false;

  static void createInterceptors() {
    _dio.interceptors.add(LogInterceptor(
      request: true,
      requestHeader: true,
      requestBody: true,
      responseHeader: true,
      responseBody: true,
      error: true,
      logPrint: (obj) => print(obj),
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.read(key: 'accessToken');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        final requestOptions = error.requestOptions;

        if (requestOptions.path.contains('/api/auth/refresh-token') &&
            (error.response?.statusCode == 401 ||
                error.response?.statusCode == 403)) {
          await _storage.delete(key: 'accessToken');
          await _storage.delete(key: 'refreshToken');
          handler.reject(_tokenExpiredException(requestOptions));
          return;
        }

        if (error.response?.statusCode == 401 ||
            error.response?.statusCode == 403) {
          if (_hasRefreshed) {
            await _storage.delete(key: 'accessToken');
            await _storage.delete(key: 'refreshToken');
            handler.reject(_tokenExpiredException(requestOptions));
            return;
          }
          try {
            final refreshToken = await _storage.read(key: 'refreshToken');
            final refreshResponse = await _dio.post(
              '/api/auth/refresh-token',
              data: {'refreshToken': refreshToken},
            );
            final newAccessToken = refreshResponse.data['accessToken'];
            await _storage.write(key: 'accessToken', value: newAccessToken);

            _hasRefreshed = true;
            _dio.options.headers["Authorization"] = "Bearer $newAccessToken";
            requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';

            final response = await _dio.fetch(requestOptions);
            handler.resolve(response);
          } catch (e) {
            await _storage.delete(key: 'accessToken');
            await _storage.delete(key: 'refreshToken');
            handler.reject(_tokenExpiredException(requestOptions));
          }
          return;
        }

        handler.next(error);
      },
    ));
  }

  static Future<Response> _retryRequest(
      RequestOptions requestOptions, String newToken) {
    final options = Options(
      method: requestOptions.method,
      headers: {
        ...requestOptions.headers,
        'Authorization': 'Bearer $newToken',
      },
    );

    return _dio.request(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: options,
    );
  }

  static DioException _tokenExpiredException(RequestOptions requestOptions) {
    return DioException(
      requestOptions: requestOptions,
      type: DioExceptionType.unknown,
      error: "Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.",
    );
  }

  static void resetRefreshFlag() {
    _hasRefreshed = false;
  }

  static Dio get instance => _dio;
}
