import 'package:flutter/material.dart';
import 'package:now_shipping/features/business/orders/providers/order_details_provider.dart';
import 'package:now_shipping/features/business/orders/widgets/order_details/section_utilities.dart';

class CustomerSection extends StatelessWidget {
  final OrderDetailsModel orderDetails;

  const CustomerSection({
    Key? key,
    required this.orderDetails,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SectionContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'Customer', icon: Icons.person_outline),
          const SizedBox(height: 16),
          
          // Customer name
          Text(
            orderDetails.customerName,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2F2F2F),
            ),
          ),
          const SizedBox(height: 8),
          
          // Phone
          Row(
            children: [
              const Icon(Icons.phone, size: 16, color: Colors.grey),
              const SizedBox(width: 8),
              Text(
                orderDetails.customerPhone,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          
          // Address
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.location_on, size: 16, color: Colors.grey),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  orderDetails.customerAddress,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}