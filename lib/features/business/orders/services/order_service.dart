import 'package:now_shipping/features/business/orders/models/order_model.dart';
import 'package:now_shipping/features/business/orders/repositories/order_repository.dart';

class OrderService {
  final OrderRepository _orderRepository;
  
  OrderService({required OrderRepository orderRepository}) : _orderRepository = orderRepository;

  // Get all orders
  Future<List<Map<String, dynamic>>> getAllOrders({String orderType = "All"}) async {
    try {
      print('DEBUG SERVICE: Fetching orders with type: $orderType');
      final response = await _orderRepository.getOrders(orderType: orderType);
      
      print('DEBUG SERVICE: Raw API response length: ${response.length}');
      if (response.isNotEmpty) {
        print('DEBUG SERVICE: First item sample: ${response.first}');
      }
      
      if (response.isEmpty) {
        print('DEBUG SERVICE: Response is empty list');
        return [];
      }
      
      // Convert response to list of maps
      final orders = response.map((order) {
        // Make sure order is a map
        if (order is! Map<String, dynamic>) {
          print('DEBUG SERVICE: Order is not a map: ${order.runtimeType}');
          return <String, dynamic>{};
        }
        
        // Extract needed information for the order list
        try {
          final apiStatus = order['orderStatus'] ?? order['status'] ?? '';
          final result = {
            'orderId': order['orderNumber'] ?? order['id'] ?? '',
            'customerName': _extractCustomerName(order),
            'location': _extractLocation(order),
            'amount': _extractAmount(order),
            'status': _mapOrderStatus(apiStatus),
            'apiStatus': apiStatus, // Keep original API status
            'statusCategory': order['statusCategory'], // Backend-provided category
            'deliveryType': order.containsKey('orderShipping') ? 
                          order['orderShipping']['orderType'] : 
                          order['deliveryType'] ?? 'Deliver',
            'attempts': order['Attemps'] ?? 0,
            'phoneNumber': _extractPhoneNumber(order),
            'rawOrder': order, // Keep the raw order for additional data if needed
          };
          print('DEBUG SERVICE: Successfully mapped order: ${result['orderId']} - Status: ${result['status']} - Category: ${result['statusCategory']}');
          return result;
        } catch (e) {
          print('DEBUG SERVICE: Error mapping order: $e');
          print('DEBUG SERVICE: Problematic order data: $order');
          return <String, dynamic>{};
        }
      }).where((order) => order.isNotEmpty).toList();
      
      print('DEBUG SERVICE: Processed orders count: ${orders.length}');
      
      return List<Map<String, dynamic>>.from(orders);
    } catch (e) {
      print('DEBUG SERVICE: Exception in getAllOrders: $e');
      throw Exception('Failed to fetch orders: $e');
    }
  }

  // Get order details
  Future<Map<String, dynamic>> getOrderDetails(String orderNumber) async {
    try {
      print('DEBUG SERVICE: Fetching order details for: $orderNumber');
      final response = await _orderRepository.getOrderDetails(orderNumber);
      
      print('DEBUG SERVICE: Order details raw response received');
      
      // Check if the API call was successful
      if (response.containsKey('status') && response['status'] == 'success' && response['order'] != null) {
        print('DEBUG SERVICE: Found order in response with status success');
        return response['order'];
      } else if (response.containsKey('orderNumber') || response.containsKey('id')) {
        // Direct order object
        print('DEBUG SERVICE: Found direct order object');
        return response;
      } else {
        print('DEBUG SERVICE: Invalid response format: $response');
        throw Exception('Failed to get order details: Invalid response format');
      }
    } catch (e) {
      print('DEBUG SERVICE: Exception in getOrderDetails: $e');
      throw Exception('Failed to fetch order details: $e');
    }
  }

  // Create new order
  Future<OrderModel> createOrder(Map<String, dynamic> orderData) async {
    try {
      print('DEBUG SERVICE: Creating order with data: $orderData');
      final response = await _orderRepository.createOrder(orderData);
      
      print('DEBUG SERVICE: Create order response received');
      
      // Check if the API call was successful
      if (response.containsKey('message') && response['message'] == 'Order created successfully.' && response['order'] != null) {
        print('DEBUG SERVICE: Order created successfully');
        // Convert API response to OrderModel
        return _mapToOrderModel(response['order']);
      } else if (response.containsKey('orderNumber') || response.containsKey('id')) {
        // Direct order object was returned
        print('DEBUG SERVICE: Direct order object returned');
        return _mapToOrderModel(response);
      } else {
        print('DEBUG SERVICE: Failed to create order: $response');
        throw Exception('Failed to create order: ${response['message'] ?? 'Unknown error'}');
      }
    } catch (e) {
      print('DEBUG SERVICE: Exception in createOrder: $e');
      throw Exception('Failed to create order: $e');
    }
  }
  
  // Update existing order
  Future<OrderModel> updateOrder(String orderId, Map<String, dynamic> orderData) async {
    try {
      print('DEBUG SERVICE: Updating order $orderId with data: $orderData');
      final response = await _orderRepository.updateOrder(orderId, orderData);
      
      print('DEBUG SERVICE: Update order response received');
      
      // Check if the API call was successful
      if (response.containsKey('message') && response['message'] == 'Order updated successfully.' && response['order'] != null) {
        print('DEBUG SERVICE: Order updated successfully');
        // Convert API response to OrderModel
        return _mapToOrderModel(response['order']);
      } else if (response.containsKey('orderNumber') || response.containsKey('id')) {
        // Direct order object was returned
        print('DEBUG SERVICE: Direct order object returned');
        return _mapToOrderModel(response);
      } else {
        print('DEBUG SERVICE: Failed to update order: $response');
        throw Exception('Failed to update order: ${response['message'] ?? 'Unknown error'}');
      }
    } catch (e) {
      print('DEBUG SERVICE: Exception in updateOrder: $e');
      throw Exception('Failed to update order: $e');
    }
  }
  
  // Calculate order fees
  Future<Map<String, dynamic>> calculateOrderFees(
    String government, 
    String orderType, 
    {bool isExpressShipping = false}
  ) async {
    try {
      print('DEBUG SERVICE: Calculating fees for $orderType in $government, express: $isExpressShipping');
      
      final Map<String, dynamic> requestData = {
        'government': government,
        'orderType': orderType,
        'isExpressShipping': isExpressShipping,
      };
      
      final response = await _orderRepository.calculateFees(requestData);
      print('DEBUG SERVICE: Fee calculation response: $response');
      
      return response;
    } catch (e) {
      print('DEBUG SERVICE: Exception in calculateOrderFees: $e');
      throw Exception('Failed to calculate order fees: $e');
    }
  }

  // Helper methods to extract data from different API response formats
  String _extractCustomerName(Map<String, dynamic> order) {
    if (order.containsKey('orderCustomer') && order['orderCustomer'] is Map) {
      return order['orderCustomer']['fullName'] ?? '';
    } else if (order.containsKey('customerName')) {
      return order['customerName'] ?? '';
    }
    return '';
  }
  
  String _extractLocation(Map<String, dynamic> order) {
    if (order.containsKey('orderCustomer') && order['orderCustomer'] is Map) {
      final government = order['orderCustomer']['government'] ?? '';
      final zone = order['orderCustomer']['zone'] ?? '';
      return '$government, $zone'.trim().replaceAll(RegExp(r', $'), '');
    } else if (order.containsKey('customerAddress')) {
      return order['customerAddress'] ?? '';
    }
    return '';
  }
  
  String _extractAmount(Map<String, dynamic> order) {
    if (order.containsKey('orderShipping') && order['orderShipping'] is Map) {
      if (order['orderShipping']['amountType'] == 'COD') {
        return '${order['orderShipping']['amount'] ?? 0}';
      } else {
        return '${order['orderFees'] ?? 0}';
      }
    } else if (order.containsKey('cashOnDeliveryAmount') && order['cashOnDelivery'] == true) {
      return '${order['cashOnDeliveryAmount'] ?? 0}';
    } else if (order.containsKey('amountToCollect')) {
      return '${order['amountToCollect'] ?? 0}';
    }
    return '0';
  }

  String _extractPhoneNumber(Map<String, dynamic> order) {
    String phoneNumber = '';
    if (order.containsKey('orderCustomer') && order['orderCustomer'] is Map) {
      phoneNumber = order['orderCustomer']['phoneNumber'] ?? '';
    } else if (order.containsKey('customerPhone')) {
      phoneNumber = order['customerPhone'] ?? '';
    }
    
    // Format phone number to use +2 instead of +20
    if (phoneNumber.startsWith('+20')) {
      phoneNumber = '+2${phoneNumber.substring(3)}';
    }
    
    return phoneNumber;
  }

  // Map API's order status to the app's status format
  String _mapOrderStatus(String apiStatus) {
    final Map<String, String> statusMap = {
      // NEW Category
      'new': 'New',
      'pendingpickup': 'Pending Pickup',
      
      // PROCESSING Category
      'pickedup': 'Picked Up',
      'instock': 'In Stock',
      'inreturnstock': 'In Return Stock',
      'inprogress': 'In Progress',
      'headingtocustomer': 'Heading to Customer',
      'returntowarehouse': 'Return to Warehouse',
      'headingtoyou': 'Heading to You',
      'rescheduled': 'Rescheduled',
      'returninitiated': 'Return Initiated',
      'returnassigned': 'Return Assigned',
      'returnpickedup': 'Return Picked Up',
      'returnatwarehouse': 'Return at Warehouse',
      'returntobusiness': 'Return to Business',
      'returnlinked': 'Return Linked',
      
      // PAUSED Category
      'waitingaction': 'Waiting Action',
      'rejected': 'Rejected',
      
      // SUCCESSFUL Category
      'completed': 'Completed',
      'returncompleted': 'Return Completed',
      
      // UNSUCCESSFUL Category
      'cancelled': 'Canceled',
      'canceled': 'Canceled',
      'returned': 'Returned',
      'terminated': 'Terminated',
      'deliveryfailed': 'Delivery Failed',
      'autoreturninitiated': 'Auto Return Initiated',
      
      // Legacy support
      'pending': 'New',
    };
    
    return statusMap[apiStatus.toLowerCase().replaceAll(' ', '')] ?? apiStatus;
  }

  // Map API order response to OrderModel
  OrderModel _mapToOrderModel(Map<String, dynamic> apiOrder) {
    String? cashAmount;
    try {
      if (apiOrder.containsKey('orderShipping') && 
          apiOrder['orderShipping'] is Map && 
          apiOrder['orderShipping']['amountType'] == 'COD') {
        cashAmount = apiOrder['orderShipping']['amount']?.toString();
      } else if (apiOrder.containsKey('cashOnDeliveryAmount')) {
        cashAmount = apiOrder['cashOnDeliveryAmount']?.toString();
      }
      
      return OrderModel(
        id: apiOrder['orderNumber'] ?? apiOrder['id'],
        customerName: _extractCustomerName(apiOrder),
        customerPhone: apiOrder.containsKey('orderCustomer') ? 
                      apiOrder['orderCustomer']['phoneNumber'] : 
                      apiOrder['customerPhone'],
        customerAddress: apiOrder.containsKey('orderCustomer') ? 
                        apiOrder['orderCustomer']['address'] : 
                        apiOrder['customerAddress'],
        deliveryType: apiOrder.containsKey('orderShipping') ? 
                     apiOrder['orderShipping']['orderType'] : 
                     apiOrder['deliveryType'] ?? 'Deliver',
        productDescription: apiOrder.containsKey('orderShipping') ? 
                           apiOrder['orderShipping']['productDescription'] : 
                           apiOrder['productDescription'],
        numberOfItems: apiOrder.containsKey('orderShipping') ? 
                      apiOrder['orderShipping']['numberOfItems'] : 
                      apiOrder['numberOfItems'] ?? 1,
        cashOnDelivery: apiOrder.containsKey('orderShipping') ? 
                       apiOrder['orderShipping']['amountType'] == 'COD' : 
                       apiOrder['cashOnDelivery'] ?? false,
        cashOnDeliveryAmount: cashAmount,
        allowPackageInspection: apiOrder['isOrderAvailableForPreview'] ?? 
                              apiOrder['allowPackageInspection'] ?? false,
        specialInstructions: apiOrder['orderNotes'] ?? apiOrder['specialInstructions'],
        referralNumber: apiOrder['referralNumber'],
        createdAt: apiOrder['orderDate'] != null ? 
                  DateTime.parse(apiOrder['orderDate']) : 
                  apiOrder['createdAt'] != null ? 
                  DateTime.parse(apiOrder['createdAt']) : 
                  DateTime.now(),
        status: _mapOrderStatus(apiOrder['orderStatus'] ?? apiOrder['status'] ?? 'New'),
      );
    } catch (e) {
      print('DEBUG SERVICE: Error mapping to OrderModel: $e');
      print('DEBUG SERVICE: API order data: $apiOrder');
      
      // Return a minimal valid order model to prevent crashes
      return OrderModel(
        id: apiOrder['orderNumber'] ?? apiOrder['id'] ?? 'unknown',
        customerName: 'Error loading data',
        status: 'Unknown',
        createdAt: DateTime.now(),
      );
    }
  }

  // Retry order tomorrow
  Future<Map<String, dynamic>> retryTomorrow(String orderId) async {
    try {
      return await _orderRepository.retryTomorrow(orderId);
    } catch (e) {
      print('DEBUG SERVICE: Error in retryTomorrow: $e');
      throw Exception('Failed to schedule retry tomorrow: $e');
    }
  }

  // Schedule retry for specific date
  Future<Map<String, dynamic>> retryScheduled(String orderId, DateTime date) async {
    try {
      return await _orderRepository.retryScheduled(orderId, date);
    } catch (e) {
      print('DEBUG SERVICE: Error in retryScheduled: $e');
      throw Exception('Failed to schedule retry: $e');
    }
  }

  // Return order to warehouse
  Future<Map<String, dynamic>> returnToWarehouse(String orderId) async {
    try {
      return await _orderRepository.returnToWarehouse(orderId);
    } catch (e) {
      print('DEBUG SERVICE: Error in returnToWarehouse: $e');
      throw Exception('Failed to return order to warehouse: $e');
    }
  }

  // Cancel order
  Future<Map<String, dynamic>> cancelOrder(String orderId) async {
    try {
      return await _orderRepository.cancelOrder(orderId);
    } catch (e) {
      print('DEBUG SERVICE: Error in cancelOrder: $e');
      throw Exception('Failed to cancel order: $e');
    }
  }

  // Validate original order for return
  Future<Map<String, dynamic>> validateOriginalOrder(String orderNumber) async {
    try {
      return await _orderRepository.validateOriginalOrder(orderNumber);
    } catch (e) {
      print('DEBUG SERVICE: Error in validateOriginalOrder: $e');
      throw Exception('Failed to validate original order: $e');
    }
  }
}