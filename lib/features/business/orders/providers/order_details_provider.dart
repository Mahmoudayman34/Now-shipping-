import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:now_shipping/core/l10n/app_localizations.dart';
import 'package:now_shipping/features/business/orders/providers/orders_provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/legacy.dart';

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
  
  // Additional API fields
  final String? completedDate;
  final String? statusLabel;
  final String? statusDescription;
  final double orderFees;
  final int? progressPercentage;
  final String? deliveryManName;
  final String? deliveryManEmail;
  final String? businessName;
  final String? businessEmail;
  
  // Exchange specific fields
  final int? currentItems;
  final String? currentProductDescription;
  final int? newItems;
  final String? newProductDescription;
  
  // Return specific fields
  final int? returnItems;
  final String? returnReason;
  final String? returnProductDescription;
  final String? originalOrderNumber;
  final bool? isPartialReturn;
  final int? partialReturnItemCount;
  final String? returnNotes;
  
  // Rescheduled field
  final String? scheduledRetryAt;

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
    this.completedDate,
    this.statusLabel,
    this.statusDescription,
    this.orderFees = 0.0,
    this.progressPercentage,
    this.deliveryManName,
    this.deliveryManEmail,
    this.businessName,
    this.businessEmail,
    this.currentItems,
    this.currentProductDescription,
    this.newItems,
    this.newProductDescription,
    this.returnItems,
    this.returnReason,
    this.returnProductDescription,
    this.originalOrderNumber,
    this.isPartialReturn,
    this.partialReturnItemCount,
    this.returnNotes,
    this.scheduledRetryAt,
  });

  // Create a model from API response
  factory OrderDetailsModel.fromApiResponse(Map<String, dynamic> apiOrder) {
    final orderCustomer = apiOrder['orderCustomer'] ?? {};
    final orderShipping = apiOrder['orderShipping'] ?? {};
    final deliveryMan = apiOrder['deliveryMan'] as Map<String, dynamic>?;
    final business = apiOrder['business'] as Map<String, dynamic>?;
    
    // Determine if this is a return order
    final isReturnOrder = orderShipping['orderType'] == 'Return';
    
    // Format phone number to remove +20 prefix
    String phoneNumber = orderCustomer['phoneNumber'] ?? '';
    if (phoneNumber.startsWith('+20')) {
      phoneNumber = phoneNumber.substring(3);
    }
    
    // Format dates
    String formattedCreatedAt = '';
    if (apiOrder['orderDate'] != null) {
      try {
        final dateTime = DateTime.parse(apiOrder['orderDate']);
        formattedCreatedAt = DateFormat('dd MMM yyyy - HH:mm').format(dateTime);
      } catch (e) {
        formattedCreatedAt = apiOrder['orderDate'] ?? '';
      }
    }
    
    String? formattedCompletedDate;
    if (apiOrder['completedDate'] != null) {
      try {
        final dateTime = DateTime.parse(apiOrder['completedDate']);
        formattedCompletedDate = DateFormat('dd MMM yyyy - HH:mm').format(dateTime);
      } catch (e) {
        formattedCompletedDate = apiOrder['completedDate'];
      }
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
      createdAt: formattedCreatedAt,
      isExpressShipping: orderShipping['isExpressShipping'] ?? apiOrder['isFastShipping'] ?? false,
      // Additional API fields
      completedDate: formattedCompletedDate,
      statusLabel: apiOrder['statusLabel'],
      statusDescription: apiOrder['statusDescription'],
      orderFees: (apiOrder['orderFees'] ?? 0).toDouble(),
      progressPercentage: apiOrder['progressPercentage'],
      deliveryManName: deliveryMan?['name'],
      deliveryManEmail: deliveryMan?['email'],
      businessName: business?['name'],
      businessEmail: business?['email'],
      // Exchange fields
      currentItems: orderShipping['numberOfItems'],
      currentProductDescription: orderShipping['productDescription'],
      newItems: orderShipping['numberOfItemsReplacement'],
      newProductDescription: orderShipping['productDescriptionReplacement'],
      // Return fields - for Return orders, use numberOfItems as returnItems
      returnItems: isReturnOrder ? orderShipping['numberOfItems'] : null,
      returnReason: isReturnOrder ? orderShipping['returnReason'] : null,
      returnProductDescription: isReturnOrder ? orderShipping['productDescription'] : null,
      originalOrderNumber: isReturnOrder ? orderShipping['originalOrderNumber'] : null,
      isPartialReturn: isReturnOrder ? (orderShipping['isPartialReturn'] ?? false) : null,
      partialReturnItemCount: isReturnOrder ? orderShipping['partialReturnItemCount'] : null,
      returnNotes: isReturnOrder ? orderShipping['returnNotes'] : null,
      // Rescheduled field
      scheduledRetryAt: apiOrder['scheduledRetryAt'],
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
      
      // Debug log for scheduledRetryAt
      print('DEBUG ORDER DETAILS: scheduledRetryAt = ${orderData['scheduledRetryAt']}');
      
      // Debug logs for return orders
      final orderShipping = orderData['orderShipping'] ?? {};
      if (orderShipping['orderType'] == 'Return') {
        print('DEBUG ORDER DETAILS: Return order detected');
        print('DEBUG ORDER DETAILS: numberOfItems = ${orderShipping['numberOfItems']}');
        print('DEBUG ORDER DETAILS: productDescription = ${orderShipping['productDescription']}');
      }
      
      // Convert API response to OrderDetailsModel
      state = OrderDetailsModel.fromApiResponse(orderData);
      
      // Debug log for scheduledRetryAt after mapping
      print('DEBUG ORDER DETAILS: After mapping, scheduledRetryAt = ${state?.scheduledRetryAt}');
      
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
  Future<void> updateWithStickerInfo(String stickerId) async {
    try {
      if (state == null) {
        print('DEBUG PROVIDER: No order state available for sticker update');
        return;
      }
      
      print('DEBUG PROVIDER: Updating order ${state!.orderId} with sticker: $stickerId');
      
      // Get order service to make the API call
      final orderService = _ref.read(orderServiceProvider);
      
      // Call the scan smart sticker API
      final response = await orderService.scanSmartSticker(state!.orderId, stickerId);
      
      print('DEBUG PROVIDER: Smart sticker scan response: $response');
      
      // Handle the response - refresh order details after successful scan
      if (response.containsKey('status') && response['status'] == 'success') {
        print('DEBUG PROVIDER: Smart sticker scanned successfully');
        // Refresh order details to get updated data including smartFlyerBarcode
        await fetchOrderDetails(state!.orderId, state!.status);
      } else {
        print('DEBUG PROVIDER: Smart sticker scan failed: $response');
      }
    } catch (e) {
      print('DEBUG PROVIDER: Error updating with sticker info: $e');
      // Re-throw to let the UI handle the error
      rethrow;
    }
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
/// Dynamic tracking steps provider that uses actual API data from orderStages and stageTimeline
final trackingStepsProvider = Provider.family<List<Map<String, dynamic>>, String>((ref, orderId) {
  // Get the raw order data
  final rawOrderData = ref.watch(rawOrderDataProvider(orderId));
  
  // If no data yet, return empty list
  if (rawOrderData.isEmpty) {
    return [];
  }
  
  // Get the stageTimeline from API response (this is already filtered to show only relevant stages)
  final stageTimeline = rawOrderData['stageTimeline'] as List<dynamic>? ?? [];
  final orderStages = rawOrderData['orderStages'] as Map<String, dynamic>? ?? {};
  final orderType = rawOrderData['orderShipping']?['orderType'] ?? 'Deliver';
  
  print('DEBUG TRACKING: Order type: $orderType');
  print('DEBUG TRACKING: Stage timeline length: ${stageTimeline.length}');
  print('DEBUG TRACKING: Order stages keys: ${orderStages.keys.toList()}');
  
  // Build tracking steps from ONLY completed stages in the timeline
  final List<Map<String, dynamic>> trackingSteps = [];
  
  for (int i = 0; i < stageTimeline.length; i++) {
    final stage = stageTimeline[i] as Map<String, dynamic>;
    final stageName = stage['stage'] as String;
    final isCompleted = stage['isCompleted'] as bool? ?? false;
    
    // ONLY add stages that are completed
    if (!isCompleted) {
      continue;
    }
    
    final completedAt = stage['completedAt'] as String?;
    final notes = stage['notes'] as String? ?? '';
    
    // Format the completed time
    String formattedTime = '';
    if (completedAt != null && completedAt.isNotEmpty) {
      try {
        final dateTime = DateTime.parse(completedAt);
        formattedTime = DateFormat('dd MMM yyyy - HH:mm').format(dateTime);
      } catch (e) {
        formattedTime = '';
      }
    }
    
    // Map stage names to display names
    final displayName = _getStageDisplayName(stageName);
    final description = notes.isNotEmpty ? notes : _getStageDefaultDescription(stageName);
    
    trackingSteps.add({
      'title': displayName,
      'status': stageName,
      'description': description,
      'time': formattedTime,
      'isCompleted': true,
      'isFirst': false,
      'isLast': false,
    });
  }
  
  // If we have a return order, check if we need to add return stages from orderStages
  if (orderType == 'Return') {
    // Check for return stages that are completed but not in timeline
    final returnStageKeys = [
      'returnInitiated',
      'returnAssigned',
      'returnPickedUp',
      'returnAtWarehouse',
      'returnInspection',
      'returnProcessing',
      'returnToBusiness',
      'returnCompleted',
    ];
    
    for (final stageKey in returnStageKeys) {
      final stageData = orderStages[stageKey] as Map<String, dynamic>?;
      if (stageData != null && stageData['isCompleted'] == true) {
        // Check if already in timeline
        final alreadyInTimeline = trackingSteps.any((step) => step['status'] == stageKey);
        if (!alreadyInTimeline) {
          final completedAt = stageData['completedAt'] as String?;
          String formattedTime = '';
          if (completedAt != null && completedAt.isNotEmpty) {
            try {
              final dateTime = DateTime.parse(completedAt);
              formattedTime = DateFormat('dd MMM yyyy - HH:mm').format(dateTime);
            } catch (e) {
              formattedTime = '';
            }
          }
          
          trackingSteps.add({
            'title': _getStageDisplayName(stageKey),
            'status': stageKey,
            'description': stageData['notes'] ?? _getStageDefaultDescription(stageKey),
            'time': formattedTime,
            'isCompleted': true,
            'isFirst': false,
            'isLast': false,
          });
        }
      }
    }
  }
  
  // Mark first and last items
  if (trackingSteps.isNotEmpty) {
    trackingSteps.first['isFirst'] = true;
    trackingSteps.last['isLast'] = true;
  }
  
  print('DEBUG TRACKING: Generated ${trackingSteps.length} completed tracking steps');
  for (final step in trackingSteps) {
    print('  - ${step['title']}: ${step['time']}');
  }
  
  return trackingSteps;
});

/// Get display name for stage
String _getStageDisplayName(String stageName) {
  const Map<String, String> stageDisplayNames = {
    'orderPlaced': 'Order Placed',
    'packed': 'Packed',
    'shipping': 'Shipping',
    'inProgress': 'In Progress',
    'outForDelivery': 'Out for Delivery',
    'delivered': 'Delivered',
    'returnInitiated': 'Return Initiated',
    'returnAssigned': 'Return Assigned',
    'returnPickedUp': 'Return Picked Up',
    'returnAtWarehouse': 'Return at Warehouse',
    'returnInspection': 'Return Inspection',
    'returnProcessing': 'Return Processing',
    'returnToBusiness': 'Return to Business',
    'returnCompleted': 'Return Completed',
    'returned': 'Returned',
  };
  
  return stageDisplayNames[stageName] ?? stageName;
}

/// Get default description for stage
String _getStageDefaultDescription(String stageName) {
  const Map<String, String> stageDefaultDescriptions = {
    'orderPlaced': 'Order has been created successfully',
    'packed': 'Order is being packed',
    'shipping': 'Order is being shipped',
    'inProgress': 'Order is in progress',
    'outForDelivery': 'Order is out for delivery',
    'delivered': 'Order delivered successfully 🎉',
    'returnInitiated': 'Return has been initiated',
    'returnAssigned': 'Return assigned to courier',
    'returnPickedUp': 'Return picked up from customer',
    'returnAtWarehouse': 'Return arrived at warehouse',
    'returnInspection': 'Return is being inspected',
    'returnProcessing': 'Return is being processed',
    'returnToBusiness': 'Return is being delivered to business',
    'returnCompleted': 'Return completed successfully 🎉',
    'returned': 'Item returned',
  };
  
  return stageDefaultDescriptions[stageName] ?? '';
}

/// Get localized display name for stage
String _getLocalizedStageDisplayName(String stageName, BuildContext context) {
  final l10n = AppLocalizations.of(context);
  
  switch (stageName) {
    case 'orderPlaced':
      return l10n.orderPlaced;
    case 'packed':
      return l10n.packed;
    case 'shipping':
      return l10n.shipping;
    case 'inProgress':
      return l10n.inProgress;
    case 'outForDelivery':
      return l10n.outForDelivery;
    case 'delivered':
      return l10n.delivered;
    case 'returnInitiated':
      return l10n.returnInitiated;
    case 'returnAssigned':
      return l10n.returnAssigned;
    case 'returnPickedUp':
      return l10n.returnPickedUp;
    case 'returnAtWarehouse':
      return l10n.returnAtWarehouse;
    case 'returnInspection':
      return l10n.returnInspection;
    case 'returnProcessing':
      return l10n.returnProcessing;
    case 'returnToBusiness':
      return l10n.returnToBusiness;
    case 'returnCompleted':
      return l10n.returnCompleted;
    case 'returned':
      return l10n.returnedStatus;
    default:
      return stageName;
  }
}

/// Get localized default description for stage
String _getLocalizedStageDefaultDescription(String stageName, BuildContext context) {
  final l10n = AppLocalizations.of(context);
  
  switch (stageName) {
    case 'orderPlaced':
      return l10n.orderHasBeenCreated;
    case 'packed':
      return l10n.fastShippingMarkedCompleted;
    case 'shipping':
      return l10n.fastShippingMarkedCompleted;
    case 'inProgress':
      return l10n.fastShippingAssignedToCourier;
    case 'outForDelivery':
      return l10n.fastShippingReadyForDelivery;
    case 'delivered':
      return l10n.orderCompletedByCourier;
    case 'returnInitiated':
      return l10n.returnInitiated;
    case 'returnAssigned':
      return l10n.returnAssigned;
    case 'returnPickedUp':
      return l10n.returnPickedUp;
    case 'returnAtWarehouse':
      return l10n.returnAtWarehouse;
    case 'returnInspection':
      return l10n.returnInspection;
    case 'returnProcessing':
      return l10n.returnProcessing;
    case 'returnToBusiness':
      return l10n.returnToBusiness;
    case 'returnCompleted':
      return l10n.returnCompleted;
    case 'returned':
      return l10n.returnedStatus;
    default:
      return '';
  }
}
