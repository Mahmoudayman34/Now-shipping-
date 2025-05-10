import 'package:flutter/material.dart';
import 'package:now_shipping/features/business/orders/providers/order_details_provider.dart';
import 'package:now_shipping/features/business/orders/widgets/order_details/section_utilities.dart';

class DeliveryDetailsSection extends StatelessWidget {
  final OrderDetailsModel orderDetails;

  const DeliveryDetailsSection({
    Key? key,
    required this.orderDetails,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SectionContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'Delivery Details',
            icon: Icons.inventory_2_outlined,
          ),
          const SizedBox(height: 16),
          
          // Package Type
          DetailRow(
            label: 'Package Type',
            value: orderDetails.packageType,
          ),
          
          const SizedBox(height: 12),
          
          // Number of Items
          DetailRow(
            label: 'Number of Items',
            value: '${orderDetails.numberOfItems}',
          ),
          
          const SizedBox(height: 12),
          
          // Package Description
          DetailRow(
            label: 'Package Description',
            value: orderDetails.packageDescription,
            maxLines: 3,
          ),
          
          const SizedBox(height: 12),
          
          // Cash on Delivery
          DetailRow(
            label: 'Cash on Delivery',
            value: '${orderDetails.collectCashAmount} EGP',
            isHighlighted: true,
          ),
          
          const SizedBox(height: 12),
          
          // Allow Opening Package
          Row(
            children: [
              Icon(
                orderDetails.allowOpeningPackage
                    ? Icons.check_box_outlined
                    : Icons.check_box_outline_blank,
                color: const Color(0xFF26A2B9),
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Allow customer to inspect package',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF2F2F2F),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}