class AppConfig {
  const AppConfig({required this.apiBaseUrl, required this.environment});

  final String apiBaseUrl;
  final String environment;

  bool get isProduction => environment == 'prod';
}
