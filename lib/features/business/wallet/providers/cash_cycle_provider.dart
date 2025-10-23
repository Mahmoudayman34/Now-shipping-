import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:now_shipping/data/services/api_service.dart';
import 'package:now_shipping/features/auth/services/auth_service.dart';
import 'package:now_shipping/features/business/wallet/models/cash_cycle_model.dart';
import 'package:now_shipping/features/business/wallet/services/cash_cycle_service.dart';

// Cash cycle service provider
final cashCycleServiceProvider = Provider<CashCycleService>((ref) {
  print('CASH CYCLE SERVICE PROVIDER: Creating service');
  final apiService = ApiService();
  return CashCycleService(apiService: apiService);
});

// Selected time period provider
final selectedTimePeriodProvider = StateProvider<String>((ref) => 'all');

// Cash cycle data provider
final cashCycleDataProvider = FutureProvider.family<CashCycleModel, String>((ref, timePeriod) async {
  try {
    print('CASH CYCLE PROVIDER: Starting provider for timePeriod: $timePeriod');
    final cashCycleService = ref.watch(cashCycleServiceProvider);
    final authService = ref.watch(authServiceProvider);
    
    final token = await authService.getToken();
    if (token == null) {
      throw Exception('No authentication token');
    }
    
    print('CASH CYCLE PROVIDER: Token obtained, calling service...');
    final result = await cashCycleService.getCashCycles(
      timePeriod: timePeriod,
      token: token,
    );
    print('CASH CYCLE PROVIDER: Service call completed successfully');
    return result;
  } catch (e, stackTrace) {
    print('CASH CYCLE PROVIDER ERROR: $e');
    print('CASH CYCLE PROVIDER STACK: $stackTrace');
    rethrow;
  }
});

// Cash cycle data by date range provider
final cashCycleDataByDateRangeProvider = FutureProvider.family<CashCycleModel, Map<String, DateTime>>((ref, dateRange) async {
  final cashCycleService = ref.watch(cashCycleServiceProvider);
  final authService = ref.watch(authServiceProvider);
  
  final token = await authService.getToken();
  if (token == null) {
    throw Exception('No authentication token');
  }
  
  return await cashCycleService.getCashCyclesByDateRange(
    startDate: dateRange['startDate']!,
    endDate: dateRange['endDate']!,
    token: token,
  );
});

// Export cash cycle data provider
final exportCashCycleProvider = FutureProvider.family<Map<String, dynamic>?, String>((ref, timePeriod) async {
  final cashCycleService = ref.watch(cashCycleServiceProvider);
  final authService = ref.watch(authServiceProvider);
  
  final token = await authService.getToken();
  if (token == null) {
    throw Exception('No authentication token');
  }
  
  return await cashCycleService.exportCashCyclesToExcel(
    timePeriod: timePeriod,
    token: token,
  );
});

// Available time periods
final availableTimePeriodsProvider = Provider<List<String>>((ref) => [
  'all',
  'today',
  'week',
  'month',
  'year',
]);

// Time period display names
final timePeriodDisplayNamesProvider = Provider<List<String>>((ref) => [
  'All Time',
  'Today',
  'This Week',
  'This Month',
  'This Year',
]);

// Helper provider for time period display name
final timePeriodDisplayNameProvider = Provider<String>((ref) {
  final selectedPeriod = ref.watch(selectedTimePeriodProvider);
  final displayNames = ref.watch(timePeriodDisplayNamesProvider);
  final periods = ref.watch(availableTimePeriodsProvider);
  
  final index = periods.indexOf(selectedPeriod);
  return index >= 0 ? displayNames[index] : selectedPeriod;
});
