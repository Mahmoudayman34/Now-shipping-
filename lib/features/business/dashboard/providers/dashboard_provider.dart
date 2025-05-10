import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:now_shipping/data/services/api_service.dart';
import 'package:now_shipping/features/auth/services/auth_service.dart';
import '../models/dashboard_model.dart';

class DashboardService {
  final ApiService _apiService;
  final AuthService _authService;
  
  DashboardService(this._apiService, this._authService);

  Future<DashboardStats> getDashboardStats() async {
    try {
      // Get authentication token
      final token = await _authService.getToken();
      if (token == null) {
        throw Exception('Authentication token not found');
      }
      
      // Fetch dashboard data from API
      final response = await _apiService.get(
        '/business/dashboard',
        token: token,
      );
      
      // Parse the response into our DashboardStats model
      return DashboardStats.fromJson(response);
    } catch (e) {
      print('Error fetching dashboard data: $e');
      // Return default data in case of error
      return DashboardStats();
    }
  }
  
  // Request email verification
  Future<Map<String, dynamic>> requestEmailVerification() async {
    try {
      // Get authentication token
      final token = await _authService.getToken();
      if (token == null) {
        print('Email verification error: Authentication token not found');
        return {
          'success': false,
          'message': 'Authentication token not found. Please log in again.'
        };
      }
      
      print('Making email verification request with token: ${token.substring(0, 10)}...');
      
      // Request email verification from API using GET instead of POST
      final response = await _apiService.get(
        '/business/request-verification-email',
        token: token,
      );
      
      print('Email verification API response: $response');
      
      // Extract status and message from the API response
      final success = response['status'] == 'success';
      final message = response['message'] ?? 'Verification email sent';
      
      return {
        'success': success,
        'message': message
      };
    } catch (e) {
      print('Error requesting email verification: $e');
      return {
        'success': false,
        'message': 'Failed to send verification email: ${e.toString()}'
      };
    }
  }
}

final dashboardServiceProvider = Provider((ref) {
  final apiService = ApiService();
  final authService = ref.watch(authServiceProvider);
  return DashboardService(apiService, authService);
});

final dashboardStatsProvider = FutureProvider<DashboardStats>((ref) async {
  final dashboardService = ref.read(dashboardServiceProvider);
  return dashboardService.getDashboardStats();
});

final detailedBreakdownTabProvider = StateProvider<DetailedBreakdownTab>((ref) {
  return DetailedBreakdownTab.awaitingAction;
});

final currentTabIndexProvider = StateProvider<int>((ref) => 0);