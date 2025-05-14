import 'package:flutter/material.dart';
import 'package:now_shipping/features/business/orders/screens/create_order/create_order_screen.dart';
import 'package:now_shipping/features/business/orders/screens/order_details_screen_refactored.dart';
import 'package:now_shipping/features/business/orders/widgets/order_details/action_item.dart';

/// Shows a bottom sheet with actions for an order
void showOrderActionsBottomSheet(BuildContext context, Map<String, dynamic> order) {
  showModalBottomSheet(
    backgroundColor: Colors.white,
    context: context,
    isScrollControlled: true,
    constraints: BoxConstraints(
      maxHeight: MediaQuery.of(context).size.height * 0.7,
    ),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (BuildContext context) {
      return OrderActionsBottomSheet(order: order);
    },
  );
}

class OrderActionsBottomSheet extends StatelessWidget {
  final Map<String, dynamic> order;

  const OrderActionsBottomSheet({
    Key? key,
    required this.order,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Row(
              children: [
                const SizedBox(width: 48),
                const Expanded(
                  child: Center(
                    child: Text(
                      'Pickup Actions',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xff2F2F2F),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          ActionItem(
            icon: Icons.description_outlined,
            title: 'View Details',
            onTap: () {
              Navigator.pop(context);
              _handleViewDetails(context, order);
            },
          ),
          ActionItem(
            icon: Icons.qr_code_scanner_outlined,
            title: 'Scan Smart Sticker',
            onTap: () {
              Navigator.pop(context);
              // Handle scan sticker
            },
          ),
          ActionItem(
            icon: Icons.print_outlined,
            title: 'Print Airwaybill',
            onTap: () {
              Navigator.pop(context);
              // Handle print
            },
          ),
          ActionItem(
            icon: Icons.edit_outlined,
            title: 'Edit order',
            onTap: () {
              Navigator.pop(context);
              _handleEditOrder(context, order);
            },
          ),
          ActionItem(
            icon: Icons.location_searching_outlined,
            title: 'Track Order',
            onTap: () {
              Navigator.pop(context);
              _handleTrackOrder(context, order);
            },
          ),
          ActionItem(
            icon: Icons.delete_outline,
            title: 'Delete order',
            titleColor: Colors.red,
            backgroundColor: const Color(0xFFFEE8E8),
            onTap: () {
              Navigator.pop(context);
              // Handle delete order
            },
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // Method to handle track order action
  void _handleTrackOrder(BuildContext context, Map<String, dynamic> order) {
    // Navigate to the OrderDetailsScreen with the tracking tab selected
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OrderDetailsScreenRefactored(
          orderId: order['orderId'],
          status: order['status'],
          initialTabIndex: 0, // 0 is the index for tracking tab
        ),
      ),
    );
  }

  // Method to handle view order details action
  void _handleViewDetails(BuildContext context, Map<String, dynamic> order) {
    // Navigate to the OrderDetailsScreen with the details tab selected
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OrderDetailsScreenRefactored(
          orderId: order['orderId'],
          status: order['status'],
          initialTabIndex: 1, // 1 is the index for details tab
        ),
      ),
    );
  }

  // Method to handle edit order action
  void _handleEditOrder(BuildContext context, Map<String, dynamic> order) {
    // Get the current order data - using the available data and adding mock data where needed
    Map<String, dynamic> orderData = {
      'orderId': order['orderId'],
      'customerName': order['customerName'],
      'customerPhone': '+201234567890', // Using a placeholder
      'customerAddress': order['location'],
      'deliveryType': 'Deliver', // Default to Deliver
      'packageType': 'Parcel',
      'numberOfItems': 1,
      'packageDescription': 'Product description',
      'collectCashAmount': double.tryParse(order['amount'].toString().replaceAll(' EGP', '')) ?? 0.0,
      'allowOpeningPackage': false,
      'deliveryNotes': '',
      'orderReference': '',
      'status': order['status'],
      'createdAt': DateTime.now().toString().substring(0, 10),
    };

    // Prepare customer data in the format expected by CreateOrderScreen
    Map<String, dynamic> customerData = {
      'name': orderData['customerName'],
      'phoneNumber': orderData['customerPhone'],
      'addressDetails': orderData['customerAddress'],
      'city': orderData['customerAddress'].toString().split(',')[0], // Extracting the city part
      'building': '', // These would be populated from your order data in a real app
      'floor': '',
      'apartment': '',
    };

    // Navigate to CreateOrderScreen in edit mode with the order data
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateOrderScreen(
          isEditing: true,
          initialOrderId: order['orderId'],
          initialCustomerData: customerData,
          initialDeliveryType: orderData['deliveryType'],
          initialProductDescription: orderData['packageDescription'],
          initialNumberOfItems: orderData['numberOfItems'],
          initialAllowPackageInspection: orderData['allowOpeningPackage'],
          initialSpecialInstructions: orderData['deliveryNotes'],
          initialReferralNumber: orderData['orderReference'],
        ),
      ),
    );
  }
}