import 'dart:developer' as developer;

import 'package:dio/dio.dart';

class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    developer.log('→ ${options.method} ${options.uri}', name: 'TaskFlow.Dio');
    if (options.data != null) {
      developer.log('  body: ${options.data}', name: 'TaskFlow.Dio');
    }
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    developer.log(
      '← ${response.statusCode} ${response.requestOptions.uri}',
      name: 'TaskFlow.Dio',
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    developer.log(
      '✕ ${err.response?.statusCode ?? '-'} ${err.requestOptions.uri} '
      '(${err.type.name}): ${err.message}',
      name: 'TaskFlow.Dio',
    );
    handler.next(err);
  }
}
