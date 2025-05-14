class ApiConstants {
  // Base URL for the API
  static const String baseUrl = '{{base_url}}';
  
  // API endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String deleteAccount = '/auth/DeleteAccount';
  
  // API response keys
  static const String token = 'token';
  static const String message = 'message';
  static const String data = 'data';
  static const String status = 'status';
  static const String error = 'error';
} 