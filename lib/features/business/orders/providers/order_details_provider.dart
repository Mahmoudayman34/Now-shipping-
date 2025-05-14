import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:now_shipping/features/business/orders/providers/orders_provider.dart';
import 'package:intl/intl.dart';

/// Model class to represent order details needed for display
class OrderDetailsModel {
  final String orderId;
  final String customerName;
  final String customerPhone;
  final String customerAddress;
  final String deliveryType; // 'Deliver', 'Exchange', 'Return'
  final String packageType;
  final int numberOfItems;
  final String packageDescription;
  final double collectCashAmount;
  final bool allowOpeningPackage;
  final String deliveryNotes;
  final String orderReference;
  final String status;
  final String createdAt;
  final bool isExpressShipping;
  
  // Exchange specific fields
  final int? currentItems;
  final String? currentProductDescription;
  final int? newItems;
  final String? newProductDescription;
  
  // Return specific fields
  final int? returnItems;
  final String? returnReason;
  final String? returnProductDescription;

  OrderDetailsModel({
    required this.orderId,
    required this.customerName,
    required this.customerPhone,
    required this.customerAddress,
    required this.deliveryType,
    required this.packageType,
    required this.numberOfItems,
    required this.packageDescription,
    required this.collectCashAmount,
    required this.allowOpeningPackage,
    required this.deliveryNotes,
    required this.orderReference,
    required this.status,
    required this.createdAt,
    this.isExpressShipping = false,
    this.currentItems,
    this.currentProductDescription,
    this.newItems,
    this.newProductDescription,
    this.returnItems,
    this.returnReason,
    this.returnProductDescription,
  });

  // Create a model from API response
  factory OrderDetailsModel.fromApiResponse(Map<String, dynamic> apiOrder) {
    final orderCustomer = apiOrder['orderCustomer'] ?? {};
    final orderShipping = apiOrder['orderShipping'] ?? {};
    
    // Determine if this is a return order
    final isReturnOrder = orderShipping['orderType'] == 'Return';
    
    // Format phone number to use +2 instead of +20
    String phoneNumber = orderCustomer['phoneNumber'] ?? '';
    if (phoneNumber.startsWith('+20')) {
      phoneNumber = '+2${phoneNumber.substring(3)}';
    }
    
    return OrderDetailsModel(
      orderId: apiOrder['orderNumber'] ?? '',
      customerName: orderCustomer['fullName'] ?? '',
      customerPhone: phoneNumber,
      customerAddress: '${orderCustomer['government'] ?? ''}, ${orderCustomer['zone'] ?? ''}, ${orderCustomer['address'] ?? ''}',
      deliveryType: orderShipping['orderType'] ?? 'Deliver',
      packageType: 'Parcel', // Default value as not provided in API
      numberOfItems: orderShipping['numberOfItems'] ?? 1,
      packageDescription: orderShipping['productDescription'] ?? '',
      collectCashAmount: orderShipping['amountType'] == 'COD' ? (orderShipping['amount'] ?? 0).toDouble() : 0.0,
      allowOpeningPackage: apiOrder['isOrderAvailableForPreview'] ?? false,
      deliveryNotes: apiOrder['orderNotes'] ?? '',
      orderReference: apiOrder['referralNumber'] ?? '',
      status: apiOrder['orderStatus'] ?? '',
      createdAt: apiOrder['orderDate'] ?? '',
      isExpressShipping: orderShipping['isExpressShipping'] ?? false,
      // Exchange fields
      currentItems: orderShipping['numberOfItems'],
      currentProductDescription: orderShipping['productDescription'],
      newItems: orderShipping['numberOfItemsReplacement'],
      newProductDescription: orderShipping['productDescriptionReplacement'],
      // Return fields - for Return orders, use numberOfItems as returnItems
      returnItems: isReturnOrder ? orderShipping['numberOfItems'] : null,
      returnReason: isReturnOrder ? (orderShipping['returnReason'] ?? 'N/A') : null,
      returnProductDescription: isReturnOrder ? orderShipping['productDescription'] : null,
    );
  }

  // Create a mock order for testing or when real data is not available
  factory OrderDetailsModel.mock({required String orderId, required String status}) {
    return OrderDetailsModel(
      orderId: orderId,
      customerName: 'Mohamed Ahmed',
      customerPhone: '+21234567890',
      customerAddress: 'Cairo, Abdeen, Building 15, Floor 3, Apt 301',
      deliveryType: 'Deliver',
      packageType: 'Parcel',
      numberOfItems: 2,
      packageDescription: 'Smartphone with protective case',
      collectCashAmount: 850.0,
      allowOpeningPackage: true,
      deliveryNotes: 'Please call before delivery',
      orderReference: 'REF123456',
      status: status,
      createdAt: '22 Apr 2025',
      isExpressShipping: false,
    );
  }
}

/// Provider to store the raw order data (including orderStages)
final rawOrderDataProvider = StateProvider.family<Map<String, dynamic>, String>((ref, orderId) => {});

/// Order details notifier that manages fetching and updating order details
class OrderDetailsNotifier extends StateNotifier<OrderDetailsModel?> {
  final Ref _ref;

  OrderDetailsNotifier(this._ref) : super(null);

  // Fetch order details from API
  Future<void> fetchOrderDetails(String orderId, String status) async {
    try {
      // Set loading state
      state = null;
      
      // Get order details from API
      final orderService = _ref.read(orderServiceProvider);
      final orderData = await orderService.getOrderDetails(orderId);
      
      // Store the raw order data in the provider for other providers to use
      _ref.read(rawOrderDataProvider(orderId).notifier).state = orderData;
      
      // Debug logs for return orders
      final orderShipping = orderData['orderShipping'] ?? {};
      if (orderShipping['orderType'] == 'Return') {
        print('DEBUG ORDER DETAILS: Return order detected');
        print('DEBUG ORDER DETAILS: numberOfItems = ${orderShipping['numberOfItems']}');
        print('DEBUG ORDER DETAILS: productDescription = ${orderShipping['productDescription']}');
      }
      
      // Convert API response to OrderDetailsModel
      state = OrderDetailsModel.fromApiResponse(orderData);
      
      // Additional debug for Return orders after mapping
      if (state?.deliveryType == 'Return') {
        print('DEBUG ORDER DETAILS: Mapped returnItems = ${state?.returnItems}');
      }
    } catch (e) {
      // If API fails, use mock data as fallback
      print('Error fetching order details: $e');
      state = OrderDetailsModel.mock(orderId: orderId, status: status);
    }
  }

  // Update order details after scanning a smart sticker
  void updateWithStickerInfo(String stickerId) {
    // In a real app, you would update the order with the sticker information
    // This would involve an API call
    print('Order updated with sticker: $stickerId');
  }
}

/// Provider for the order details state notifier
final orderDetailsProvider = StateNotifierProvider.family<OrderDetailsNotifier, OrderDetailsModel?, String>(
  (ref, orderId) => OrderDetailsNotifier(ref),
);

/// Provider to get tracking steps from the orderStages data in the API response
final orderStagesTrackingProvider = Provider.family<List<Map<String, dynamic>>, String>((ref, orderId) {
  final rawOrderData = ref.watch(rawOrderDataProvider(orderId));
  
  // If there's no raw order data yet, return an empty list
  if (rawOrderData.isEmpty) {
    return [];
  }
  
  final String currentStatus = (rawOrderData['orderStatus'] as String? ?? '').toLowerCase();
  
  // Get the orderStages array from the raw order data
  final orderStages = rawOrderData['orderStages'] as List<dynamic>? ?? [];
  
  // Define all possible tracking stages
  final List<Map<String, dynamic>> allTrackingSteps = [
    {
      'title': 'New',
      'status': 'New',
      'description': 'You successfully created the order.',
      'time': '',
      'isCompleted': false,
      'isFirst': true,
      'apiStageName': 'Order Created'
    },
    {
      'title': 'Picked up',
      'status': 'Picked Up',
      'description': 'We got your order! It should be at our warehouses by the end of day.',
      'time': '',
      'isCompleted': false,
      'apiStageName': 'pickedUp'
    },
    {
      'title': 'In Stock',
      'status': 'In Stock',
      'description': 'Your order is now in our warehouse.',
      'time': '',
      'isCompleted': false,
      'apiStageName': 'inStock'
    },
    {
      'title': 'Heading to customer',
      'status': 'Heading to customer',
      'description': 'We shipped the order for delivery to your customer.',
      'time': '',
      'isCompleted': false,
      'apiStageName': 'headingToCustomer'
    },
    {
      'title': 'Successful',
      'status': 'Successful',
      'description': 'Order delivered successfully to your customer 🎉',
      'time': '',
      'isCompleted': false,
      'isLast': true,
      'apiStageName': 'completed'
    },
  ];
  
  // Also set completion based on current status (even if no stage info exists)
  for (int i = 0; i < allTrackingSteps.length; i++) {
    final stageName = allTrackingSteps[i]['apiStageName'].toString().toLowerCase();
    
    // Set stages as completed based on current status
         if (stageName == 'order created' && 
         (currentStatus == 'new' || currentStatus == 'pickedup' || 
          currentStatus == 'instock' || 
          currentStatus == 'headingtocustomer' || currentStatus == 'completed')) {
      allTrackingSteps[i]['isCompleted'] = true;
         } else if (stageName == 'pickedup' && 
                (currentStatus == 'pickedup' || currentStatus == 'instock' || 
                 currentStatus == 'headingtocustomer' || 
                 currentStatus == 'completed')) {
      allTrackingSteps[i]['isCompleted'] = true;
         } else if (stageName == 'instock' && 
                (currentStatus == 'instock' || 
                 currentStatus == 'headingtocustomer' || currentStatus == 'completed')) {
       allTrackingSteps[i]['isCompleted'] = true;
     } else if (stageName == 'headingtocustomer' &&  
               (currentStatus == 'headingtocustomer' || currentStatus == 'completed')) {
      allTrackingSteps[i]['isCompleted'] = true;
    } else if (stageName == 'completed' && currentStatus == 'completed') {
      allTrackingSteps[i]['isCompleted'] = true;
    }
  }
  
  // If no stages found in API, return the list with completion based on current status
  if (orderStages.isEmpty) {
    return allTrackingSteps;
  }
  
  // Create a map from stage name to its data
  Map<String, Map<String, dynamic>> stagesMap = {};
  for (var stage in orderStages) {
    final String stageName = stage['stageName'] as String? ?? '';
    stagesMap[stageName] = stage;
  }
  
  // Update the tracking steps with real data from orderStages
  for (int i = 0; i < allTrackingSteps.length; i++) {
    final String apiStageName = allTrackingSteps[i]['apiStageName'] as String;
    
    if (stagesMap.containsKey(apiStageName)) {
      final apiStage = stagesMap[apiStageName]!;
      final stageDate = apiStage['stageDate'] != null ? DateTime.parse(apiStage['stageDate']) : null;
      
      // Get stage notes for additional context
      final stageNotes = apiStage['stageNotes'] as List<dynamic>? ?? [];
      String noteText = '';
      if (stageNotes.isNotEmpty && stageNotes.first is Map) {
        noteText = (stageNotes.first as Map)['text'] ?? '';
      }
      
      // Format the time for display
      String formattedTime = '';
      if (stageDate != null) {
        final dateFormat = DateFormat('dd MMM yyyy - HH:mm');
        formattedTime = dateFormat.format(stageDate);
      }
      
      // Update the tracking step with real data
      allTrackingSteps[i]['time'] = formattedTime;
      allTrackingSteps[i]['isCompleted'] = true;
      
      // Update description if there's a note
      if (noteText.isNotEmpty) {
        allTrackingSteps[i]['description'] = noteText;
      }
    }
  }
  
  return allTrackingSteps;
});

/// Provider to get tracking steps based on the current order status
final trackingStepsProvider = Provider.family<List<Map<String, dynamic>>, String>((ref, status) {
  // Define tracking steps with their corresponding statuses
  final List<Map<String, dynamic>> trackingSteps = [
    {
      'title': 'New',
      'status': 'New',
      'description': 'You successfully created the order.',
      'time': '24 Feb 2025 - 21:07 PM',
      'isCompleted': status == 'New' || status == 'Picked Up' || 
                     status == 'In Stock' || status == 'In Progress' || 
                     status == 'Heading To Customer' || status == 'Completed',
      'isFirst': true,
    },
    {
      'title': 'Picked up',
      'status': 'Picked Up',
      'description': 'We got your order! It should be at our warehouses by the end of day.',
      'time': '',
      'isCompleted': status == 'Picked Up' || status == 'In Stock' || 
                     status == 'In Progress' || status == 'Heading To Customer' || 
                     status == 'Completed',
    },
    {
      'title': 'In Progress',
      'status': 'In Progress',
      'description': 'We\'re preparing your order and we\'ll start shipping it soon.',
      'time': '',
      'isCompleted': status == 'In Progress' || status == 'Heading To Customer' || 
                     status == 'Completed',
    },
    {
      'title': 'Heading to customer',
      'status': 'Heading to customer',
      'description': 'We shipped the order for delivery to your customer.',
      'time': '',
      'isCompleted': status == 'Heading To Customer' || status == 'Completed',
    },
    {
      'title': 'Successful',
      'status': 'Successful',
      'description': 'Order delivered successfully to your customer 🎉',
      'time': '',
      'isCompleted': status == 'Completed',
      'isLast': true,
    },
  ];
  
  return trackingSteps;
});