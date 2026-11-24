import 'package:dio/dio.dart';

enum AppErrorType {
  network,
  timeout,
  unauthorized,
  notFound,
  validation,
  server,
  unknown,
}

class AppException implements Exception {
  const AppException(
    this.type, {
    required this.message,
    this.statusCode,
    this.cause,
    this.stackTrace,
  });

  factory AppException.fromDioException(DioException error) {
    final statusCode = error.response?.statusCode;
    final responseMessage = _extractMessage(error.response?.data);

    return switch (error.type) {
      DioExceptionType.connectionError ||
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout ||
      DioExceptionType.transformTimeout => AppException(
        AppErrorType.timeout,
        message: responseMessage ?? 'No se pudo conectar con el servidor.',
        cause: error,
        stackTrace: error.stackTrace,
      ),
      DioExceptionType.badCertificate => AppException(
        AppErrorType.network,
        message: 'Certificado no válido.',
        cause: error,
        stackTrace: error.stackTrace,
      ),
      DioExceptionType.badResponse => _fromBadResponse(
        statusCode: statusCode,
        message: responseMessage,
        error: error,
      ),
      DioExceptionType.cancel => AppException(
        AppErrorType.unknown,
        message: 'La petición fue cancelada.',
        cause: error,
        stackTrace: error.stackTrace,
      ),
      DioExceptionType.unknown => AppException(
        AppErrorType.network,
        message: responseMessage ?? 'Error de red inesperado.',
        cause: error,
        stackTrace: error.stackTrace,
      ),
    };
  }

  final AppErrorType type;
  final String message;
  final int? statusCode;
  final Object? cause;
  final StackTrace? stackTrace;

  static AppException _fromBadResponse({
    required int? statusCode,
    required String? message,
    required DioException error,
  }) {
    final AppErrorType type;
    if (statusCode == 401 || statusCode == 403) {
      type = AppErrorType.unauthorized;
    } else if (statusCode == 404) {
      type = AppErrorType.notFound;
    } else if (statusCode == 400 || statusCode == 422) {
      type = AppErrorType.validation;
    } else if (statusCode != null && statusCode >= 500) {
      type = AppErrorType.server;
    } else {
      type = AppErrorType.unknown;
    }

    return AppException(
      type,
      message: message ?? 'Error en la petición (HTTP $statusCode).',
      statusCode: statusCode,
      cause: error,
      stackTrace: error.stackTrace,
    );
  }

  static String? _extractMessage(Object? data) {
    if (data is Map) {
      final message = data['message'];
      if (message is String && message.isNotEmpty) {
        return message;
      }
      if (message is List && message.isNotEmpty) {
        return message.join(', ');
      }
      final error = data['error'];
      if (error is String && error.isNotEmpty) {
        return error;
      }
    }
    return null;
  }

  @override
  String toString() =>
      'AppException(${type.name}${statusCode != null ? ', $statusCode' : ''}): '
      '$message';
}
