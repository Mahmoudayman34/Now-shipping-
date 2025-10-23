import 'dart:async';
import 'package:now_shipping/core/constants/api_constants.dart';
import 'package:now_shipping/data/services/api_service.dart';
import 'package:now_shipping/features/business/wallet/models/cash_cycle_model.dart';

class CashCycleService {
  final ApiService _apiService;

  CashCycleService({ApiService? apiService}) 
      : _apiService = apiService ?? ApiService();

  /// Get cash cycle data for a specific time period
  /// 
  /// [timePeriod] can be: 'today', 'week', 'month', 'year', 'all'
  /// [token] is the authentication token
  Future<CashCycleModel> getCashCycles({
    required String timePeriod,
    required String token,
  }) async {
    try {
      print('CASH CYCLE: Starting request for timePeriod: $timePeriod with timeout: 300s');
      
      final response = await _apiService.get(
        ApiConstants.cashCycles,
        token: token,
        queryParams: {
          'timePeriod': timePeriod,
        },
      );

      if (response == null) {
        print('CASH CYCLE: No data received from server');
        throw Exception('No data received from server');
      }

      print('CASH CYCLE: Request completed successfully for timePeriod: $timePeriod');
      print('CASH CYCLE: Response type: ${response.runtimeType}');
      print('CASH CYCLE: Response keys: ${response is Map ? response.keys.toList() : 'Not a map'}');
      print('CASH CYCLE: Starting model parsing...');

      final model = CashCycleModel.fromJson(response);
      print('CASH CYCLE: Model parsing completed successfully');
      print('CASH CYCLE: Model has ${model.orders.length} orders');
      
      return model;
    } catch (e, stackTrace) {
      print('CASH CYCLE ERROR: $e');
      print('CASH CYCLE STACK: $stackTrace');
      
      // Check if it's a timeout error
      if (e.toString().contains('timeout') || e.toString().contains('Timeout')) {
        if (timePeriod == 'all') {
          throw Exception('Loading all data is taking longer than expected. Please try a shorter time period or check your connection.');
        } else {
          throw Exception('Request timed out. Please check your connection and try again.');
        }
      }
      throw Exception('Failed to fetch cash cycle data: $e');
    }
  }

  /// Get cash cycle data with custom date range
  /// 
  /// [startDate] and [endDate] should be in ISO 8601 format
  /// [token] is the authentication token
  Future<CashCycleModel> getCashCyclesByDateRange({
    required DateTime startDate,
    required DateTime endDate,
    required String token,
  }) async {
    try {
      final response = await _apiService.get(
        ApiConstants.cashCycles,
        token: token,
        queryParams: {
          'startDate': startDate.toIso8601String(),
          'endDate': endDate.toIso8601String(),
        },
      );

      if (response == null) {
        throw Exception('No data received from server');
      }

      return CashCycleModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to fetch cash cycle data: $e');
    }
  }

  /// Export cash cycle data to Excel
  /// 
  /// [timePeriod] can be: 'today', 'week', 'month', 'year', 'all'
  /// [dateFrom] and [dateTo] are optional for custom date range
  /// [orderStatus] filters by order status (default: 'completed')
  /// [token] is the authentication token
  Future<Map<String, dynamic>> exportCashCyclesToExcel({
    required String timePeriod,
    String? dateFrom,
    String? dateTo,
    String orderStatus = 'completed',
    required String token,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'timePeriod': timePeriod,
        'orderStatus': orderStatus,
      };

      // Add custom date range if provided
      if (dateFrom != null && dateTo != null) {
        queryParams['dateFrom'] = dateFrom;
        queryParams['dateTo'] = dateTo;
      }

      final response = await _apiService.get(
        ApiConstants.exportCashCycles,
        token: token,
        queryParams: queryParams,
      );

      if (response == null) {
        throw Exception('No Excel file received from server');
      }

      // Check if response is binary data
      if (response is Map<String, dynamic> && response['type'] == 'binary') {
        return response;
      }

      throw Exception('Invalid response format from server');
    } catch (e) {
      throw Exception('Failed to export cash cycle data: $e');
    }
  }
}
