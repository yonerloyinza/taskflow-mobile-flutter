import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../config/app_config.dart';
import '../constants/app_constants.dart';
import 'interceptors/error_interceptor.dart';
import 'interceptors/logging_interceptor.dart';
import 'interceptors/retry_interceptor.dart';

Dio createDio(AppConfig config, {bool enableLogging = kDebugMode}) {
  final dio = Dio(
    BaseOptions(
      baseUrl: config.apiBaseUrl,
      connectTimeout: AppConstants.connectTimeout,
      receiveTimeout: AppConstants.receiveTimeout,
      headers: const <String, dynamic>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      responseType: ResponseType.json,
    ),
  );

  dio.interceptors.addAll([
    LoggingInterceptor(),
    RetryInterceptor(dio: dio),
    ErrorInterceptor(),
  ]);

  return dio;
}
