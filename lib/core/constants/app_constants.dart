class AppConstants {
  const AppConstants._();

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);
  static const int retryCount = 3;
  static const Duration retryBaseDelay = Duration(milliseconds: 500);

  static const int defaultPageSize = 10;
  static const int maxPageSize = 100;
}
