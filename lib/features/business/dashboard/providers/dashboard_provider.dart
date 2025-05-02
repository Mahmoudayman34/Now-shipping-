import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/dashboard_model.dart';

class DashboardService {
  Future<DashboardStats> getDashboardStats() async {
    // In a real app, this would fetch from an API
    await Future.delayed(const Duration(milliseconds: 800));
    
    // For now, return dummy data
    return DashboardStats(
      inHubPackages: 0,
      toDeliverToday: 0,
      headingToCustomer: 0,
      awaitingAction: 0,
      successfulOrders: 0,
      unsuccessfulOrders: 0,
      headingToYou: 0,
      newOrders: 1,
      expectedCash: 0.0,
      collectedCash: 0.0,
    );
  }
}

final dashboardServiceProvider = Provider((ref) => DashboardService());

final dashboardStatsProvider = FutureProvider<DashboardStats>((ref) async {
  final dashboardService = ref.read(dashboardServiceProvider);
  return dashboardService.getDashboardStats();
});

final detailedBreakdownTabProvider = StateProvider<DetailedBreakdownTab>((ref) {
  return DetailedBreakdownTab.awaitingAction;
});

final currentTabIndexProvider = StateProvider<int>((ref) => 0);