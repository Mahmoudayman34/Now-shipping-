enum Environment {
  development,
  staging,
  production,
}

class AppConfig {
  static const Environment environment = Environment.development;
  
  // API configuration
  static String get apiBaseUrl {
    switch (environment) {
      case Environment.development:
        return 'https://nowshipping.co/api/v1';
      case Environment.staging:
        return 'https://nowshipping.co/api/v1';
      case Environment.production:
        return 'https://nowshipping.co/api/v1';
    }
  }
  
  // Feature toggles
  static bool get enableAnalytics {
    return environment == Environment.production;
  }
  
  static bool get showDebugBanner {
    return environment != Environment.production;
  }
  
  // App versions
  static const String appVersion = '1.0.0';
  static const int appBuildNumber = 1;
}
