import 'package:now_shipping/data/services/api_service.dart';
import 'package:now_shipping/features/auth/services/auth_service.dart';
import 'dart:convert';

class OrderRepository {
  final ApiService _apiService;
  final AuthService _authService;
  
  OrderRepository({
    required ApiService apiService,
    required AuthService authService,
  }) : 
    _apiService = apiService,
    _authService = authService;

  // Get all orders
  Future<List<dynamic>> getOrders({String orderType = "All"}) async {
    try {
      print('DEBUG REPO: Fetching orders with orderType: $orderType');
      
      // Get authentication token
      final token = await _authService.getToken();
      if (token == null) {
        print('DEBUG REPO: Auth token is null');
        throw Exception('Authentication token not found');
      }
      
      // Fetch orders from API
      final response = await _apiService.get(
        '/business/orders',
        token: token,
        queryParams: {'orderType': orderType},
      );

      print('DEBUG REPO: API response type: ${response.runtimeType}');
      print('DEBUG REPO: API response: $response');
      
      // Check if response is valid
      if (response == null) {
        print('DEBUG REPO: Response is null');
        return [];
      }
      
      // Check if orders array is present in response
      if (response is Map<String, dynamic>) {
        if (response.containsKey('data')) {
          final data = response['data'];
          print('DEBUG REPO: Found data field in response, type: ${data.runtimeType}');
          
          if (data is List) {
            return data;
          } else {
            print('DEBUG REPO: Data field is not a list: $data');
            return [];
          }
        } else if (response.containsKey('orders')) {
          final orders = response['orders'];
          print('DEBUG REPO: Found orders field in response, type: ${orders.runtimeType}');
          
          if (orders is List) {
            return orders;
          } else {
            print('DEBUG REPO: Orders field is not a list: $orders');
            return [];
          }
        }
      }
      
      // Direct list response
      if (response is List) {
        print('DEBUG REPO: Response is a direct list of length: ${response.length}');
        return response;
      }
      
      print('DEBUG REPO: Unexpected response format: $response');
      return [];
    } catch (e) {
      print('DEBUG REPO: Exception in getOrders: $e');
      throw Exception('Failed to fetch orders: $e');
    }
  }

  // Get order details by orderNumber
  Future<Map<String, dynamic>> getOrderDetails(String orderNumber) async {
    try {
      print('DEBUG REPO: Fetching order details for orderNumber: $orderNumber');
      
      // Get authentication token
      final token = await _authService.getToken();
      if (token == null) {
        print('DEBUG REPO: Auth token is null');
        throw Exception('Authentication token not found');
      }
      
      // Fetch order details from API
      final response = await _apiService.get(
        '/business/order-details/$orderNumber',
        token: token,
      );
      
      print('DEBUG REPO: Order details response type: ${response.runtimeType}');
      print('DEBUG REPO: Order details response: $response');
      
      // Return the order details
      if (response is Map<String, dynamic>) {
        return response;
      } else {
        print('DEBUG REPO: Response is not a map: $response');
        return {};
      }
    } catch (e) {
      print('DEBUG REPO: Exception in getOrderDetails: $e');
      throw Exception('Failed to fetch order details: $e');
    }
  }

  // Create a new order
  Future<Map<String, dynamic>> createOrder(Map<String, dynamic> orderData) async {
    try {
      print('DEBUG REPO: Creating order with data: $orderData');
      print('DEBUG EXPRESS REPO: expressShipping in repository: ${orderData['expressShipping']}');
      
      // Rename expressShipping to isExpressShipping for API compatibility
      if (orderData.containsKey('expressShipping')) {
        // Store the value and remove the old key
        bool expressValue = orderData['expressShipping'];
        orderData.remove('expressShipping');
        
        // Add with the correct key name that matches the API response format
        orderData['isExpressShipping'] = expressValue;
        print('DEBUG EXPRESS REPO: Renamed parameter to isExpressShipping: ${orderData['isExpressShipping']}');
      }
      
      // Special handling for Cash Collection orders
      if (orderData['orderType'] == 'Cash Collection') {
        print('DEBUG REPO: Processing Cash Collection order');
        
        // Validate required fields for Cash Collection
        if (!orderData.containsKey('amountCashCollection')) {
          throw Exception('Missing required field: amountCashCollection');
        }
        
        // Make sure amountCashCollection is an integer
        final amount = orderData['amountCashCollection'];
        if (amount is String) {
          orderData['amountCashCollection'] = int.tryParse(amount) ?? 0;
        }
        
        print('DEBUG REPO: Cash Collection request payload: ${json.encode(orderData)}');
      }
      
      // Get authentication token
      final token = await _authService.getToken();
      if (token == null) {
        print('DEBUG REPO: Auth token is null');
        throw Exception('Authentication token not found');
      }
      
      // Send order data to API
      print('DEBUG REPO: Sending create order request with body: ${json.encode(orderData)}');
      print('DEBUG EXPRESS REPO: isExpressShipping right before API call: ${orderData['isExpressShipping']}');
      
      final response = await _apiService.post(
        '/business/submit-order',
        token: token,
        body: orderData,
      );
      
      print('DEBUG REPO: Create order response: $response');
      if (response is Map && response.containsKey('order')) {
        final orderResponse = response['order'];
        if (orderResponse is Map && orderResponse.containsKey('orderShipping')) {
          print('DEBUG EXPRESS REPO: isExpressShipping in response: ${orderResponse['orderShipping']['isExpressShipping']}');
        }
      }
      
      // Return the created order
      if (response is Map<String, dynamic>) {
        return response;
      } else {
        print('DEBUG REPO: Response is not a map: $response');
        return {};
      }
    } catch (e) {
      print('DEBUG REPO: Exception in createOrder: $e');
      
      // Provide more specific error messages
      if (e.toString().contains('400')) {
        print('DEBUG REPO: 400 Bad Request error - likely invalid data format');
        
        // Check common issues
        if (orderData['orderType'] == 'Cash Collection' && 
            (!orderData.containsKey('amountCashCollection') || 
             orderData['amountCashCollection'] == 0)) {
          throw Exception('Cash Collection amount is missing or invalid');
        }
      }
      
      throw Exception('Failed to create order: $e');
    }
  }

  // Update an existing order
  Future<Map<String, dynamic>> updateOrder(String orderId, Map<String, dynamic> orderData) async {
    try {
      print('DEBUG REPO: Updating order $orderId with data: $orderData');
      
      // Rename expressShipping to isExpressShipping for API compatibility
      if (orderData.containsKey('expressShipping')) {
        // Store the value and remove the old key
        bool expressValue = orderData['expressShipping'];
        orderData.remove('expressShipping');
        
        // Add with the correct key name that matches the API response format
        orderData['isExpressShipping'] = expressValue;
        print('DEBUG EXPRESS REPO: Renamed parameter to isExpressShipping: ${orderData['isExpressShipping']}');
      }
      
      // Get authentication token
      final token = await _authService.getToken();
      if (token == null) {
        print('DEBUG REPO: Auth token is null');
        throw Exception('Authentication token not found');
      }
      
      // Send update order data to API
      print('DEBUG REPO: Sending update order request with body: ${json.encode(orderData)}');
      
      final response = await _apiService.put(
        '/business/orders/edit-order/$orderId',
        token: token,
        body: orderData,
      );
      
      print('DEBUG REPO: Update order response: $response');
      
      // Return the updated order
      if (response is Map<String, dynamic>) {
        return response;
      } else {
        print('DEBUG REPO: Response is not a map: $response');
        return {};
      }
    } catch (e) {
      print('DEBUG REPO: Exception in updateOrder: $e');
      throw Exception('Failed to update order: $e');
    }
  }

  // Calculate order delivery fees
  Future<Map<String, dynamic>> calculateFees(Map<String, dynamic> requestData) async {
    try {
      print('DEBUG REPO: Calculating fees with data: $requestData');
      
      // Get authentication token
      final token = await _authService.getToken();
      if (token == null) {
        print('DEBUG REPO: Auth token is null');
        throw Exception('Authentication token not found');
      }
      
      // Send calculate fees request to API
      final response = await _apiService.post(
        '/business/calculate-fees',
        token: token,
        body: requestData,
      );
      
      print('DEBUG REPO: Calculate fees response: $response');
      
      // Return the fee calculation
      if (response is Map<String, dynamic>) {
        return response;
      } else {
        print('DEBUG REPO: Response is not a map: $response');
        return {};
      }
    } catch (e) {
      print('DEBUG REPO: Exception in calculateFees: $e');
      throw Exception('Failed to calculate fees: $e');
    }
  }
}