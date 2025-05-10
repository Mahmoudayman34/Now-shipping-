import 'package:flutter/material.dart';
import 'package:tes1/features/business/orders/widgets/order_details/section_utilities.dart';

class ShippingSection extends StatelessWidget {
  final String deliveryType;

  const ShippingSection({
    Key? key,
    required this.deliveryType,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SectionContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'Shipping Information',
            icon: Icons.local_shipping_outlined,
          ),
          const SizedBox(height: 16),
          
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFE3F8FC),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(
                  deliveryType == 'Deliver' ? Icons.local_shipping_outlined :
                  deliveryType == 'Exchange' ? Icons.swap_horiz_outlined :
                  Icons.assignment_return_outlined,
                  color: Colors.blue,
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      deliveryType,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: Colors.blue,
                      ),
                    ),
                    Text(
                      deliveryType == 'Deliver' ? 'Deliver items to customer' :
                      deliveryType == 'Exchange' ? 'Exchange items with customer' :
                      'Return items from customer',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}