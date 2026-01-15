import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../env/env.dart';
import 'api_exception.dart';

part 'api_client.g.dart';

@riverpod
Dio dio(Ref ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: Env.apiBaseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  if (Env.enableLogging) {
    dio.interceptors.add(LogInterceptor(requestBody: true, responseBody: true));
  }

  dio.interceptors.add(_ErrorInterceptor());

  return dio;
}

class _ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final apiException = _mapDioException(err);
    handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        error: apiException,
        type: err.type,
        response: err.response,
      ),
    );
  }

  ApiException _mapDioException(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiException.timeout(message: error.message);
      case DioExceptionType.connectionError:
        return ApiException.network(message: error.message);
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        if (statusCode != null) {
          return mapStatusCodeToException(statusCode, message: error.message);
        }
        return ApiException.unknown(message: error.message);
      default:
        return ApiException.unknown(message: error.message);
    }
  }
}
