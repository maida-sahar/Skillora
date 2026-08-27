enum Environment { development, staging, production }

class AppEnv {
  static Environment _environment = Environment.development;

  static Environment get current => _environment;

  static void initialize(Environment env) {
    _environment = env;
  }

  static String get baseUrl {
    switch (_environment) {
      case Environment.development:
        return 'https://dev-api.skillora.app/v1';
      case Environment.staging:
        return 'https://staging-api.skillora.app/v1';
      case Environment.production:
        return 'https://api.skillora.app/v1';
    }
  }

  static bool get isDev => _environment == Environment.development;
  static bool get isProd => _environment == Environment.production;
}
