import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:now_shipping/features/business/orders/providers/order_details_provider.dart';
import 'package:now_shipping/features/business/orders/widgets/order_details/customer_section.dart';
import 'package:now_shipping/features/business/orders/widgets/order_details/shipping_section.dart';
import 'package:now_shipping/features/business/orders/widgets/order_details/delivery_details_section.dart';
import 'package:now_shipping/features/business/orders/widgets/order_details/exchange_details_section.dart';
import 'package:now_shipping/features/business/orders/widgets/order_details/return_details_section.dart';
import 'package:now_shipping/features/business/orders/widgets/order_details/additional_details_section.dart';
import 'package:now_shipping/features/business/orders/widgets/order_details/scan_sticker_button.dart';

/// The details tab showing customer and order information
class DetailsTab extends ConsumerWidget {
  final String orderId;
  final VoidCallback onScanSticker;

  const DetailsTab({
    Key? key,
    required this.orderId,
    required this.onScanSticker,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get order details from the provider
    final orderDetails = ref.watch(orderDetailsProvider(orderId));
    
    if (orderDetails == null) {
      return const Center(child: CircularProgressIndicator());
    }
    
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      children: [
        // Scan Smart Sticker button at the top
        ScanStickerButton(onTap: onScanSticker),
        const SizedBox(height: 16),
        
        // Customer section
        CustomerSection(orderDetails: orderDetails),
        const SizedBox(height: 16),
        
        // Shipping section
        ShippingSection(deliveryType: orderDetails.deliveryType),
        const SizedBox(height: 16),
        
        // Show different package details section based on delivery type
        if (orderDetails.deliveryType == 'Deliver')
          DeliveryDetailsSection(orderDetails: orderDetails)
        else if (orderDetails.deliveryType == 'Exchange')
          ExchangeDetailsSection(orderDetails: orderDetails)
        else if (orderDetails.deliveryType == 'Return')
          ReturnDetailsSection(orderDetails: orderDetails),
        
        const SizedBox(height: 16),
        
        // Additional details section
        AdditionalDetailsSection(orderDetails: orderDetails),
      ],
    );
  }
}