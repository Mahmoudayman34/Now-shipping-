import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    this.currentItems,
    this.currentProductDescription,
    this.newItems,
    this.newProductDescription,
    this.returnItems,
    this.returnReason,
    this.returnProductDescription,
  });

  // Create a mock order for testing or when real data is not available
  factory OrderDetailsModel.mock({required String orderId, required String status}) {
    return OrderDetailsModel(
      orderId: orderId,
      customerName: 'Mohamed Ahmed',
      customerPhone: '+201234567890',
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
    );
  }
}

/// Order details notifier that manages fetching and updating order details
class OrderDetailsNotifier extends StateNotifier<OrderDetailsModel?> {
  OrderDetailsNotifier() : super(null);

  // Fetch order details from API or local storage
  Future<void> fetchOrderDetails(String orderId, String status) async {
    // In a real app, you would make an API call here
    // For now, we'll use mock data
    state = OrderDetailsModel.mock(orderId: orderId, status: status);
  }

  // Update order details after scanning a smart sticker
  void updateWithStickerInfo(String stickerId) {
    // In a real app, you would update the order with the sticker information
    // For now, we'll just log it
    print('Order updated with sticker: $stickerId');
  }
}

/// Provider for the order details state notifier
final orderDetailsProvider = StateNotifierProvider.family<OrderDetailsNotifier, OrderDetailsModel?, String>(
  (ref, orderId) => OrderDetailsNotifier(),
);

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