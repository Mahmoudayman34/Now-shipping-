import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:now_shipping/features/business/orders/models/order_model.dart';
import 'package:now_shipping/features/business/orders/providers/orders_provider.dart';
import 'package:flutter_riverpod/legacy.dart';
// Provider for customer data
final customerDataProvider = StateProvider<Map<String, dynamic>?>((ref) => null);

// Provider for the order being created or edited
final orderModelProvider = StateNotifierProvider<OrderNotifier, OrderModel>((ref) {
  return OrderNotifier();
});

// Order submission provider
final orderSubmissionProvider = FutureProvider.autoDispose<OrderModel>((ref) async {
  throw UnimplementedError('Call this provider with parameter to create order');
});

// Order submission provider with parameter
final orderSubmissionWithParamProvider = FutureProvider.autoDispose.family<OrderModel, Map<String, dynamic>>((ref, orderData) async {
  final orderService = ref.watch(orderServiceProvider);
  return await orderService.createOrder(orderData);
});

// Order state notifier
class OrderNotifier extends StateNotifier<OrderModel> {
  OrderNotifier() : super(OrderModel());
  
  // Convert current state to API request format
  Map<String, dynamic> toApiRequest(WidgetRef ref) {
    print('DEBUG EXPRESS: Original expressShipping value from state: ${state.expressShipping}');
    
    // Get customer data from provider for additional fields
    final customerData = ref.read(customerDataProvider);
    
    // Extract government and zone from customer data if available
    String government = 'Cairo';
    String zone = '';
    String address = state.customerAddress ?? '';
    
    if (customerData != null) {
      // Use city from customer data as government
      if (customerData['city'] != null && customerData['city'].toString().isNotEmpty) {
        government = customerData['city'] as String;
      }
      
      // Use zone from customer data
      if (customerData['zone'] != null && customerData['zone'].toString().isNotEmpty) {
        zone = customerData['zone'] as String;
      }
      
      // Build address from customer data fields
      final List<String> addressParts = [];
      if (customerData['addressDetails'] != null && customerData['addressDetails'].toString().isNotEmpty) {
        addressParts.add(customerData['addressDetails'] as String);
      }
      if (customerData['building'] != null && customerData['building'].toString().isNotEmpty) {
        addressParts.add('Building ${customerData['building']}');
      }
      if (customerData['floor'] != null && customerData['floor'].toString().isNotEmpty) {
        addressParts.add('Floor ${customerData['floor']}');
      }
      if (customerData['apartment'] != null && customerData['apartment'].toString().isNotEmpty) {
        addressParts.add('Apartment ${customerData['apartment']}');
      }
      if (addressParts.isNotEmpty) {
        address = addressParts.join(', ');
      }
    } else {
      // Fallback to parsing from customerAddress if customerData is not available
      if (state.customerAddress != null && state.customerAddress!.contains(',')) {
        final parts = state.customerAddress!.split(',');
        if (parts.length >= 2) {
          government = parts.first.trim();
          zone = parts.last.trim();
        }
      }
    }
    
    final Map<String, dynamic> request = {
      'fullName': state.customerName ?? '',
      'phoneNumber': state.customerPhone ?? '',
      'address': address,
      'government': government,
      'zone': zone,
      'orderType': state.deliveryType ?? 'Deliver',
      'previewPermission': state.allowPackageInspection == true ? 'on' : 'off',
      'Notes': state.specialInstructions ?? '',
      'isExpressShipping': state.expressShipping ?? false,
    };
    
    // Add otherPhoneNumber if available from customer data
    if (customerData != null && customerData['secondaryPhone'] != null && customerData['secondaryPhone'].toString().isNotEmpty) {
      request['otherPhoneNumber'] = customerData['secondaryPhone'] as String;
    }
    
    // Add deliverToWorkAddress if available from customer data
    if (customerData != null && customerData['isWorkingAddress'] == true) {
      request['deliverToWorkAddress'] = true;
    }

    print('DEBUG EXPRESS: isExpressShipping in initial request: ${request['isExpressShipping']}');

    // Add fields based on order type
    final orderType = state.deliveryType ?? 'Deliver';
    
    if (orderType == 'Deliver') {
      request['productDescription'] = state.productDescription ?? '';
      request['numberOfItems'] = state.numberOfItems ?? 1;
      if (state.cashOnDelivery == true) {
        request['COD'] = true;
        request['amountCOD'] = int.tryParse(state.cashOnDeliveryAmount ?? '0') ?? 0;
      }
    } 
    else if (orderType == 'Exchange') {
      request['currentPD'] = state.productDescription ?? '';
      request['numberOfItemsCurrentPD'] = state.numberOfItems ?? 1;
      request['newPD'] = state.newProductDescription ?? '';
      request['numberOfItemsNewPD'] = state.numberOfNewItems ?? 1;
      if (state.hasCashDifference == true) {
        request['CashDifference'] = true;
        request['amountCashDifference'] = int.tryParse(state.cashDifferenceAmount ?? '0') ?? 0;
      }
    }
    else if (orderType == 'Cash Collection' || orderType == 'Cash Collect') {
      // Use 'Cash Collection' as the order type name (matches the API specification)
      request['orderType'] = 'Cash Collection';
      // Ensure amount is correctly parsed as an integer
      final amount = int.tryParse(state.amountToCollect ?? '0') ?? 0;
      request['amountCashCollection'] = amount;
    }
    else if (orderType == 'Return') {
      // Format Return order according to API specification
      request['productDescription'] = state.productDescription ?? '';
      request['originalOrderNumber'] = state.originalOrderNumber ?? '';
      request['returnReason'] = state.returnReason ?? '';
      
      // Add return notes if available
      if (state.specialInstructions != null && state.specialInstructions!.isNotEmpty) {
        request['returnNotes'] = state.specialInstructions;
      }
      
      // Determine if it's a partial return
      final isPartialReturn = state.returnType == 'partial';
      
      if (isPartialReturn) {
        // Partial Return fields
        request['isPartialReturn'] = true;
        request['partialReturnItemCount'] = state.numberOfItemsToReturn ?? 1;
        
        // Get original order item count from original order data
        if (state.originalOrderData != null) {
          final orderShipping = state.originalOrderData!['orderShipping'] as Map<String, dynamic>?;
          final originalItemCount = orderShipping?['numberOfItems'] as int? ?? 0;
          if (originalItemCount > 0) {
            request['originalOrderItemCount'] = originalItemCount;
          }
        }
      } else {
        // Full Return fields
        request['numberOfItems'] = state.numberOfItems ?? 1;
      }
      
      // Log the Return order request for debugging
      print('DEBUG PROVIDER: Final Return order request: $request');
    }

    // Add referral number if available
    if (state.referralNumber != null && state.referralNumber!.isNotEmpty) {
      request['referralNumber'] = state.referralNumber;
    }

    // Save isExpressShipping value before cleaning up
    final bool isExpressShippingValue = request['isExpressShipping'] ?? false;
    print('DEBUG EXPRESS: isExpressShipping value before cleanup: $isExpressShippingValue');

    // Add selected pickup address ID if express shipping is enabled
    if (isExpressShippingValue == true && state.selectedPickupAddressId != null) {
      request['selectedPickupAddressId'] = state.selectedPickupAddressId;
      print('DEBUG PICKUP: Added selectedPickupAddressId to request: ${state.selectedPickupAddressId}');
    }

    // Clean up empty/null fields, but keep boolean false values for isExpressShipping and COD
    request.removeWhere((key, value) {
      // Keep isExpressShipping even if false
      if (key == 'isExpressShipping') return false;
      // Keep COD even if false (it's a valid value)
      if (key == 'COD' && value == false) return false;
      // Keep CashDifference even if false
      if (key == 'CashDifference' && value == false) return false;
      // Keep deliverToWorkAddress even if false
      if (key == 'deliverToWorkAddress' && value == false) return false;
      // Remove empty strings, null values, and other false booleans
      return value == '' || value == null || (value is bool && value == false);
    });
    
    // Always include isExpressShipping regardless of its value
    request['isExpressShipping'] = isExpressShippingValue;
    print('DEBUG EXPRESS: isExpressShipping value after explicitly setting it: ${request['isExpressShipping']}');

    print('DEBUG EXPRESS: Final request map contains isExpressShipping key: ${request.containsKey('isExpressShipping')}');
    print('DEBUG EXPRESS: Final request isExpressShipping value: ${request['isExpressShipping']}');
    print('DEBUG PROVIDER: Final request: $request');

    return request;
  }
  
  // Update delivery type
  void updateDeliveryType(String deliveryType) {
    state = OrderModel(
      id: state.id,
      customerName: state.customerName,
      customerPhone: state.customerPhone, 
      customerAddress: state.customerAddress,
      deliveryType: deliveryType,
      productDescription: state.productDescription,
      newProductDescription: state.newProductDescription,
      numberOfItems: state.numberOfItems,
      numberOfNewItems: state.numberOfNewItems,
      numberOfReturnItems: state.numberOfReturnItems,
      cashOnDelivery: state.cashOnDelivery,
      cashOnDeliveryAmount: state.cashOnDeliveryAmount,
      hasCashDifference: state.hasCashDifference,
      cashDifferenceAmount: state.cashDifferenceAmount,
      allowPackageInspection: state.allowPackageInspection,
      specialInstructions: state.specialInstructions,
      referralNumber: state.referralNumber,
      amountToCollect: state.amountToCollect,
      createdAt: state.createdAt,
      status: state.status,
      originalOrderNumber: state.originalOrderNumber,
      originalOrderData: state.originalOrderData,
      returnType: state.returnType,
      numberOfItemsToReturn: state.numberOfItemsToReturn,
      returnReason: state.returnReason,
    );
  }
  
  // Update customer data
  void updateCustomerData(Map<String, dynamic> customerData) {
    state = OrderModel(
      id: state.id,
      customerName: customerData['name'],
      customerPhone: customerData['phoneNumber'],
      customerAddress: '${customerData['city']}, ${customerData['addressDetails']}',
      deliveryType: state.deliveryType,
      productDescription: state.productDescription,
      newProductDescription: state.newProductDescription,
      numberOfItems: state.numberOfItems,
      numberOfNewItems: state.numberOfNewItems,
      numberOfReturnItems: state.numberOfReturnItems,
      cashOnDelivery: state.cashOnDelivery,
      cashOnDeliveryAmount: state.cashOnDeliveryAmount,
      hasCashDifference: state.hasCashDifference,
      cashDifferenceAmount: state.cashDifferenceAmount,
      allowPackageInspection: state.allowPackageInspection,
      specialInstructions: state.specialInstructions,
      referralNumber: state.referralNumber,
      amountToCollect: state.amountToCollect,
      createdAt: state.createdAt,
      status: state.status,
      originalOrderNumber: state.originalOrderNumber,
      originalOrderData: state.originalOrderData,
      returnType: state.returnType,
      numberOfItemsToReturn: state.numberOfItemsToReturn,
      returnReason: state.returnReason,
    );
  }
  
  // Update delivery details
  void updateDeliveryDetails({
    String? productDescription,
    int? numberOfItems,
    bool? cashOnDelivery,
    String? cashOnDeliveryAmount,
    bool? expressShipping,
  }) {
    state = OrderModel(
      id: state.id,
      customerName: state.customerName,
      customerPhone: state.customerPhone,
      customerAddress: state.customerAddress,
      deliveryType: state.deliveryType,
      productDescription: productDescription ?? state.productDescription,
      newProductDescription: state.newProductDescription,
      numberOfItems: numberOfItems ?? state.numberOfItems,
      numberOfNewItems: state.numberOfNewItems,
      numberOfReturnItems: state.numberOfReturnItems,
      cashOnDelivery: cashOnDelivery ?? state.cashOnDelivery,
      cashOnDeliveryAmount: cashOnDeliveryAmount ?? state.cashOnDeliveryAmount,
      hasCashDifference: state.hasCashDifference,
      cashDifferenceAmount: state.cashDifferenceAmount,
      allowPackageInspection: state.allowPackageInspection,
      specialInstructions: state.specialInstructions,
      referralNumber: state.referralNumber,
      amountToCollect: state.amountToCollect,
      createdAt: state.createdAt,
      status: state.status,
      expressShipping: expressShipping ?? state.expressShipping,
      originalOrderNumber: state.originalOrderNumber,
      originalOrderData: state.originalOrderData,
      returnType: state.returnType,
      numberOfItemsToReturn: state.numberOfItemsToReturn,
      returnReason: state.returnReason,
    );
  }
    // Update exchange details
  void updateExchangeDetails({
    String? currentProductDescription,
    String? newProductDescription,
    int? numberOfCurrentItems,
    int? numberOfNewItems,
    bool? hasCashDifference,
    String? cashDifferenceAmount,
    bool? expressShipping,
  }) {
    state = OrderModel(
      id: state.id,
      customerName: state.customerName,
      customerPhone: state.customerPhone,
      customerAddress: state.customerAddress,
      deliveryType: state.deliveryType,
      productDescription: currentProductDescription ?? state.productDescription,
      newProductDescription: newProductDescription ?? state.newProductDescription,
      numberOfItems: numberOfCurrentItems ?? state.numberOfItems,
      numberOfNewItems: numberOfNewItems ?? state.numberOfNewItems,
      numberOfReturnItems: state.numberOfReturnItems,
      cashOnDelivery: state.cashOnDelivery,
      cashOnDeliveryAmount: state.cashOnDeliveryAmount,
      hasCashDifference: hasCashDifference ?? state.hasCashDifference,
      cashDifferenceAmount: cashDifferenceAmount ?? state.cashDifferenceAmount,
      allowPackageInspection: state.allowPackageInspection,
      specialInstructions: state.specialInstructions,
      referralNumber: state.referralNumber,
      amountToCollect: state.amountToCollect,
      createdAt: state.createdAt,
      status: state.status,
      expressShipping: expressShipping ?? state.expressShipping,
      originalOrderNumber: state.originalOrderNumber,
      originalOrderData: state.originalOrderData,
      returnType: state.returnType,
      numberOfItemsToReturn: state.numberOfItemsToReturn,
      returnReason: state.returnReason,
    );
  }
    // Update return details
  void updateReturnDetails({
    String? returnProductDescription,
    String? productDescription,
    int? numberOfReturnItems,
    bool? expressShipping,
    String? originalOrderNumber,
    Map<String, dynamic>? originalOrderData,
    String? returnType,
    int? numberOfItemsToReturn,
    String? returnReason,
  }) {
    state = OrderModel(
      id: state.id,
      customerName: state.customerName,
      customerPhone: state.customerPhone,
      customerAddress: state.customerAddress,
      deliveryType: state.deliveryType,
      productDescription: productDescription ?? returnProductDescription ?? state.productDescription,
      newProductDescription: state.newProductDescription,
      numberOfItems: numberOfReturnItems ?? state.numberOfItems,
      numberOfNewItems: state.numberOfNewItems,
      numberOfReturnItems: numberOfReturnItems ?? state.numberOfReturnItems,
      cashOnDelivery: state.cashOnDelivery,
      cashOnDeliveryAmount: state.cashOnDeliveryAmount,
      hasCashDifference: state.hasCashDifference,
      cashDifferenceAmount: state.cashDifferenceAmount,
      allowPackageInspection: state.allowPackageInspection,
      specialInstructions: state.specialInstructions,
      referralNumber: state.referralNumber,
      amountToCollect: state.amountToCollect,
      createdAt: state.createdAt,
      status: state.status,
      expressShipping: expressShipping ?? state.expressShipping,
      originalOrderNumber: originalOrderNumber ?? state.originalOrderNumber,
      originalOrderData: originalOrderData ?? state.originalOrderData,
      returnType: returnType ?? state.returnType,
      numberOfItemsToReturn: numberOfItemsToReturn ?? state.numberOfItemsToReturn,
      returnReason: returnReason ?? state.returnReason,
    );
  }
    // Update cash collection details
  void updateCashCollectionDetails(String amountToCollect, {bool? expressShipping}) {
    state = OrderModel(
      id: state.id,
      customerName: state.customerName,
      customerPhone: state.customerPhone,
      customerAddress: state.customerAddress,
      deliveryType: state.deliveryType,
      productDescription: state.productDescription,
      newProductDescription: state.newProductDescription,
      numberOfItems: state.numberOfItems,
      numberOfNewItems: state.numberOfNewItems,
      numberOfReturnItems: state.numberOfReturnItems,
      cashOnDelivery: state.cashOnDelivery,
      cashOnDeliveryAmount: state.cashOnDeliveryAmount,
      hasCashDifference: state.hasCashDifference,
      cashDifferenceAmount: state.cashDifferenceAmount,
      allowPackageInspection: state.allowPackageInspection,
      specialInstructions: state.specialInstructions,
      referralNumber: state.referralNumber,
      amountToCollect: amountToCollect,
      createdAt: state.createdAt,
      status: state.status,
      expressShipping: expressShipping ?? state.expressShipping,
      originalOrderNumber: state.originalOrderNumber,
      originalOrderData: state.originalOrderData,
      returnType: state.returnType,
      numberOfItemsToReturn: state.numberOfItemsToReturn,
      returnReason: state.returnReason,
      selectedPickupAddressId: state.selectedPickupAddressId,
    );
  }
  
  // Update pickup address for express shipping
  void updatePickupAddress(String? pickupAddressId) {
    state = OrderModel(
      id: state.id,
      customerName: state.customerName,
      customerPhone: state.customerPhone,
      customerAddress: state.customerAddress,
      deliveryType: state.deliveryType,
      productDescription: state.productDescription,
      newProductDescription: state.newProductDescription,
      numberOfItems: state.numberOfItems,
      numberOfNewItems: state.numberOfNewItems,
      numberOfReturnItems: state.numberOfReturnItems,
      cashOnDelivery: state.cashOnDelivery,
      cashOnDeliveryAmount: state.cashOnDeliveryAmount,
      hasCashDifference: state.hasCashDifference,
      cashDifferenceAmount: state.cashDifferenceAmount,
      allowPackageInspection: state.allowPackageInspection,
      specialInstructions: state.specialInstructions,
      referralNumber: state.referralNumber,
      amountToCollect: state.amountToCollect,
      createdAt: state.createdAt,
      status: state.status,
      expressShipping: state.expressShipping,
      originalOrderNumber: state.originalOrderNumber,
      originalOrderData: state.originalOrderData,
      returnType: state.returnType,
      numberOfItemsToReturn: state.numberOfItemsToReturn,
      returnReason: state.returnReason,
      selectedPickupAddressId: pickupAddressId,
    );
  }
    // Update additional options
  void updateAdditionalOptions({
    bool? allowPackageInspection,
    String? specialInstructions,
    String? referralNumber,
  }) {
    state = OrderModel(
      id: state.id,
      customerName: state.customerName,
      customerPhone: state.customerPhone,
      customerAddress: state.customerAddress,
      deliveryType: state.deliveryType,
      productDescription: state.productDescription,
      newProductDescription: state.newProductDescription,
      numberOfItems: state.numberOfItems,
      numberOfNewItems: state.numberOfNewItems,
      numberOfReturnItems: state.numberOfReturnItems,
      cashOnDelivery: state.cashOnDelivery,
      cashOnDeliveryAmount: state.cashOnDeliveryAmount,
      hasCashDifference: state.hasCashDifference,
      cashDifferenceAmount: state.cashDifferenceAmount,
      allowPackageInspection: allowPackageInspection ?? state.allowPackageInspection,
      specialInstructions: specialInstructions ?? state.specialInstructions,
      referralNumber: referralNumber ?? state.referralNumber,
      amountToCollect: state.amountToCollect,
      createdAt: state.createdAt,
      status: state.status,
      expressShipping: state.expressShipping,
      originalOrderNumber: state.originalOrderNumber,
      originalOrderData: state.originalOrderData,
      returnType: state.returnType,
      numberOfItemsToReturn: state.numberOfItemsToReturn,
      returnReason: state.returnReason,
      selectedPickupAddressId: state.selectedPickupAddressId,
    );
  }
  
  // Set an existing order for editing
  void setOrder(OrderModel order) {
    state = order;
  }
  
  // Reset order data
  void resetOrder() {
    state = OrderModel();
  }
}