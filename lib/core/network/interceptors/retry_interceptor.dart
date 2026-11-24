import 'dart:developer' as developer;

import 'package:dio/dio.dart';

import '../../constants/app_constants.dart';

class RetryInterceptor extends Interceptor {
  RetryInterceptor({
    required this.dio,
    this.retries = AppConstants.retryCount,
    this.retryBaseDelay = AppConstants.retryBaseDelay,
  });

  final Dio dio;
  final int retries;
  final Duration retryBaseDelay;

  static const Set<String> _retryableErrors = {
    'connectionError',
    'connectionTimeout',
    'sendTimeout',
    'receiveTimeout',
  };

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final attempt = (err.requestOptions.extra['__retryAttempt'] as int?) ?? 0;
    final isRetryable =
        _retryableErrors.contains(err.type.name) ||
        (err.response?.statusCode != null && err.response!.statusCode! >= 500);

    if (!isRetryable || attempt >= retries) {
      handler.next(err);
      return;
    }

    final nextAttempt = attempt + 1;
    final delay = retryBaseDelay * (1 << (nextAttempt - 1));

    developer.log(
      'Reintentando ($nextAttempt/$retries) en '
      '${delay.inMilliseconds}ms: ${err.requestOptions.uri}',
      name: 'TaskFlow.Dio.Retry',
    );

    await Future<void>.delayed(delay);

    err.requestOptions.extra['__retryAttempt'] = nextAttempt;

    try {
      final response = await dio.fetch<dynamic>(err.requestOptions);
      handler.resolve(response);
    } on DioException catch (nextError) {
      handler.next(nextError);
    }
  }
}
