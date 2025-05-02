class AppConstants {
  // Storage keys
  static const String userDataKey = 'user_data';
  static const String tokenKey = 'auth_token';
  static const String themeKey = 'app_theme';
  static const String languageKey = 'app_language';
  
  // API endpoints
  static const String loginEndpoint = '/auth/login';
  static const String registerEndpoint = '/auth/register';
  static const String logoutEndpoint = '/auth/logout';
  static const String shipmentsEndpoint = '/shipments';
  
  // App settings
  static const int apiTimeoutSeconds = 30;
  static const String appName = 'Logistics App';
  
  // Error messages
  static const String networkErrorMessage = 'Network error. Please check your connection.';
  static const String generalErrorMessage = 'Something went wrong. Please try again.';
  static const String authErrorMessage = 'Authentication failed. Please login again.';
  
  // Validation
  static const int passwordMinLength = 6;
  static const int nameMinLength = 3;
}
