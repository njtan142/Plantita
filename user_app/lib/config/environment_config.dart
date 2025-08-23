class EnvironmentConfig {
  final String baseUrl;
  final String apiKey;

  EnvironmentConfig({
    required this.baseUrl,
    required this.apiKey,
  });

  factory EnvironmentConfig.development() {
    return EnvironmentConfig(
      baseUrl: 'https://dev.api.plantita.com',
      apiKey: 'dev_api_key',
    );
  }

  factory EnvironmentConfig.production() {
    return EnvironmentConfig(
      baseUrl: 'https://api.plantita.com',
      apiKey: 'prod_api_key',
    );
  }
}
