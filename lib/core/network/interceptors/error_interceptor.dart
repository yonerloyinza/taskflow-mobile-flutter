import 'dart:developer' as developer;

import 'package:dio/dio.dart';

import '../../errors/app_exception.dart';

class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final appException = AppException.fromDioException(err);
    developer.log(
      'Error mapeada: $appException',
      name: 'TaskFlow.Dio',
      error: appException.cause,
      stackTrace: appException.stackTrace,
    );
    handler.next(err);
  }
}
