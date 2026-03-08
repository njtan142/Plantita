import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvironmentConfig {
  final String baseUrl;
  final String apiKey;

  EnvironmentConfig({
    required this.baseUrl,
    required this.apiKey,
  });

  factory EnvironmentConfig.development() {
    return EnvironmentConfig(
      baseUrl: dotenv.env['BASE_URL'] ?? 'http://localhost:8080', // Provide a fallback
      apiKey: dotenv.env['API_KEY'] ?? 'default_dev_api_key', // Provide a fallback
    );
  }

  factory EnvironmentConfig.production() {
    return EnvironmentConfig(
      baseUrl: dotenv.env['BASE_URL'] ?? 'https://api.plantita.com', // Provide a fallback
      apiKey: dotenv.env['API_KEY'] ?? 'default_prod_api_key', // Provide a fallback
    );
  }
}
