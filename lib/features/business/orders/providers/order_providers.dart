import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tes1/features/business/orders/models/order_model.dart';

// Provider for customer data
final customerDataProvider = StateProvider<Map<String, dynamic>?>((ref) => null);

// Provider for the order being created or edited
final orderModelProvider = StateNotifierProvider<OrderNotifier, OrderModel>((ref) {
  return OrderNotifier();
});

// Order state notifier
class OrderNotifier extends StateNotifier<OrderModel> {
  OrderNotifier() : super(OrderModel());

  // Update delivery type
  void updateDeliveryType(String deliveryType) {
    state = OrderModel(
      id: state.id,
      customerName: state.customerName,
      customerPhone: state.customerPhone, 
      customerAddress: state.customerAddress,
      deliveryType: deliveryType,
      productDescription: state.productDescription,
      numberOfItems: state.numberOfItems,
      numberOfNewItems: state.numberOfNewItems,
      numberOfReturnItems: state.numberOfReturnItems,
      cashOnDelivery: state.cashOnDelivery,
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
      numberOfItems: state.numberOfItems,
      numberOfNewItems: state.numberOfNewItems,
      numberOfReturnItems: state.numberOfReturnItems,
      cashOnDelivery: state.cashOnDelivery,
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
  }) {
    state = OrderModel(
      id: state.id,
      customerName: state.customerName,
      customerPhone: state.customerPhone,
      customerAddress: state.customerAddress,
      deliveryType: state.deliveryType,
      productDescription: productDescription ?? state.productDescription,
      numberOfItems: numberOfItems ?? state.numberOfItems,
      numberOfNewItems: state.numberOfNewItems,
      numberOfReturnItems: state.numberOfReturnItems,
      cashOnDelivery: cashOnDelivery ?? state.cashOnDelivery,
      allowPackageInspection: state.allowPackageInspection,
      specialInstructions: state.specialInstructions,
      referralNumber: state.referralNumber,
      amountToCollect: state.amountToCollect,
      createdAt: state.createdAt,
      status: state.status,
    );
  }
  
  // Update exchange details
  void updateExchangeDetails({
    String? currentProductDescription,
    String? newProductDescription,
    int? numberOfCurrentItems,
    int? numberOfNewItems,
  }) {
    state = OrderModel(
      id: state.id,
      customerName: state.customerName,
      customerPhone: state.customerPhone,
      customerAddress: state.customerAddress,
      deliveryType: state.deliveryType,
      productDescription: currentProductDescription ?? state.productDescription,
      numberOfItems: numberOfCurrentItems ?? state.numberOfItems,
      numberOfNewItems: numberOfNewItems ?? state.numberOfNewItems,
      numberOfReturnItems: state.numberOfReturnItems,
      cashOnDelivery: state.cashOnDelivery,
      allowPackageInspection: state.allowPackageInspection,
      specialInstructions: state.specialInstructions,
      referralNumber: state.referralNumber,
      amountToCollect: state.amountToCollect,
      createdAt: state.createdAt,
      status: state.status,
    );
  }
  
  // Update return details
  void updateReturnDetails({
    String? returnProductDescription,
    int? numberOfReturnItems,
  }) {
    state = OrderModel(
      id: state.id,
      customerName: state.customerName,
      customerPhone: state.customerPhone,
      customerAddress: state.customerAddress,
      deliveryType: state.deliveryType,
      productDescription: returnProductDescription ?? state.productDescription,
      numberOfItems: state.numberOfItems,
      numberOfNewItems: state.numberOfNewItems,
      numberOfReturnItems: numberOfReturnItems ?? state.numberOfReturnItems,
      cashOnDelivery: state.cashOnDelivery,
      allowPackageInspection: state.allowPackageInspection,
      specialInstructions: state.specialInstructions,
      referralNumber: state.referralNumber,
      amountToCollect: state.amountToCollect,
      createdAt: state.createdAt,
      status: state.status,
    );
  }
  
  // Update cash collection details
  void updateCashCollectionDetails(String amountToCollect) {
    state = OrderModel(
      id: state.id,
      customerName: state.customerName,
      customerPhone: state.customerPhone,
      customerAddress: state.customerAddress,
      deliveryType: state.deliveryType,
      productDescription: state.productDescription,
      numberOfItems: state.numberOfItems,
      numberOfNewItems: state.numberOfNewItems,
      numberOfReturnItems: state.numberOfReturnItems,
      cashOnDelivery: state.cashOnDelivery,
      allowPackageInspection: state.allowPackageInspection,
      specialInstructions: state.specialInstructions,
      referralNumber: state.referralNumber,
      amountToCollect: amountToCollect,
      createdAt: state.createdAt,
      status: state.status,
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
      numberOfItems: state.numberOfItems,
      numberOfNewItems: state.numberOfNewItems,
      numberOfReturnItems: state.numberOfReturnItems,
      cashOnDelivery: state.cashOnDelivery,
      allowPackageInspection: allowPackageInspection ?? state.allowPackageInspection,
      specialInstructions: specialInstructions ?? state.specialInstructions,
      referralNumber: referralNumber ?? state.referralNumber,
      amountToCollect: state.amountToCollect,
      createdAt: state.createdAt,
      status: state.status,
    );
  }
  
  // Set an existing order for editing
  void setOrder(OrderModel order) {
    state = order;
  }
}