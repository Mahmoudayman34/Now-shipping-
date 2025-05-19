import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:now_shipping/features/business/orders/models/order_model.dart';
import 'package:now_shipping/features/business/orders/providers/orders_provider.dart';

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
  Map<String, dynamic> toApiRequest() {
    print('DEBUG EXPRESS: Original expressShipping value from state: ${state.expressShipping}');
    
    final Map<String, dynamic> request = {
      'fullName': state.customerName ?? '',
      'phoneNumber': state.customerPhone ?? '',
      'address': state.customerAddress ?? '',
      'government': state.customerAddress?.split(',').first.trim() ?? 'Cairo',
      'zone': state.customerAddress?.split(',').last.trim() ?? '',
      'orderType': state.deliveryType ?? 'Deliver',
      'previewPermission': state.allowPackageInspection == true ? 'on' : 'off',
      'Notes': state.specialInstructions ?? '',
      'expressShipping': state.expressShipping ?? false,
    };

    print('DEBUG EXPRESS: expressShipping in initial request: ${request['expressShipping']}');

    // Add fields based on order type
    if (state.deliveryType == 'Deliver') {
      request['productDescription'] = state.productDescription ?? '';
      request['numberOfItems'] = state.numberOfItems ?? 1;
      request['COD'] = state.cashOnDelivery ?? false;
      request['amountCOD'] = state.cashOnDelivery == true ? 
                      int.tryParse(state.cashOnDeliveryAmount ?? '0') ?? 0 : 0;
    } 
    else if (state.deliveryType == 'Exchange') {
      request['currentPD'] = state.productDescription ?? '';
      request['numberOfItemsCurrentPD'] = state.numberOfItems ?? 1;
      request['newPD'] = state.newProductDescription ?? '';
      request['numberOfItemsNewPD'] = state.numberOfNewItems ?? 1;
      request['CashDifference'] = state.hasCashDifference ?? false;
      request['amountCashDifference'] = state.hasCashDifference == true ? 
                                  int.tryParse(state.cashDifferenceAmount ?? '0') ?? 0 : 0;
    }
    else if (state.deliveryType == 'Cash Collection') {
      // Use 'Cash Collection' as the order type name (matches the API sample)
      request['orderType'] = 'Cash Collection';
      // Ensure amount is correctly parsed as an integer
      final amount = int.tryParse(state.amountToCollect ?? '0') ?? 0;
      request['amountCashCollection'] = amount;
      
      // Remove any unneeded fields that might be causing issues
      if (request.containsKey('productDescription')) request.remove('productDescription');
      if (request.containsKey('numberOfItems')) request.remove('numberOfItems');
    }
    else if (state.deliveryType == 'Cash Collect') {
      // Use 'Cash Collection' as the order type name (matches the API sample)
      request['orderType'] = 'Cash Collection';
      // Ensure amount is correctly parsed as an integer
      final amount = int.tryParse(state.amountToCollect ?? '0') ?? 0;
      request['amountCashCollection'] = amount;
      
      // Remove any unneeded fields that might be causing issues
      if (request.containsKey('productDescription')) request.remove('productDescription');
      if (request.containsKey('numberOfItems')) request.remove('numberOfItems');
      
      // Log the final request to help debugging
      print('DEBUG PROVIDER: Final Cash Collection request: $request');
    }
    else if (state.deliveryType == 'Return') {
      // Format Return order according to requirements
      request['productDescription'] = state.productDescription ?? '';
      request['numberOfItems'] = state.numberOfItems ?? 1;  // Use standard numberOfItems field to match API schema
      
      // Log the Return order request for debugging
      print('DEBUG PROVIDER: Final Return order request: $request');
    }

    // Add referral number if available
    if (state.referralNumber != null && state.referralNumber!.isNotEmpty) {
      request['referralNumber'] = state.referralNumber;
    }

    // Save expressShipping value before removing false booleans
    final bool expressShippingValue = request['expressShipping'] ?? false;
    print('DEBUG EXPRESS: expressShipping value before removeWhere: $expressShippingValue');

    // Make sure we're not sending empty fields that the API doesn't expect
    request.removeWhere((key, value) => value == '' || value == null || (value is bool && value == false));
    
    // Always include expressShipping regardless of its value
    request['expressShipping'] = expressShippingValue;
    print('DEBUG EXPRESS: expressShipping value after explicitly setting it: ${request['expressShipping']}');

    print('DEBUG EXPRESS: Final request map contains expressShipping key: ${request.containsKey('expressShipping')}');
    print('DEBUG EXPRESS: Final request expressShipping value: ${request['expressShipping']}');

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
    );
  }
    // Update return details
  void updateReturnDetails({
    String? returnProductDescription,
    int? numberOfReturnItems,
    bool? expressShipping,
  }) {
    state = OrderModel(
      id: state.id,
      customerName: state.customerName,
      customerPhone: state.customerPhone,
      customerAddress: state.customerAddress,
      deliveryType: state.deliveryType,
      productDescription: returnProductDescription ?? state.productDescription,
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