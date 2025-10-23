class ApiConstants {
  // Base URL for the API
  static const String baseUrl = '{{base_url}}';
  
  // API endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String deleteAccount = '/auth/DeleteAccount';
  static const String ratePickup = '/business/pickup-details';
  static const String transactions = '/business/transactions';
  static const String cashCycles = '/business/cash-cycles';
  static const String exportCashCycles = '/business/wallet/export-cash-cycles';
  
  // API response keys
  static const String token = 'token';
  static const String message = 'message';
  static const String data = 'data';
  static const String status = 'status';
  static const String error = 'error';
} 