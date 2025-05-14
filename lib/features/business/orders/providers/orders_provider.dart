import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:now_shipping/data/services/api_service.dart';
import 'package:now_shipping/features/auth/services/auth_service.dart';
import 'package:now_shipping/features/business/orders/repositories/order_repository.dart';
import 'package:now_shipping/features/business/orders/services/order_service.dart';

// Order loading state
enum OrderLoadingState { initial, loading, loaded, error }

// Provider for the selected tab in the orders screen
final selectedOrderTabProvider = StateProvider<String>((ref) => 'All');

// Provider for API dependencies
final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  final apiService = ApiService();
  final authService = AuthService();
  return OrderRepository(
    apiService: apiService,
    authService: authService,
  );
});

final orderServiceProvider = Provider<OrderService>((ref) {
  final repository = ref.watch(orderRepositoryProvider);
  return OrderService(orderRepository: repository);
});

// Provider for orders loading state
final ordersLoadingStateProvider = StateProvider<OrderLoadingState>((ref) => OrderLoadingState.initial);

// Provider for orders data
final ordersDataProvider = StateProvider<List<Map<String, dynamic>>>((ref) => []);

// Provider for fetch orders function
final fetchOrdersProvider = Provider<Future<void> Function()>((ref) {
  return () async {
    print('DEBUG PROVIDER: This provider is deprecated. Use OrderService.getAllOrders directly with the orderType parameter');
    // The actual fetching is now done directly in the screen using the OrderService
    // This provider is kept for backwards compatibility
  };
});

// Provider for orders (backwards compatibility)
final ordersProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final orderService = ref.watch(orderServiceProvider);
  // Fetch orders from the API
  try {
    final orders = await orderService.getAllOrders();
    print('DEBUG PROVIDER: Orders fetched via legacy provider: ${orders.length}');
    return orders;
  } catch (e) {
    print('DEBUG PROVIDER: Error fetching orders in legacy provider: $e');
    rethrow;
  }
});

// Provider for filtered orders based on selected tab
final filteredOrdersProvider = Provider<List<Map<String, dynamic>>>((ref) {
  final orders = ref.watch(ordersDataProvider);
  final selectedTab = ref.watch(selectedOrderTabProvider);
  
  print('DEBUG PROVIDER: Filtering orders. Total: ${orders.length}, Selected tab: $selectedTab');
  
  if (selectedTab == 'All') {
    return orders;
  } else {
    final filtered = orders.where((order) => order['status'] == selectedTab).toList();
    print('DEBUG PROVIDER: Filtered orders: ${filtered.length}');
    return filtered;
  }
});

// Provider for order details
final orderDetailsProvider = FutureProvider.family<Map<String, dynamic>, String>((ref, orderNumber) async {
  final orderService = ref.watch(orderServiceProvider);
  // Fetch order details from the API
  try {
    final details = await orderService.getOrderDetails(orderNumber);
    print('DEBUG PROVIDER: Order details fetched for $orderNumber');
    return details;
  } catch (e) {
    print('DEBUG PROVIDER: Error fetching order details: $e');
    rethrow;
  }
});